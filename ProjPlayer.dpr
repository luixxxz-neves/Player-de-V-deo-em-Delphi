program ProjPlayer;

uses
  Forms,
  Form_Player in 'Form_Player.pas' {FormPlayer},
  ModalConfirmacao in 'ModalConfirmacao.pas' {FModalConfirmar},
  uValidacoes in 'uValidacoes.pas',
  uCliente in 'uCliente.pas',
  WMPLib_TLB in 'WMPLib_TLB.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormPlayer, FormPlayer);
  Application.CreateForm(TFModalConfirmar, FModalConfirmar);
  Application.Run;
end.
