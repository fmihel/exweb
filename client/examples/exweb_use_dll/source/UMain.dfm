object frmMain: TfrmMain
  Left = 955
  Top = 258
  Caption = 'exweb 2.0'
  ClientHeight = 678
  ClientWidth = 908
  Color = clBtnFace
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Arial'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 16
  object Splitter1: TSplitter
    Left = 0
    Top = 417
    Width = 908
    Height = 10
    Cursor = crVSplit
    Align = alTop
    ExplicitTop = 385
    ExplicitWidth = 945
  end
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 908
    Height = 417
    ActivePage = TabSheet4
    Align = alTop
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
    ExplicitWidth = 895
    object TabSheet1: TTabSheet
      Caption = '1. '#1055#1086#1076#1082#1083#1102#1095#1077#1085#1080#1077
      ExplicitLeft = 8
      ExplicitTop = 25
      DesignSize = (
        900
        386)
      object Label1: TLabel
        Left = 224
        Top = 21
        Width = 74
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
        Color = clWhite
        DirList = DirectoryListBox1
        TabOrder = 1
      end
      object DllFileName: TEdit
        Left = 224
        Top = 40
        Width = 636
        Height = 24
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 2
        Text = '*.xml'
        ExplicitWidth = 623
      end
      object DirectoryListBox1: TDirectoryListBox
        Left = 225
        Top = 106
        Width = 240
        Height = 263
        Anchors = [akLeft, akTop, akBottom]
        Color = clWhite
        FileList = FileListBox1
        ItemHeight = 16
        TabOrder = 3
      end
      object FileListBox1: TFileListBox
        Left = 480
        Top = 78
        Width = 380
        Height = 291
        Anchors = [akLeft, akTop, akRight, akBottom]
        Color = clWhite
        ItemHeight = 16
        Mask = '*.dll'
        TabOrder = 4
        OnClick = FileListBox1Click
        ExplicitWidth = 367
      end
      object Button14: TButton
        Left = 16
        Top = 96
        Width = 177
        Height = 41
        Action = actDisconnect
        TabOrder = 5
      end
    end
    object TabSheet4: TTabSheet
      Caption = '2. '#1055#1072#1088#1072#1084#1077#1090#1088#1099
      ImageIndex = 1
      ExplicitWidth = 887
      DesignSize = (
        900
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
        Width = 646
        Height = 24
        Anchors = [akLeft, akTop, akRight]
        ItemHeight = 16
        ItemIndex = 0
        TabOrder = 1
        Text = 'http://windeco/exweb/server/'
        Items.Strings = (
          'http://windeco/exweb/server/'
          'https://windeco.su/remote_access_api/exweb/server/index.php')
        ExplicitWidth = 633
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
      Caption = '3. send'
      ImageIndex = 1
      ExplicitWidth = 887
      object PageControl2: TPageControl
        Left = 150
        Top = 0
        Width = 750
        Height = 386
        ActivePage = TabSheet5
        Align = alClient
        TabOrder = 0
        object TabSheet5: TTabSheet
          Caption = #1057#1090#1088#1086#1082#1072' '#1082' '#1086#1090#1087#1088#1072#1074#1082#1077':'
          ExplicitWidth = 692
          DesignSize = (
            742
            355)
          object Edit1: TEdit
            Left = 3
            Top = 16
            Width = 639
            Height = 24
            Anchors = [akLeft, akTop, akRight]
            TabOrder = 0
            Text = '*.xml'
            ExplicitWidth = 665
          end
          object Button19: TButton
            Left = 648
            Top = 13
            Width = 91
            Height = 29
            Action = actNew
            Anchors = [akTop, akRight]
            TabOrder = 1
            ExplicitLeft = 674
          end
          object Memo8: TMemo
            Left = 3
            Top = 46
            Width = 529
            Height = 263
            TabStop = False
            Anchors = [akLeft, akTop, akRight, akBottom]
            Font.Charset = RUSSIAN_CHARSET
            Font.Color = clNavy
            Font.Height = -11
            Font.Name = 'Courier New'
            Font.Style = [fsBold]
            ParentFont = False
            ScrollBars = ssBoth
            TabOrder = 2
            WantTabs = True
            WordWrap = False
            ExplicitWidth = 555
          end
          object FileListBox3: TFileListBox
            Left = 538
            Top = 46
            Width = 201
            Height = 145
            Anchors = [akTop, akRight, akBottom]
            ItemHeight = 16
            Mask = '*.xml'
            TabOrder = 3
            OnDblClick = FileListBox3DblClick
            ExplicitLeft = 564
          end
          object DirectoryListBox3: TDirectoryListBox
            Left = 538
            Top = 199
            Width = 201
            Height = 122
            Anchors = [akRight, akBottom]
            FileList = FileListBox3
            ItemHeight = 16
            TabOrder = 4
            ExplicitLeft = 564
          end
          object DriveComboBox3: TDriveComboBox
            Left = 538
            Top = 327
            Width = 201
            Height = 22
            Anchors = [akRight, akBottom]
            DirList = DirectoryListBox1
            TabOrder = 5
            ExplicitLeft = 564
          end
          object Button18: TButton
            Left = 443
            Top = 315
            Width = 89
            Height = 37
            Action = actClear
            Anchors = [akRight, akBottom]
            TabOrder = 6
            ExplicitLeft = 469
          end
          object Button17: TButton
            Left = 103
            Top = 315
            Width = 98
            Height = 37
            Action = actSaveXMLAs
            Anchors = [akLeft, akBottom]
            TabOrder = 7
          end
          object Button16: TButton
            Left = 3
            Top = 315
            Width = 94
            Height = 37
            Action = actSaveXML
            Anchors = [akLeft, akBottom]
            TabOrder = 8
          end
        end
        object str: TTabSheet
          Caption = #1060#1072#1081#1083' '#1082#1072#1082' '#1073#1080#1085#1072#1088#1085#1099#1077' '#1076#1072#1085#1085#1099#1077' '#1082' '#1086#1090#1087#1088#1072#1074#1082#1077
          ImageIndex = 1
          ExplicitWidth = 692
          DesignSize = (
            742
            355)
          object FileListBox2: TFileListBox
            Left = 3
            Top = 164
            Width = 630
            Height = 176
            Anchors = [akLeft, akTop, akRight, akBottom]
            Color = clInfoBk
            ItemHeight = 16
            TabOrder = 0
            OnClick = FileListBox2Click
          end
          object DirectoryListBox2: TDirectoryListBox
            Left = 2
            Top = 61
            Width = 631
            Height = 97
            Anchors = [akLeft, akTop, akRight]
            Color = clInfoBk
            FileList = FileListBox2
            ItemHeight = 16
            TabOrder = 1
          end
          object DriveComboBox2: TDriveComboBox
            Left = 3
            Top = 33
            Width = 630
            Height = 22
            Anchors = [akLeft, akTop, akRight]
            Color = clInfoBk
            DirList = DirectoryListBox2
            TabOrder = 2
          end
          object Button4: TButton
            Left = 648
            Top = 33
            Width = 91
            Height = 25
            Anchors = [akTop, akRight]
            Caption = 'clear'
            TabOrder = 3
            OnClick = Button4Click
            ExplicitLeft = 598
          end
          object StreamSend: TEdit
            Left = 3
            Top = 3
            Width = 736
            Height = 24
            Anchors = [akLeft, akTop, akRight]
            TabOrder = 4
            ExplicitWidth = 686
          end
        end
      end
      object Panel2: TPanel
        Left = 0
        Top = 0
        Width = 150
        Height = 386
        Align = alLeft
        BevelOuter = bvNone
        Caption = 'Panel2'
        ShowCaption = False
        TabOrder = 1
        object Button2: TButton
          Left = 15
          Top = 11
          Width = 129
          Height = 41
          Action = actSend
          TabOrder = 0
        end
      end
    end
    object TabSheet3: TTabSheet
      Caption = '4. recv'
      ImageIndex = 2
      ExplicitWidth = 887
      DesignSize = (
        900
        386)
      object Label4: TLabel
        Left = 240
        Top = 16
        Width = 106
        Height = 16
        Caption = #1057#1095#1080#1090#1072#1085#1085#1072#1103' '#1089#1090#1088#1086#1082#1072
      end
      object Label5: TLabel
        Left = 240
        Top = 176
        Width = 113
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
        Width = 613
        Height = 121
        Anchors = [akLeft, akTop, akRight]
        Lines.Strings = (
          'StrRecv')
        ScrollBars = ssBoth
        TabOrder = 1
        ExplicitWidth = 600
      end
      object StreamRecv: TMemo
        Left = 240
        Top = 208
        Width = 613
        Height = 153
        Anchors = [akLeft, akTop, akRight, akBottom]
        Lines.Strings = (
          'StreamRecv')
        ScrollBars = ssBoth
        TabOrder = 2
        ExplicitWidth = 600
      end
    end
    object TabSheet7: TTabSheet
      Caption = 'Auto test'
      ImageIndex = 4
      ExplicitWidth = 887
      object Label2: TLabel
        Left = 208
        Top = 32
        Width = 103
        Height = 16
        Caption = #1055#1088#1086#1096#1083#1086' '#1074#1088#1077#1084#1077#1085#1080
      end
      object Label3: TLabel
        Left = 208
        Top = 80
        Width = 71
        Height = 16
        Caption = #1054#1090#1087#1088#1072#1074#1083#1077#1085#1086
      end
      object Button12: TButton
        Left = 24
        Top = 32
        Width = 161
        Height = 49
        Action = actStartTest
        TabOrder = 0
      end
      object Button13: TButton
        Left = 24
        Top = 87
        Width = 161
        Height = 49
        Action = actStopTest
        TabOrder = 1
      end
      object edTime: TEdit
        Left = 208
        Top = 51
        Width = 273
        Height = 24
        TabOrder = 2
      end
      object edCountAuto: TEdit
        Left = 208
        Top = 99
        Width = 273
        Height = 24
        TabOrder = 3
      end
    end
  end
  object MemoLog: TMemo
    Left = 0
    Top = 427
    Width = 908
    Height = 251
    Align = alClient
    Color = 15790320
    Lines.Strings = (
      'MemoLog')
    ScrollBars = ssBoth
    TabOrder = 1
    ExplicitWidth = 895
  end
  object ActionList1: TActionList
    OnUpdate = ActionList1Update
    Left = 832
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
    object actStartTest: TAction
      Caption = 'Start Test'
      OnExecute = actStartTestExecute
    end
    object actStopTest: TAction
      Caption = 'Stop Test'
      OnExecute = actStopTestExecute
    end
    object actDisconnect: TAction
      Caption = 'Disconnect'
      OnExecute = actDisconnectExecute
    end
    object actSaveXMLAs: TAction
      Caption = 'Save XML as'
      OnExecute = actSaveXMLAsExecute
    end
    object actSaveXML: TAction
      Caption = 'Save XML'
      OnExecute = actSaveXMLExecute
    end
    object actClear: TAction
      Caption = 'clear'
      OnExecute = actClearExecute
    end
    object actNew: TAction
      Caption = 'new'
      OnExecute = actNewExecute
    end
  end
  object Timer1: TTimer
    Enabled = False
    OnTimer = Timer1Timer
    Left = 756
    Top = 6
  end
  object SaveDialog1: TSaveDialog
    DefaultExt = 'xml'
    Filter = '*.xml'
    Left = 432
    Top = 448
  end
end
