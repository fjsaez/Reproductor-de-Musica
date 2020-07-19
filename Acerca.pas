unit Acerca;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Controls.Presentation, FMX.StdCtrls;

type
  TFAcerca = class(TForm)
    Rectangle1: TRectangle;
    Rectangle2: TRectangle;
    Image1: TImage;
    Button1: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    LVersion: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FAcerca: TFAcerca;

implementation

{$R *.fmx}

procedure TFAcerca.Button1Click(Sender: TObject);
begin
  Close;
end;

procedure TFAcerca.FormCreate(Sender: TObject);
begin
  {$IFDEF 64_BITS}
    LVersion.Text:='v1.0 (64 bits)';
  {$ELSE}
    LVersion.Text:='v1.0 (32 bits)';
  {$ENDIF}
end;

end.
