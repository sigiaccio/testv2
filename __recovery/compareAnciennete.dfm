object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 769
  ClientWidth = 728
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object lbldev: TLabel
    Left = 152
    Top = 24
    Width = 30
    Height = 19
    Caption = 'DEV'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object lblprod: TLabel
    Left = 536
    Top = 24
    Width = 42
    Height = 19
    Caption = 'PROD'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object lblrecordDev: TLabel
    Left = 216
    Top = 24
    Width = 60
    Height = 13
    Caption = 'lblrecordDev'
  end
  object lblrecordProd: TLabel
    Left = 657
    Top = 24
    Width = 63
    Height = 26
    Caption = 'lblrecordProd'#13#10
  end
  object gridProd: TDBGrid
    Left = 384
    Top = 56
    Width = 320
    Height = 425
    DataSource = DSPROD
    TabOrder = 0
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
    Columns = <
      item
        Expanded = False
        FieldName = 'ID_PERS'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'ANNEE_SCOL'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'ANC_SERV'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'ANC_EPFC'
        Visible = True
      end>
  end
  object DBGrid2: TDBGrid
    Left = 8
    Top = 487
    Width = 696
    Height = 274
    DataSource = DSDEV
    TabOrder = 1
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
  end
  object btnCompare: TButton
    Left = 320
    Top = 8
    Width = 75
    Height = 25
    Caption = 'btnCompare'
    TabOrder = 2
    OnClick = btnCompareClick
  end
  object gridDev: TwwDBGrid
    Left = 8
    Top = 56
    Width = 337
    Height = 425
    Selected.Strings = (
      'ID_PERS'#9'7'#9'ID_PERS'#9#9
      'ANNEE_SCOL'#9'10'#9'ANNEE_SCOL'#9#9
      'ANC_SERV'#9'10'#9'ANC_SERV'#9#9
      'ANC_EPFC'#9'10'#9'ANC_EPFC'#9#9)
    IniAttributes.Delimiter = ';;'
    IniAttributes.UnicodeIniFile = False
    TitleColor = clBtnFace
    FixedCols = 0
    ShowHorzScrollBar = True
    DataSource = DSDEV
    TabOrder = 3
    TitleAlignment = taLeftJustify
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
    TitleLines = 1
    TitleButtons = False
  end
  object qry_dev: TIBOQuery
    KeyLinks.Strings = (
      'DET_ANC.ID_PERS')
    RecordCountAccurate = True
    SQL.Strings = (
      'select'
      '  ID_PERS, annee_scol, anc_serv,anc_epfc'
      'from'
      '  DET_ANC'
      '/*where'
      '  ID_PERS = :PIdPers*/')
    Left = 16
    Top = 8
    object qry_devID_PERS: TStringField
      DisplayWidth = 7
      FieldName = 'ID_PERS'
      Required = True
      Size = 7
    end
    object qry_devANNEE_SCOL: TIntegerField
      DisplayWidth = 10
      FieldName = 'ANNEE_SCOL'
      Required = True
    end
    object qry_devANC_SERV: TIntegerField
      DisplayWidth = 10
      FieldName = 'ANC_SERV'
    end
    object qry_devANC_EPFC: TIntegerField
      DisplayWidth = 10
      FieldName = 'ANC_EPFC'
    end
  end
  object DSDEV: TDataSource
    DataSet = qry_dev
    Left = 72
    Top = 8
  end
  object tiboDB_PROD: TIBODatabase
    CacheStatementHandles = False
    SQLDialect = 3
    Params.Strings = (
      'SERVER=isis.epfc.local'
      'PROTOCOL=TCP/IP'
      'PATH=C:\EPFC1920.fdb'
      'USER NAME=SYSDBA')
    Isolation = tiCommitted
    DriverName = ''
    Left = 608
    Top = 8
    SavedPassword = '.JuMbLe.01.4B3A132E012A154B'
  end
  object DSPROD: TDataSource
    DataSet = qry_prod
    Left = 400
    Top = 8
  end
  object qry_prod: TIBOQuery
    IB_Connection = tiboDB_PROD
    KeyLinks.Strings = (
      'DET_ANC.ID_PERS')
    RecordCountAccurate = True
    SQL.Strings = (
      'select'
      '  ID_PERS, annee_scol, anc_serv,anc_epfc'
      'from'
      '  DET_ANC'
      '/*where'
      '  ID_PERS = :PIdPers*/')
    Left = 488
    Top = 8
    object qry_prodID_PERS: TStringField
      FieldName = 'ID_PERS'
      Required = True
      Size = 7
    end
    object qry_prodANNEE_SCOL: TIntegerField
      FieldName = 'ANNEE_SCOL'
      Required = True
    end
    object qry_prodANC_SERV: TIntegerField
      FieldName = 'ANC_SERV'
      Origin = 'DET_ANC.ANC_SERV'
    end
    object qry_prodANC_EPFC: TIntegerField
      FieldName = 'ANC_EPFC'
    end
  end
end
