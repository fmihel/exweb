unit exweb_import;

interface

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls, Forms, Dialogs,
  exweb_type,UExWebType;

type
    TExweb_import = class(TObject)
    private
        dll: THandle;
        hGetParam: TProcGetParam;
        hRecv: TProcRecv;
        hSend: TProcSend;
        hSetParam: TProcSetParam;
        function getConnected: Boolean;
    public
        constructor Create;
        destructor Destroy; override;
        function Connect(const aDllFileName: string = ''): Boolean;
        procedure Disconnect;
        function getParam(name:string): string;
        function recv(var str:string;data:TStream;prevState:TExWebState):
            TExWebState;
        function send(const str:string;data:TStream;prevState:TExWebState):
            TExWebState;
        procedure setParam(name:string;value:string);
        property Connected: Boolean read getConnected;
    end;

implementation

{
******************************** TExweb_import *********************************
}
constructor TExweb_import.Create;
begin
    inherited Create;
    dll:=0;
end;

destructor TExweb_import.Destroy;
begin
    Disconnect();
    inherited Destroy;
end;

function TExweb_import.Connect(const aDllFileName: string = ''): Boolean;
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
        hSetParam:=GetProcAddress(dll,strProcSetParam);
        hGetParam:=GetProcAddress(dll,strProcGetParam);

        result:=true;
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

function TExweb_import.recv(var str:string;data:TStream;prevState:TExWebState):
    TExWebState;
begin
    result:=hRecv(str,data,prevState);
end;

function TExweb_import.send(const str:string;data:TStream;
    prevState:TExWebState): TExWebState;
begin
    result:=hSend(str,data,prevState);
end;

procedure TExweb_import.setParam(name:string;value:string);
begin
    hSetParam(name,value);
end;



end.
