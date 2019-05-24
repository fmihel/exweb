object frmMain: TfrmMain
  Left = 825
  Top = 42
  Caption = 'exweb 2.0'
  ClientHeight = 690
  ClientWidth = 895
  Color = clBtnFace
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Courier New'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesigned
  Scaled = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 16
  object Splitter1: TSplitter
    Left = 0
    Top = 417
    Width = 895
    Height = 10
    Cursor = crVSplit
    Align = alTop
    ExplicitTop = 385
    ExplicitWidth = 945
  end
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 895
    Height = 417
    ActivePage = TabSheet1
    Align = alTop
    TabOrder = 0
    ExplicitWidth = 990
    object TabSheet1: TTabSheet
      Caption = #1055#1086#1076#1082#1083#1102#1095#1077#1085#1080#1077
      DesignSize = (
        887
        386)
      object Label1: TLabel
        Left = 224
        Top = 21
        Width = 96
        Height = 16
        Caption = 'DllFileName:'
      end
      object Button1: TButton
        Left = 16
        Top = 32
        Width = 177
        Height = 41
        Action = actConnect
        TabOrder = 0
      end
      object DriveComboBox1: TDriveComboBox
        Left = 224
        Top = 78
        Width = 241
        Height = 22
        DirList = DirectoryListBox1
        TabOrder = 1
      end
      object DllFileName: TEdit
        Left = 224
        Top = 40
        Width = 623
        Height = 24
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 2
        Text = '*.dll'
      end
      object DirectoryListBox1: TDirectoryListBox
        Left = 224
        Top = 106
        Width = 240
        Height = 263
        Anchors = [akLeft, akTop, akBottom]
        FileList = FileListBox1
        ItemHeight = 16
        TabOrder = 3
      end
      object FileListBox1: TFileListBox
        Left = 480
        Top = 78
        Width = 367
        Height = 291
        Anchors = [akLeft, akTop, akRight, akBottom]
        ItemHeight = 16
        Mask = '*.dll'
        TabOrder = 4
        OnClick = FileListBox1Click
      end
    end
    object TabSheet4: TTabSheet
      Caption = #1055#1072#1088#1072#1084#1077#1090#1088#1099
      ImageIndex = 1
      ExplicitLeft = 8
      ExplicitTop = 25
      ExplicitWidth = 941
      ExplicitHeight = 354
      DesignSize = (
        887
        386)
      object Button3: TButton
        Left = 16
        Top = 32
        Width = 177
        Height = 41
        Action = actSetUrl
        TabOrder = 0
      end
      object Url: TComboBox
        Left = 216
        Top = 40
        Width = 633
        Height = 24
        Anchors = [akLeft, akTop, akRight]
        ItemHeight = 16
        ItemIndex = 1
        TabOrder = 1
        Text = 'http://windeco/exweb/server/'
        Items.Strings = (
          'https://windeco.su/exweb'
          'http://windeco/exweb/server/')
      end
      object Key: TEdit
        Left = 216
        Top = 104
        Width = 633
        Height = 24
        TabOrder = 2
        Text = 'jqwed67dec'
      end
      object Button6: TButton
        Left = 16
        Top = 96
        Width = 177
        Height = 41
        Action = actSetKey
        TabOrder = 3
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'send'
      ImageIndex = 1
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 941
      ExplicitHeight = 378
      DesignSize = (
        887
        386)
      object Label2: TLabel
        Left = 248
        Top = 16
        Width = 144
        Height = 16
        Caption = #1057#1090#1088#1086#1082#1072' '#1082' '#1086#1090#1087#1088#1072#1074#1082#1077':'
      end
      object Label3: TLabel
        Left = 536
        Top = 16
        Width = 280
        Height = 16
        Caption = #1060#1072#1081#1083' '#1082#1072#1082' '#1073#1080#1085#1072#1088#1085#1099#1077' '#1076#1072#1085#1085#1099#1077' '#1082' '#1086#1090#1087#1088#1072#1074#1082#1077
      end
      object Button2: TButton
        Left = 16
        Top = 32
        Width = 177
        Height = 41
        Action = actSend
        TabOrder = 0
      end
      object StrSend: TMemo
        Left = 248
        Top = 40
        Width = 273
        Height = 329
        Anchors = [akLeft, akTop, akBottom]
        Lines.Strings = (
          'This text will sending...'
          #1069#1090#1086#1090' '#1090#1077#1082#1089#1090' '#1073#1091#1076#1077#1090' '#1086#1090#1087#1088#1072#1074#1083#1077#1085'..'
          '01234567890'
          '-+\/=!@#$%^&()[]{} "" '#39#39' ;:><?/_'
          'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
          'abcdefghijklmnopqrstuvwxyz'
          #1040#1041#1042#1043#1044#1045#1025#1046#1047#1048#1049#1050#1051#1052#1053#1054#1055#1056#1057#1058#1059#1060#1061#1062#1063#1064#1065#1066#1067#1068#1069#1070#1071
          #1072#1073#1074#1075#1076#1077#1105#1078#1079#1080#1081#1082#1083#1084#1085#1086#1087#1088#1089#1090#1091#1092#1093#1094#1095#1096#1097#1098#1099#1100#1101#1102#1103)
        ScrollBars = ssBoth
        TabOrder = 1
      end
      object StreamSend: TEdit
        Left = 536
        Top = 40
        Width = 226
        Height = 24
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 2
      end
      object DriveComboBox2: TDriveComboBox
        Left = 536
        Top = 80
        Width = 323
        Height = 22
        Anchors = [akLeft, akTop, akRight]
        DirList = DirectoryListBox2
        TabOrder = 3
      end
      object DirectoryListBox2: TDirectoryListBox
        Left = 536
        Top = 108
        Width = 323
        Height = 97
        Anchors = [akLeft, akTop, akRight]
        FileList = FileListBox2
        ItemHeight = 16
        TabOrder = 4
      end
      object FileListBox2: TFileListBox
        Left = 536
        Top = 211
        Width = 323
        Height = 158
        Anchors = [akLeft, akTop, akRight, akBottom]
        ItemHeight = 16
        TabOrder = 5
        OnClick = FileListBox2Click
      end
      object Button4: TButton
        Left = 768
        Top = 40
        Width = 91
        Height = 25
        Anchors = [akTop, akRight]
        Caption = 'clear'
        TabOrder = 6
        OnClick = Button4Click
      end
    end
    object TabSheet3: TTabSheet
      Caption = 'recv'
      ImageIndex = 2
      ExplicitLeft = 8
      ExplicitTop = 25
      ExplicitWidth = 936
      ExplicitHeight = 354
      DesignSize = (
        887
        386)
      object Label4: TLabel
        Left = 240
        Top = 16
        Width = 128
        Height = 16
        Caption = #1057#1095#1080#1090#1072#1085#1085#1072#1103' '#1089#1090#1088#1086#1082#1072
      end
      object Label5: TLabel
        Left = 240
        Top = 176
        Width = 128
        Height = 16
        Caption = #1041#1080#1085#1072#1088#1085#1099#1077' '#1076#1072#1085#1085#1099#1077':'
      end
      object Button5: TButton
        Left = 16
        Top = 32
        Width = 177
        Height = 41
        Action = actRecv
        TabOrder = 0
      end
      object StrRecv: TMemo
        Left = 240
        Top = 40
        Width = 600
        Height = 121
        Anchors = [akLeft, akTop, akRight]
        Lines.Strings = (
          'StrRecv')
        ScrollBars = ssBoth
        TabOrder = 1
      end
      object StreamRecv: TMemo
        Left = 240
        Top = 208
        Width = 600
        Height = 153
        Anchors = [akLeft, akTop, akRight, akBottom]
        Lines.Strings = (
          'StreamRecv')
        ScrollBars = ssBoth
        TabOrder = 2
      end
    end
  end
  object MemoLog: TMemo
    Left = 0
    Top = 427
    Width = 895
    Height = 263
    Align = alClient
    Lines.Strings = (
      'MemoLog')
    ScrollBars = ssBoth
    TabOrder = 1
  end
  object ActionList1: TActionList
    OnUpdate = ActionList1Update
    Left = 736
    Top = 8
    object actConnect: TAction
      Caption = 'Connect'
      OnExecute = actConnectExecute
    end
    object actSend: TAction
      Caption = 'send'
      OnExecute = actSendExecute
    end
    object actRecv: TAction
      Caption = 'recv'
      OnExecute = actRecvExecute
    end
    object actSetUrl: TAction
      Caption = 'set url of script'
      OnExecute = actSetUrlExecute
    end
    object actSetKey: TAction
      Caption = 'set autorize key'
      OnExecute = actSetKeyExecute
    end
  end
end
