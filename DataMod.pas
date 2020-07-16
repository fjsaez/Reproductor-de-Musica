unit DataMod;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs, FireDAC.FMXUI.Wait, Data.DB,
  FireDAC.Comp.Client, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf,
  FireDAC.DApt, FireDAC.Comp.DataSet, FMX.Forms, FMX.Dialogs, UtilesReproductor;

type
  TDMod = class(TDataModule)
    FDConn: TFDConnection;
    Query: TFDQuery;
    procedure DataModuleCreate(Sender: TObject);
  private
    procedure CargarConfig;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DMod: TDMod;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

procedure TDMod.CargarConfig;
begin
  //se carga la configuraci�n; se crea el �nico registro en caso de no existir:
  Query.SQL.Text:='select * from config';
  Query.Open;
  if Query.IsEmpty then   //valores por defecto:
  begin
    Config.Volumen:=0.7;
    Query.SQL.Text:='insert into config (Volumen) values (:vol)';
    Query.ParamByName('vol').AsSingle:=Config.Volumen;
    Query.ExecSQL;
  end
  else
  begin    //poner aqu� posibles campos de config en el futuro:
    Config.Volumen:=Query.FieldByName('Volumen').AsSingle;
  end;
end;

procedure TDMod.DataModuleCreate(Sender: TObject);
const
  BD = 'ReproMusica.db';
var
  HayError: boolean;
begin
  if FileExists(BD) then
  begin
    try
      FDConn.Params.Database:=BD;
      FDConn.Connected:=true;
      CargarConfig;
    except
      HayError:=true;
      ShowMessage('No fue posible abrir el archivo '+BD+'.'+
                  #13#10+'La aplicaci�n se cerrar�.');
    end;
  end
  else
  begin
    HayError:=true;
    ShowMessage('No se encontr� el archivo '+BD+'.'+
                #13#10+'La aplicaci�n se cerrar�.');
  end;
  if HayError then Application.Terminate;
end;

end.