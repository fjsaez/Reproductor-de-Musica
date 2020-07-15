object DMod: TDMod
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Height = 213
  Width = 314
  object FDConn: TFDConnection
    ConnectionName = 'DB'
    Params.Strings = (
      'DriverID=SQLite'
      'OpenMode=CreateUTF16'
      'StringFormat=Unicode')
    LoginPrompt = False
    Left = 48
    Top = 32
  end
end
