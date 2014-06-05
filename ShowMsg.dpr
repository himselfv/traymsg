program ShowMsg;

uses
  Forms,
  InstanceChecker,
  TaskbarFlyout in 'TaskbarFlyout.pas' {FlyoutForm},
  ShowMsg_Main in 'ShowMsg_Main.pas' {MainForm};

{$R *.res}

begin
  if InstanceChecker.RestoreIfRunning(Application.Handle) then
    exit;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
