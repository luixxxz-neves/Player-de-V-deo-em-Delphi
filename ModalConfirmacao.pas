unit ModalConfirmacao;

interface

uses
   Windows, Messages, SysUtils, Variants,
   Classes, Graphics,
   Controls, Forms, Dialogs, StdCtrls, ExtCtrls,
   ImgList;

type
   TFModalConfirmar = class(TForm)
    ImageList164: TImageList;
      BtnAction: TButton;
      BtnCancelar: TButton;
      IconIMG: TImage;
      LTitulo: TLabel;
      Memo1: TMemo;
    ImageListICO: TImageList;
    edtConfirmacao: TEdit;
    LError: TLabel;
    LAviso: TLabel;
    LTermo: TLabel;
      procedure FormCreate(Sender: TObject);
      procedure BtnActionClick(Sender: TObject);
      procedure edtConfirmacaoChange(Sender: TObject);
      procedure BtnCancelarClick(Sender: TObject);
    procedure edtConfirmacaoKeyPress(Sender: TObject; var Key: Char);
   private
      { Private declarations }
   public
      { Public declarations }

      constructor Create(AOwner: TComponent; ATermoDigitado: string);
        reintroduce; overload;
   end;

var
   FModalConfirmar: TFModalConfirmar;

implementation

{$R *.dfm}

var
   FTermo: string;

procedure TFModalConfirmar.BtnActionClick(Sender: TObject);
begin
   if FTermo <> edtConfirmacao.Text then
   begin

      LError.Visible := True;

      if edtConfirmacao.CanFocus then
         edtConfirmacao.SetFocus;

   end;

   if FTermo = edtConfirmacao.Text then
      ModalResult := mrOk;
end;

procedure TFModalConfirmar.BtnCancelarClick(Sender: TObject);
begin
   Close;
end;

constructor TFModalConfirmar.Create(AOwner: TComponent; ATermoDigitado: string);
begin
   inherited Create(AOwner);

   FTermo := ATermoDigitado;
   LTermo.Caption := Format('"%s"', [ATermoDigitado]);
end;

procedure TFModalConfirmar.edtConfirmacaoChange(Sender: TObject);
begin

   if Length(edtConfirmacao.Text) < 3 then
   begin
      LError.Visible := false;
      exit;
   end;

   if FTermo <> edtConfirmacao.Text then
      LError.Visible := True;

   if FTermo = edtConfirmacao.Text then
      LError.Visible := false;

end;

procedure TFModalConfirmar.edtConfirmacaoKeyPress(Sender: TObject;
  var Key: Char);
begin
   if Key = #13 then
   begin
      if BtnAction.CanFocus then
         BtnAction.SetFocus;
   end;
end;



procedure TFModalConfirmar.FormCreate(Sender: TObject);
begin

   ImageList164.GetBitmap(0, IconIMG.Picture.Bitmap);
   ImageListICO.GetIcon(0, Self.Icon);

end;

end.
