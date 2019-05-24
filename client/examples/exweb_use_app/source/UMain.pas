unit UMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, ActnList, FileCtrl, UExWebType;
{-$define _log_}
type
  TfrmMain = class(TForm)
    GroupBox1: TGroupBox;
    Addr: TComboBox;
    Label1: TLabel;
    Panel1: TPanel;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    GroupBox2: TGroupBox;
    Splitter1: TSplitter;
    LogMemo: TMemo;
    Panel2: TPanel;
    ActionList1: TActionList;
    Button1: TButton;
    actClearLog: TAction;
    Label2: TLabel;
    Memo1: TMemo;
    Button2: TButton;
    actSendStream: TAction;
    Label3: TLabel;
    DriveComboBox1: TDriveComboBox;
    DirectoryListBox1: TDirectoryListBox;
    FileListBox1: TFileListBox;
    Edit1: TEdit;
    actSendStr: TAction;
    Button3: TButton;
    Button4: TButton;
    actGet: TAction;
    Label4: TLabel;
    edFileName: TEdit;
    Memo2: TMemo;
    Label5: TLabel;
    procedure actClearLogExecute(Sender: TObject);
    procedure actGetExecute(Sender: TObject);
    procedure actSendStrExecute(Sender: TObject);
    procedure actSendStreamExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
     ExWebState:TExWebState;
     ExWebStateRecv:TExWebState;
     procedure _Log(aMsg:string);
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation
Uses {$ifdef _log_}ULog, {$endif}UExWeb, umd5;
{$R *.dfm}

procedure TfrmMain.actClearLogExecute(Sender: TObject);
begin
    LogMemo.Clear();
end;

procedure TfrmMain.actGetExecute(Sender: TObject);
var cData:TMemoryStream;
    cStr:string;
    exweb:TExWeb;
    cStart:TDateTime;
const
    cFuncName = 'actGetExecute';
begin
    cStart:=Now();
    exweb:=TExWeb.Create(Addr.Text);
    cData:=TMemoryStream.Create;
    Memo2.Lines.Clear;
    try
    try
        ExWebStateRecv:=exweb.recv(cStr,cData,ExWebStateRecv);
        if (ExWebStateRecv.result) then begin
            if (cData.Size>0) then
                cData.SaveToFile(edFileName.Text);

            Memo2.Lines.Clear;
            Memo2.Lines.Add(cStr);
        end;

        if (ExWebStateRecv.result) then
            ShowMessage('recv ok')
        else
            ShowMessage('ERROR recv');

        {$ifdef _log_} ULog.Log('%s',[TExWebStateToStr(ExWebStateRecv)],ClassName,cFuncName);{$endif}
    except
    on e:Exception do
    begin
    	{$ifdef _log_}ULog.Error('',e,ClassName,cFuncName);{$endif}
    end;
    end;
    finally
        cData.Free;
        exweb.Free;
    end;
    {$ifdef _log_} ULog.Log('time %s',[TimeToStr(Now()-cStart)],ClassName,cFuncName);{$endif}

end;

procedure TfrmMain.actSendStrExecute(Sender: TObject);
var
    exweb:TExWeb;
    cData:TMemoryStream;
    cStart:TDateTime;
const
    cFuncName = 'actSimpleStrExecute';
begin

    cStart:=Now();
    exweb:=TExWeb.Create(Addr.Text);

    try
    try
        ExWebState:=exweb.send(Memo1.Lines.Text,nil,ExWebState);
        {$ifdef _log_} ULog.Log('%s',[TExWebStateToStr(ExWebState)],ClassName,cFuncName);{$endif}

        if (ExWebState.result) then
            ShowMessage('send ok')
        else
            ShowMessage('ERROR send');

    except
    on e:Exception do
    begin
    	{$ifdef _log_}ULog.Error('',e,ClassName,cFuncName);{$endif}
    end;
    end;
    finally
        exweb.Free;
    end;

    {$ifdef _log_} ULog.Log('time %s',[TimeToStr(Now()-cStart)],ClassName,cFuncName);{$endif}

end;

procedure TfrmMain.actSendStreamExecute(Sender: TObject);
var
    exweb:TExWeb;
    cData:TMemoryStream;
    cStart:TDateTime;
const
    cFuncName = 'actSimpleSendExecute';
begin

    cStart:=Now();
    exweb:=TExWeb.Create(Addr.Text);
    cData:=TMemoryStream.Create;

    try
    try
        cData.LoadFromFile(FileListBox1.FileName);
        {$ifdef _log_} ULog.Log('sending MD5 = %s size= %d Mb',[MD5(cData),cData.Size div (1024*1024)],ClassName,cFuncName);{$endif}

        ExWebState:=exweb.send(Memo1.Lines.Text,cData,ExWebState);
        {$ifdef _log_} ULog.Log('%s',[TExWebStateToStr(ExWebState)],ClassName,cFuncName);{$endif}
        if (ExWebState.result) then
            ShowMessage('send ok')
        else
            ShowMessage('ERROR send');
    except
    on e:Exception do
    begin
    	{$ifdef _log_}ULog.Error('',e,ClassName,cFuncName);{$endif}
    end;
    end;
    finally
        cData.Free;
        exweb.Free;
    end;

    {$ifdef _log_} ULog.Log('time %s',[TimeToStr(Now()-cStart)],ClassName,cFuncName);{$endif}

end;

procedure TfrmMain.FormCreate(Sender: TObject);
const
    cFuncName = '';
begin
    LogMemo.Clear;
    DirectoryListBox1.Directory:=ExtractFileDir(Application.ExeName);
    {$ifdef _log_}ULog.GlobalLogEvent:=_Log;{$endif}

    ExWebState.id:='-1';
    ExWebState.webResult:=ewrOk;
    ExWebState.result:=true;

    ExWebStateRecv.id:='-1';
    ExWebStateRecv.webResult:=ewrOk;
    ExWebStateRecv.result:=true;

end;

procedure TfrmMain._Log(aMsg: string);
begin
    LogMemo.Lines.Add(aMsg);
end;

end.
