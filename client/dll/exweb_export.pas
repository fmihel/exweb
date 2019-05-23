unit exweb_export;


interface
uses SysUtils,Classes,UExWebType;

function send(const str:string;data:TStream;prevState:TExWebState):TExWebState;exports send;
function recv(var str:string;data:TStream;prevState:TExWebState):TExWebState;exports recv;
procedure setParam(name:string;value:string);exports setParam;
function getParam(name:string):string;exports getParam;

implementation
uses UExWeb;
var
    exweb:TExWeb;

function send(const str:string;data:TStream;prevState:TExWebState):TExWebState;
begin
    result:=exweb.send(str,data,prevState);
end;

function recv(var str:string;data:TStream;prevState:TExWebState):TExWebState;
begin
    result:=exweb.recv(str,data,prevState);
end;

procedure setParam(name:string;value:string);
begin
    if (name = 'script') or (name='url') then
        exweb.Script:=value;
end;

function getParam(name:string):string;
begin
    if (name = 'script') or (name='url') then
        result := exweb.Script;
end;

initialization
    exweb:=TExWeb.Create('http://windeco/exweb/server/');
finalization
    exweb.Free;
end.
