unit UHttp;

interface

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls, Forms, Dialogs,
  IdBaseComponent, IdComponent, IdCustomTCPServer,
  IdCustomHTTPServer, IdHTTPServer, StdCtrls, ComCtrls, IdServerIOHandler,
  IdSSL, IdSSLOpenSSL, IdIOHandler, IdIOHandlerSocket, IdIOHandlerStack,
  IdTCPConnection, IdTCPClient, IdHTTP,UHash,IdMultipartFormData;

type
{
    hrError - ошибка пр загрузке (возможно нет коннекта)
    hrNoValidJSON - загруженный json не валдный
    hrErrorCreateHash - не удаетс€ создать hash по загруженному json

}
    THttpResult = (hrOk,hrError,hrNoValidJSON,hrErrorCreateHash);
    THttp = class(TObject)
    private
        fEncode: Boolean;
        fhttp: TidHTTP;
        fread_block_name: string;
        fScript: string;
        fUrl: THash;
        procedure setScript(const Value: string);
    public
        constructor Create;
        destructor Destroy; override;
        //1 ѕростой GET запрос
        function get(NameValueParams: array of variant; var Response: string):
            THttpResult; overload;
        //1 ѕростой GET запрос с последующим распарсиванием ответа (aResponse)
        function get(NameValueParams: array of variant; aResponse: THash):
            THttpResult; overload;
        //1 ѕростой GET запрос
        function get(aParams: THash; var aResponse: string): THttpResult;
            overload;
        //1 ѕростой GET запрос  с последующим распарсиванием ответа (aResponse)
        function get(aParams, aResponse: THash): THttpResult; overload;
        //1 „тение данных в поток
        function read(aParams:THash;aData:TStream): THttpResult;
        //1 «апись строки на сервер (POST)
        function write(aParams: THash; var aResponse: string): THttpResult;
            overload;
        function write(aParams, aResponse: THash): THttpResult; overload;
        function write(aParams: THash; data: TStream; var aResponse: string):
            THttpResult; overload;
        function write(aParams: THash; data: TStream; aResponse: THash):
            THttpResult; overload;
        function write(data: TStream; var aResponse: string): THttpResult;
            overload;
        property Encode: Boolean read fEncode write fEncode;
        property http: TidHTTP read fhttp write fhttp;
        property read_block_name: string read fread_block_name write
            fread_block_name;
        property Script: string read fScript write setScript;
        property Url: THash read fUrl write fUrl;
    end;


implementation

uses
  UUrl, UUtils;

{
************************************ THttp *************************************
}
constructor THttp.Create;
begin
    inherited Create;
    fEncode:=false;
    fHttp:=TIdHttp.Create(nil);
    fHttp.IOHandler:=TIdSSLIOHandlerSocketOpenSSL.Create(nil);
    fUrl:=Hash();
    Script:='http://windeco/exweb/server/';
    fread_block_name:='b';
end;

destructor THttp.Destroy;
var
    cSSL: TIdIOHandler;
begin
    FreeHash(fUrl);
    cSSL:=fHttp.IOHandler;
    fHttp.IOHandler:=nil;
    cSSL.Free;
    fHttp.Free;
    inherited Destroy;
end;

function THttp.get(NameValueParams: array of variant; var Response: string):
    THttpResult;
var
    cUrl: string;
begin
    result:=hrError;
    try
    try
        cUrl:=UUrl.Url.build(Url,NameValueParams,false,Encode);

        Response:=Http.Get(cUrl);
        result:=hrOk;
    except
    on e:Exception do begin

    end;
    end;
    finally
    end;
end;

function THttp.get(NameValueParams: array of variant; aResponse: THash):
    THttpResult;
var
    cHashParsingResult: THashJsonResult;
    cResponse: string;
begin
    result:=get(NameValueParams,cResponse);
    if (result = hrOk) then begin
        cHashParsingResult:=aResponse.fromJSON(cResponse);
        if (cHashParsingResult = hjprErrorParsing) then
            result:=hrNoValidJSON;
        if (cHashParsingResult = hjprErrorCreate) then
            result:=hrErrorCreateHash;
    end;
end;

function THttp.get(aParams: THash; var aResponse: string): THttpResult;
var
    cUrl: string;
begin
    result:=hrError;
    try
    try

        cUrl:=UUrl.Url.build(Url,aParams,false,Encode);


        aResponse:=Http.Get(cUrl);
        result:=hrOk;
    except
    on e:Exception do begin

    end;
    end;
    finally
    end;
end;

function THttp.get(aParams, aResponse: THash): THttpResult;
var
    cHashParsingResult: THashJsonResult;
    cResponse: string;
begin
    result:=get(aParams,cResponse);
    if (result = hrOk) then begin
        cHashParsingResult:=aResponse.fromJSON(cResponse);
        if (cHashParsingResult = hjprErrorParsing) then
            result:=hrNoValidJSON;
        if (cHashParsingResult = hjprErrorCreate) then
            result:=hrErrorCreateHash;
    end;
end;

function THttp.read(aParams:THash;aData:TStream): THttpResult;
var
    cChar: AnsiChar;
    cPostStream: TIdMultiPartFormDataStream;
    cPostStrings: TStringList;
    cResponse: AnsiString;
    cUrl: string;
    i: Integer;

    const
        cFuncName = 'read';

begin

    cPostStream:=TIdMultiPartFormDataStream.Create();
    cPostStrings:=TStringList.Create();
    result:=hrError;
    try
    try

        aData.Size:=0;
        if (aParams<>nil) then
            cUrl:=UUrl.Url.build(Url,aParams,false,Encode)
        else
            cUrl:=Script;

        http.Get(cUrl,aData);

        aData.Position:=0;
        result:=hrOK;
    except
    on e:Exception do
    begin
        {$ifdef _log_}ULog.Error('',e,ClassName,cFuncName);{$endif}
    end;
    end;
    finally
        cPostStrings.Free;
        cPostStream.Free;
    end;
end;

procedure THttp.setScript(const Value: string);
begin
    if (Value<>fScript) then
        UUrl.Url.parse(Value,fUrl,Encode);
    fScript := Value;
end;

function THttp.write(aParams: THash; var aResponse: string): THttpResult;
var
    cPostStream: TIdMultiPartFormDataStream;
    cUrl: string;
    data: TMemoryStream;
begin
    result:=hrError;

    cPostStream:=TIdMultiPartFormDataStream.Create();
    data:=TMemoryStream.Create;

    try
    try
        if (aParams<>nil) then
            cUrl:=UUrl.Url.build(Url,aParams,false,Encode)
        else
            cUrl:=Script;

        cPostStream.AddFormField('empty','','',data,'file100tmp_');
        aResponse:=http.Post(cUrl,cPostStream);

        result:=hrOk;
    except
    on e:Exception do
    begin
       {$ifdef _log_}ULog.Error(aResponse,e,ClassName,cFuncName);{$endif}
    end;
    end;
    finally
      data.Free;
      cPostStream.Free;
    end;
end;

function THttp.write(aParams, aResponse: THash): THttpResult;
var
    cHashParsingResult: THashJsonResult;
    cResponse: string;
begin
    result:=write(aParams,cResponse);

    if (result = hrOk) then begin
        cHashParsingResult:=aResponse.fromJSON(cResponse);
        if (cHashParsingResult = hjprErrorParsing) then
            result:=hrNoValidJSON;
        if (cHashParsingResult = hjprErrorCreate) then
            result:=hrErrorCreateHash;
    end;
end;

function THttp.write(aParams: THash; data: TStream; var aResponse: string):
    THttpResult;
var
    cPostStream: TIdMultiPartFormDataStream;
    idField: TIdFormDataField;
    cUrl: string;
begin
    result:=hrError;

    cPostStream:=TIdMultiPartFormDataStream.Create();
    try
    try
        data.Position:=0;
        if (aParams<>nil) then
            cUrl:=UUrl.Url.build(Url,aParams,false,Encode)
        else
            cUrl:=Script;

        idField:=cPostStream.AddFormField(read_block_name,'','',data,'file100tmp_');

        aResponse:=http.Post(cUrl,cPostStream);
        result:=hrOk;
    except
    on e:Exception do
    begin

    end;
    end;
    finally
        cPostStream.Free();
    end;
end;

function THttp.write(aParams: THash; data: TStream; aResponse: THash):
    THttpResult;
var
    cHashParsingResult: THashJsonResult;
    cResponse: string;
begin
    result:=write(aParams,data,cResponse);

    if (result = hrOk) then begin
        cHashParsingResult:=aResponse.fromJSON(cResponse);
        if (cHashParsingResult = hjprErrorParsing) then
            result:=hrNoValidJSON;
        if (cHashParsingResult = hjprErrorCreate) then
            result:=hrErrorCreateHash;
    end;
end;

function THttp.write(data: TStream; var aResponse: string): THttpResult;
begin
    result:=write(nil,data,aResponse);
end;



end.
