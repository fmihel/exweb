unit UMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, exweb_import, ActnList, ComCtrls, StdCtrls, ExtCtrls, FileCtrl,
  UExWebType;

type
  TfrmMain = class(TForm)
    ActionList1: TActionList;
    actConnect: TAction;
    actSend: TAction;
    actRecv: TAction;
    actSetUrl: TAction;
    PageControl1: TPageControl;
    Splitter1: TSplitter;
    MemoLog: TMemo;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    Button1: TButton;
    DriveComboBox1: TDriveComboBox;
    DllFileName: TEdit;
    Label1: TLabel;
    DirectoryListBox1: TDirectoryListBox;
    FileListBox1: TFileListBox;
    Button2: TButton;
    TabSheet4: TTabSheet;
    Button3: TButton;
    Url: TComboBox;
    Button5: TButton;
    StrRecv: TMemo;
    Label4: TLabel;
    StreamRecv: TMemo;
    Label5: TLabel;
    actSetKey: TAction;
    Key: TEdit;
    Button6: TButton;
    PageControl2: TPageControl;
    TabSheet5: TTabSheet;
    str: TTabSheet;
    FileListBox2: TFileListBox;
    DirectoryListBox2: TDirectoryListBox;
    DriveComboBox2: TDriveComboBox;
    Button4: TButton;
    StreamSend: TEdit;
    Panel2: TPanel;
    TabSheet7: TTabSheet;
    Button12: TButton;
    actStartTest: TAction;
    Button13: TButton;
    actStopTest: TAction;
    Timer1: TTimer;
    edTime: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    edCountAuto: TEdit;
    Button14: TButton;
    actDisconnect: TAction;
    actSaveXMLAs: TAction;
    actSaveXML: TAction;
    actClear: TAction;
    actNew: TAction;
    SaveDialog1: TSaveDialog;
    Edit1: TEdit;
    Button19: TButton;
    Memo8: TMemo;
    FileListBox3: TFileListBox;
    DirectoryListBox3: TDirectoryListBox;
    DriveComboBox3: TDriveComboBox;
    Button18: TButton;
    Button17: TButton;
    Button16: TButton;
    procedure actClearExecute(Sender: TObject);
    procedure actConnectExecute(Sender: TObject);
    procedure actDisconnectExecute(Sender: TObject);
    procedure ActionList1Update(Action: TBasicAction; var Handled: Boolean);
    procedure actNewExecute(Sender: TObject);
    procedure actRecvExecute(Sender: TObject);
    procedure actSaveXMLAsExecute(Sender: TObject);
    procedure actSaveXMLExecute(Sender: TObject);
    procedure actSendExecute(Sender: TObject);
    procedure actSetKeyExecute(Sender: TObject);
    procedure actSetUrlExecute(Sender: TObject);
    procedure actStartTestExecute(Sender: TObject);
    procedure actStopTestExecute(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure FileListBox1Click(Sender: TObject);
    procedure FileListBox2Click(Sender: TObject);
    procedure FileListBox3DblClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
    cStartAutoTime:double;
    cCountAuto:integer;
    procedure log(template:string;val:array of TVarRec);overload;
    procedure log(template:string);overload;
    procedure clear();
    procedure ActionUpdate();
    procedure Send;

  public
    { Public declarations }
    exweb:TExweb_import;
    sendState:TExWebState;
    recvState:TExWebState;
  end;

var
  frmMain: TfrmMain;

implementation

uses
  UMathUtils;

{$R *.dfm}

procedure TfrmMain.actClearExecute(Sender: TObject);
begin
    Memo8.Lines.Clear;
end;

procedure TfrmMain.actConnectExecute(Sender: TObject);
begin

    clear();
    if exweb.Connect(DllFileName.Text) then
        log('Connect to "%s" is Ok!',[DllFileName.Text])
     else
        log('ERROR: connect to "%s"',[DllFileName.Text]);
end;

procedure TfrmMain.actDisconnectExecute(Sender: TObject);
begin
    exweb.Disconnect;
end;

procedure TfrmMain.ActionList1Update(Action: TBasicAction; var Handled:
    Boolean);
begin
    ActionUpdate();
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
    exweb.Free;
end;

procedure TfrmMain.log(template: string);
begin
    log(template,[]);
end;

procedure TfrmMain.log(template: string; val: array of TVarRec);
begin
    MemoLog.Lines.Add(' '+TimeToStr(Now)+': '+Format(template,val));

end;

procedure TfrmMain.ActionUpdate;
begin

    actConnect.Enabled:=not exweb.Connected and FileExists(DllFileName.Text);
    actDisconnect.Enabled:=not actConnect.Enabled;
    actSend.Enabled:=exweb.Connected;
    actRecv.Enabled:=exweb.Connected;
    actSetUrl.Enabled:=exweb.Connected;
    actSetKey.Enabled:=exweb.Connected;
    actStartTest.Enabled:=not Timer1.Enabled;
    actStopTest.Enabled:=Timer1.Enabled;

end;

procedure TfrmMain.actNewExecute(Sender: TObject);
begin
    Memo8.Lines.Clear;
    Edit1.Text:='';
end;

procedure TfrmMain.actRecvExecute(Sender: TObject);
var
    data:TMemoryStream;
    cStr:string;
    i,j:integer;
    cChar:AnsiChar;
begin

    data:=TMemoryStream.Create;
    StrREcv.Clear;
    StreamRecv.Clear;

    try
    try
        recvState:=exweb.recv(cStr,data,recvState);



        if (recvState.result) then begin
            StrRecv.Lines.Add(cStr);
            log('recv ok! id = %s',[recvState.id]);
            if (data.Size>0) then begin
                for i:=0 to 10 do begin
                    cStr:='';
                    for j:=0 to 10 do begin
                        data.Read(cChar,sizeof(cChar));
                        cStr:=cStr+trim(cChar);
                    end;
                    StreamRecv.Lines.Add(cStr);
                end

            end;
        end else begin
            log('ERROR recv!');
        end;
    except
    on e:Exception do
    begin

    end;
    end;
    finally
        data.Free;
    end;
end;

procedure TfrmMain.actSaveXMLAsExecute(Sender: TObject);
var cFileName:string;
begin
    if (Memo8.Lines.Text <> '') then begin
        cFileName:='';

        SaveDialog1.InitialDir:= DirectoryListBox3.Directory;
        if (SaveDialog1.Execute) then begin
            cFileName:=SaveDialog1.FileName;
            FileListBox3.Update;
        end;

        if (cFileName<>'') then begin
            Edit1.Text:=cFileName;
            Memo8.Lines.SaveToFile(cFileName);
            self.log('save to ['+cFileName+'} : ok.');
            FileListBox3.Update;
        end else
            self.log('FileName is not set');

    end else
        self.log('Xml is empty..');

end;

procedure TfrmMain.actSaveXMLExecute(Sender: TObject);
var cFileName:string;
begin
    if (Memo8.Lines.Text <> '') then begin
        cFileName:='';
        if (Edit1.Text = '') or (Edit1.Text = '*.xml') then
        begin
            SaveDialog1.InitialDir:= DirectoryListBox3.Directory;
            if (SaveDialog1.Execute) then begin
                cFileName:=SaveDialog1.FileName;
                FileListBox3.Update;

            end;
        end else
            cFileName:=Edit1.Text;


        if (cFileName<>'') then begin
            Edit1.Text:=cFileName;
            Memo8.Lines.SaveToFile(cFileName);
            self.log('save to ['+cFileName+'} : ok.');
            FileListBox3.Update;
        end else
            self.log('FileName is not set');

    end else
        self.log('Xml is empty..');
end;

procedure TfrmMain.actSendExecute(Sender: TObject);
var
    data:TMemoryStream;
    cLogMsg:string;
begin

    data:=TMemoryStream.Create;

    try
    try
        if (FileExists(StreamSend.Text)) then
            data.LoadFromFile(StreamSend.Text);

        if (data.Size>0) then
            sendState:=exweb.send(Memo8.Text,data,sendState)
        else
            sendState:=exweb.send(Memo8.Text,nil,sendState);

        if (sendState.result) then
            cLogMsg:='ok: '
        else
            cLogMsg:='ERROR: ';

        log(cLogMsg+'id:%s , %s:"%s"',[sendState.id,TExWebResultStr[integer(sendState.webResult)],TExWebResultNotes[integer(sendState.webResult)]]);
    except
    on e:Exception do
    begin

    end;
    end;
    finally
        data.Free;
    end;
end;

procedure TfrmMain.actSetKeyExecute(Sender: TObject);
begin
    exweb.setParam('key',Key.Text);
    log('Новый ключ авторизации: %s',[exweb.getParam('key')]);
end;

procedure TfrmMain.actSetUrlExecute(Sender: TObject);
begin
    exweb.setParam('url',Url.Text);
    log('Путь к скрипту обмена: %s',[exweb.getParam('url')]);
end;

procedure TfrmMain.actStartTestExecute(Sender: TObject);
begin
    Timer1.Enabled:=true;
    cStartAutoTime:=Now();
    Timer1.Tag:=0;
    cCountAuto:=0;

end;

procedure TfrmMain.actStopTestExecute(Sender: TObject);
begin
    Timer1.Enabled:=false;
end;

procedure TfrmMain.Button4Click(Sender: TObject);
begin
    StreamSend.Clear;
end;

procedure TfrmMain.clear;
begin
    MemoLog.Clear();
end;

procedure TfrmMain.FileListBox1Click(Sender: TObject);
begin
    DllFileName.Text:=FileListBox1.FileName;
end;

procedure TfrmMain.FileListBox2Click(Sender: TObject);
begin
    StreamSend.Text:=FileListBox2.FileName;

end;

procedure TfrmMain.FileListBox3DblClick(Sender: TObject);
begin
    Edit1.Text:=FileListBox3.FileName;
    Memo8.Lines.LoadFromFile(Edit1.Text);
end;

procedure TfrmMain.FormCreate(Sender: TObject);
var
  cdir: string;
begin
    clear();
    log('log..');
    // создание объекта для работы с протоколом обмена
    exweb:=TExweb_import.Create;
    PageControl1.ActivePage := TabSheet1;
    cdir:='E:\work\windeco\exweb\client\examples\xml\';
    if (SysUtils.DirectoryExists(cDir)) then
        DirectoryListBox3.Directory:=cDir;

end;
procedure TfrmMain.Send();
var i:integer;
begin
    randomize();
    i:=random(4);
    if (i = 1) then begin
        Memo8.Lines.Text:='qwkjedqjkw';
    end else if (i = 2) then begin
        Memo8.Lines.Text:='jhedjkqwehd';
    end else if (i = 3) then begin
        Memo8.Lines.Text:='hdjwhqe';
    end else
        Memo8.Text:='АБВГДЕ 123457678';
    actSendExecute(nil);
end;

procedure TfrmMain.Timer1Timer(Sender: TObject);
const
    cFuncName = 'Timer1Timer';
begin
    if Timer1.Tag = 1 then
        exit;

    Timer1.Tag:=1;
    {$ifdef _log_} SLog.Stack(ClassName,cFuncName);{$endif}
    try
    try
        inc(cCountAuto);
        edTime.Text:=TimeToStr(Now()-cStartAutoTime);
        edCountAuto.Text:=IntToStr(cCountAuto);
        Send();
    except
    on e:Exception do
    begin
    	{$ifdef _log_}error_log(e,ClassName,cFuncName);{$endif}
    end;
    end;
    finally
        Timer1.Tag:=0;
    end;


end;

end.
