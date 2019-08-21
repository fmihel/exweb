unit exweb_import;

interface

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls, Forms, Dialogs,
  exweb_type,UExWebType, DB, DBClient;

type
    TExweb_import = class(TObject)
    private
        dll: THandle;
        fDllFileName: string;
        fParam: TStringList;
        fTimeStart: Double;
        hGetParam: TProcGetParam;
        hPrepare: TProcPrepare;
        hQuery: TProcQuery;
        hRecv: TProcRecv;
        hSend: TProcSend;
        hSetParam: TProcSetParam;
        function getConnected: Boolean;
        function getTimeSec: Double;
        procedure reConnectAuto;
    public
        constructor Create(const aDllFileName: string = '');
        destructor Destroy; override;
        //1 �������� ����������
        function Connect(const aDllFileName: string): Boolean;
        procedure Disconnect;
        //1 �������� ��������� exweb
        function getParam(name:string): string;
        //1 ��������� ������ � ����.
        {:
        sql - ������ ( �� ������ select )
        base - ����� ���� � ������� ����������� ������
        outDS - ClientDataSet - � ����������� ������� ( ��� nil)
        coding - ��������� ���������
        }
        function query(const sql, base: string; outDS: TClientDataSet; const
            coding: string = ''): Boolean;
        //1 ������ ��������������� ����������
        function reConnect: Boolean;
        {:
        ����� ������ � �������.
        }
        function recv(var str:string;data:TStream;prevState:TExWebState):
            TExWebState;
        {:
        �������� ������ �� ������.
        data ����� ������� nil.
        !!! ������������ ��������� TExWebResult ���������� � ��� �� ����
        ���������� � ��������� ����� send, �� �������� �� ���� ������
        ��� ��� ��������
        }
        function send(const str: string; data: TStream; prevState:
            TExWebState): TExWebState;
        //1 ������������� �������� ������
        {:
        �������� ��������� ���������
        SCRIPT or URL - ����� ������� exweb
        KEY  - ���� ����������� ( �� ������� �������� � ws_conf.php)
        PROXYPASSWORD
        PROXYPORT
        PROXYSERVER
        PROXYUSERNAME
        MAXDATASETFIELDLEN - ������������ ����� ���� ������
        }
        procedure setParam(name:string;value:string);
        //1 ������� ���� ��� ��� �����������
        property Connected: Boolean read getConnected;
    end;

implementation
var

  ptPrecInit:boolean = false;
  ptPrecRate:double;

{
******************************** TExweb_import *********************************
}
constructor TExweb_import.Create(const aDllFileName: string = '');
begin
    inherited Create;
    dll:=0;
    fParam:=TStringList.Create();
    if (aDllFileName<>'') then
        Connect(aDllFileName);
end;

destructor TExweb_import.Destroy;
begin
    Disconnect();
    fParam.Free();
    inherited Destroy;
end;

function TExweb_import.Connect(const aDllFileName: string): Boolean;
var
    cStr: string;
begin
    if Connected then
        Disconnect;

    if (not FileExists(aDllFileName)) then begin
        result:=false;
        exit;
    end;


    try
        fDllFileName:=aDllFileName;
        fTimeStart:=getTimeSec();

        dll := LoadLibrary(PChar(aDllFileName));

        hSend:=GetProcAddress(dll,strProcSend);
        hRecv:=GetProcAddress(dll,strProcRecv);
        hQuery:=GetProcAddress(dll,strProcQuery);

        hSetParam:=GetProcAddress(dll,strProcSetParam);
        hGetParam:=GetProcAddress(dll,strProcGetParam);

        hPrepare:=GetProcAddress(dll,strProcPrepare);

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

function TExweb_import.getTimeSec: Double;
var
    ET: TLargeInteger;
    l: LARGE_INTEGER;
begin
    if not ptPrecInit then
    begin
       ptPrecInit:=true;
       QueryPerformanceFrequency(ET);
       l:=LARGE_INTEGER(ET);
       ptPrecRate:=L.QuadPart;
    end;

    QueryPerformanceCounter(ET);
    l:=LARGE_INTEGER(ET);
    Result := (l.QuadPart)/ptPrecRate;
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
    reConnectAuto();

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

function TExweb_import.reConnect: Boolean;
var
    cName: string;
    cValue: string;
    i: Integer;
begin
    if (not Connected) then begin
        result:=false;
        exit;
    end;
    Disconnect();
    if (Connect(fDllFileName)) then begin
        // ������ ���������� ���������
        for i:=0 to fParam.Count - 1 do begin
            cName:=fParam.Names[i];
            cValue:=fParam.Values[cName];
            setParam(cName,cValue);
        end;
    end;
end;

procedure TExweb_import.reConnectAuto;
begin
    if (Connected) and  (getTimeSec()-fTimeStart>3600) then
        reConnect();
end;

function TExweb_import.recv(var str:string;data:TStream;prevState:TExWebState):
    TExWebState;
begin
    reConnectAuto();
    result:=hRecv(str,data,prevState);
end;

function TExweb_import.send(const str: string; data: TStream; prevState:
    TExWebState): TExWebState;
begin
    reConnectAuto();
    result:=hSend(str,data,prevState);
end;

procedure TExweb_import.setParam(name:string;value:string);
begin
    // ��������� ��������� ( ��� reConnect)
    fParam.Values[name]:=value;
    hSetParam(name,value);
end;



end.
