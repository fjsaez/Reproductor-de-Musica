﻿unit Principal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Media,
  FMX.StdCtrls, FMX.Controls.Presentation, System.Rtti, FMX.Grid.Style, FMX.Grid,
  FMX.ScrollBox, FMX.ExtCtrls, UtilesReproductor, FireDAC.Comp.Client,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param, FMX.Edit,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet, FMX.Objects;

type

  TFPrinc = class(TForm)
    MPlayer: TMediaPlayer;
    BPlay: TButton;
    BPausa: TButton;
    Timer1: TTimer;
    ODialog: TOpenDialog;
    SGrid: TStringGrid;
    LVolumen: TLabel;
    TrackVolumen: TTrackBar;
    SColNombre: TStringColumn;
    SColTiempo: TStringColumn;
    BParar: TButton;
    SBar: TStatusBar;
    EStatus1: TEdit;
    Query: TFDQuery;
    EStatus2: TEdit;
    Timer2: TTimer;
    ImgPlay: TImage;
    ImgPausa: TImage;
    ImgParar: TImage;
    BRetroceder: TButton;
    Image1: TImage;
    BAvanzar: TButton;
    Image2: TImage;
    Rectangle1: TRectangle;
    LArchivo: TLabel;
    Label1: TLabel;
    Rectangle2: TRectangle;
    LTransc: TLabel;
    TrackTiempo: TTrackBar;
    LTotal: TLabel;
    BAcerca: TButton;
    ImgAcerca: TImage;
    SColNumero: TStringColumn;
    PrgBar: TProgressBar;
    EAviso: TEdit;
    TimerAviso: TTimer;
    StyleBook: TStyleBook;
    BSelArchivo: TCornerButton;
    BSelCarpeta: TCornerButton;
    BVaciar: TCornerButton;
    procedure BSelArchivo1Click(Sender: TObject);
    procedure BPlayClick(Sender: TObject);
    procedure BPausaClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure TrackVolumenChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BSelCarpeta1Click(Sender: TObject);
    procedure SGridCellDblClick(const Column: TColumn; const Row: Integer);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure BPararClick(Sender: TObject);
    procedure TrackTiempoClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure TrackTiempoTracking(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure BVaciar1Click(Sender: TObject);
    procedure BRetrocederClick(Sender: TObject);
    procedure BAvanzarClick(Sender: TObject);
    procedure BAcercaClick(Sender: TObject);
    procedure TrackTiempoChange(Sender: TObject);
    procedure TimerAvisoTimer(Sender: TObject);
    procedure PrgBarMouseEnter(Sender: TObject);
  private
    { Private declarations }
    procedure BarraStatus;
    procedure ActivaBotones(CondPlay,CondPausa,CondParar: boolean);
    procedure Aviso(Activo: boolean);
    procedure CargarSGrid;
    procedure RecorrerDirectorio(sRuta: String);
    procedure MuestraDatos(Nombre,Duracion: string);
    procedure CambiarPista(Opcion: boolean);
    procedure ActivarTimers(Activo: boolean);
  public
    { Public declarations }
  end;

var
  FPrinc: TFPrinc;
  TiempoActual: TMediaTime;
  TrackTiempoEsMovido: boolean;
  NumPistaActual: integer;
  Porcentaje: string;

implementation

{$R *.fmx}

uses DataMod,Acerca;

procedure TFPrinc.BarraStatus;
begin
  EStatus1.Text:=' Total pistas: '+Length(Pista).ToString;
  EStatus2.Text:=' Tiempo total: '+TotalTiempoLista;
end;

procedure TFPrinc.ActivaBotones(CondPlay,CondPausa,CondParar: boolean);
begin
  BPlay.Enabled:=CondPlay;
  BPausa.Enabled:=CondPausa;
  BParar.Enabled:=CondParar;
  BAvanzar.Enabled:=SGrid.Row<SGrid.RowCount-1;
  BRetroceder.Enabled:=(SGrid.Row>0) and (SGrid.RowCount>=1);
  TrackTiempo.Enabled:=CondPlay or CondPausa or CondParar;
end;

procedure TFPrinc.Aviso(Activo: boolean);
begin
  if Activo then
  begin
    EAviso.Text:='Cargando listado... ';
    Application.ProcessMessages;
  end
  else EAviso.Text:='';
end;

procedure TFPrinc.CargarSGrid;
var
  I: integer;
begin
  SGrid.RowCount:=0;
  for I:=Low(Pista) to High(Pista) do
  begin
    SGrid.RowCount:=SGrid.RowCount+1;
    SGrid.Cells[0,I]:=(I+1).ToString;
    SGrid.Cells[1,I]:=Pista[I].Nombre;
    SGrid.Cells[2,I]:=Pista[I].TxtDuracion;
  end;
  AjustarCamposStringGrid(SGrid);
end;

procedure TFPrinc.RecorrerDirectorio(sRuta: string);
var
  Directorio: TSearchRec;
  iResultado: Integer;
  Tmp: TTiempo;
begin
  Pista:=nil;
  if sRuta[Length(sRuta)]<>'\' then sRuta:=sRuta+'\';
  iResultado:=FindFirst(sRuta+'*.mp3',FaAnyfile,Directorio);
  while iResultado=0 do
  begin
    // ¿No es el nombre de una unidad ni un directorio?
    if (Directorio.Attr and faVolumeId<>faVolumeID) then
    begin
      MPlayer.FileName:=sRuta+Directorio.Name;
      Tmp:=DecodificaTiempo(MPlayer.Duration);
      CargarPista(sRuta,Directorio.Name,Tmp.FrmCadena,MPlayer.Duration);
    end;
    iResultado:=FindNext(Directorio);
  end;
  FindClose(Directorio);
end;

procedure TFPrinc.MuestraDatos(Nombre,Duracion: string);
begin
  LArchivo.Text:=Nombre;
  LTotal.Text:=Duracion;
end;

procedure TFPrinc.PrgBarMouseEnter(Sender: TObject);
begin
  PrgBar.Hint:='Pista Nº '+(SGrid.Row+1).ToString+' de '+SGrid.RowCount.ToString+
    ' ('+Round((SGrid.Row+1)*100/SGrid.RowCount).ToString+' %)';
end;

procedure TFPrinc.CambiarPista(Opcion: boolean);
begin
  if Opcion then SGrid.Row:=SGrid.Row+1     //avanzar
            else SGrid.Row:=SGrid.Row-1;    //retroceder
  MPlayer.FileName:=Pista[SGrid.Row].Ruta+Pista[SGrid.Row].NombreArch;
  TiempoActual:=0;
  NumPistaActual:=SGrid.Row;
  MPLayer.CurrentTime:=TiempoActual;
  BPlayClick(Self);
end;

procedure TFPrinc.ActivarTimers(Activo: boolean);
begin
  Timer1.Enabled:=Activo;
  Timer2.Enabled:=Activo;
end;

//// Botones ////

procedure TFPrinc.BPlayClick(Sender: TObject);
begin
  PrgBar.Value:=(SGrid.Row+1)*100/Length(Pista);
  ActivaBotones(false,true,true);
  MuestraDatos((SGrid.Row+1).ToString+'.- '+Pista[SGrid.Row].Nombre,
               Pista[SGrid.Row].TxtDuracion);
  Tiempo:=DecodificaTiempo(Pista[SGrid.Row].Duracion);
  ActivarTimers(true);
  MPlayer.FileName:=Pista[SGrid.Row].Ruta+Pista[SGrid.Row].NombreArch;
  MPlayer.Volume:=TrackVolumen.Value;
  if SGrid.Row=NumPistaActual then
    MPlayer.CurrentTime:=TiempoActual
  else MPlayer.CurrentTime:=0;
  MPlayer.Play;
end;

procedure TFPrinc.BAvanzarClick(Sender: TObject);
begin
  CambiarPista(true);
end;

procedure TFPrinc.BRetrocederClick(Sender: TObject);
begin
  CambiarPista(false);
end;

procedure TFPrinc.BPausaClick(Sender: TObject);
begin
  ActivaBotones(true,false,true);
  if MPlayer.Media<>nil then
  begin
    if MPlayer.State=TMediaState.Playing then MPlayer.Stop;
    Timer1.Enabled:=not (MPlayer.State=TMediaState.Playing);
    TiempoActual:=MPLayer.CurrentTime;
    Timer2.Enabled:=Timer1.Enabled;
  end;
end;

procedure TFPrinc.BPararClick(Sender: TObject);
begin
  ActivaBotones(true,false,false);
  MPlayer.Stop;
  MPLayer.CurrentTime:=0;
  TiempoActual:=0;
  TrackTiempo.Value:=0;
  ActivarTimers(false);
  LTransc.Text:='00:00:00';
end;

procedure TFPrinc.BSelArchivo1Click(Sender: TObject);
var
  Tmp: TTiempo;
  I: integer;
begin
  if ODialog.Execute then
  begin
    try
      for I:=0 to ODialog.Files.Count-1 do
      begin
        MPlayer.FileName:=ODialog.Files.Strings[I];
        Tmp:=DecodificaTiempo(MPlayer.Duration);
        CargarPista(ExtraerRuta(ODialog.Files.Strings[I]),
          ExtraerNombreArchivo(ODialog.Files.Strings[I]),
          Tmp.FrmCadena,MPlayer.Duration);
      end;
      Aviso(true);
      InsertarEnBD(Query);  //se carga en la BD
      Aviso(false);
      CargarSGrid;                     //se carga en el stringgrid
      ActivaBotones(true,false,false);
      BarraStatus;
    except
      ShowMessage('No se puede cargar el archivo '+ODialog.FileName);
    end;
  end;
end;

procedure TFPrinc.BSelCarpeta1Click(Sender: TObject);
var
  Carpeta: string;
begin
  if SelectDirectory('Seleccionar carpeta', '',Carpeta) then
  begin
    Aviso(true);
    try
      RecorrerDirectorio(Carpeta);
      CargarSGrid;
      InsertarEnBD(Query);  //se carga en la BD
      SGrid.Row:=0;
      ActivaBotones(true,false,false);
      BarraStatus;
    except
      ShowMessage('No fue posible cargar el(los) archivo(s) de esta carpeta');
    end;
    Aviso(false);
  end;
end;

procedure TFPrinc.BAcercaClick(Sender: TObject);
begin
  with TFAcerca.Create(Self) do
    try ShowModal;
    finally Free
  end;
end;

procedure TFPrinc.BVaciar1Click(Sender: TObject);
begin
  SGrid.RowCount:=0;             //el stringrid
  Pista:=nil;                    //el array
  PrgBar.Value:=0;
  Query.SQL.Text:='delete from listado';
  Query.ExecSQL;                //la tabla 'listado'
  LArchivo.Text:='';
  MPLayer.Stop;
  TiempoActual:=0;
  TrackTiempo.Value:=0;
  ActivarTimers(false);
  LTransc.Text:='00:00:00';
  LTotal.Text:='00:00:00';
  ActivaBotones(false,false,false);
  BarraStatus;
end;

//// StringGrid ////

procedure TFPrinc.SGridCellDblClick(const Column: TColumn; const Row: Integer);
begin
  TiempoActual:=0;
  BPlayClick(Self);
end;

//// Timers y trackbars ////

{Timer que obtiene el tiempo transcurrido de la pista en curso. Intervalo=500}
procedure TFPrinc.Timer1Timer(Sender: TObject);
begin
  if MPLayer.CurrentTime=MPLayer.Duration then TiempoActual:=0
  else TiempoActual:=MPLayer.CurrentTime;
  if (MPlayer.State=TMediaState.Playing) and (MPlayer.CurrentTime=MPlayer.Duration) then
  begin
    if SGrid.Row<SGrid.RowCount-1 then
    begin
      SGrid.Row:=SGrid.Row+1;
      BPlayClick(Self);
    end
    else BPararClick(Self);
    NumPistaActual:=SGrid.Row;
  end;
end;

{Timer que controla el trackbar de tiempo de la pista en curso. Intervalo=500}
procedure TFPrinc.Timer2Timer(Sender: TObject);
begin
  TrackTiempo.Value:=TiempoActual*100/MPlayer.Duration;
  LTransc.Text:=DecodificaTiempo(TiempoActual).FrmCadena;
end;

procedure TFPrinc.TimerAvisoTimer(Sender: TObject);
begin  //por ahora no es posible mostrar el porcentaje. de momento no lo borraré
  EAviso.Text:='Cargando listado... '+Porcentaje;
  Application.ProcessMessages;
end;

procedure TFPrinc.TrackTiempoChange(Sender: TObject);
begin
  if TrackTiempoEsMovido then
  begin
    MPlayer.CurrentTime:=TiempoActual;
    TrackTiempoEsMovido:=false;
  end;
end;

procedure TFPrinc.TrackTiempoClick(Sender: TObject);
begin
  TrackTiempoEsMovido:=true;
  TrackTiempoChange(Self);
end;

procedure TFPrinc.TrackTiempoTracking(Sender: TObject);
begin                 //el deslizado!!:
  TiempoActual:=Trunc(TrackTiempo.Value*MPlayer.Duration/100);
  LTransc.Text:=DecodificaTiempo(TiempoActual).FrmCadena;
end;

procedure TFPrinc.TrackVolumenChange(Sender: TObject);
begin
  MPlayer.Volume:=TrackVolumen.Value;
  Config.Volumen:=TrackVolumen.Value;
  LVolumen.Text:='Volumen: '+Trunc(TrackVolumen.Value*20).ToString;
  GuardarConfig(Query);
end;

//// Formulario principal ////

procedure TFPrinc.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  Config.TiempoActual:=TiempoActual;
  Config.NumPistaActual:=SGrid.Row;
  GuardarConfig(Query);
  DMod.FDConn.Connected:=false;
  CanClose:=true;
  Application.Terminate;
end;

procedure TFPrinc.FormCreate(Sender: TObject);
begin
  TiempoActual:=Config.TiempoActual;
  NumPistaActual:=Config.NumPistaActual;
  TrackVolumen.Value:=Config.Volumen;
  LVolumen.Text:='Volumen: '+Trunc(TrackVolumen.Value*20).ToString;
end;

procedure TFPrinc.FormShow(Sender: TObject);
begin
  SGrid.RowCount:=0;
  SetLength(Pista,0);
  //se revisa si hay pistas en la BD:
  Query.SQL.Text:='select * from listado';
  Query.Open;
  with Query do
    if RecordCount>0 then  //de haberlas...:
    begin
      while not Eof do
      begin           //se carga array Pista:
        if FileExists(FieldByName('Ruta').AsString+FieldByName('Pista').AsString) then
          CargarPista(FieldByName('Ruta').AsString,FieldByName('Pista').AsString,
            FieldByName('TxtDuracion').AsString,FieldByName('Duracion').AsLargeInt);
        Next;
      end;
      CargarSGrid;
      //en caso de que falten pistas:
      if Length(Pista)=RecordCount then
      begin
        MPlayer.FileName:=Pista[NumPistaActual].Ruta+Pista[NumPistaActual].NombreArch;
        MPlayer.CurrentTime:=TiempoActual;
        TrackTiempo.Value:=TiempoActual*100/MPlayer.Duration;
        LTransc.Text:=DecodificaTiempo(TiempoActual).FrmCadena;
        SGrid.Row:=Config.NumPistaActual;
        MuestraDatos((SGrid.Row+1).ToString+'.- '+Pista[SGrid.Row].Nombre,
               Pista[SGrid.Row].TxtDuracion);
      end
      else
        if (Length(Pista)>0) and (Length(Pista)<RecordCount) then
        begin
          SGrid.Row:=0;
          Aviso(true);
          InsertarEnBD(Query);
          Aviso(false);
        end
    end;
  PrgBar.Value:=(SGrid.Row+1)*100/Length(Pista);
  ActivaBotones(SGrid.RowCount>0,false,false);
  BarraStatus;
end;

end.
