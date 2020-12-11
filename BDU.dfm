object BDDM: TBDDM
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Height = 318
  Width = 359
  object EPFCIBODB: TIBODatabase
    CacheStatementHandles = False
    SQLDialect = 3
    Params.Strings = (
      'PROTOCOL=TCP/IP'
      'USER NAME=SYSDBA'
      'SQL DIALECT=3'
      'SERVER=epfc01dev01.epfc.local'
      'PATH=c:\DATA\DB_ref\EPFCRef.fdb')
    Isolation = tiCommitted
    TimeoutProps.AllowCheckOAT = 0
    DriverName = ''
    Left = 56
    Top = 56
    SavedPassword = '.JuMbLe.01.4B3A132E012A154B'
  end
  object EPFC_DB_ANNEE_PREC: TIBODatabase
    CacheStatementHandles = False
    SQLDialect = 3
    Params.Strings = (
      'PROTOCOL=TCP/IP'
      'USER NAME=SYSDBA'
      'SQL DIALECT=3'
      'SERVER=epfc01dev01.epfc.local'
      'PATH=c:\DATA\DB_ref\EPFCRef.fdb')
    Isolation = tiCommitted
    TimeoutProps.AllowCheckOAT = 0
    DriverName = ''
    Left = 56
    Top = 8
    SavedPassword = '.JuMbLe.01.4B3A132E012A154B'
  end
  object EPFC_DB_CHOICE: TIBODatabase
    CacheStatementHandles = False
    SQLDialect = 3
    Params.Strings = (
      'PATH=c:\Data\DB_ref\EPFCRef.fdb'
      'USER NAME=SYSDBA'
      'SERVER=epfc01dev01.epfc.local'
      'PROTOCOL=TCP/IP')
    Isolation = tiCommitted
    TimeoutProps.AllowCheckOAT = 0
    DriverName = ''
    Left = 64
    Top = 120
    SavedPassword = '.JuMbLe.01.4B3A132E012A154B'
  end
end
