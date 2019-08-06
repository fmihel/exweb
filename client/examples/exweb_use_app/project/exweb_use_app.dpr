program exweb_use_app;

uses
  Forms,
  UMain in '..\source\UMain.pas' {frmMain},
  UExweb in '..\..\..\source\UExweb.pas',
  UHash in '..\..\..\source\UHash.pas',
  UHttp in '..\..\..\source\UHttp.pas',
  uLkJSON in '..\..\..\source\uLkJSON.pas',
  UMD5 in '..\..\..\source\UMD5.pas',
  UUrl in '..\..\..\source\UUrl.pas',
  UUtils in '..\..\..\source\UUtils.pas',
  UExWebType in '..\..\..\source\UExWebType.pas',
  ULogMsg in '..\..\..\source\ULogMsg.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
