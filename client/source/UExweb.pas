unit UExweb;

interface

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls, Forms, Dialogs,
  UUrl,UHash,UHttp,UExWebType, DB, DBClient;
{$define _log_}


type
    TExWebBlockInfo = record
    public
        blockSize: Integer;
        count: Integer;
        id: string;
        md5: string;
        size: Int64;
    end;

    TExWeb = class(TObject)
    private
        fApp: TApplication;
        fBlockLen: Integer;
        fBlockSize: Integer;
        fHttp: THttp;
        fKey: string;
        fMaxDataSetFieldLen: Integer;
        procedure addKey(Params: THash);
        procedure ExceptionOtvet(var res:TExWebResult;otvet: THash;
            event:string; msg: string='');
        function getEnableLog: Boolean;
        function getLogFileName: string;
        function getScript: string;
        function httpResultToExWebResult(aHttpResult: THttpResult):
            TExWebResult;
        procedure processMessages;
        function read(Params: THash; aData: TStream): TExWebResult;
        procedure setEnableLog(Value: Boolean);
        procedure setLogFileName(const Value: string);
        procedure setScript(const Value: string);
        function _recvBlock(data: TStream;id:string;count:integer):
            TExWebResult;
        function _send(str:string; id: string): TExWebResult; overload;
        function _send(data: TStream; id: string): TExWebResult; overload;
        function _sendBlock(info: TExWebBlockInfo; data: TStream): TExWebResult;
        property BlockLen: Integer read fBlockLen write fBlockLen;
        property BlockSize: Integer read fBlockSize write fBlockSize;
    public
        constructor Create(aScript: string);
        destructor Destroy; override;
        function get(NameValueParams: array of variant; Response: THash):
            TExWebResult; overload;
        function get(Params, Response: THash): TExWebResult; overload;
        function post(Params:array of variant; data: TStream; Response: THash):
            TExWebResult; overload;
        function post(Params: THash; data: TStream; Response: THash):
            TExWebResult; overload;
        {:
        Возвращает список outDS:TStringList. Список - упорядоченная структура и
        данные.
        1-я Строка - Кол-во полей (len)
        2-я Строка - Длина первого поля
        3-я Строка - Имя первого поля
        4-я Строка - Длина второго поля
        5-я Строка - Имя второго поля
        ... и так len*2 строк
        len*2+1 строка - значение 1-го поля в 1-й строке данных
        len*2+2 строка - значение 2-го поля в 1-й строке данных
        len*2+3 строка - значение 3-го поля в 1-й строке данных
        ...
        }
        function query(const sql, base: string; outDS: TStrings = nil; const
            coding: string = ''): Boolean; overload;
        {:
        К сожалению данная ф-ция выдвет Exception заверешении работы
        exweb_import. (при работе через dll). Переполнение идет если
        вызывается метод ClientDataSet.FieldDefs :)
        Поэтому саму ф-цию query заменяю, и часть логики переношу в
        exweb_import. см query(..)
        Оставляю как пример ошибки :(
        }
        function query1(const sql, base: string; outDS: TClientDataSet; const
            coding: string = ''): Boolean; overload;
        //1 чтение данных
        function recv(var str: string; data: TStream; prevState: TExWebState):
            TExWebState;
        //1 отправка сообщения
        function send(const str: string; data: TStream; prevState:
            TExWebState): TExWebState;
        property App: TApplication read fApp write fApp;
        property EnableLog: Boolean read getEnableLog write setEnableLog;
        property Http: THttp read fHttp write fHttp;
        //1 Ключ доступа к передачи
        property Key: string read fKey write fKey;
        property LogFileName: string read getLogFileName write setLogFileName;
        //1 Максимальная длина загружаемого поля (остаток обрезается) условие включается при значении >0
        property MaxDataSetFieldLen: Integer read fMaxDataSetFieldLen write
            fMaxDataSetFieldLen;
        property Script: string read getScript write setScript;
    end;

function TExWebStateToStr(aState:TExWebState):string;
implementation

uses
{$ifdef _log_}ULogMsg,  {$endif} umd5, UUtils;

function TExWebStateToStr(aState:TExWebState):string;
begin

    result:='result:';
    if (aState.result) then
        result:=result+'true'
    else
        result:=result+'false';

    result:=result+', ';

    result:=result+'id:'+aState.id+', ';
    result:=result+'webResult:'+TExWebResultStr[integer(aState.webResult)];

    result:='{'+result+'}';

end;
{
************************************ TExWeb ************************************
}
constructor TExWeb.Create(aScript: string);
begin
    inherited Create;

    fApp:=nil;
    if (Application<>nil) then begin
        fApp:=Application;
        //error_log('app NOT nil %s',[Application.ExeName]);

    end else
        error_log('app = nil');


    fHttp:=THttp.Create();
    Script:=aScript;
    BlockSize:=1024;
    BlockLen:=1024;
    fMaxDataSetFieldLen:=256;
    Key:='test';
end;

destructor TExWeb.Destroy;
begin
    fHttp.Free();
    inherited Destroy;
end;

procedure TExWeb.addKey(Params: THash);
begin
    Params['key']:=Key;
end;

procedure TExWeb.ExceptionOtvet(var res:TExWebResult;otvet: THash; event:string;
    msg: string='');
begin
    if res<>ewrOk then
        raise Exception.Create('event='+event);

    if (otvet.Int['res'] = 0) then begin
        res:=ewrRes0;
        raise Exception.Create('event='+event+', otvet='+otvet['msg']+' '+msg);
    end;

end;

function TExWeb.get(NameValueParams: array of variant; Response: THash):
    TExWebResult;
var
    cParams: THash;

    const
        cFuncName = 'get';

begin
    cParams:=Hash(NameValueParams);
    try
    try
        result:=get(cParams,Response);
    except
    on e:Exception do
    begin
        {$ifdef _log_}error_log(e,ClassName,cFuncName);{$endif}
    end;
    end;
    finally
        FreeHash(cParams);
    end;
end;

function TExWeb.get(Params, Response: THash): TExWebResult;
begin
    addKey(Params);
    result:=httpResultToExWebResult(http.get(Params,Response));
    processMessages();

end;

function TExWeb.getEnableLog: Boolean;
begin
    {$ifdef _log_}
    result:=LogMsg.EnableWriteToFile;
    {$else}
    result:=false;
    {$endif}
end;

function TExWeb.getLogFileName: string;
begin
    {$ifdef _log_}
    result:=LogMsg.LogFileName;
    {$else}
    result:='';
    {$endif}
end;

function TExWeb.getScript: string;
begin
    result:=fHttp.Script;
end;

function TExWeb.httpResultToExWebResult(aHttpResult: THttpResult): TExWebResult;
begin
    result:=ewrUnknownError;
    case aHttpResult of
        hrOk:               result:=ewrOk;
        hrError:            result:=ewrNoResponse;
        hrNoValidJSON:      result:=ewrNoValidJSON;
        hrErrorCreateHash:  result:=ewrErrorCreateHash;
    end;
end;

function TExWeb.post(Params:array of variant; data: TStream; Response: THash):
    TExWebResult;
var
    cParams: THash;

    const
        cFuncName = 'post';

begin
    result:=ewrUnknownError;
    cParams:=Hash(Params);

    try
    try
        addKey(cParams);
        result:=post(cParams,data,Response);
    except
    on e:Exception do
    begin
        {$ifdef _log_}error_log(e,ClassName,cFuncName);{$endif}
    end;
    end;
    finally
        cParams.Free;
    end;
end;

function TExWeb.post(Params: THash; data: TStream; Response: THash):
    TExWebResult;
begin
    addKey(Params);
    if (data<>nil) then
        result:=httpResultToExWebResult(http.write(Params,data,Response))
    else
        result:=httpResultToExWebResult(http.write(Params,Response));
    processMessages();
end;

procedure TExWeb.processMessages;
begin
    try
        if (fApp<>nil) then
            App.ProcessMessages();
    except
    on e:Exception do
        fApp:=nil;
    end;
end;

function TExWeb.query(const sql, base: string; outDS: TStrings = nil; const
    coding: string = ''): Boolean;
var
    cStoryEncode: Boolean;
    fields: THash;
    i: Integer;
    j: Integer;
    len: Integer;
    name: string;
    otvet: THash;
    res: TExWebResult;
    return: string;
    rows: THash;
    stype: string;
    value: string;
    cFieldDefs: string;

    const
                cFuncName = 'query';

begin
    otvet:=Hash();
    result:=false;
    try
    try
        if (outDS = nil) then return:='bool' else return:='table';

        cStoryEncode:=http.Encode;
        http.Encode:=true;
        res:=get(['event','query','sql',sql,'base',base,'return',return,'coding',coding],otvet);
        http.Encode:=cStoryEncode;
        if ((res = ewrOk) and (otvet['res']='1')) then begin

            if (return = 'table') then begin
                fields  :=otvet.Hash['data'].Hash['fields'];
                rows    :=otvet.Hash['data'].Hash['rows'];
                cFieldDefs:='';
                outDS.Add(IntToStr(fields.Count));
                for i:=0 to fields.Count - 1 do begin
                    stype   :=fields.Item[i].hash['type'];
                    len     :=fields.Item[i].hash.Int['length'];
                    name    :=fields.Item[i].hash['name'];

                    if (((MaxDataSetFieldLen>0) and (len>MaxDataSetFieldLen) )or (stype='blob')) then
                        len:=MaxDataSetFieldLen;
                    outDS.Add(IntToStr(len));
                    outDS.Add(name);

                end;

                for i:=0 to rows.Count-1 do begin
                    for j:=0 to fields.Count - 1 do begin
                        name    :=fields.Item[j].hash['name'];
                        value   :=rows.Item[i].hash[name];
                        outDS.Add(value);
                    end;
                end;
            end;

            result:=true;
        end;

    except
    on e:Exception do
    begin
    end;
    end;
    finally
        otvet.Free();
    end;
end;

function TExWeb.query1(const sql, base: string; outDS: TClientDataSet; const
    coding: string = ''): Boolean;
var
    cStoryEncode: Boolean;
    fields: THash;
    i: Integer;
    j: Integer;
    len: Integer;
    name: string;
    otvet: THash;
    res: TExWebResult;
    return: string;
    rows: THash;
    stype: string;
    value: string;

    const
                cFuncName = 'query';

begin
    otvet:=Hash();
    result:=false;
    try
    try
        if (outDS = nil) then return:='bool' else return:='table';

        cStoryEncode:=http.Encode;
        http.Encode:=true;
        res:=get(['event','query','sql',sql,'base',base,'return',return,'coding',coding],otvet);
        http.Encode:=cStoryEncode;
        if ((res = ewrOk) and (otvet['res']='1')) then begin

            if (return = 'table') then begin
                fields  :=otvet.Hash['data'].Hash['fields'];
                rows    :=otvet.Hash['data'].Hash['rows'];
                outDS.Active:=false;
                outDS.FieldDefs.Clear;
                outDS.Fields.Clear;
                for i:=0 to fields.Count - 1 do begin
                    stype   :=fields.Item[i].hash['type'];
                    len     :=fields.Item[i].hash.Int['length'];
                    name    :=fields.Item[i].hash['name'];

                    if (((MaxDataSetFieldLen>0) and (len>MaxDataSetFieldLen) )or (stype='blob')) then
                        len:=MaxDataSetFieldLen;
                    //outDS.FieldDefs.Add(name,ftString,len,true);

                    break;
                end;

                //outDS.CreateDataSet;

                for i:=0 to rows.Count-1 do begin
                    //outDS.Append;
                    for j:=0 to fields.Count - 1 do begin
                        name    :=fields.Item[j].hash['name'];
                        value:=rows.Item[i].hash[name];
                        //outDS.Fields.FieldByName(name).AsString:=value;

                    end;

                    //outDS.Post;
                end;
            end;

            result:=true;
        end;

    except
    on e:Exception do
    begin
    end;
    end;
    finally
        otvet.Free();
    end;
end;

function TExWeb.read(Params: THash; aData: TStream): TExWebResult;
begin
    addKey(Params);
    result:=httpResultToExWebResult(http.read(Params,aData));
end;

function TExWeb.recv(var str: string; data: TStream; prevState: TExWebState):
    TExWebState;
var
    cBlockLen: Integer;
    otvet: THash;
    cMD5: string;
    cMD5Recv: string;
    count: Integer;
    cResult: TExWebResult;
    id: string;
    size: Integer;

    const
        cFuncName = 'recv';

begin

    result:=prevState;
    result.result:=false;
    otvet:=Hash();
    try
    try

        if (prevState.webResult = ewrNeedConfirm) then begin
            // есть необходимость закрыть последнюю успешную предачу
            cResult:=get(['event','completed','id',prevState.id],otvet);

            if cResult<>ewrOk then begin
                result:=prevState;
                result.result:=false;
                raise Exception.Create('event=completed');
            end;

            if (otvet.Int['res'] = 0) then begin
                result:=prevState;
                result.result:=false;
                raise Exception.Create('event=completed, otvet='+otvet['msg']);
            end;
        end;

        // получаем id сообщения
        cResult:=get(['event','recv_get_id'],otvet);

        if cResult<>ewrOk then begin
            result:=prevState;
            result.result:=false;
            raise Exception.Create('event=recv_get_id');
        end;

        if (otvet.Int['res'] = 0) then begin
            result:=prevState;
            result.result:=false;
            raise Exception.Create('event=init_recv, otvet='+otvet['msg']);
        end;

        id          :=  otvet.Hash['data']['id'];
        if (id = '-1') then begin
            result:=prevState;
            result.result:=false;
            raise Exception.Create('no messages');
        end;

        cBlockLen    :=  otvet.Hash['data'].Int['str_len'];
        size         :=  otvet.Hash['data'].Int['size'];
        count        :=  otvet.Hash['data'].Int['count_blocks'];
        cMD5         :=  UpperCase(otvet.Hash['data']['md5']);

        if (cBlockLen>0) then begin
            cResult:=get(['event','recv_string','id',id],otvet);

            if cResult<>ewrOk then begin
                result:=prevState;
                result.result:=false;
                raise Exception.Create('event=recv_str');
            end;

            str:=otvet.Hash['data']['string'];

            str:=Utils.rusEnCod(str);
         end else
            str:='';

        //----------------------------------------------------------------------------------------
        if (size>0) then begin
            data.Size:=0;
            cResult:=_recvBlock(data,id,count);

            if cResult<>ewrOk then begin
                result:=prevState;
                result.result:=false;
                data.Size:=0;
                raise Exception.Create('_recvBlock<>ewrOk');
            end;

            cMD5Recv := UpperCase(MD5(data));
            if (cMD5<>cMD5Recv) then begin
                result:=prevState;
                result.result:=false;
                data.Size:=0;
                raise Exception.Create('hesh sum recv and sending is not equal');
            end;

        end;

        //----------------------------------------------------------------------------------------
        // подтверждение передачи
        // не зависимо от результата подтверждения, считаем общий результат успешным
        cResult:=get(['event','completed','id',id],otvet);
        if (cResult<>ewrOk) or (otvet.Int['res'] = 0) then
            cResult:=ewrNeedConfirm;

        if (cResult = ewrOk) or (cResult = ewrNeedConfirm) then begin
            result.result       :=  true;
            result.id           :=  id;
            result.webResult    :=  cResult;
        end;

    except
    on e:Exception do
    begin
        if (e.Message<>'no messages') then begin
            {$ifdef _log_}error_log(Format('state:%s',[TExWebStateToStr(prevState)]),e,ClassName,cFuncName);{$endif}
            {$ifdef _log_}error_log(Format('key:%s, script:%s',[self.Key,self.Script]),e,ClassName,cFuncName);{$endif}
        end;
    end;
    end;
    finally
        FreeHash(otvet);
    end;


end;

function TExWeb.send(const str: string; data: TStream; prevState: TExWebState):
    TExWebState;
var
    otvet: THash;
    cMD5: string;
    cResult: TExWebResult;
    id: string;
    csize: Int64;

    const
        cFuncName = 'send';

begin
    otvet:=Hash();

    result:=prevState;
    result.result:=false;

    try
    try

        if (data<>nil) and (data.size>0) then begin
            data.Position:=0;
            cMD5:=MD5(data);
        end;

        if (prevState.webResult = ewrNeedConfirm) then begin
            // есть необходимость закрыть последнюю успешную предачу
            cResult:=get(['event','ready','id',prevState.id],otvet);

            if cResult<>ewrOk then begin
                result:=prevState;
                result.result:=false;
                raise Exception.Create('event=ready,result='+TExWebResultStr[integer(cResult)]);
            end;

            if (otvet.Int['res'] = 0) then begin
                result:=prevState;
                result.result:=false;
                raise Exception.Create('event=ready, otvet='+otvet['msg']);
            end;
        end;

        // инициализируем передачу и получаем настрйки сервера
        cResult:=get(['event','init_send'],otvet);

        //if (1>0) then begin
        if cResult<>ewrOk then begin
            result:=prevState;
            result.result:=false;
            raise Exception.Create('event=init_send,result='+TExWebResultStr[integer(cResult)]);
        end;

        if (otvet.Int['res'] = 0) then begin
            result:=prevState;
            result.result:=false;
            raise Exception.Create('event=init_send,otvet='+otvet['msg']);
        end;


        id          :=  otvet.Hash['data']['id'];
        BlockSize   :=  otvet.Hash['data'].Int['block_size'];
        BlockLen    :=  otvet.Hash['data'].Int['block_len'];

        // отправка строки
        cResult:=_send(str,id);

        if cResult<>ewrOk then begin
            result:=prevState;
            result.result:=false;
            raise Exception.Create('_send(str)<>ewrOk,result='+TExWebResultStr[integer(cResult)]);
        end;


        //----------------------------------------------------------------------------------------
        // отправка бинарных данных
        if (data<>nil) and (data.size>0) then begin
            cResult:=_send(data,id);

            if cResult<>ewrOk then begin
                result:=prevState;
                result.result:=false;
                raise Exception.Create('_send(stream)<>ewrOk,result='+TExWebResultStr[integer(cResult)]);
            end;
        end;

        //----------------------------------------------------------------------------------------
        // подтверждение передачи
        // не зависимо от результата подтверждения, считаем общий результат успешным

        cResult:=get(['event','ready','id',id],otvet);


        if (cResult<>ewrOk) or (otvet.Int['res'] = 0) then
            cResult:=ewrNeedConfirm;


        if (cResult = ewrOk) or (cResult = ewrNeedConfirm) then begin
            result.result       :=  true;
            result.id           :=  id;
            result.webResult    :=  cResult;
        end;


    except
    on e:Exception do
    begin
        cSize:=0;
        if (data<>nil)then
            cSize:=data.Size;
        {$ifdef _log_}error_log(Format('str:%s',[str]),e,ClassName,cFuncName);{$endif}
        {$ifdef _log_}error_log(Format('data:%d',[cSize]),e,ClassName,cFuncName);{$endif}
        {$ifdef _log_}error_log(Format('state:%s',[TExWebStateToStr(prevState)]),e,ClassName,cFuncName);{$endif}
        {$ifdef _log_}error_log(Format('key:%s,script:%s',[self.Key,self.Script]),e,ClassName,cFuncName);{$endif}
    end;
    end;
    finally
        FreeHash(otvet);
    end;
end;

procedure TExWeb.setEnableLog(Value: Boolean);
begin
    {$ifdef _log_}LogMsg.EnableWriteToFile:=Value;{$endif}
end;

procedure TExWeb.setLogFileName(const Value: string);
begin
    {$ifdef _log_}
    LogMsg.LogFileName:=Value;
    {$endif}
end;

procedure TExWeb.setScript(const Value: string);
begin
    fHttp.Script:=Value;
end;

function TExWeb._recvBlock(data: TStream;id:string;count:integer): TExWebResult;
var
    otvet: THash;
    i: Integer;
    cParams: THash;
    cRead: TMemoryStream;

    const
        cFuncName = '_recvBlock';

begin
    result:=ewrUnknownError;
    otvet:=Hash();
    cParams:=Hash();
    cRead:=TMemoryStream.Create;
    try
    try

        //----------------------------------------------------------------------------------------
        data.Position:=0;

        for i:=0 to count-1 do begin
            cParams.clear;
            cParams.add(['event','recv_block','i',i,'id',id]);
            cRead.Clear;

            result:=read(cParams,cRead);
            if result<>ewrOk then
                raise Exception.Create('event=recv_block');

            data.CopyFrom(cRead,cRead.Size);

        end;


        data.Position:=0;
        result:=ewrOk;
    except
    on e:Exception do
    begin
        {$ifdef _log_}error_log(TExWebResultStr[integer(result)],e,ClassName,cFuncName);{$endif}
    end;
    end;
    finally
        cRead.Free;
        FreeHash(otvet);
        FreeHash(cParams);
    end;
end;

function TExWeb._send(str:string; id: string): TExWebResult;
var
    cBlockLen: Integer;
    cLen: Integer;
    otvet: THash;
    cStr: string;
    cBlock: string;

    const
        cFuncName = '_send(str..)';

begin
    result:=ewrUnknownError;
    otvet:=Hash();
    try
    try
        cStr:=str;

        cStr:=Utils.rusCod(cStr);

        cLen:=Length(cStr);
        cBlockLen:=BlockLen;

        while(Length(cStr)>0) do begin
            cBlock:=Utils.UrlEncode(copy(cStr,1,cBlockLen));
            cStr:=copy(cStr,cBlockLen+1);

            result:=post(['event','send_string','string',cBlock,'id',id],nil,otvet);
            ExceptionOtvet(result,otvet,'send_string');
        end;

        //------------------------------------------------------
        result:=get(['event','string_encode','id',id],otvet);
        ExceptionOtvet(result,otvet,'string_encode');
        //------------------------------------------------------

    except
    on e:Exception do
    begin
        {$ifdef _log_}error_log(TExWebResultStr[integer(result)],e,ClassName,cFuncName);{$endif}
    end;
    end;
    finally
        FreeHash(otvet);
    end;

end;

function TExWeb._send(data: TStream; id: string): TExWebResult;
var
    cCountF: Single;
    info: TExWebBlockInfo;
    otvet: THash;

    const
        cFuncName = '_send';

begin
    result:=ewrUnknownError;
    otvet:=Hash();

    try
    try

        //----------------------------------------------------------------------------------------
        data.Position:=0;

        info.size:=data.Size;
        info.blockSize:=BlockSize;
        info.md5:=UMd5.MD5(data);
        info.id :=  id;

        info.count:=info.size div info.blockSize;
        cCountF:=(info.size)/info.blockSize;
        if (cCountF <> info.count) then
            info.count:=info.count+1;

        //----------------------------------------------------------------------------------------
        // инициируем начало передачи
        result:=get(['event','init_send_block','size',info.size,'blockSize',info.blockSize,'count',info.count,'md5',info.md5,'id',info.id],otvet);
        ExceptionOtvet(result,otvet,'init_send_block');

        //----------------------------------------------------------------------------------------
        // отсылка полезной информации
        result:=_sendBlock(info,data);

        if result<>ewrOk then
            raise Exception.Create('_sendBlock return error');


        //----------------------------------------------------------------------------------------
        // сравнение хеш сумм
        result:=get(['event','hash_sum_compare','id',info.id],otvet);
        ExceptionOtvet(result,otvet,'hash_sum_compare');

        if (otvet.Hash['data'].Int['check'] = 0) then begin
            result:=ewrHashSumNotCompare;
            raise Exception.Create('event=hash_sum_compare,check = 0');
        end;

    except
    on e:Exception do
    begin
        {$ifdef _log_}error_log(TExWebResultStr[integer(result)],e,ClassName,cFuncName);{$endif}
    end;
    end;
    finally
        FreeHash(otvet);
    end;
end;

function TExWeb._sendBlock(info: TExWebBlockInfo; data: TStream): TExWebResult;
var
    otvet: THash;
    cCurrentSize: Int64;
    i: Integer;
    params: THash;
    block: TMemoryStream;
    httpResponse: THash;

    const
        cFuncName = '_sendBlock';

begin
    otvet:=Hash();
    params:=Hash();
    result:=ewrUnknownError;

    try
    try
        data.Position:=0;
        //----------------------------------------------------------------------------------------
        // поблочная передача данных
        params['event'] :=  'send_block';
        params['id']    :=  info.id;
        //----------------------------------------------------------------------------------------
        for i:=0 to info.count-1 do begin

            block:=TMemoryStream.Create;
            httpResponse:=Hash();
            params['i'] := intToStr(i);

            try
            try
                cCurrentSize:=info.blockSize;
                if (data.Position+cCurrentSize>data.Size) then
                    cCurrentSize:=data.Size - data.Position;

                params['size'] := intToStr(cCurrentSize);

                block.CopyFrom(data,cCurrentSize);
                params['md5']:=MD5(block);
                block.Position:=0;

                result:=post(params,block,httpResponse);
                ExceptionOtvet(result,httpResponse,'send_block');


            except
            on e:Exception do
            begin
                {$ifdef _log_}error_log('',e,ClassName,cFuncName);{$endif}
            end;
            end;
            finally
                FreeHash(httpResponse);
                block.Free;
            end;
            // ошибка при предаче блока - прерываем цикл
            if (result<>ewrOk) then
                break;
        end;//for

        //----------------------------------------------------------------------------------------
    except
    on e:Exception do
    begin
        {$ifdef _log_} error_log('ERROR: %s',[TExWebResultStr[integer(result)]],ClassName,cFuncName);{$endif}
    end;
    end;
    finally
        FreeHash(params);
        FreeHash(otvet);
    end;
end;







end.
