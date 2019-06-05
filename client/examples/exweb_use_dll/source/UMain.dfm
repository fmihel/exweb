object frmMain: TfrmMain
  Left = 893
  Top = 207
  Caption = 'exweb 2.0'
  ClientHeight = 690
  ClientWidth = 895
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
    ParentShowHint = False
    ShowHint = True
    Style = tsButtons
    TabOrder = 0
    object TabSheet1: TTabSheet
      Caption = '1. '#1055#1086#1076#1082#1083#1102#1095#1077#1085#1080#1077
      DesignSize = (
        887
        383)
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
        Color = clInfoBk
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
        Left = 225
        Top = 106
        Width = 240
        Height = 260
        Anchors = [akLeft, akTop, akBottom]
        Color = clInfoBk
        FileList = FileListBox1
        ItemHeight = 16
        TabOrder = 3
      end
      object FileListBox1: TFileListBox
        Left = 480
        Top = 78
        Width = 367
        Height = 288
        Anchors = [akLeft, akTop, akRight, akBottom]
        Color = clInfoBk
        ItemHeight = 16
        Mask = '*.dll'
        TabOrder = 4
        OnClick = FileListBox1Click
      end
    end
    object TabSheet4: TTabSheet
      Caption = '2. '#1055#1072#1088#1072#1084#1077#1090#1088#1099
      ImageIndex = 1
      DesignSize = (
        887
        383)
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
      Caption = '3. send'
      ImageIndex = 1
      object PageControl2: TPageControl
        Left = 187
        Top = 0
        Width = 700
        Height = 383
        ActivePage = TabSheet5
        Align = alClient
        TabOrder = 0
        object TabSheet5: TTabSheet
          Caption = #1057#1090#1088#1086#1082#1072' '#1082' '#1086#1090#1087#1088#1072#1074#1082#1077':'
          object StrSend: TMemo
            Left = 145
            Top = 0
            Width = 547
            Height = 352
            Align = alClient
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
            TabOrder = 0
          end
          object Panel1: TPanel
            Left = 0
            Top = 0
            Width = 145
            Height = 352
            Align = alLeft
            BevelOuter = bvNone
            Caption = 'Panel1'
            ShowCaption = False
            TabOrder = 1
            object Button7: TButton
              Left = 2
              Top = 124
              Width = 137
              Height = 25
              Caption = 'sendPassToClient'
              TabOrder = 0
              OnClick = Button7Click
            end
            object Button8: TButton
              Left = 2
              Top = 0
              Width = 137
              Height = 25
              Caption = 'clientUpdate'
              TabOrder = 1
              OnClick = Button8Click
            end
            object Button9: TButton
              Left = 2
              Top = 31
              Width = 137
              Height = 25
              Caption = 'addr_dost'
              TabOrder = 2
              OnClick = Button9Click
            end
            object Button10: TButton
              Left = 2
              Top = 62
              Width = 137
              Height = 25
              Caption = 'ostKarniz'
              TabOrder = 3
              OnClick = Button10Click
            end
            object Button11: TButton
              Left = 2
              Top = 93
              Width = 137
              Height = 25
              Caption = 'ostTkani'
              TabOrder = 4
              OnClick = Button11Click
            end
          end
        end
        object str: TTabSheet
          Caption = #1060#1072#1081#1083' '#1082#1072#1082' '#1073#1080#1085#1072#1088#1085#1099#1077' '#1076#1072#1085#1085#1099#1077' '#1082' '#1086#1090#1087#1088#1072#1074#1082#1077
          ImageIndex = 1
          DesignSize = (
            692
            352)
          object FileListBox2: TFileListBox
            Left = 3
            Top = 164
            Width = 541
            Height = 173
            Anchors = [akLeft, akTop, akRight, akBottom]
            Color = clInfoBk
            ItemHeight = 16
            TabOrder = 0
            OnClick = FileListBox2Click
          end
          object DirectoryListBox2: TDirectoryListBox
            Left = 3
            Top = 61
            Width = 541
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
            Width = 541
            Height = 22
            Anchors = [akLeft, akTop, akRight]
            Color = clInfoBk
            DirList = DirectoryListBox2
            TabOrder = 2
          end
          object Button4: TButton
            Left = 598
            Top = 33
            Width = 91
            Height = 25
            Anchors = [akTop, akRight]
            Caption = 'clear'
            TabOrder = 3
            OnClick = Button4Click
          end
          object StreamSend: TEdit
            Left = 3
            Top = 3
            Width = 686
            Height = 24
            Anchors = [akLeft, akTop, akRight]
            TabOrder = 4
          end
        end
        object TabSheet6: TTabSheet
          Caption = 'TabSheet6'
          Font.Charset = RUSSIAN_CHARSET
          Font.Color = clWindowText
          Font.Height = -8
          Font.Name = 'Small Fonts'
          Font.Style = []
          ImageIndex = 2
          ParentFont = False
          object Memo1: TMemo
            Left = 3
            Top = 19
            Width = 126
            Height = 78
            Font.Charset = RUSSIAN_CHARSET
            Font.Color = clWindowText
            Font.Height = -8
            Font.Name = 'Small Fonts'
            Font.Style = []
            Lines.Strings = (
              '<?xml version="1.0" encoding="unicode"?>'#9
              '<Msg Kind="3" Action="1" Ver='#8221'1">'#9
              '<List>'#9
              '<Tovar Id=" 33197" Ost="2" Kind='#8221'0'#8221' Deliv='#8221'01.03.2011'#8221'/>  '#9
              '<Tovar Id=" 33193" Ost="0" Kind='#8221'1'#8221' Deliv='#8221'01.03.2011'#8221'/>'#9
              ' </List>'
              '</Msg>')
            ParentFont = False
            TabOrder = 0
            WordWrap = False
          end
          object Memo2: TMemo
            Left = 143
            Top = 19
            Width = 138
            Height = 78
            Font.Charset = RUSSIAN_CHARSET
            Font.Color = clWindowText
            Font.Height = -8
            Font.Name = 'Small Fonts'
            Font.Style = []
            Lines.Strings = (
              '<?xml version="1.0" encoding="unicode" Ver="1"?>'
              '<Msg Kind="2" Action="1" >'
              #9'<KlientInfo>'
              #9#9'<AdresatKind>3</AdresatKind>'
              #9#9'<KlientId>175</KlientId>'
              '                 '#9'<KlientName>ccccccc</KlientName>'
              #9#9'<RemoteAccess>1</RemoteAccess>'
              #9#9'<EMail>123@mail.ru</EMail>'
              #9#9'< DecoRMail>123@mail.ru</DecoRMail >'
              #9#9'<Arch>0</Arch>'
              #9'</KlientInfo>'
              '</Msg>')
            ParentFont = False
            TabOrder = 1
            WordWrap = False
          end
          object Memo3: TMemo
            Left = 287
            Top = 19
            Width = 146
            Height = 78
            Lines.Strings = (
              '<?xml version="1.0" encoding="unicode"?>'#9
              '<Msg Kind="2" Action="3" Ver="1">'#9
              '<KlientName>"'#1055#1083#1072#1085#1077#1090#1072'"</KlientName>'#9
              '<BossPost>'#1043#1077#1085#1077#1088#1072#1083#1100#1085#1099#1081' '#1076#1080#1088#1077#1082#1090#1086#1088'</BossPost>'#9
              '<BossName>'#1048#1074#1072#1085#1086#1074' '#1048'.'#1048'.</BossName>'#9
              '<KindOplata>1</KindOplata>'#9
              '<DbNum>6</DbNum>'#9
              '<List>'#9
              
                '  <Addr Id="9834" Txt="'#1075'.'#1058#1074#1077#1088#1100', '#1091#1083'. '#1053#1072#1073#1077#1088#1077#1078#1085#1072#1103' 25 '#1082' 4. '#1090#1077#1083' 123-4' +
                '5-67 '#1054#1083#1077#1075'"/>'#9
              
                '  <Addr Id="9835" Txt="'#1075'.'#1058#1074#1077#1088#1100', '#1091#1083'. '#1053#1072#1073#1077#1088#1077#1078#1085#1072#1103' 25 '#1082' 4. '#1090#1077#1083' 123-4' +
                '5-67 '#1054#1083#1077#1075'"/>'#9
              
                '  <Addr Id="9836" Txt="'#1075'.'#1058#1074#1077#1088#1100', '#1091#1083'. '#1053#1072#1073#1077#1088#1077#1078#1085#1072#1103' 25 '#1082' 4. '#1090#1077#1083' 123-4' +
                '5-67 '#1054#1083#1077#1075'"/>'#9
              '</List>'#9
              '<EnableDiscont>1</EnableDiscont>'#9
              '<ShowImmediatly>1</ShowImmediatly>'#9
              '<UserId>17</UserId>'#9
              '</Msg>'#9)
            TabOrder = 2
            WordWrap = False
          end
          object Memo4: TMemo
            Left = 439
            Top = 19
            Width = 161
            Height = 78
            Lines.Strings = (
              '<?xml version="1.0" encoding="unicode"?>'#9
              '<Msg Kind="3" Action="1" Ver="1">'#9
              ' <List>'#9
              '<Tovar Id=" 33197" Ost="2" Kind="0" Deliv="01.03.2011"/>  '#9
              '<Tovar Id=" 33198" Ost="5" Kind="1" Deliv="01.03.2011"/>  '#9
              '<Tovar Id=" 33199" Ost="9" Kind="1" Deliv="01.03.2011"/>  '#9
              '</List>'#9
              '</Msg>'#9)
            TabOrder = 3
            WordWrap = False
          end
          object Memo5: TMemo
            Left = 3
            Top = 115
            Width = 158
            Height = 86
            Lines.Strings = (
              '<?xml version="1.0" encoding="unicode"?>'
              '<Msg Kind="8" Action="1">'
              ' <TxProductsList>'
              '  <TxProduct IdTextile="15595" IdTxColor="27332" Ostatok="0">'
              
                '   <TxPiece IdTxPiece="213473" Nom="783" Ostatok="0" Bronir="24,' +
                '5"/>'
              '  </TxProduct>'
              ' </TxProductsList>'
              '</Msg>')
            TabOrder = 4
            WordWrap = False
          end
          object Memo6: TMemo
            Left = 184
            Top = 115
            Width = 185
            Height = 89
            Lines.Strings = (
              '<?xml version="1.0" encoding="unicode" '
              'Ver='#8221'1'#8221'?>'
              '<Msg Kind="2" Action="4" >'
              #9'<KlientId>175</KlientId>'
              #9'<DestKind>1</ DestKind >'
              '</Msg>')
            TabOrder = 5
          end
        end
      end
      object Panel2: TPanel
        Left = 0
        Top = 0
        Width = 187
        Height = 383
        Align = alLeft
        BevelOuter = bvNone
        Caption = 'Panel2'
        ShowCaption = False
        TabOrder = 1
        object Button2: TButton
          Left = 4
          Top = 19
          Width = 177
          Height = 41
          Action = actSend
          TabOrder = 0
        end
      end
    end
    object TabSheet3: TTabSheet
      Caption = '4. recv'
      ImageIndex = 2
      DesignSize = (
        887
        383)
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
        Height = 150
        Anchors = [akLeft, akTop, akRight, akBottom]
        Lines.Strings = (
          'StreamRecv')
        ScrollBars = ssBoth
        TabOrder = 2
      end
    end
    object TabSheet7: TTabSheet
      Caption = 'Auto test'
      ImageIndex = 4
      ExplicitLeft = 8
      ExplicitTop = 28
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
    Width = 895
    Height = 263
    Align = alClient
    Color = 15790320
    Lines.Strings = (
      'MemoLog')
    ScrollBars = ssBoth
    TabOrder = 1
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
  end
  object Timer1: TTimer
    Enabled = False
    OnTimer = Timer1Timer
    Left = 244
    Top = 174
  end
end
