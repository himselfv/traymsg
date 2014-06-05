object FlyoutForm: TFlyoutForm
  Left = 0
  Top = 0
  BorderIcons = []
  BorderStyle = bsNone
  Caption = 'FlyoutForm'
  ClientHeight = 338
  ClientWidth = 289
  Color = clWindow
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PopupMode = pmExplicit
  TipMode = tipOpen
  OnCreate = FormCreate
  OnDeactivate = FormDeactivate
  PixelsPerInch = 96
  TextHeight = 13
  object FlyoutSplitter1: TFlyoutSplitter
    Left = 0
    Top = 41
    Width = 289
    Height = 1
    Cursor = crVSplit
    Align = alTop
  end
  object Header: TPanel
    Left = 0
    Top = 0
    Width = 289
    Height = 41
    Align = alTop
    BevelOuter = bvNone
    Caption = 'Header text'
    TabOrder = 0
  end
  object Footer: TFlyoutLinkArea
    Left = 0
    Top = 297
    Width = 289
    Height = 41
    Align = alBottom
    BevelEdges = [beTop]
    BevelOuter = bvNone
    Color = clInactiveBorder
    ParentBackground = False
    TabOrder = 1
  end
end
