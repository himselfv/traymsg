unit TaskbarFlyout;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, FlyoutControls, Vcl.Buttons;

type
  TFlyoutForm = class(TForm)
    Header: TPanel;
    Footer: TFlyoutLinkArea;
    FlyoutSplitter1: TFlyoutSplitter;
    procedure FormDeactivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  protected
    FResizeable: boolean;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure WmActivate(var msg: TMessage); message WM_ACTIVATE;
    procedure WmNcHitTest(var Msg: TMessage); message WM_NCHITTEST;
  public
    procedure Popup(const AMousePos: TPoint);
    property Resizeable: boolean read FResizeable write FResizeable;
  end;

var
  FlyoutForm: TFlyoutForm;

implementation

{$R *.dfm}

procedure TFlyoutForm.FormCreate(Sender: TObject);
begin
  FResizeable := false; //by default flyouts aren't
end;

procedure TFlyoutForm.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.Style := WS_POPUP or WS_CLIPSIBLINGS or WS_BORDER or WS_THICKFRAME
    or WS_MINIMIZEBOX;
  Params.ExStyle := WS_EX_LEFT or WS_EX_LTRREADING or WS_EX_RIGHTSCROLLBAR
    or WS_EX_PALETTEWINDOW;
end;

procedure TFlyoutForm.WmActivate(var msg: TMessage);
begin
  if Msg.WParam = WA_INACTIVE then
    Hide; // or close
end;

procedure TFlyoutForm.WmNcHitTest(var Msg: TMessage);
begin
  if not FResizeable then begin
   //Always return HTCLIENT to disable resizing even with THICKFRAME
    Msg.Result := HTCLIENT;
  end else
    inherited;
end;

procedure TFlyoutForm.FormDeactivate(Sender: TObject);
begin
  Self.Hide;
end;

procedure TFlyoutForm.Popup(const AMousePos: TPoint);
begin
//  Self.Hide;
//  Self.Top := Screen.WorkAreaHeight - Self.Height;
  Self.Left := Screen.WorkAreaWidth - Self.Width;
  Self.Top := AMousePos.Y - Self.Height - 20;
  Self.Visible := true;
  Self.Activate;
  Self.BringToFront;
  SetForegroundWindow(Self.Handle);
end;

end.
