unit UMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, DBClient, Grids, DBGrids, StdCtrls,exweb_import;

type
  TfrmMain = class(TForm)
    DBGrid1: TDBGrid;
    ClientDataSet1: TClientDataSet;
    Button1: TButton;
    DataSource1: TDataSource;
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    exweb:TExweb_import;
  end;

var
  frmMain: TfrmMain;

implementation


{$R *.dfm}

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
    if (exweb<>nil) then
        exweb.Free;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
    exweb:=TExweb_import.Create;
    try
    try
        if not exweb.Connect('exweb.dll') then
            raise Exception.Create('connect to exweb.dll');

        exweb.setParam('url','http://windeco/exweb/server/');
        exweb.setParam('key','jqwed67dec');

    except
    on e:Exception do
    begin
        exweb.Free();
        exweb:=nil;
        ShowMessage(e.Message);
    end;
    end;
    finally
    end;

end;

procedure TfrmMain.Button1Click(Sender: TObject);
begin
    if (exweb<>nil) and (exweb.query('select * from REST_API where 1>0 limit 5','exweb',ClientDataSet1,'')) then
        ClientDataSet1.Active:=true;
end;

end.
