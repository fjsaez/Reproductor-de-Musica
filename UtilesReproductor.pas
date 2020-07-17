unit UtilesReproductor;

interface

uses System.SysUtils, FMX.Media, FireDAC.Comp.Client, FMX.Dialogs, FMX.Grid,
  FMX.Grid.Style, FMX.ScrollBox;

type
  TConfig = record
    Volumen: single;
  end;

  TPista = record
    Nombre,
    Ruta,
    TxtDuracion: string;
    Duracion: TMediaTime;
  end;

  TAPista = array of TPista;

  TTiempo = record
    Horas,
    Minutos,
    Segundos: word;
    TotSegundos: integer;
    FrmCadena: string;
  end;

  function DecodificaTiempo(Tmp: TMediaTime): TTiempo;
  function TotalTiempoLista: string;
  function ExtraerNombreArchivo(const Arch: string): string;
  function ExtraerRuta(const Arch: string): string;
  procedure AjustarCamposStringGrid(var xGrid: TStringGrid);
  procedure CargarPista(Ruta,Nombre,Duracion: string; DTDuracion: TMediaTime);
  procedure InsertarEnBD(var Qr: TFDQuery);
  procedure GuardarConfig(var Qr: TFDQuery);

var
  Config: TConfig;
  Tiempo: TTiempo;
  Pista: TAPista;

implementation

function DecodificaTiempo(Tmp: TMediaTime): TTiempo;
var
  Hh,Mm,Ss,Ms: word;
begin
  DecodeTime(Tmp.ToDateTime,Hh,Mm,Ss,Ms);
  result.Horas:=Hh;
  result.Minutos:=Mm;
  result.Segundos:=Ss;
  result.TotSegundos:=(Hh*3600)+(Mm*60)+(Ss);
  //a este campo se le da el formato "00:00:00":
  if Hh<10 then result.FrmCadena:='0'+Hh.ToString+':'
           else result.FrmCadena:=Hh.ToString+':';
  if Mm<10 then result.FrmCadena:=result.FrmCadena+'0'+Mm.ToString+':'
           else result.FrmCadena:=result.FrmCadena+Mm.ToString+':';
  if Ss<10 then result.FrmCadena:=result.FrmCadena+'0'+Ss.ToString
           else result.FrmCadena:=result.FrmCadena+Ss.ToString;
end;

function TotalTiempoLista: string;
var
  I: integer;
  Temp: TMediaTime;
  Tmpx: TTiempo;
begin
  Temp:=0;
  for I:=Low(Pista) to High(Pista) do Temp:=Temp+Pista[I].Duracion;
  Tmpx:=DecodificaTiempo(Temp);
  Result:=Tmpx.FrmCadena;
end;

function ExtraerNombreArchivo(const Arch: string): string;
var
  I: Integer;
begin
  I:=LastDelimiter('\',Arch);
  Result:=Copy(Arch,I+1,Length(Arch)-I);
end;

function ExtraerRuta(const Arch: string): string;
var
  I: Integer;
begin
  I:=LastDelimiter('\',Arch);
  Result:=Copy(Arch,1,I);
end;

procedure AjustarCamposStringGrid(var xGrid: TStringGrid);
const
  Sep=20;
var
  X,Y: integer;
  Mayor: single;
begin
  with xGrid do
    for X:=0 to ColumnCount-1 do
    begin
      Mayor:=0;
      for Y:=0 to RowCount-1 do
        if Canvas.TextWidth(Cells[X,Y])>Mayor then
          Mayor:=Canvas.TextWidth(Cells[X,Y]);
      if Canvas.TextWidth(Columns[X].Header)>Mayor then
        Columns[X].Width:=Canvas.TextWidth(Columns[X].Header)+Sep
      else Columns[X].Width:=Mayor+Sep;
    end;
end;

procedure CargarPista(Ruta,Nombre,Duracion: string; DTDuracion: TMediaTime);
begin
  SetLength(Pista,Length(Pista)+1);
  Pista[High(Pista)].Ruta:=Ruta;
  Pista[High(Pista)].Nombre:=Nombre;
  Pista[High(Pista)].TxtDuracion:=Duracion;
  Pista[High(Pista)].Duracion:=DTDuracion;
end;

procedure InsertarEnBD(var Qr: TFDQuery);
var
  I: integer;
begin
  Qr.Close;
  Qr.SQL.Text:='delete from listado';
  Qr.ExecSQL;
  for I:=Low(Pista) to High(Pista) do
  begin
    Qr.Close;
    Qr.SQL.Text:='insert into listado (Numero,Ruta,Pista,Transcurrido,'+
                 'Duracion,TxtDuracion) values (:nro,:rta,:pst,:trc,:drc,:txd)';
    Qr.ParamByName('nro').AsInteger:=I;
    Qr.ParamByName('rta').AsString:=Pista[I].Ruta;
    Qr.ParamByName('pst').AsString:=Pista[I].Nombre;
    Qr.ParamByName('trc').AsLargeInt:=0;
    Qr.ParamByName('drc').AsLargeInt:=Pista[I].Duracion;
    Qr.ParamByName('txd').AsString:=Pista[I].TxtDuracion;
    Qr.ExecSQL;
  end;
end;

procedure GuardarConfig(var Qr: TFDQuery);
begin    //agregar aquí los campos que se vayan incorporando a tabla config:
  Qr.SQL.Text:='update config set Volumen=:vol';
  Qr.ParamByName('vol').AsSingle:=Config.Volumen;
  Qr.ExecSQL;
end;

end.
