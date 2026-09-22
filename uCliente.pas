unit uCliente;

interface

uses
   Classes, Types;

type
   TBytes = TByteDynArray;

   PCliente = ^TCliente;

   TCliente = record
      ID: Integer;
      IDPlano: Integer;
      Nome: String;
      Telefone: String;
      CPF: String;
      Email: String;
      Senha: String;
      DataNasc: TDateTime;
      DataAssinatura: TDateTime;
      Avatar: TBytes;
      SFDelete: Integer;

      procedure Clear;
      function GetObjectString(Prev: PCliente = nil): string;
      function DataToLog(AData: TDateTime): string;
   end;

   TClienteLogado = class(TPersistent)
   private
      FID: Integer;
      FIDPlano: Integer;
      FNome: String;
      FTelefone: String;
      FCPF: String;
      FEmail: String;
      FSenha: String;
      FDataNasc: TDateTime;
      FDataAssinatura: TDateTime;
      FAvatar: TBytes;
      FSFDelete: Integer;

      class var FInstancia: TCliente;

   published
      property ID: Integer read FID write FID;
      property IDPlano: Integer read FIDPlano write FIDPlano;
      property Nome: string read FNome write FNome;
      property Telefone: string read FTelefone write FTelefone;
      property CPF: string read FCPF write FCPF;
      property Email: string read FEmail write FEmail;
      property Senha: string read FSenha write FSenha;
      property DataNasc: TDateTime read FDataNasc write FDataNasc;
      property DataAssinatura: TDateTime read FDataAssinatura
        write FDataAssinatura;
      property Avatar: TBytes read FAvatar write FAvatar;
      property SFDelete: Integer read FSFDelete write FSFDelete;
   public
      procedure AddUser(ACliente: TCliente);
      procedure Clear;

      class function getUserLogado: TCliente;
   end;

implementation

uses
   SysUtils;

{ TCliente }

procedure TCliente.Clear;
begin
   ID := 0;
   IDPlano := 0;
   Nome := '';
   Telefone := '';
   CPF := '';
   Email := '';
   Senha := '';
   DataNasc := 0;
   DataAssinatura := 0;
   Avatar := nil;
   SFDelete := -1;
end;

function TCliente.GetObjectString(Prev: PCliente = nil): string;
var
   Prevs: string;
   LSenha: string;
begin
   LSenha := 'SENHA: *******';

   if not Assigned(Prev) then
   begin
      Result := Format
        ('Cliente: {ID: %d; ID PLANO: %d; NOME: %s; TELEFONE: %s; CPF: %s; ' +
        'EMAIL: %s; SENHA: *******; DATA NASCIMENTO: %s; DATA ASSINATURA: %s}',
        [ID, IDPlano, Nome, Telefone, CPF, Email, DateToStr(DataNasc),
        DateToStr(DataAssinatura)]);
   end
   else
   begin
      if Prev^.Senha <> Senha then
         LSenha := 'SENHA: [ALTERADA]';

      Prevs := Format
        ('Antiga: {ID: %d; ID PLANO: %d; NOME: %s; TELEFONE: %s; CPF: %s; ' +
        'EMAIL: %s; SENHA: *******; DATA NASCIMENTO: %s; DATA ASSINATURA: %s}',
        [Prev^.ID, Prev^.IDPlano, Prev^.Nome, Prev^.Telefone, Prev^.CPF,
        Prev^.Email, DateToStr(Prev^.DataNasc),
        DateToStr(Prev^.DataAssinatura)]);

      Result := Prevs + sLineBreak +
        Format('Nova: {ID: %d; ID PLANO: %d; NOME: %s; TELEFONE: %s; CPF: %s; '
        + 'EMAIL: %s; ' + LSenha +
        '; DATA NASCIMENTO: %s; DATA ASSINATURA: %s}',
        [ID, IDPlano, Nome, Telefone, CPF, Email, DataToLog(DataNasc),
        DataToLog(DataAssinatura)]);
   end;
end;

function TCliente.DataToLog(AData: TDateTime): string;
begin
   if AData = 0 then
      Result := '<vazio>'
   else
      Result := DateToStr(AData);
end;

{ TClienteLogado }

procedure TClienteLogado.AddUser(ACliente: TCliente);
begin
   FInstancia := ACliente;
end;

procedure TClienteLogado.Clear;
begin
   with FInstancia do
   begin
      ID := 0;
      IDPlano := 0;
      Nome := '';
      Telefone := '';
      CPF := '';
      Email := '';
      Senha := '';
      DataNasc := 0;
      DataAssinatura := 0;
      Avatar := nil;
      SFDelete := -1;
   end;
end;

class function TClienteLogado.getUserLogado: TCliente;
begin
   Result := FInstancia;
end;

end.
