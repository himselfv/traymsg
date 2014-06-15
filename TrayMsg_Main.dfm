inherited MainForm: TMainForm
  Caption = 'MainForm'
  ClientWidth = 335
  OnDestroy = FormDestroy
  OnMouseWheel = FormMouseWheel
  OnResize = FormResize
  OnShow = FormShow
  ExplicitWidth = 335
  ExplicitHeight = 338
  PixelsPerInch = 96
  TextHeight = 13
  inherited FlyoutSplitter1: TFlyoutSplitter
    Width = 335
    ExplicitWidth = 335
  end
  inherited Header: TPanel
    Width = 335
    ExplicitWidth = 335
  end
  inherited Footer: TFlyoutLinkArea
    Width = 335
    ExplicitWidth = 335
    object DismissAllLink: TLinkLabel
      Left = 138
      Top = 11
      Width = 59
      Height = 19
      Anchors = [akTop]
      Caption = '<a href="id://1">Dismiss all</a>'
      TabOrder = 0
      UseVisualStyle = True
      OnLinkClick = DismissAllLinkLinkClick
    end
  end
  object Scrollbox: TScrollBox
    Left = 0
    Top = 42
    Width = 335
    Height = 255
    Align = alClient
    BevelInner = bvNone
    BevelOuter = bvNone
    BorderStyle = bsNone
    Ctl3D = True
    ParentCtl3D = False
    TabOrder = 2
  end
  object TrayIcon: TTrayIcon
    BalloonHint = 'test'
    BalloonTitle = 'asd'
    Icon.Data = {
      0000010001001010000001002000680400001600000028000000100000002000
      0000010020000000000000040000120B0000120B00000000000000000000047F
      BD00047FBD00047FBD00047FBD06047FBD96047FBDFF047FBDFF047FBDFF047F
      BDFF047FBDFF047FBDFF047FBD96047FBD06047FBD00FFFFFF00FFFFFF00047F
      BD00047FBD00047FBD03047FBD963DAAD6FF88E1F6FF88E1F6FF88E1F6FF88E1
      F6FF88E1F6FF88E1F6FF3DAAD6FF047FBD96047FBD06FFFFFF00FFFFFF00047F
      BD00047FBD00047FBD963CA9D6FF88E1F7FF53D3F3FF3BCDF1FF9DE6F8FF9DE6
      F8FF3BCDF1FF53D3F3FF88E1F7FF3DAAD6FF047FBD96047FBD09FFFFFF00047F
      BD00047FBD963BA8D5FF89E2F7FF55D5F3FF3BCEF1FF3BCEF1FF025BA1FF025B
      A2FF3BCEF1FF3BCEF1FF54D4F3FF89E2F7FF3FABD7FF047FBD96047FBD09047F
      BD963CA8D5FF8BE3F7FF5AD7F3FF3DD0F1FF3DD0F1FF3DD0F1FF02589FFF0258
      9FFF3DD0F1FF3DD0F1FF3DD0F1FF54D6F3FF8BE3F7FF40ACD7FF047FBD96047F
      BDFF8CE3F7FF5CD8F4FF3FD1F2FF3FD1F2FF3FD1F2FF3FD1F2FF9FE8F9FF9FE8
      F9FF3FD1F2FF3FD1F2FF3FD1F2FF3FD1F2FF56D6F4FF8CE3F7FF047FBDFF047F
      BDFF8DE4F7FF42D2F2FF41D2F2FF41D2F2FF41D2F2FF41D2F2FF01559DFF0155
      9DFF41D2F2FF41D2F2FF41D2F2FF41D2F2FF42D2F2FF8DE4F7FF047FBDFF047F
      BDFF8FE5F8FF45D3F3FF44D3F3FF44D3F3FF44D3F3FF44D3F3FF01559DFF0153
      9CFF44D3F3FF44D3F3FF44D3F3FF44D3F3FF45D3F3FF8FE5F8FF047FBDFF047F
      BDFF90E6F8FF47D5F4FF46D5F4FF46D5F4FF46D5F4FF46D5F4FF01559DFF0154
      9CFF46D5F4FF46D5F4FF46D5F4FF46D5F4FF47D5F4FF90E6F8FF047FBDFF047F
      BDFF92E6F8FF49D6F4FF48D6F4FF48D6F4FF48D6F4FF48D6F4FF01569DFF0155
      9DFF48D6F4FF48D6F4FF48D6F4FF48D6F4FF49D6F4FF91E6F8FF047FBDFF047F
      BDFCB5EEFAFF6ADEF7FF4AD7F5FF4AD7F5FF4AD7F5FF4AD7F5FF02589FFF0157
      9EFF4AD7F5FF4AD7F5FF4AD7F5FF4AD7F5FF69DEF7FFB7EFFBFF047FBDFF047F
      BD9350ABD5FFB7EFFAFF6CE0F7FF4CD9F5FF4CD9F5FF4CD9F5FF025BA1FF0259
      A0FF4CD9F5FF4CD9F5FF4CD9F5FF6BE0F7FFB9F0FBFF50ABD5FF047FBD96047F
      BD00047FBD9350ABD5FFB8F0FAFF70E1F7FF4EDAF5FF4EDAF5FF4EDAF5FF4EDA
      F5FF4EDAF5FF4EDAF5FF6DE0F7FFB9F1FBFF50ABD5FF047FBD96FFFFFF00047F
      BD00047FBD00047FBD934EAAD4FFB9F0FBFF72E1F8FF50DAF6FF50DAF6FF50DA
      F6FF50DAF6FF6DE0F8FFB9F1FCFF50ABD5FF047FBD96FFFFFF00FFFFFF00047F
      BD00047FBD00047FBD00047FBD934CA9D4FFCEF4FCFFD0F5FDFFD0F5FDFFD0F5
      FDFFD0F5FDFFD0F5FDFF51ABD5FF047FBD96047FBD00FFFFFF00FFFFFF00047F
      BD00047FBD00047FBD00047FBD00047FBD93047FBDFC047FBDFF047FBDFF047F
      BDFF047FBDFF047FBDFF047FBD96047FBD00047FBD00FFFFFF00FFFFFF00E007
      0000C0030000C001000080000000000000000000000000000000000000000000
      000000000000000000000000000080010000C0030000E0070000F00F0000}
    PopupMenu = pmRightClick
    Visible = True
    OnBalloonClick = TrayIconClick
    OnClick = TrayIconClick
    Left = 120
    Top = 96
  end
  object ApplicationEvents1: TApplicationEvents
    Left = 32
    Top = 64
  end
  object SweepTimer: TTimer
    Enabled = False
    Interval = 100
    OnTimer = SweepTimerTimer
    Left = 200
    Top = 64
  end
  object InstanceTimer: TTimer
    Interval = 250
    OnTimer = InstanceTimerTimer
    Left = 32
    Top = 120
  end
  object pmRightClick: TPopupMenu
    Left = 32
    Top = 176
    object miDismissAll: TMenuItem
      Caption = 'Dismiss all'
      OnClick = miDismissAllClick
    end
    object miExit: TMenuItem
      Caption = 'Exit'
      OnClick = miExitClick
    end
  end
end
