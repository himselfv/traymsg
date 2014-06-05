unit FlyoutControls;

interface

uses
  SysUtils, Classes, Types, Controls, StdCtrls, ExtCtrls;

type
  TFlyoutLinkArea = class(TPanel)
  public
    procedure Paint; override;
  end;

  TFlyoutSplitter = class(TSplitter)
  public
    procedure Paint; override;
  end;

procedure Register;

implementation
uses UxTheme, Themes;

procedure Register;
begin
  RegisterComponents('FlyoutControls', [TFlyoutLinkArea]);
  RegisterComponents('FlyoutControls', [TFlyoutSplitter]);
end;

procedure TFlyoutLinkArea.Paint;
var aeroTheme: HTHEME;
  rect: TRect;
begin
  rect := Self.ClientRect;
  aeroTheme := OpenThemeData(Self.Handle, 'FLYOUT');
  DrawThemeBackground(aeroTheme, Self.Canvas.Handle, FLYOUT_LINKAREA, 0, rect, @rect);
  CloseThemeData(aeroTheme);
end;

procedure TFlyoutSplitter.Paint;
var aeroTheme: HTHEME;
  rect: TRect;
begin
  rect := Self.ClientRect;
  aeroTheme := OpenThemeData(Self.Parent.Handle, 'FLYOUT');
  DrawThemeBackground(aeroTheme, Self.Canvas.Handle, FLYOUT_DIVIDER, 0, rect, @rect);
  CloseThemeData(aeroTheme);
end;

end.
