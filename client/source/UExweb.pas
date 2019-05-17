unit UExweb;

interface

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls, Forms, Dialogs,
  UUrl,UHash,UHttp,UExWebType;
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
        fBlockLen: Integer;
        fBlockSize: Integer;
        fHttp: THttp;
        fKey: string;
        procedure addKey(Params: THash);
        procedure ExceptionOtvet(var res:TExWebResult;otvet: THash;
            event:string; msg: string='');
        function getScript: string;
        procedure setScript(const Value: string);
        function _send(str:string; id: string): TExWebResult; overload;
        function _send(data: TStream; id: string): TExWebResult; overload;
        function _sendBlock(info: TExWebBlockInfo; data: TStream): TExWebResult;
    public
        constructor Create(aScript: string);
        destructor Destroy; override;
        function get(NameValueParams: array of variant; Response: THash):
            TExWebResult; overload;
        function get(Params, Response: THash): TExWebResult; overload;
        function httpResultToExWebResult(aHttpResult: THttpResult):
            TExWebResult;
        function post(Params:array of variant; data: TStream; Response: THash):
            TExWebResult; overload;
        function post(Params: THash; data: TStream; Response: THash):
            TExWebResult; overload;
        //1 чтение данных
        function recv(var str: string; data: TStream; prevResult: TExWebState):
            TExWebState;
        function send(const str: string; data: TStream; prevState:
            TExWebState): TExWebState;
        //1 Размер блока, на которые будет разбита строка отсылки. (загружается с сервера)
        property BlockLen: Integer read fBlockLen write fBlockLen;
        //1 Размер блока, на которые будет разбит пакет отсылки. (загружается с сервера)
        property BlockSize: Integer read fBlockSize write fBlockSize;
        property Http: THttp read fHttp write fHttp;
        //1 Ключ доступа к передачи
        property Key: string read fKey write fKey;
        property Script: string read getScript write setScript;
    end;

function TExWebStateToStr(aState:TExWebState):string;
implementation

uses
{$ifdef _log_}ULog  {$endif}, umd5, UUtils;
function TExWebStateToStr(aState:TExWebState):string;
begin

    result:='result:';
    if (aState.result) then
        result:=result+'true'
    else
        result:=result+'false';

    result:=result+','+#13#10;

    result:=result+'id:'+aState.id+','+#13#10;
    result:=result+'webResult:'+TExWebResultStr[integer(aState.webResult)];

    result:='{'+#13#10+result+#13#10+'}';

end;
{
************************************ TExWeb ************************************
}
constructor TExWeb.Create(aScript: string);
begin
    inherited Create;
    fHttp:=THttp.Create();
    Script:=aScript;
    BlockSize:=1024;
    BlockLen:=1024;
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
        raise Exception.Create('event='+event+','+otvet['msg']+' '+msg);
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
        {$ifdef _log_}ULog.Error('',e,ClassName,cFuncName);{$endif}
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
        {$ifdef _log_}ULog.Error('',e,ClassName,cFuncName);{$endif}
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
end;

function TExWeb.recv(var str: string; data: TStream; prevResult: TExWebState):
    TExWebState;
begin
end;

function TExWeb.send(const str: string; data: TStream; prevState: TExWebState):
    TExWebState;
var
    otvet: THash;
    cMD5: string;
    cResult: TExWebResult;
    id: string;

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
            cResult:=get(['event','close','id',prevState.id],otvet);

            if cResult<>ewrOk then begin
                result:=prevState;
                result.result:=false;
                raise Exception.Create('event=close');
            end;

            if (otvet.Int['res'] = 0) then begin
                result:=prevState;
                result.result:=false;
                raise Exception.Create('event=close,'+otvet['msg']);
            end;
        end;

        // инициализируем передачу и получаем настрйки сервера
        cResult:=get(['event','init'],otvet);

        if cResult<>ewrOk then begin
            result:=prevState;
            result.result:=false;
            raise Exception.Create('event=init');
        end;

        if (otvet.Int['res'] = 0) then begin
            result:=prevState;
            result.result:=false;
            raise Exception.Create('event=init,'+otvet['msg']);
        end;

        id          :=  otvet.Hash['data']['id'];
        BlockSize   :=  otvet.Hash['data'].Int['block_size'];
        BlockLen    :=  otvet.Hash['data'].Int['block_len'];

        // отправка строки
        cResult:=_send(str,id);

        if cResult<>ewrOk then begin
            result:=prevState;
            result.result:=false;
            raise Exception.Create('_send(str)<>ewrOk');
        end;


        //----------------------------------------------------------------------------------------
        // отправка бинарных данных
        if (data<>nil) and (data.size>0) then begin
            cResult:=_send(data,id);

            if cResult<>ewrOk then begin
                result:=prevState;
                result.result:=false;
                raise Exception.Create('_send(stream)<>ewrOk');
            end;
        end;

        //----------------------------------------------------------------------------------------
        // подтверждение передачи
        // не зависимо от результата подтверждения, считаем общий результат успешным
        cResult:=get(['event','close','id',id],otvet);
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
        {$ifdef _log_}ULog.Error('',e,ClassName,cFuncName);{$endif}
    end;
    end;
    finally
        FreeHash(otvet);
    end;
end;

procedure TExWeb.setScript(const Value: string);
begin
    fHttp.Script:=Value;
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
        result:=get(['event','encode_string','id',id],otvet);
        ExceptionOtvet(result,otvet,'encode_string');
        //------------------------------------------------------

    except
    on e:Exception do
    begin
        {$ifdef _log_}ULog.Error(TExWebResultStr[integer(result)],e,ClassName,cFuncName);{$endif}
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
        result:=get(['event','open','size',info.size,'blockSize',info.blockSize,'count',info.count,'md5',info.md5,'id',info.id],otvet);
        ExceptionOtvet(result,otvet,'open');

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
            raise Exception.Create('event=hash_sum_copare,check = 0');
        end;

    except
    on e:Exception do
    begin
        {$ifdef _log_}ULog.Error(TExWebResultStr[integer(result)],e,ClassName,cFuncName);{$endif}
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
        params['event'] :=  'block';
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
                ExceptionOtvet(result,httpResponse,'block');


            except
            on e:Exception do
            begin
                {$ifdef _log_}ULog.Error('',e,ClassName,cFuncName);{$endif}
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
        {$ifdef _log_} ULog.Log('ERROR: %s',[TExWebResultStr[integer(result)]],ClassName,cFuncName);{$endif}
    end;
    end;
    finally
        FreeHash(params);
        FreeHash(otvet);
    end;
end;



end.
