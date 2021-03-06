unit uFrmThumbor;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.IniFiles,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.Imaging.jpeg,
  Vcl.Buttons,
  Vcl.Samples.Spin,
  FS.Cloud,
  FS.Thumbor;

type
  TfrmThumbor = class(TForm)
    edtSecretKey: TEdit;
    lbl1: TLabel;
    memUrl: TMemo;
    edtUrlServerThumbor: TEdit;
    lbl2: TLabel;
    lbl4: TLabel;
    edtPathImage: TEdit;
    imgThumbor: TImage;
    btnGenerateByClass: TBitBtn;
    grpParams: TGroupBox;
    lbl3: TLabel;
    lbl5: TLabel;
    chkUseSmart: TCheckBox;
    edtWitdh: TSpinEdit;
    edtHeigth: TSpinEdit;
    edtQuality: TSpinEdit;
    lbl6: TLabel;
    lbl7: TLabel;
    edtCustom: TEdit;
    procedure btnGenerateByClassClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    procedure GetImageByUrl(URL: string; APicture: TPicture);
    procedure LoadConfigIni();
  public
    { Public declarations }
  end;

var
  frmThumbor: TfrmThumbor;

implementation

{$R *.dfm}

procedure TfrmThumbor.btnGenerateByClassClick(Sender: TObject);
var
  Thumbor: TThumbor;
  vUrlThumbor: string;
begin
  Thumbor := TThumbor.Create(edtUrlServerThumbor.Text, edtSecretKey.Text);
  try
    if edtCustom.Text = EmptyStr then
    begin
      vUrlThumbor :=
        Thumbor
          .BuildImage(edtPathImage.Text)
          .Resize(edtWitdh.Value, edtHeigth.Value)
          .Quality(edtQuality.Value)
          .Smart()
          .ToUrl();
    end else
    begin
      vUrlThumbor :=
        Thumbor
          .BuildImage(edtPathImage.Text)
          .Custom(edtCustom.Text)
          .ToUrl();
    end;

    memUrl.Lines.Add(vUrlThumbor);
    GetImageByUrl(vUrlThumbor, imgThumbor.Picture);
  finally
    Thumbor.Free;
  end;
end;

procedure TfrmThumbor.FormCreate(Sender: TObject);
begin
  LoadConfigIni;
end;

procedure TfrmThumbor.GetImageByUrl(URL: string; APicture: TPicture);
var
  Jpeg: TJPEGImage;
  Strm: TMemoryStream;
  Cloud: TFSCloud;
begin
  Jpeg := TJPEGImage.Create;
  Strm := TMemoryStream.Create;
  Cloud := TFSCloud.Create(Self);
  try
    Cloud.Get(URL, Strm);
    if (Strm.Size > 0) then
    begin
      Strm.Position := 0;
      Jpeg.LoadFromStream(Strm);
      APicture.Assign(Jpeg);
    end;
  finally
    Strm.Free;
    Jpeg.Free;
    Cloud.Free;
  end;
end;

procedure TfrmThumbor.LoadConfigIni;
var
  IniFile: TIniFile;
  vArqIni: string;
begin
  try
    vArqIni := ExtractFilePath(Application.ExeName) + '\config.ini';

    if not(FileExists(vArqIni)) then
      Exit;

    IniFile := TIniFile.Create(vArqIni);
    try
      edtSecretKey.Text := IniFile.ReadString('THUMBOR', 'KEY', '');
      edtUrlServerThumbor.Text := IniFile.ReadString('THUMBOR', 'URLSERVERTHUMBOR', '');
      edtPathImage.Text := IniFile.ReadString('THUMBOR', 'PATHIMAGE', '');
    finally
      FreeAndNil(IniFile);
    end;
  except
    on e: Exception do
      raise Exception.Create('LoadConfigIni '+ e.Message);
  end;

end;

end.
