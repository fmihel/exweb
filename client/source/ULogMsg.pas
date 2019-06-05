unit ULogMsg;

interface

uses
  SysUtils, Windows, Forms;

type
    TLogMsg = class(TObject)
    private
        fClearSize: Integer;
        fEnableWriteToFile: Boolean;
        fLogFileName: string;
        fMaxLenWrite: Integer;
        fSizeFile: Int64;
        function getFileSize(aFileName: string): Int64;
    public
        constructor Create;
        destructor Destroy; override;
        procedure write(const aText: string);
        //1 Максимальный размер лог файла, после он очищается
        property ClearSize: Integer read fClearSize write fClearSize;
        property EnableWriteToFile: Boolean read fEnableWriteToFile write
            fEnableWriteToFile;
        property LogFileName: string read fLogFileName write fLogFileName;
        property MaxLenWrite: Integer read fMaxLenWrite write fMaxLenWrite;
    end;

procedure error_log(e:Exception;const aClassName:string = '';const aFuncName:string='');overload;
procedure error_log(const aMsg:string ;const aClassName:string = '';const aFuncName:string='');overload;
procedure error_log(const aMsg:string;e:Exception ;const aClassName:string = '';const aFuncName:string='');overload;
procedure error_log(const aMsg:string;const aArgs: array of const;const aClassName:string = '';const aFuncName:string='');overload;

var LogMsg:TLogMsg;

implementation

procedure error_log(const aMsg:string;e:Exception ;const aClassName:string = '';const aFuncName:string='');overload;
var
    cClass  :string;
    cError  :string;
    cTime   :string;
begin
    cTime:='['+DateToStr(Now())+' '+TimeToStr(Now())+']';
    cClass:='';
    if (aClassName<>'') then
        cClass:=cClass+aClassName+'.';
    if (aFuncName<>'') then
        cClass:=cClass+aFuncName;
    if (cClass<>'') then cClass:=' {'+cClass+'}';

    cError:='';
    if (e<>nil) then begin
        cError:=' ['+e.ClassName;
        if (e.Message<>'') then
            cError:=cError+': '+e.Message+' ';
        cError:=cError+']';
    end;
    LogMsg.write(cTime+cClass+cError+' '+aMsg)

end;
procedure error_log(e:Exception;const aClassName:string = '';const aFuncName:string='');
begin
    error_log('',e,aClassName,aFuncName);
end;
procedure error_log(const aMsg:string ;const aClassName:string = '';const aFuncName:string='');
begin
    error_log(aMsg,nil,aClassName,aFuncName);
end;
procedure error_log(const aMsg:string;const aArgs: array of const;const aClassName:string = '';const aFuncName:string='');overload;
begin
    error_log(Format(aMsg,aArgs),aClassName,aFuncName);
end;
{
*********************************** TLogMsg ************************************
}
constructor TLogMsg.Create;
begin
    inherited Create;
    if(Application<>nil) then begin
        fLogFileName:=ExtractFileDir(Application.ExeName)+'/error_log.txt';
    end else begin
        fLogFileName:='';
    end;

    fEnableWriteToFile:=false;
    fSizeFile:=0;
    fClearSize:=1024*1024*10; // 10 mb
    fMaxLenWrite:=512*4;
end;

destructor TLogMsg.Destroy;
begin
    inherited Destroy;
end;

function TLogMsg.getFileSize(aFileName: string): Int64;
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
    if Length(aText)>MaxLenWrite then
        cStr:=copy(aText,1,MaxLenWrite)+'..'
    else
        cStr:=aText;

    Windows.OutputDebugString(PWideChar(cStr));

    if (EnableWriteToFile) then begin

        try
            AssignFile(hFile, LogFileName);

            if (not FileExists(fLogFileName)) or (fSizeFile>fClearSize) then
                ReWrite(hFile)
            else
                Append(hFile);

            WriteLn(hFile,cStr);
            CloseFile(hFile);

            fSizeFile:=GetFileSize(LogFileName);

        except
        on e:Exception do begin
            EnableWriteToFile:=false;
        end;end;


    end;
end;

initialization
LogMsg:=TLogMsg.Create();
finalization
LogMsg.Free();
end.
