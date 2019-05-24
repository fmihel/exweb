program exweb_dll_use;

uses
  Forms,
  UMain in '..\source\UMain.pas' {frmMain},
  exweb_type in '..\..\..\dll\exweb_type.pas',
  UExWebType in '..\..\..\source\UExWebType.pas',
  exweb_import in '..\..\..\dll\exweb_import.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
