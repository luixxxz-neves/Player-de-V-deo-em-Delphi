unit Form_Player;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ImgList, StdCtrls, ExtCtrls, Buttons, WMPLib_TLB, ComCtrls,
  ModalConfirmacao, DB, DBClient, SimpleDS, uCliente;

type
   SalvarTempo = record
      TimerAtual : Double;
      TimerTotal : Double;
   end;

   PosicaoMouse = record
      PosX : Integer;
      PosY : Integer;
   end;

type
   TFormPlayer = class(TForm)
    listaIcons: TImageList;
    pn_player: TPanel;
    pn_controlsBar: TPanel;
    pn_topBar: TPanel;
    navControls: TShape;
    titleBar: TShape;
    btnSair: TSpeedButton;
    btnPlayer: TSpeedButton;
    btnVolta: TSpeedButton;
    btnAvanca: TSpeedButton;
    btnMaximiza: TSpeedButton;
    progressBar: TTrackBar;
    btnVolume: TSpeedButton;
    volumeBar: TTrackBar;
    LBTitulo: TLabel;
    Temporizador: TTimer;
    LB_Timer: TLabel;
    DestravaVideo: TTimer;
    ExibeControles: TTimer;
    procedure BtnMaximizaClick(Sender: TObject);
    procedure btnPlayerClick(Sender: TObject);
    procedure BtnSairClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure titleBarMouseDown(Sender: TObject; Button: TMouseButton;
    Shift: TShiftState; X, Y: Integer);
    procedure btnVolumeClick(Sender: TObject);
    procedure btnAvancaClick(Sender: TObject);
    procedure btnVoltaClick(Sender: TObject);
    procedure btnVolumeMouseEnter(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TemporizadorTimer(Sender: TObject);
    procedure FormMouseWheel(Sender: TObject; Shift: TShiftState;
    WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure DestravaVideoTimer(Sender: TObject);
    procedure ExibeControlesTimer(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnVolumeMouseLeave(Sender: TObject);
   private
      { Private declarations }
      botaoMx, botaoPl : Boolean;
      Drag, VolumeMix : Boolean;
      priAnunc, segAnunc, exibindoAnuncio : boolean;
      URLOriginal, URLAnunc : WideString;
      LastX, LastY : Integer;
      ultimoSeg : Integer;
      TempoSalvo : SalvarTempo;
      PosicaoSalva : PosicaoMouse;
      Player: TWindowsMediaPlayer;
      FCliente : TCliente;
      procedure ProgressBarChangeDynamic(Sender: TObject);
      procedure VolumeBarChangeDynamic(Sender: TObject);
      function FormatTime(Seg: Double): string;
      function CalcTempAnuncio(TempAtual,TempVideo : Double):boolean;
      function VerificaVideo(VideoAtual : WideString):boolean;
      procedure PlayerPlayStateChangeDynamic(Sender: TObject; NewState: Integer);
      procedure PlayerMouseMoveDynamic(Sender: TObject; nButton: Smallint;
                        nShiftState: Smallint;fX: Integer; fY: Integer);
      function GuardaTempo(timeAtual : Double): SalvarTempo;
      procedure DisparaAnunc(tempoAtual : Double);
      function GuardaPosicao(posX, posY : integer): PosicaoMouse;
   public
      { Public declarations }
      constructor create(AOnwer : TComponent; titulo : string); reintroduce; overload;
   end;

var
  FormPlayer: TFormPlayer;

implementation

{$R *.dfm}
procedure TFormPlayer.BtnMaximizaClick(Sender: TObject);
begin
   if botaoMx then
   begin
      ShowWindowAsync(Handle, 1);
      Drag := True
   end
   else
   begin
      ShowWindowAsync(Handle, 3);
      Drag := False;
   end;
   botaoMx := not botaoMx;
end;

procedure TFormPlayer.btnPlayerClick(Sender: TObject);
begin
   if botaoPl then
   begin
      BtnPlayer.Glyph := nil;
      listaIcons.GetBitmap(1, BtnPlayer.Glyph);
      Player.controls.pause;
   end
   else
   begin
      BtnPlayer.Glyph := nil;
      listaIcons.GetBitmap(0, BtnPlayer.Glyph);
      Player.controls.play ;
   end;
   botaoPl := not botaoPl;
end;

procedure TFormPlayer.BtnSairClick(Sender: TObject);
   var
      ModalConfirmacao: TFModalConfirmar;
begin
   BtnPlayer.Glyph := nil;
   listaIcons.GetBitmap(1, BtnPlayer.Glyph);
   Player.controls.pause;
   ModalConfirmacao := TFModalConfirmar.Create(self{,
   'Estou ciente das consequencias'});

   try
   with ModalConfirmacao do
   begin
   { Mensagem dentro do Modal }
      memo1.top := 105;
      LAviso.Enabled := False;
      LAviso.Visible := False;
      LError.Enabled := False;
      LError.Visible := False;
      LTermo.Enabled := False;
      LTermo.Visible := False;
      edtConfirmacao.Enabled := False;
      edtConfirmacao.Visible := False;
      with Memo1.Lines do
      begin
         Add('');
         Add('Deseja encerrar o conteúdo que está assistindo?');
         Add('');
         Add('Deseja realemente fazer isso?');
      end;

      if ShowModal = mrOk then
      begin
         Self.Close
      end
      else
      begin
         BtnPlayer.Glyph := nil;
         listaIcons.GetBitmap(0, BtnPlayer.Glyph);
         Player.controls.play ;
         exit;
      end;
   end;
   finally
      ModalConfirmacao.Free;
   end;
end;

procedure TFormPlayer.btnAvancaClick(Sender: TObject);
begin
   progressBar.Position := progressBar.Position +10
end;

procedure TFormPlayer.btnVoltaClick(Sender: TObject);
begin
   progressBar.Position := progressBar.Position -10
end;

procedure TFormPlayer.btnVolumeClick(Sender: TObject);
begin
   if volumeMix then
   begin
      btnVolume.Glyph := nil;
      listaIcons.GetBitmap(8, btnVolume.Glyph);
      volumeBar.Position := 100;
      player.settings.volume := 0;
   end
   else
   begin
      btnVolume.Glyph := nil;
      listaIcons.GetBitmap(6, btnVolume.Glyph);
      volumeBar.Position := 30;
   end;
   volumeMix := not volumeMix;
end;

procedure TFormPlayer.btnVolumeMouseEnter(Sender: TObject);
begin
   volumeBar.Visible := True;
   volumeBar.BringToFront;
   volumeBar.SetFocus;
end;

procedure TFormPlayer.btnVolumeMouseLeave(Sender: TObject);
begin
   volumeBar.Visible := False;
   volumeBar.SendToBack;
end;

function TFormPlayer.CalcTempAnuncio(TempAtual, TempVideo: double): boolean;
   var
      TercoVideo, SegundoTerco : Double;
begin
   Result := False;
   if exibindoAnuncio then Exit;

   TercoVideo := TempVideo / 3;
   SegundoTerco := TercoVideo * 2;

   if FCliente.IDPlano = 1 then
   begin
      if (StrToInt(FloatToStr(Round(TempAtual))) mod 10 = 0) and (ultimoSeg <> Round(TempAtual)) then
      begin
         ultimoSeg := Round(TempAtual);
         Result  := true;
      end;
   end;

   if FCliente.IDPlano = 2 then
   begin
      if(not priAnunc)and(Abs(TempAtual - TercoVideo) <= 0.5)then
      begin
         priAnunc := True;
         Result := True;
         Exit;
      end;

      if(not segAnunc)and(Abs(TempAtual - SegundoTerco) <= 0.5)then
      begin
         segAnunc := True;
         Result := True;
      end;
   end;
end;

constructor TFormPlayer.create(AOnwer: TComponent; titulo: string);
begin
   inherited create(Aonwer);
   LBTitulo.Caption := titulo;
end;

procedure TFormPlayer.DisparaAnunc(tempoAtual: Double);
begin
   exibindoAnuncio := True;
   TempoSalvo := GuardaTempo(tempoAtual);

   progressBar.Enabled := False;
   btnAvanca.enabled := False;
   btnVolta.enabled := False;
   btnPlayer.Enabled := False;

   player.URL := URLAnunc;
   Player.Controls.play;
end;

procedure TFormPlayer.ExibeControlesTimer(Sender: TObject);
begin
   pn_topBar.Visible := False;
   pn_controlsBar.Visible := False;
   ExibeControles.Enabled := False;
end;

function TFormPlayer.FormatTime(Seg: Double): string;
   var
      totalSeg, min, segs, hora : Integer;
begin
   totalSeg := Round(Seg);
   hora := TotalSeg div 3600;
   min := (totalSeg div 60) mod 60;
   segs := totalSeg mod 60;

   result := Format('%.2d:%.2d:%.2d', [hora, min, segs]);
end;

procedure TFormPlayer.FormCreate(Sender: TObject);
begin
   {Criação do WMPlayer em Run Time}
   ShowWindowAsync(Handle, 3);
   Player := TWindowsMediaPlayer.Create(Self);
   Player.Parent := pn_player;
   Player.uiMode := 'none';
   Player.Align := AlClient;
   Player.URL := 'C:\Filme\Filme.mp4';
   Player.stretchToFit := True;
   player.OnMouseMove := PlayerMouseMoveDynamic;
//   Player.settings.setMode('loop', True);

   {Manipulação dos arquivos do Player}
   URLOriginal := Player.URL;
   URLAnunc := '\\192.168.1.30\D\Banco Dexflix\Projeto DexFlix\IMG\Filmes\video-fundo.mp4';
   Player.OnPlayStateChange := PlayerPlayStateChangeDynamic;

   {Manipulação do volume Player}
   VolumeBar.onChange := VolumeBarChangeDynamic;

   {Variáel que manipula os botões do player}
   botaoMx := true;
   botaoPl := true;
   Drag := False;
   volumeMix := true;

   {Icones dos botões do Player}
   listaIcons.GetBitmap(0, BtnPlayer.Glyph);
   listaIcons.GetBitmap(2, BtnVolta.Glyph);
   listaIcons.GetBitmap(3, BtnAvanca.Glyph);
   listaIcons.GetBitmap(4, BtnMaximiza.Glyph);
   listaIcons.GetBitmap(5, BtnSair.Glyph);
   listaIcons.GetBitmap(7, BtnVolume.Glyph);

   {Verificação da Assinatura do cliente}
   FCliente := TClienteLogado.getUserLogado;
end;

procedure TFormPlayer.FormDestroy(Sender: TObject);
begin
   if Assigned(Player) then
   begin
      Player.controls.stop;
      Player.close;
      Player.URL := '';
      FreeAndNil(Player);
   end;

   if Assigned(FormPlayer) then
      FreeAndNil(FormPlayer);
end;

procedure TFormPlayer.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   case key  of
      vk_Space: if btnPlayer.enabled then btnPlayer.Click;

      ord('M'): if btnVolume.enabled then btnVolume.Click;

      ord('F'): if btnMaximiza.enabled then btnMaximiza.Click;

      ord('J'): if btnVolta.enabled then btnVolta.Click;

      ord('L'): if btnAvanca.enabled then btnAvanca.Click;

      vk_Escape: if btnSair.enabled then btnSair.Click;
   end;
end;

procedure TFormPlayer.FormMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin
   if VolumeBar.Focused then
   begin
      if WheelDelta > 0 then
         VolumeBar.Position := VolumeBar.Position - VolumeBar.LineSize
      else
         VolumeBar.Position := VolumeBar.Position + VolumeBar.LineSize;

      Handled := True;
   end;
end;

procedure TFormPlayer.FormShow(Sender: TObject);
begin
   Player.controls.play;
end;

function TFormPlayer.GuardaPosicao(posX, posY: integer): PosicaoMouse;
begin
   Result.PosX := posX;
   Result.PosY := posY;
end;

function TFormPlayer.GuardaTempo(timeAtual: Double): SalvarTempo;
begin
   Result.TimerAtual := timeAtual;
end;

procedure TFormPlayer.PlayerMouseMoveDynamic(Sender: TObject; nButton,
  nShiftState: Smallint; fX, fY: Integer);
begin
   LastX := fx;
   LastY := fy;

   if(LastX <> PosicaoSalva.PosX)or(LastY <> PosicaoSalva.PosY)then
   begin
      pn_controlsBar.Visible := True;
      pn_topBar.visible := true;
   end;

   ExibeControles.Enabled := False;
   ExibeControles.Enabled := true;

   PosicaoSalva := GuardaPosicao(LastX, LastY);
end;

procedure TFormPlayer.PlayerPlayStateChangeDynamic(Sender: TObject;
  NewState: Integer);
   var
      Confirmacao : Integer;
begin
   case NewState of
      3:{A mídia está tocando com sucesso}
      begin
         if not exibindoAnuncio then
         begin
            if TempoSalvo.TimerAtual > 0 then
            begin
               Player.controls.currentPosition := TempoSalvo.TimerAtual;
               TempoSalvo.TimerAtual := 0;
            end;
            ProgressBar.Enabled := True;
            btnAvanca.Enabled := True;
            btnVolta.Enabled := True;
            DestravaVideo.Enabled := false;
         end;
      end;

      8:{A mídia chegou ao fim}
      begin
         if exibindoAnuncio then
         begin
            exibindoAnuncio := False;
            btnPlayer.Enabled := True;
            player.URL := URLOriginal;
            DestravaVideo.Enabled := true;
         end
         else
         begin
            Confirmacao := Application.MessageBox('Deseja repetir o vídeo?',
            'Confirmação',MB_YESNO + MB_ICONASTERISK + MB_DEFBUTTON2);
            if Confirmacao = mrYes then
            begin
               Player.controls.currentPosition := 0;
               DestravaVideo.Enabled := true;
               Temporizador.Enabled := True;
            end
            else
               Self.Close;
         end;
      end;

      9:{Preparando para carregar uma nova mídia/URL}
      begin
         Temporizador.Enabled := False;
         ProgressBar.Enabled := False;
         btnAvanca.enabled := False;
         btnVolta.enabled := False;
      end;

      10:{Mídia pronta e carregada para começar a tocar.}
      begin
         Temporizador.Enabled := True;
      end;
   end;
end;

procedure TFormPlayer.ProgressBarChangeDynamic(Sender: TObject);
begin
   if Assigned(player) then
      player.controls.currentPosition := progressBar.Position;
end;

procedure TFormPlayer.TemporizadorTimer(Sender: TObject);
   var
      tmpAtual, tmpTotal : Double;
begin
   {Verificação do bom funcionamento do Player}
   if(Player.controls = nil)or(player.currentMedia.duration = 0)then Exit;

   {Variáveis que recebem a posição atual e a duração total da mídia}
   try
      tmpAtual := Player.controls.currentPosition;
      tmpTotal := Player.currentMedia.duration;
   except
      on E: Exception do
         raise Exception.Create('Erro ao ler tempos do Player: ' + E.Message);
   end;

   {Configurações da barra de progresso do Player}
   progressBar.Min := 0;
   progressBar.Max := Round(tmpTotal);
   ProgressBar.SelEnd := Round(tmpAtual);
   progressBar.OnChange := nil;
   progressBar.Position := Round(tmpAtual);
   progressBar.OnChange := ProgressBarChangeDynamic;

   {Configurações da exibição de tempo do Player}
   LB_Timer.Caption := FormatTime(tmpAtual)+' / '+FormatTime(tmpTotal);

   {Verificação da xibição de anúncios}
   if(VerificaVideo(Player.URL))and(not exibindoAnuncio)then
   begin
      if FCliente.IDPlano <> 3 then
      begin
         if CalcTempAnuncio(tmpAtual, tmpTotal)then
         begin
            Temporizador.Enabled := False;
            DisparaAnunc(tmpAtual);
         end;
      end
      else
         exit;
   end;
end;

procedure TFormPlayer.DestravaVideoTimer(Sender: TObject);
begin
   Player.Controls.pause;
   Player.Controls.play;
end;

procedure TFormPlayer.titleBarMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
 const
   SC_DRAGMOVE = $F012;
begin
   if Drag then
   begin
      if Button = mbLeft then
      begin
         ReleaseCapture;
         Perform(WM_SYSCOMMAND, SC_DRAGMOVE, 0);
      end;
   end
   else
      exit;
end;

function TFormPlayer.VerificaVideo(VideoAtual: WideString): boolean;
begin
   if VideoAtual = URLOriginal then
      Result := true
   else
      Result := false;
end;

procedure TFormPlayer.VolumeBarChangeDynamic(Sender: TObject);
begin
   if Assigned(Player) then
      player.settings.volume := 100 - volumeBar.position;

   VolumeBar.SelStart :=  Round(100 - player.settings.volume);

   if volumeBar.Position > 50 then
   begin
      btnVolume.Glyph := nil;
      listaIcons.GetBitmap(7, btnVolume.Glyph)
   end;

   if volumeBar.Position <= 50 then
   begin
      btnVolume.Glyph := nil;
      listaIcons.GetBitmap(6, btnVolume.Glyph);
   end;

   if volumeBar.Position = 100 then
   begin
      btnVolume.Glyph := nil;
      listaIcons.GetBitmap(8, btnVolume.Glyph)
   end;
end;

end.
