unit exweb_import;

interface

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls, Forms, Dialogs,
  exweb_type,UExWebType, DB, DBClient;

type
    TExweb_import = class(TObject)
    private
        dll: THandle;
        hGetParam: TProcGetParam;
        hQuery: TProcQuery;
        hRecv: TProcRecv;
        hSend: TProcSend;
        hSetParam: TProcSetParam;
        function getConnected: Boolean;
    public
        constructor Create(const aDllFileName: string = '');
        destructor Destroy; override;
        //1 Загрузка библиотеки
        function Connect(const aDllFileName: string): Boolean;
        procedure Disconnect;
        //1 Получить параметры exweb
        function getParam(name:string): string;
        //1 Выполнить запрос к базе.
        {:
        sql - запрос ( не только select )
        base - алиас базы к которой выполняется запрос
        outDS - ClientDataSet - с результатом запроса ( или nil)
        coding - кодировка результат
        }
        function query(const sql, base: string; outDS: TClientDataSet; const
            coding: string = ''): Boolean;
        {:
        Прием данных с сервера.
        }
        function recv(var str:string;data:TStream;prevState:TExWebState):
            TExWebState;
        {:
        Отправка данных на сервер.
        data можно указать nil.
        !!! Возвращаемый результат TExWebResult необходимо в том же виде
        передавать в следующий вызов send, не зависимо от того прошла 
        или нет передача
        }
        function send(const str: string; data: TStream; prevState:
            TExWebState): TExWebState;
        //1 Устанавливает параметр обмена
        {:
        Доступны следующие параметры
        SCRIPT or URL - адрес скрипта exweb
        KEY  - ключ авторизации ( на сервере прописан в ws_conf.php)
        PROXYPASSWORD 
        PROXYPORT
        PROXYSERVER
        PROXYUSERNAME
        MAXDATASETFIELDLEN - максимальная длина поля данных
        }
        procedure setParam(name:string;value:string);
        //1 Признак есть или нет подключение
        property Connected: Boolean read getConnected;
    end;

implementation

{
******************************** TExweb_import *********************************
}
constructor TExweb_import.Create(const aDllFileName: string = '');
begin
    inherited Create;
    dll:=0;
    if (aDllFileName<>'') then
        Connect(aDllFileName);
end;

destructor TExweb_import.Destroy;
begin
    Disconnect();
    inherited Destroy;
end;

function TExweb_import.Connect(const aDllFileName: string): Boolean;
var
    cStr:string;
begin
    if Connected then
        Disconnect;

    if (not FileExists(aDllFileName)) then begin
        result:=false;
        exit;
    end;


    try
        dll := LoadLibrary(PChar(aDllFileName));

        hSend:=GetProcAddress(dll,strProcSend);
        hRecv:=GetProcAddress(dll,strProcRecv);
        hQuery:=GetProcAddress(dll,strProcQuery);

        hSetParam:=GetProcAddress(dll,strProcSetParam);
        hGetParam:=GetProcAddress(dll,strProcGetParam);

        result:=true;

        if (Application<>nil) then begin
            cStr:=ExtractFileDir(Application.ExeName)+'\exweb_error.log';
            setParam('LOGFILENAME',cStr);
            setParam('ENABLELOG','1');
        end;
    except
        result:=false;
        Disconnect();
    end;
end;

procedure TExweb_import.Disconnect;
begin
    if (dll<>0) then begin
        FreeLibrary(dll);
        dll:=0;
    end;
end;

function TExweb_import.getConnected: Boolean;
begin
    result:= (dll<>0);
end;

function TExweb_import.getParam(name:string): string;
begin
    result:=hGetParam(name);
end;

function TExweb_import.query(const sql, base: string; outDS: TClientDataSet;
    const coding: string = ''): Boolean;
var
    cLen: Integer;
    cName: string;
    cNameIndex: Integer;
    data: TStringList;
    i: Integer;
    len: Integer;
    cNames: TStringList;
begin

    if outDS<>nil then begin
        data:=TstringList.Create();
        cNames:=TStringList.Create;
    end else
        data:=nil;

    try
    try
        result:=hQuery(sql, base,data,coding);
        if (not result) then
            raise Exception.Create('query result=false');
        if data = nil then
            exit;

        outDS.Active:=false;
        outDS.FieldDefs.Clear;
        outDS.Fields.Clear;

        len:=StrToInt(data.Strings[0]);
        for i:=0 to len-1 do begin
            cLen:=StrToInt(data[1+i*2]);
            cName:=data[1+i*2+1];
            cNames.Add(cName);
            outDS.FieldDefs.Add(cName,ftString,cLen);
        end;

        outDS.CreateDataSet;

        cNameIndex:=0;
        for i:=1+len*2 to data.Count-1 do begin
            if (cNameIndex = 0) then
                outDS.Append;

            cName:=cNames[cNameIndex];
            outDS.FieldByName(cName).AsString:=data[i];

            cNameIndex:=cNameIndex+1;
            if cNameIndex>=len then begin
                outDS.Post;
                cNameIndex:=0;
            end
        end;

    except
    on e:Exception do
    begin
        result:=false;
    end;
    end;
    finally
        if (data<>nil) then begin
            cNames.Free;
            data.Free;
        end;
    end;
end;

function TExweb_import.recv(var str:string;data:TStream;prevState:TExWebState):
    TExWebState;
begin
    result:=hRecv(str,data,prevState);
end;

function TExweb_import.send(const str: string; data: TStream; prevState:
    TExWebState): TExWebState;
begin
    result:=hSend(str,data,prevState);
end;

procedure TExweb_import.setParam(name:string;value:string);
begin
    hSetParam(name,value);
end;



end.
