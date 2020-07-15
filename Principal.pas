unit Principal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Media,
  FMX.StdCtrls, FMX.Controls.Presentation, FMX.ListView.Types,
  FMX.ListView.Appearances, FMX.ListView.Adapters.Base, FMX.ListView,
  System.Rtti, FMX.Grid.Style, FMX.Grid, FMX.ScrollBox, UtilesReproductor,
  System.ImageList, FMX.ImgList, FMX.Layouts, FMX.ExtCtrls, FMX.Edit,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, FMX.Objects;

type

  TFPrinc = class(TForm)
    MPlayer: TMediaPlayer;
    BSelArchivo: TButton;
    BPlay: TButton;
    BPausa: TButton;
    Timer1: TTimer;
    ODialog: TOpenDialog;
    SGrid: TStringGrid;
    LVolumen: TLabel;
    TrackBar: TTrackBar;
    BSelCarpeta: TButton;
    SColNombre: TStringColumn;
    SColTiempo: TStringColumn;
    AniInd: TAniIndicator;
    LAviso: TLabel;
    BParar: TButton;
    SBar: TStatusBar;
    EStatus1: TEdit;
    Query: TFDQuery;
    EStatus2: TEdit;
    Timer2: TTimer;
    BVaciar: TButton;
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
    Track: TTrackBar;
    LTotal: TLabel;
    BAcerca: TButton;
    ImgAcerca: TImage;
    procedure BSelArchivoClick(Sender: TObject);
    procedure BPlayClick(Sender: TObject);
    procedure BPausaClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure TrackBarChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BSelCarpetaClick(Sender: TObject);
    procedure SGridCellDblClick(const Column: TColumn; const Row: Integer);
    procedure SGridCellClick(const Column: TColumn; const Row: Integer);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure BPararClick(Sender: TObject);
    procedure TrackClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure TrackTracking(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure BVaciarClick(Sender: TObject);
    procedure BRetrocederClick(Sender: TObject);
    procedure BAvanzarClick(Sender: TObject);
    procedure BAcercaClick(Sender: TObject);
  private
    { Private declarations }
    procedure BarraStatus;
    procedure ActivaBotones(CondPlay,CondPausa,CondParar: boolean);
    procedure Aviso(Activo: boolean);
    procedure CargarSGrid;
    procedure RecorrerDirectorio(sRuta: String);
    procedure MuestraDatos(Nombre,Duracion: string);
    procedure CambiarPista(Opcion: boolean);
  public
    { Public declarations }
  end;

var
  FPrinc: TFPrinc;
  TiempoActual: TMediaTime;

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
  BRetroceder.Enabled:=SGrid.Row>0;
end;

procedure TFPrinc.Aviso(Activo: boolean);
begin
  AniInd.Visible:=Activo;
  AniInd.Enabled:=Activo;
  LAviso.Visible:=Activo;
  if Activo then Application.ProcessMessages;
end;

procedure TFPrinc.CargarSGrid;
var
  I: integer;
begin
  SGrid.RowCount:=0;
  for I:=Low(Pista) to High(Pista) do
  begin
    SGrid.RowCount:=SGrid.RowCount+1;
    SGrid.Cells[0,I]:=Pista[I].Nombre;
    SGrid.Cells[1,I]:=Pista[I].TxtDuracion;
  end;
end;

procedure TFPrinc.RecorrerDirectorio(sRuta: String);
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
    // �No es el nombre de una unidad ni un directorio?
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

procedure TFPrinc.CambiarPista(Opcion: boolean);
begin
  if Opcion then SGrid.Row:=SGrid.Row+1     //avanzar
            else SGrid.Row:=SGrid.Row-1;    //retroceder
  MPlayer.FileName:=Pista[SGrid.Row].Ruta+Pista[SGrid.Row].Nombre;
  TiempoActual:=0;
  MPLayer.CurrentTime:=TiempoActual;
  BPlayClick(Self);
end;

//// Botones ////

procedure TFPrinc.BPlayClick(Sender: TObject);
var
  I: integer;
begin
  Parar:=false;
  for I:=SGrid.Row to SGrid.RowCount-1 do
  begin
    ActivaBotones(false,true,true);
    MPlayer.FileName:=Pista[I].Ruta+Pista[I].Nombre;
    MuestraDatos(Pista[I].Nombre,Pista[I].TxtDuracion);
    Tiempo:=DecodificaTiempo(MPlayer.Duration);
    Timer1.Enabled:=true;
    Timer2.Enabled:=Timer1.Enabled;                    //esto es una prueba
    MPlayer.Volume:=TrackBar.Value;
    MPlayer.CurrentTime:=TiempoActual;
    MPlayer.Play;
    while (MPlayer.CurrentTime<MPlayer.Duration) and not Parar do
    //while MPlayer.State=TMediaState.Playing do
    begin
      Application.ProcessMessages;
      if Parar then
      begin
        MPlayer.Stop;
        Break;
      end;
    end;
    if MPlayer.State=TMediaState.Playing then
    begin
      SGrid.Row:=SGrid.Row+1;
      TiempoActual:=0;
    end;
    if Parar then Break;
  end;
  ActivaBotones(false,false,false);
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
    Timer2.Enabled:=Timer1.Enabled;              //esto es una prueba
  end;
end;

procedure TFPrinc.BPararClick(Sender: TObject);
begin
  ActivaBotones(true,false,false);
  Parar:=true;
  MPlayer.Stop;
  MPLayer.CurrentTime:=0;
  TiempoActual:=0;
  Track.Value:=0;
  Timer1.Enabled:=false;
  Timer2.Enabled:=Timer1.Enabled;                  //esto es una prueba
  LTransc.Text:='00:00:00';
end;

procedure TFPrinc.BSelArchivoClick(Sender: TObject);
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
      InsertarEnBD(Query);  //se carga en la BD
      CargarSGrid;          //se carga en el stringgrid
      BarraStatus;
    except
      ShowMessage('No se puede cargar el archivo '+ODialog.FileName);
    end;
  end;
end;

procedure TFPrinc.BSelCarpetaClick(Sender: TObject);
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
      BarraStatus;
    except
      //no mostrar nada...
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

procedure TFPrinc.BVaciarClick(Sender: TObject);
begin
  SGrid.RowCount:=0;             //el stringrid
  Pista:=nil;                    //el array
  Query.SQL.Text:='delete from listado';
  Query.ExecSQL;                //la tabla 'listado'
  BarraStatus;
end;

//// StringGrid ////

procedure TFPrinc.SGridCellClick(const Column: TColumn; const Row: Integer);
begin
  ActivaBotones(SGrid.Cells[0,Row]<>'',false,false);
end;

procedure TFPrinc.SGridCellDblClick(const Column: TColumn; const Row: Integer);
begin
  TiempoActual:=0;
  BPlayClick(Self);
end;

//// Timers y trackbars ////

procedure TFPrinc.Timer1Timer(Sender: TObject);
begin
  if MPLayer.CurrentTime=MPLayer.Duration then TiempoActual:=0
  else TiempoActual:=MPLayer.CurrentTime;
  LTransc.Text:=DecodificaTiempo(TiempoActual).FrmCadena;
end;

procedure TFPrinc.Timer2Timer(Sender: TObject);
begin
  Track.Value:=TiempoActual*100/MPlayer.Duration;       //esto es una prueba!!!
end;

procedure TFPrinc.TrackBarChange(Sender: TObject);
begin
  MPlayer.Volume:=TrackBar.Value;
  LVolumen.Text:='Volumen: '+Trunc(TrackBar.Value*20).ToString;
end;

procedure TFPrinc.TrackClick(Sender: TObject);
begin
  MPlayer.CurrentTime:=TiempoActual;
end;

procedure TFPrinc.TrackTracking(Sender: TObject);
begin
  TiempoActual:=Trunc(Track.Value*MPlayer.Duration/100);    //el deslizado!!
end;

//// Formulario principal ////

procedure TFPrinc.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  BPararClick(Self);
  DMod.FDConn.Connected:=false;
  CanClose:=true;
  Application.Terminate;
end;

procedure TFPrinc.FormCreate(Sender: TObject);
begin
  TrackBar.Value:=0.7;   //de momento as�, pero se pondr� en la configuraci�n
  MPlayer.Volume:=TrackBar.Value;
  LVolumen.Text:='Volumen: '+Trunc(TrackBar.Value*20).ToString;
  Parar:=false;
end;

procedure TFPrinc.FormShow(Sender: TObject);
begin
  SGrid.RowCount:=0;
  SetLength(Pista,0);
  //se revisa si hay pistas en la BD:
  try
    Query.SQL.Text:='select * from listado';
    Query.Open;
    with Query do
      if RecordCount>0 then  //de haberlas...:
      begin
        while not Eof do
        begin           //se carga array Pista:
          CargarPista(FieldByName('Ruta').AsString,FieldByName('Pista').AsString,
            FieldByName('TxtDuracion').AsString,FieldByName('Duracion').AsLargeInt);
          Next;
        end;
        CargarSGrid;    //se carga el stringgrid
      end;
  except
    ShowMessage('No se encontr� el archivo ReproMusica.db o est� da�ado.'+
                #13#10+'La aplicaci�n se cerrar�.');
    Application.Terminate;
  end;
  BarraStatus;
end;

end.
