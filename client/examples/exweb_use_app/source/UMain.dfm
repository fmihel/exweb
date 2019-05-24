object frmMain: TfrmMain
  Left = 1129
  Top = 90
  Anchors = [akLeft, akTop, akRight]
  Caption = 'exweb 2.0 test'
  ClientHeight = 727
  ClientWidth = 658
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PrintScale = poNone
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 16
  object Splitter1: TSplitter
    Left = 0
    Top = 409
    Width = 658
    Height = 10
    Cursor = crVSplit
    Align = alBottom
    ExplicitTop = 377
    ExplicitWidth = 689
  end
  object GroupBox1: TGroupBox
    Left = 0
    Top = 9
    Width = 658
    Height = 72
    Align = alTop
    Caption = #1054#1073#1097#1080#1077' '#1085#1072#1089#1090#1088#1086#1081#1082#1080
    TabOrder = 0
    DesignSize = (
      658
      72)
    object Label1: TLabel
      Left = 13
      Top = 32
      Width = 90
      Height = 16
      Caption = #1040#1076#1088#1077#1089' '#1089#1082#1088#1080#1087#1090#1072':'
    end
    object Addr: TComboBox
      Left = 109
      Top = 29
      Width = 533
      Height = 24
      Anchors = [akLeft, akTop, akRight]
      ItemHeight = 16
      ItemIndex = 0
      TabOrder = 0
      Text = 'http://windeco/exweb/server/'
      Items.Strings = (
        'http://windeco/exweb/server/')
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 658
    Height = 9
    Align = alTop
    BevelOuter = bvNone
    Caption = 'Panel1'
    Ctl3D = True
    ParentCtl3D = False
    ShowCaption = False
    TabOrder = 1
  end
  object PageControl1: TPageControl
    Left = 0
    Top = 81
    Width = 658
    Height = 328
    ActivePage = TabSheet1
    Align = alClient
    TabOrder = 2
    object TabSheet1: TTabSheet
      Caption = 'Send'
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object Label2: TLabel
        Left = 16
        Top = 16
        Width = 116
        Height = 16
        Caption = #1058#1077#1082#1089#1090' '#1076#1083#1103' '#1086#1090#1087#1088#1072#1074#1082#1080
      end
      object Label3: TLabel
        Left = 272
        Top = 16
        Width = 234
        Height = 16
        Caption = #1060#1072#1081#1083' '#1076#1083#1103' '#1086#1090#1087#1088#1072#1074#1082#1080' ('#1073#1080#1085#1072#1088#1085#1099#1077' '#1076#1072#1085#1085#1099#1077')'
      end
      object Memo1: TMemo
        Left = 16
        Top = 35
        Width = 233
        Height = 215
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        Lines.Strings = (
          'This text will sending...'
          #1069#1090#1086#1090' '#1090#1077#1082#1089#1090' '#1073#1091#1076#1077#1090' '#1086#1090#1087#1088#1072#1074#1083#1077#1085'..'
          '01234567890'
          '-+\/=!@#$%^&()[]{} "" '#39#39' ;:><?/_'
          'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
          'abcdefghijklmnopqrstuvwxyz'
          #1040#1041#1042#1043#1044#1045#1025#1046#1047#1048#1049#1050#1051#1052#1053#1054#1055#1056#1057#1058#1059#1060#1061#1062#1063#1064#1065#1066#1067#1068#1069#1070#1071
          #1072#1073#1074#1075#1076#1077#1105#1078#1079#1080#1081#1082#1083#1084#1085#1086#1087#1088#1089#1090#1091#1092#1093#1094#1095#1096#1097#1098#1099#1100#1101#1102#1103)
        ParentFont = False
        TabOrder = 0
        WordWrap = False
      end
      object Button2: TButton
        Left = 272
        Top = 253
        Width = 113
        Height = 25
        Action = actSendStream
        TabOrder = 1
      end
      object DriveComboBox1: TDriveComboBox
        Left = 272
        Top = 35
        Width = 337
        Height = 22
        DirList = DirectoryListBox1
        TabOrder = 2
      end
      object DirectoryListBox1: TDirectoryListBox
        Left = 272
        Top = 63
        Width = 337
        Height = 58
        FileList = FileListBox1
        ItemHeight = 16
        TabOrder = 3
      end
      object FileListBox1: TFileListBox
        Left = 272
        Top = 127
        Width = 337
        Height = 90
        FileEdit = Edit1
        ItemHeight = 16
        TabOrder = 4
      end
      object Edit1: TEdit
        Left = 272
        Top = 223
        Width = 337
        Height = 24
        TabOrder = 5
        Text = '*.*'
      end
      object Button3: TButton
        Left = 16
        Top = 256
        Width = 104
        Height = 25
        Action = actSendStr
        TabOrder = 6
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'Get'
      ImageIndex = 1
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      DesignSize = (
        650
        297)
      object Label4: TLabel
        Left = 16
        Top = 24
        Width = 113
        Height = 16
        Caption = 'Stream save to file:'
      end
      object Label5: TLabel
        Left = 16
        Top = 64
        Width = 39
        Height = 16
        Caption = 'String:'
      end
      object Button4: TButton
        Left = 16
        Top = 256
        Width = 75
        Height = 25
        Action = actGet
        Anchors = [akLeft, akBottom]
        TabOrder = 0
      end
      object edFileName: TEdit
        Left = 135
        Top = 21
        Width = 489
        Height = 24
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 1
        Text = 'c:\test.bin'
      end
      object Memo2: TMemo
        Left = 135
        Top = 64
        Width = 489
        Height = 153
        Anchors = [akLeft, akTop, akRight, akBottom]
        Lines.Strings = (
          '')
        TabOrder = 2
      end
    end
  end
  object GroupBox2: TGroupBox
    Left = 0
    Top = 419
    Width = 658
    Height = 308
    Align = alBottom
    Caption = 'Log'
    TabOrder = 3
    object LogMemo: TMemo
      Left = 2
      Top = 49
      Width = 654
      Height = 257
      Align = alClient
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      Lines.Strings = (
        'LogMemo'
        
          'qwe w kjqwek djkqjwd kh qwkjehd kj hk  qkjhdkw k kjhkjhq kqjdh k' +
          'jk k kqjh kewdk kq kwe jd')
      ParentFont = False
      ScrollBars = ssBoth
      TabOrder = 0
      WordWrap = False
    end
    object Panel2: TPanel
      Left = 2
      Top = 18
      Width = 654
      Height = 31
      Align = alTop
      BevelOuter = bvNone
      Caption = 'Panel2'
      ShowCaption = False
      TabOrder = 1
    end
    object Button1: TButton
      Left = 20
      Top = 18
      Width = 75
      Height = 25
      Action = actClearLog
      TabOrder = 2
    end
  end
  object ActionList1: TActionList
    Left = 576
    Top = 16
    object actClearLog: TAction
      Caption = 'clear'
      OnExecute = actClearLogExecute
    end
    object actSendStream: TAction
      Caption = 'send stream'
      OnExecute = actSendStreamExecute
    end
    object actSendStr: TAction
      Caption = 'send only str'
      OnExecute = actSendStrExecute
    end
    object actGet: TAction
      Caption = 'get'
      OnExecute = actGetExecute
    end
  end
end
