unit TrayMsg_Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, TaskbarFlyout, AppEvnts, ExtCtrls, Menus, FlyoutControls, Buttons,
  StdCtrls, Generics.Collections, ComCtrls;

type
  TStringArray = TArray<string>;

  TEventRecord = class
    Id: integer;
    Panel: TPanel;
    Action: string;
    Dismissing: boolean;
  end;
  PEventRecord = ^TEventRecord;

  TMainForm = class(TFlyoutForm)
    TrayIcon: TTrayIcon;
    ApplicationEvents1: TApplicationEvents;
    DismissAll: TLinkLabel;
    SweepTimer: TTimer;
    InstanceTimer: TTimer;
    Scrollbox: TScrollBox;
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure TrayIconClick(Sender: TObject);
    procedure DismissLinkClick(Sender: TObject; const Link: string;
      LinkType: TSysLinkType);
    procedure FormDestroy(Sender: TObject);
    procedure SweepTimerTimer(Sender: TObject);
    procedure InstanceTimerTimer(Sender: TObject);
    procedure FormMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure DismissAllLinkClick(Sender: TObject; const Link: string;
      LinkType: TSysLinkType);
    procedure ActionLinkClick(Sender: TObject; const Link: string;
      LinkType: TSysLinkType);
  protected
    NoStart: boolean; //don't start UI, only execute a command (add event etc)
    procedure ParseCommandLine(ALine: string);
  protected
    FEvents: TObjectList<TEventRecord>;
    procedure ClearEvents;
    procedure LoadEvent(const AId: integer; const ACaption, AText: string; AAction: string);
    function FindEvent(const AId: integer): integer;
    procedure DismissEvent(AIndex: integer);
    procedure SweepEvents;
    procedure EventListChanged;
  protected
    procedure DeepResize(AControl: TControl);
    procedure PanelMouseEnter(Sender: TObject);
    procedure PanelMouseLeave(Sender: TObject);
  public
    procedure ReloadEvents;
    function AddEvent(const ACaption, AText: string; AAction: string): integer;
  end;

var
  MainForm: TMainForm;

implementation
uses UITypes, Registry, ShellApi, InstanceChecker;

{$R *.dfm}

procedure TMainForm.FormCreate(Sender: TObject);
begin
  inherited;
//  Self.Resizeable := true; //for testing
  FEvents := TObjectList<TEventRecord>.Create({OwnsObjects=}true);
  Application.ShowMainForm := false;
  ReloadEvents();
  ParseCommandLine(GetCommandLine());
  if NoStart then begin
    Self.Close;
    Application.Terminate;
  end;
  EventListChanged;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FEvents);
  inherited;
end;

function CommandLineParams(ALine: string): TArray<string>; overload;
var i: integer;
  c: char;
  flag_quotes: boolean;
  flag_escape: boolean;
  AParam: PString;

  procedure AddChar(const ac: char);
  begin
    if AParam=nil then begin
      SetLength(Result, Length(Result)+1);
      AParam := @Result[Length(Result)-1];
      AParam^ := '';
    end;
    AParam^ := AParam^ + ac;
  end;

  procedure CloseParam;
  begin
    AParam := nil;
  end;

begin
  SetLength(Result, 0);

  AParam := nil;
  flag_quotes := false;
  flag_escape := false;

  i := 1;
  while i<=Length(ALine) do begin
    c := ALine[i];
    if (c='"') and not flag_escape then
      flag_quotes := not flag_quotes
    else
    if (c='\') and not flag_escape then
      flag_escape := true
    else
    if (c=' ') and not flag_quotes then
      CloseParam
    else begin
      AddChar(c);
      flag_escape := false;
    end;
    Inc(i);
  end;
end;

function CommandLineParams: TArray<string>; overload;
begin
  Result := CommandLineParams(GetCommandLine());
end;

procedure TMainForm.ParseCommandLine(ALine: string);
var params: TArray<string>;
  i: integer;
  pm: string;
  ACaption, AText, AAction: string;
begin
  params := CommandLineParams(ALine);
  i := 1;
  while i<Length(params) do begin
    pm := params[i].ToLower;

    if pm='/add' then begin
      Inc(i);
      if i>=Length(params) then
        raise Exception.Create('/add requires caption');
      ACaption := params[i];
      Inc(i);
      if i>=Length(params) then
        raise Exception.Create('/add requires text');
      AText := params[i];
      Inc(i);
      if i>=Length(params) then
        raise Exception.Create('/add requires action');
      AAction := params[i];
      AddEvent(ACaption, AText, AAction);
    end else
    if pm='/nostart' then begin
      NoStart := true;
    end else
      raise Exception.Create('Invalid parameter: '+pm);

    Inc(i);
  end;
end;

procedure TMainForm.TrayIconClick(Sender: TObject);
begin
  inherited;
  if not Self.Visible then
    Popup(Mouse.CursorPos)
  else
    Self.Hide;
end;

procedure TMainForm.ClearEvents;
var i: integer;
begin
  for i := 0 to FEvents.Count-1 do
    FreeAndNil(FEvents[i].panel);
  FEvents.Clear;
end;

function EncodeStr(AValue: string): string;
var i: integer;
begin
  Result := '';
  for i := 1 to Length(AValue) do
    if AValue[i]='"' then
      Result := Result + '\"'
    else
    if AValue[i]='\' then
      Result := Result + '\\'
    else
      Result := Result + AValue[i];
end;

function DecodeSplit(AValue: string): TStringArray;
var i: integer;
  flag_specsymbol: boolean;
  flag_quotes: boolean;
  curPart: PString;

  procedure addChar(const c: char);
  begin
    if curPart=nil then begin
      SetLength(Result, Length(Result)+1);
      curPart := @Result[Length(Result)-1];
      curPart^ :=  c;
    end else
      curPart^ := curPart^ + c;
  end;

begin
  SetLength(Result, 0);
  flag_specsymbol := false;
  flag_quotes := false;
  curPart := nil;
  for i := 1 to Length(AValue) do
    if flag_specsymbol then begin
      addChar(AValue[i]);
      flag_specsymbol := false;
    end else
    if AValue[i]='\' then begin
      flag_specsymbol := true;
    end else
    if AValue[i]='"' then begin
      flag_quotes := not flag_quotes;
    end else
    if (AValue[i]=',') and not flag_quotes then begin
      curPart := nil;
    end else begin
      addChar(AValue[i]);
    end;
end;

const
  RegKey: string = 'Software\TrayMsg';

function OpenRegistry: TRegistry;
begin
  Result := TRegistry.Create;
  Result.RootKey := HKEY_CURRENT_USER;
  Result.OpenKey(RegKey, true);
end;

function FindLastId(AReg: TRegistry): integer;
var valueNames: TStringList;
  i, tmp: integer;
begin
  valueNames := TStringList.Create;
  try
    Result := 1;
    AReg.GetValueNames(valueNames);
   //Can go in any order and list would sort them wrong (1 10 2 3)
    for i := 0 to valueNames.Count-1 do begin
      tmp := StrToInt(valueNames[i]);
      if tmp>Result then
        Result := tmp;
    end;
  finally
    FreeAndNil(valueNames);
  end;
end;

procedure TMainForm.ReloadEvents;
var reg: TRegistry;
  valueNames: TStringList;
  valueStr: string;
  valueParts: TStringArray;
  i: integer;
  ACaption, AText, AAction: string;
begin
  ClearEvents;
  valueNames := nil;
  reg := OpenRegistry;
  try
    valueNames := TStringList.Create;
    reg.GetValueNames(valueNames);
    valueNames.Sort;
    for i := 0 to valueNames.Count-1 do begin
      valueStr := reg.GetDataAsString(valueNames[i]);
      valueParts := DecodeSplit(valueStr);
      if Length(valueParts)>=0 then
        ACaption := valueParts[0]
      else
        ACaption := '';
      if Length(valueParts)>=1 then
        AText := valueParts[1]
      else
        AText := '';
      if Length(valueParts)>=2 then
        AAction := valueParts[2]
      else
        AAction := '';
      LoadEvent(StrToInt(valueNames[i]), ACaption, AText, AAction);
    end;
  finally
    FreeAndNil(valueNames);
    FreeAndNil(reg);
  end;
end;

//Returns the maximal Y value in local coordinates, where children of AControl
//still exist.
function MaxUsedY(AControl: TWinControl): integer;
var i, tmp: integer;
begin
  Result := 0;
  for i := 0 to AControl.ControlCount-1 do begin
    tmp := AControl.Controls[i].Top + AControl.Controls[i].Height;
    if tmp > Result then
      Result := tmp;
  end;
end;

procedure TMainForm.LoadEvent(const AId: integer; const ACaption, AText: string; AAction: string);
var panel: TPanel;
  evt: TEventRecord;
begin
  evt := TEventRecord.Create;
  evt.Id := AId;
  panel := TPanel.Create(Self);
  panel.Parent := Scrollbox;
  panel.Align := alTop;
  panel.BevelOuter := bvNone;
  panel.Caption := '';
  panel.Top := MaxUsedY(Scrollbox)+1;
  panel.Tag := NativeInt(evt);
  panel.Height := 10;
  panel.Margins.Left := 8;
  panel.Margins.Right := 8;
  panel.Margins.Top := 8;
  panel.AlignWithMargins := true;
  panel.AutoSize := true;

  with TLinkLabel.Create(panel) do begin
    Parent := panel;
    Caption := '<a href="'+AAction+'">'+ACaption+'</a>';
    Align := alTop;
    UseVisualStyle := true;
    OnLinkClick := ActionLinkClick;
    Font.Style := Font.Style + [fsBold];
    Font.Size := Font.Size + 2;
  end;
  with TLabel.Create(panel) do begin
    Parent := panel;
    if AText<>'' then
      Caption := AText
    else
      Caption := 'Click here for more info...';
    Align := alTop;
    WordWrap := true;
    Autosize := true;
    Top := MaxUsedY(panel)+1;
  end;
  with TLinkLabel.Create(panel) do begin
    Parent := panel;
    Caption := '<a href="id://1">Dismiss</a>';
    Tag := NativeInt(evt);
    OnLinkClick := DismissLinkClick;
    UseVisualStyle := true;
    Align := alTop;
    Alignment := taRightJustify;
    AutoSize := true;
    Margins.Top := 6;
    AlignWithMargins := true;
    Top := MaxUsedY(panel)+1;
  end;

  evt.Panel := nil;
  evt.Panel := panel;
  evt.Action := AAction;
  FEvents.Add(evt);
end;

function TMainForm.FindEvent(const AId: integer): integer;
var i: integer;
begin
  Result := -1;
  for i := 0 to FEvents.Count-1 do
    if FEvents[i].Id = AId then begin
      Result := i;
      break;
    end;
end;

function TMainForm.AddEvent(const ACaption, AText: string; AAction: string): integer;
var reg: TRegistry;
begin
  reg := OpenRegistry;
  Result := FindLastId(reg)+1;
  reg.WriteString(IntToStr(Result), '"'+EncodeStr(ACaption)+'","'+EncodeStr(AText)+'","'+EncodeStr(AAction)+'"');
  LoadEvent(Result, ACaption, AText, AAction);

  TrayIcon.BalloonFlags := bfWarning;
  TrayIcon.BalloonTitle := ACaption;
  TrayIcon.BalloonHint := AText;
  TrayIcon.ShowBalloonHint;
end;

procedure TMainForm.DismissEvent(AIndex: integer);
var reg: TRegistry;
begin
  reg := OpenRegistry;
  try
    reg.DeleteValue(IntToStr(FEvents[AIndex].Id));
  finally
    FreeAndNil(reg);
  end;

  FreeAndNil(FEvents[AIndex].Panel);
  FEvents.Delete(AIndex);
end;

procedure TMainForm.EventListChanged;
begin
  if FEvents.Count<=0 then begin
    Self.Close;
    Application.Terminate;
  end else begin
    Header.Caption := IntToStr(FEvents.Count)+' messages:';
    TrayIcon.Hint := IntToStr(FEvents.Count)+' messages';
  end;
end;

procedure TMainForm.SweepEvents;
var i: integer;
begin
  for i := FEvents.Count-1 downto 0 do
    if FEvents[i].Dismissing then
      DismissEvent(i);
  EventListChanged;
end;

procedure TMainForm.DismissLinkClick(Sender: TObject; const Link: string;
  LinkType: TSysLinkType);
begin
  if Link='id://1' then begin
    TEventRecord(TLinkLabel(Sender).Tag).Dismissing := true;
    SweepTimer.Enabled := true;
  end;
end;

procedure TMainForm.DismissAllLinkClick(Sender: TObject; const Link: string;
  LinkType: TSysLinkType);
var i: integer;
begin
  if Link='id://1' then begin
    for i := 0 to FEvents.Count-1 do
      FEvents[i].Dismissing := true;
    SweepTimer.Enabled := true;
  end;
end;

procedure TMainForm.ActionLinkClick(Sender: TObject; const Link: string;
  LinkType: TSysLinkType);
begin
  ShellExecute(0, 'open', PChar(Link), nil, '', SW_SHOW);
end;


procedure TMainForm.SweepTimerTimer(Sender: TObject);
begin
  SweepEvents();
  SweepTimer.Enabled := false;
end;

procedure TMainForm.InstanceTimerTimer(Sender: TObject);
var AInfo: TNewInstanceInfo;
begin
  if not TryAcceptNewInstance(AInfo) then exit;
  ParseCommandLine(AInfo.CommandLine);
end;

//Tests if the mouse is pointing at a window, or at a child of that window etc.
function PointingAt(AHwnd: HWND; const APoint: TPoint): boolean;
var ACurHwnd: HWND;
begin
  ACurHwnd := WindowFromPoint(mouse.CursorPos);
  while ACurHwnd<>0 do
    if ACurHwnd=AHwnd then begin
      Result := true;
      exit;
    end else
      ACurHwnd := GetParent(ACurHwnd);
  Result := false;
end;

procedure TMainForm.FormMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
var msg, code, i, n: integer;
begin
  inherited;
 { Scrollbox does not support mouse wheel nor even focus, so handle it here }
  if PointingAt(scrollBox.Handle, mouse.CursorPos) then begin
    Handled := true;
    if ssShift in Shift Then
      msg := WM_HSCROLL
    else
      msg := WM_VSCROLL;

    if WheelDelta < 0 then begin
      code := SB_LINEDOWN;
      WheelDelta := -WheelDelta;
    end else
      code := SB_LINEUP;

    n := 3* Mouse.WheelScrollLines * (WheelDelta div WHEEL_DELTA);
    for i := 1 to n do
      scrollbox.Perform(msg, code, 0);
    scrollbox.Perform(msg, SB_ENDSCROLL, 0);
  end;
end;

procedure TMainForm.DeepResize(AControl: TControl);
var i: integer;
begin
  TPanel(AControl).AutoSize := false;
  if AControl is TWinControl then begin
    TWinControl(AControl).Realign;
    for i := 0 to TWinControl(AControl).ControlCount-1 do
      DeepResize(TWinControl(AControl).Controls[i]);
  end;
  TPanel(AControl).AutoSize := true;
end;

procedure TMainForm.FormResize(Sender: TObject);
var i: integer;
begin
  inherited;
  for i := 0 to FEvents.Count-1 do
    DeepResize(FEvents[i].Panel);
  Scrollbox.Realign;
end;

procedure TMainForm.PanelMouseEnter(Sender: TObject);
begin
  TPanel(Sender).Color := clHighlight;
end;

procedure TMainForm.PanelMouseLeave(Sender: TObject);
begin
  TPanel(Sender).Color := clBtnFace;
end;


end.
