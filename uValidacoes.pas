unit uValidacoes;

interface
  uses
    Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
    Dialogs, StdCtrls, DBCtrls, Mask, DB, DateUtils, SqlExpr;
type
   TValidacao = class
   private
   public
      function ValidaCPF(CPF : TMaskEdit):Boolean;
      function ValidaEdits(Container: TWinControl): Boolean;
      function ValidaTelefone(Telf : TMaskEdit):Boolean;
      function validaData(data : TMaskEdit):Boolean;
      function ValidaCEP(CEP : TMaskEdit):Boolean;
      function ValidaNumCartao(numCard : TMaskEdit):Boolean;
      function ValidaCVV(CVV : TEdit):Boolean;
      function ValidaEdit(informacao : TEdit):Boolean;
      function ValidaDataCartao(data : TMaskEdit): Boolean;
   end;

implementation

{ TValidacao }

function TValidacao.ValidaNumCartao(numCard : TMaskEdit): Boolean;
   var
      i, numDobrado, soma : Integer;
      Alternar : Boolean;
      Text : String;
begin
   {Algoritimo de Luhn}
   {2089 2928 2277 2920}
   Result := False;
   Alternar := False;
   soma := 0;
   Text := Trim(numCard.Text);

   text := StringReplace(Text, '_','',[rfReplaceAll]);
   if (Text = '0000000000000000') or (Length(text) < 16)then
   begin
      Result := False;
      Exit;
   end;

   for i := 1 to Length(Text) do
   begin
      if Text[i] = ' ' then
      begin
         Result := False;
         Exit;
      end;
   end;

   for I := Length(Text) Downto 1 do
   begin
      if Alternar then
      begin
        numDobrado := StrToInt(Text[i]) * 2;
        if numDobrado > 9 then
           numDobrado := numDobrado - 9;
        soma := soma + numDobrado;
      end
      else
         soma := soma + StrToInt(Text[i]);

      Alternar := not alternar;
   end;

   if soma mod 10 = 0 then
      Result := True;
end;

function TValidacao.ValidaCEP(CEP: TMaskEdit): boolean;
   var
      i : integer;
begin
   CEP.Text := StringReplace(CEP.Text,'-','',[rfReplaceAll] );
   if((CEP.Text = '00000000') or (Length(CEP.Text) < 8)  or
      (CEP.Text = '11111111') or (CEP.Text = '22222222') or
      (CEP.Text = '33333333') or (CEP.Text = '44444444') or
      (CEP.Text = '55555555') or (CEP.Text = '66666666') or
      (CEP.Text = '77777777') or (CEP.Text = '88888888') or
      (CEP.Text = '99999999')) then
   begin
      Result := False;
   end
   else
   begin
      Result := True;
   end;

   for i := 1 to Length(CEP.Text) do
   begin
      if CEP.Text[i] = ' ' then
      begin
         Result := False;
         Exit;
      end;
   end;
end;

function TValidacao.ValidaCPF(CPF: TMaskEdit): boolean;
var
   Verificador1, Verificador2 : String;
   soma, resto, i, peso : integer;
begin
   Result := False;

   CPF.Text := StringReplace(CPF.Text,'.','',[rfReplaceAll] );
   CPF.Text := StringReplace(CPF.Text,'-','',[rfReplaceAll] );

   if trim(CPF.Text) <> '' then
   begin
      if ((CPF.Text = '00000000000') or (CPF.Text = '11111111111') or
          (CPF.Text = '22222222222') or (CPF.Text = '33333333333') or
          (CPF.Text = '44444444444') or (CPF.Text = '55555555555') or
          (CPF.Text = '66666666666') or (CPF.Text = '77777777777') or
          (CPF.Text = '88888888888') or (CPF.Text = '99999999999')) then
      begin
          Result := False;
      end
      else
      begin
         try
            {*Primeiro Verificador*}
            soma := 0;
            peso := 10;
            for i := 1 to 9 do
            begin
               soma := soma + (StrToIntDef(CPF.Text[i], 0) * peso);
               dec(peso);
            end;
               resto := 11 - (soma mod 11);

            if((resto = 10) or (resto = 11)) then
               verificador1 := '0'
            else
               str(resto:1, Verificador1);

            {*Segundo Verificador*}
            soma := 0;
            peso := 11;
            for i := 1 to 10 do
            begin
               soma := soma + (StrToIntDef(CPF.Text[i], 0) * peso);
               dec(peso);
            end;
               resto := 11 - (soma mod 11);

            if((resto = 10) or (resto = 11)) then
               verificador2 := '0'
            else
               str(resto:1, Verificador2);

            if((verificador1 = CPF.Text[10]) and (verificador2 = CPF.Text[11]))then
               Result := True
            else
               Result := False;

         except
               Result := False;
         end;
      end;
   end;
end;

function TValidacao.ValidaCVV(CVV: TEdit): Boolean;
begin
   Result := False;

   if Trim(CVV.text) <> '' then
   begin
      if((CVV.Text = '000') or (CVV.Text = '111') or (CVV.Text = '222') or
         (CVV.Text = '333') or (CVV.Text = '444') or (CVV.Text = '555') or
         (CVV.Text = '666') or (CVV.Text = '777') or (CVV.Text = '888') or
         (CVV.Text = '999') or (Length(CVV.Text) < 3))then
         Result := False
      else
         Result := True;
   end;
end;

function TValidacao.validaData(data: TMaskEdit): boolean;
   var
      RecebeData : TDateTime;
begin
   Result := False;

   if trim(data.Text) <> '' then
   begin
      if tryStrToDate(data.Text, RecebeData) then
         Result := True
      else
         Result := False;
   end;
end;

function TValidacao.ValidaDataCartao(data: TMaskEdit): Boolean;
   var
      RecebeData : TDateTime;
begin
   Result := False;

   if tryStrToDate(data.Text, RecebeData) then
   begin
      if RecebeData > today then
         Result := True;
   end
   else
      Result := False;
end;

function TValidacao.ValidaEdit(informacao: TEdit): Boolean;
begin
   Result := False;

   if Trim(informacao.Text) <> '' then
      Result := True;
end;

function TValidacao.ValidaEdits(Container: TWinControl): Boolean;
   var
      i: integer;
begin
   Result := False;

   for i := 0 to Container.ControlCount - 1 do
   begin
      if (Container.Controls[i] is TEdit) then
      begin
         if Trim(TEdit(Container.Controls[i]).Text) <> '' then
         begin
            Result := True;
         end;
      end;
   end;
end;

function TValidacao.ValidaTelefone(Telf: TMaskEdit): boolean;
begin
   Result := False;

   Telf.Text := StringReplace(Telf.Text,'(','',[rfReplaceAll] );
   Telf.Text := StringReplace(Telf.Text,')','',[rfReplaceAll] );
   Telf.Text := StringReplace(Telf.Text,'-','',[rfReplaceAll] );

   if trim(Telf.Text) <> '' then
   begin
      if((copy(Telf.Text,1,2) = '00') or  (copy(Telf.Text,1,2) = '01') or
         (copy(Telf.Text,1,2) = '02') or  (copy(Telf.Text,1,2) = '03') or
         (copy(Telf.Text,1,2) = '04') or  (copy(Telf.Text,1,2) = '05') or
         (copy(Telf.Text,1,2) = '06') or  (copy(Telf.Text,1,2) = '07') or
         (copy(Telf.Text,1,2) = '08') or  (copy(Telf.Text,1,2) = '09') or
         (copy(Telf.Text,1,2) = '10') or  (copy(Telf.Text,3,1) <> '9') or
         (copy(Telf.Text,4,1) = '0')  or  (copy(Telf.Text,4,1) = '1')) then

         Result := False
      else
         Result := True;
   end;
end;

end.
