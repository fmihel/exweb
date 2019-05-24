unit UMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, DBClient, Grids, DBGrids;

type
  TForm30 = class(TForm)
    DBGrid1: TDBGrid;
    ClientDataSet1: TClientDataSet;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form30: TForm30;

implementation

uses
  exweb_import;

{$R *.dfm}

procedure TForm30.FormCreate(Sender: TObject);
var exweb:TExweb_import;
begin
    exweb:=TExweb_import.Create;
    try
    try
        if not exweb.Connect('exweb.dll') then
            raise Exception.Create('connect to exweb.dll');

        exweb.setParam('url','http://windeco/exweb/server/');
        exweb.setParam('key','jqwed67dec');

        if (exweb.query('select * from rest_api where 1>0 limit 5','exweb',ClientDataSet1,'')) then
            ClientDataSet1.Active:=true;


    except
    on e:Exception do
    begin
        ShowMessage(e.Message);
    end;
    end;
    finally
        exweb.Free;
    end;

end;

end.
