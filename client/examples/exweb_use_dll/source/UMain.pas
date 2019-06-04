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
    StrSend: TMemo;
    Panel1: TPanel;
    Button7: TButton;
    FileListBox2: TFileListBox;
    DirectoryListBox2: TDirectoryListBox;
    DriveComboBox2: TDriveComboBox;
    Button4: TButton;
    StreamSend: TEdit;
    Panel2: TPanel;
    TabSheet6: TTabSheet;
    Memo1: TMemo;
    Memo2: TMemo;
    Button8: TButton;
    Memo3: TMemo;
    Button9: TButton;
    Memo4: TMemo;
    Button10: TButton;
    Memo5: TMemo;
    Button11: TButton;
    Memo6: TMemo;
    procedure actConnectExecute(Sender: TObject);
    procedure ActionList1Update(Action: TBasicAction; var Handled: Boolean);
    procedure actRecvExecute(Sender: TObject);
    procedure actSendExecute(Sender: TObject);
    procedure actSetKeyExecute(Sender: TObject);
    procedure actSetUrlExecute(Sender: TObject);
    procedure Button10Click(Sender: TObject);
    procedure Button11Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure FileListBox1Click(Sender: TObject);
    procedure FileListBox2Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    procedure log(template:string;val:array of TVarRec);overload;
    procedure log(template:string);overload;
    procedure clear();
    procedure ActionUpdate();
  public
    { Public declarations }
    exweb:TExweb_import;
    sendState:TExWebState;
    recvState:TExWebState;
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

procedure TfrmMain.actConnectExecute(Sender: TObject);
begin
    clear();
    if exweb.Connect(DllFileName.Text) then
        log('Connect to "%s" is Ok!',[DllFileName.Text])
     else
        log('ERROR: connect to "%s"',[DllFileName.Text]);
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
    actSend.Enabled:=exweb.Connected;
    actRecv.Enabled:=exweb.Connected;
    actSetUrl.Enabled:=exweb.Connected;
    actSetKey.Enabled:=exweb.Connected;

end;

procedure TfrmMain.actRecvExecute(Sender: TObject);
var
    data:TMemoryStream;
    cStr:string;
    i,j,m:integer;
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
                m:=0;
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

procedure TfrmMain.actSendExecute(Sender: TObject);
var
    data:TMemoryStream;
begin

    data:=TMemoryStream.Create;

    try
    try
        if (FileExists(StreamSend.Text)) then
            data.LoadFromFile(StreamSend.Text);

        if (data.Size>0) then
            sendState:=exweb.send(StrSend.Text,data,sendState)
        else
            sendState:=exweb.send(StrSend.Text,nil,sendState);

        if (sendState.result) then begin
            log('send ok! id = %s',[sendState.id]);
        end else begin
            log('ERROR send!');
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

procedure TfrmMain.actSetKeyExecute(Sender: TObject);
begin
    exweb.setParam('key',Key.Text);
    log('����� ���� �����������: %s',[exweb.getParam('key')]);
end;

procedure TfrmMain.actSetUrlExecute(Sender: TObject);
begin
    exweb.setParam('url',Url.Text);
    log('���� � ������� ������: %s',[exweb.getParam('url')]);
end;

procedure TfrmMain.Button10Click(Sender: TObject);
begin
    StrSend.Lines.Text:=Memo4.Lines.Text;
end;

procedure TfrmMain.Button11Click(Sender: TObject);
begin
    StrSend.Lines.Text:=Memo5.Lines.Text;
end;

procedure TfrmMain.Button4Click(Sender: TObject);
begin
    StreamSend.Clear;
end;

procedure TfrmMain.Button7Click(Sender: TObject);
begin
    StrSend.Lines.Text:=Memo6.Lines.Text;
end;

procedure TfrmMain.Button8Click(Sender: TObject);
begin
    StrSend.Lines.Text:=Memo2.Lines.Text;
end;

procedure TfrmMain.Button9Click(Sender: TObject);
begin
    StrSend.Lines.Text:=Memo3.Lines.Text;
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

procedure TfrmMain.FormCreate(Sender: TObject);
begin
    clear();
    log('log..');
    // �������� ������� ��� ������ � ���������� ������
    exweb:=TExweb_import.Create;
    TabSheet6.TabVisible:=false;
end;

end.
