unit ULogMsg;

interface

uses
  SysUtils, Windows, Forms;

type
    TLogMsg = class(TObject)
    private
        fAppName: string;
        fEnableWriteToFile: Boolean;
        fLogFileName: string;
        fSizeFile: Int64;
        function GetFileSize(aFileName: string): Int64;
    public
        constructor Create;
        destructor Destroy; override;
        procedure write(const aText: string);
        property AppName: string read fAppName write fAppName;
        property EnableWriteToFile: Boolean read fEnableWriteToFile write
            fEnableWriteToFile;
        property LogFileName: string read fLogFileName write fLogFileName;
    end;

procedure error_log(e:Exception;const aClassName:string = '';const aFuncName:string='');overload;
procedure error_log(const aMsg:string ;const aClassName:string = '';const aFuncName:string='');overload;
procedure error_log(const aMsg:string;e:Exception ;const aClassName:string = '';const aFuncName:string='');overload;

var LogMsg:TLogMsg;

implementation

procedure error_log(const aMsg:string;e:Exception ;const aClassName:string = '';const aFuncName:string='');overload;
var
    cStr:string;
    cTime:string;
begin
    cTime:='['+DateToStr(Now())+' '+TimeToStr(Now())+'] ';
    cStr:='';
    if (aClassName<>'') then
        cStr:=cStr+aClassName+'.'+aFuncName+' ';
    if (e<>nil) then
        cStr:=cStr+e.ClassName+': '+e.Message;
    if (aMsg<>'') then
        LogMsg.write(cTime+cStr+': '+copy(aMsg,1,512)+' ')
    else
        LogMsg.write(cTime+cStr);
end;
procedure error_log(e:Exception;const aClassName:string = '';const aFuncName:string='');
begin
    error_log('',e,aClassName,aFuncName);
end;
procedure error_log(const aMsg:string ;const aClassName:string = '';const aFuncName:string='');
begin
    error_log(aMsg,nil,aClassName,aFuncName);
end;

{
*********************************** TLogMsg ************************************
}
constructor TLogMsg.Create;
begin
    inherited Create;
    if(Application<>nil) then begin
        fAppName:=ExtractFileName(Application.ExeName);
        fLogFileName:=ExtractFileDir(Application.ExeName)+'/error_log.txt';
        fEnableWriteToFile:=true;
    end;

    fSizeFile:=0;
end;

destructor TLogMsg.Destroy;
begin
    inherited Destroy;
end;

function TLogMsg.GetFileSize(aFileName: string): Int64;
var
    cSearchRec: _WIN32_FIND_DATAW;
    cFileName: PChar;
    hFind: THandle;
begin
    result:=0;
    try
        if FileExists(aFileName) then
        begin
            cFileName:=PChar(aFileName);
            hFind:=Windows.FindFirstFile(cFileName, cSearchRec);
            result := cSearchRec.nFileSizeHigh;
            result := result shl 32;
            result := result + cSearchRec.nFileSizeLow;
            Windows.FindClose(hFind);
        end;
    finally
    end;
end;

procedure TLogMsg.write(const aText: string);
var
    cStr: string;
    hFile: TextFile;
begin
    cStr:=aText;
    Windows.OutputDebugString(PWideChar(cStr));

    if (EnableWriteToFile) then begin

        AssignFile(hFile, LogFileName);

        if (not FileExists(LogFileName)) or (fSizeFile>1024*1024*10) then
            ReWrite(hFile)
        else
            Append(hFile);

        WriteLn(hFile,cStr);
        CloseFile(hFile);

        fSizeFile:=GetFileSize(LogFileName);

    end;
end;

initialization
LogMsg:=TLogMsg.Create();
finalization
LogMsg.Free();
end.
