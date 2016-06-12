object FMain: TFMain
  Left = 0
  Top = 0
  BorderStyle = bsSizeToolWin
  ClientHeight = 412
  ClientWidth = 418
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  Menu = MainMenu1
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 13
  object pFondo: TPanel
    Left = 0
    Top = 0
    Width = 418
    Height = 412
    Align = alClient
    BevelInner = bvLowered
    DoubleBuffered = True
    ParentBackground = False
    ParentDoubleBuffered = False
    TabOrder = 0
  end
  object MainMenu1: TMainMenu
    Left = 160
    Top = 136
    object Gioco1: TMenuItem
      Caption = 'Gioco'
      object Inizio1: TMenuItem
        Caption = 'Inizio'
        OnClick = Inizio1Click
      end
      object testanteprima1: TMenuItem
        Caption = 'test anteprima'
      end
    end
    object Uscita1: TMenuItem
      Caption = 'Uscita'
      OnClick = Uscita1Click
    end
  end
  object Timer: TTimer
    Enabled = False
    OnTimer = TimerTimer
    Left = 200
    Top = 224
  end
end
