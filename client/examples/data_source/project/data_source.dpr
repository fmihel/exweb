program data_source;

uses
  Forms,
  UMain in '..\source\UMain.pas' {Form30},
  exweb_import in '..\..\..\dll\exweb_import.pas',
  exweb_type in '..\..\..\dll\exweb_type.pas',
  UExWebType in '..\..\..\source\UExWebType.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm30, Form30);
  Application.Run;
end.
