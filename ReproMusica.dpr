program ReproMusica;

uses
  System.StartUpCopy,
  FMX.Forms,
  Principal in 'Principal.pas' {FPrinc},
  UtilesReproductor in 'UtilesReproductor.pas',
  DataMod in 'DataMod.pas' {DMod: TDataModule},
  Acerca in 'Acerca.pas' {FAcerca};

{$R *.res}

begin
  Application.Initialize;
  Application.Title:='Reproductor de música';
  Application.CreateForm(TDMod, DMod);
  Application.CreateForm(TFPrinc, FPrinc);
  Application.Run;
end.
