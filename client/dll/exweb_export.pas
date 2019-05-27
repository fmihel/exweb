unit exweb_export;


interface
uses SysUtils,Classes,UExWebType;
{-$define _log_}
function send(const str:string;data:TStream;prevState:TExWebState):TExWebState;exports send;
function recv(var str:string;data:TStream;prevState:TExWebState):TExWebState;exports recv;
procedure setParam(name:string;value:string);exports setParam;
function getParam(name:string):string;exports getParam;
//function query(const sql, base: string; outDS: TClientDataSet; const coding: string): Boolean;exports query;
function query(const sql, base: string; outDS: TStrings; const coding: string): Boolean;exports query;

implementation
uses {$ifdef _log_}ULog,{$endif}UExWeb;
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

function query(const sql, base: string; outDS: TStrings; const coding: string): Boolean;
const
    cFuncName = 'query';
begin
    {$ifdef _log_} ULog.Log('query',[],'',cFuncName);{$endif}
    result:=exweb.query(sql,base,outDS,coding);
end;

procedure setParam(name:string;value:string);
begin
    name:=Trim(UpperCase(name));
    if (name = 'SCRIPT') or (name='URL') then
        exweb.Script:=value;
    if (name = 'KEY') then
        exweb.Key:=value;

    if (name = 'PROXYPASSWORD') then
        exweb.Http.ProxyPassword:=value;
    if (name = 'PROXYPORT') then
        exweb.Http.ProxyPort:=StrToInt(value);
    if (name = 'PROXYSERVER') then
        exweb.Http.ProxyServer:=value;
    if (name = 'PROXYUSERNAME') then
        exweb.Http.ProxyUserName:=value;
    if (name = 'MAXDATASETFIELDLEN') then
        exweb.MaxDataSetFieldLen:=StrToInt(value);

end;

function getParam(name:string):string;
begin
    result:='';
    name:=Trim(UpperCase(name));
    if (name = 'SCRIPT') or (name='URL') then
        result := exweb.Script;
    if (name = 'KEY') then
        result:=exweb.Key;

    if (name = 'PROXYPASSWORD') then
        result:=exweb.Http.ProxyPassword;
    if (name = 'PROXYPORT') then
        result:=IntToStr(exweb.Http.ProxyPort);
    if (name = 'PROXYSERVER') then
        result:=exweb.Http.ProxyServer;
    if (name = 'PROXYUSERNAME') then
        result:=exweb.Http.ProxyUserName;

    if (name = 'MAXDATASETFIELDLEN') then
        result:=IntToStr(exweb.MaxDataSetFieldLen);

end;

initialization
    exweb:=TExWeb.Create('https://windeco.su/exweb/');
finalization
    exweb.Free;
end.
