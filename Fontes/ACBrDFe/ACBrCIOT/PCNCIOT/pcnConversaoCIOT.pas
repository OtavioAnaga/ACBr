
{$I ACBr.inc}

unit pcnConversaoCIOT;

interface

uses
  SysUtils, StrUtils, Classes;

type
  TVersaoCIOT = (ve500);
  TCIOTIntegradora = (iNone, ieFrete, iRepom, iPamcard);
  TpCIOTTipoViagem = (Indefinido, Padrao, TAC_Agregado, Frota);
  TpCIOTUnidadeDeMedidaDaMercadoria = (umIndefinido, umTonelada, umKg);
  TpCIOTViagemTipoDeCalculo = (SemQuebra, QuebraSomenteUltrapassado, QuebraIntegral);
  TpCIOTTipoProporcao = (tpNenhum, tpPorcentagem, tpValorAbsoluto);
  TpCIOTDiferencaFreteTipo = (SemDiferenca, SomenteUltrapassado, Integral);
  TpCIOTDiferencaFreteBaseCalculo = (QuantidadeDesembarque, QuantidadeMenor);
  TpCIOTTipoPagamento = (TransferenciaBancaria, eFRETE);
  TpCIOTTipoCategoriaPagamento = (tcpAdiantamento, tcpEstadia, tcpQuitacao, tcpSemCategoria, tcpFrota);
  TStatusACBrCIOT = (stCIOTIdle, stCIOTEnviar, stCIOTRetEnviar, stCIOTEmail, stCIOTEnvioWebService);
  TLayOutCIOT = (LayCIOTOperacaoTransporte, LayCIOTRetEnviar);
  TpCIOTTipoProprietario = (tpTAC, tpETC, tpCTC);
  TpCIOTTipoEmbalagem = (Nenhum, Bigbag, Pallet, Granel, Container, Saco, Caixa, Unitario, Fardo);
  TpCIOTOperacao = (opObterPdf, opAdicionar, opRetificar, opCancelar, opAdicionarViagem, opAdicionarPagamento, opCancelarPagamento, opEncerrar);




  TSchemaCIOT     = (schErro, schEnviar, schEnviarRetorno);

const
  NAME_SPACE_CIOT  = '';//'xmlns:urn="ATMWebSvr"';

function LayOutToSchema(const t: TLayOutCIOT): TSchemaCIOT;

function LayOutToServico(const t: TLayOutCIOT): String;
function ServicoToLayOut(out ok: Boolean; const s: String): TLayOutCIOT;

function SchemaCIOTToStr(const t: TSchemaCIOT): String;
function StrToSchemaCIOT(out ok: Boolean; const s: String): TSchemaCIOT;

function StrToVersaoCIOT(out ok: Boolean; const s: String): TVersaoCIOT;
function VersaoCIOTToStr(const t: TVersaoCIOT): String;

function DblToVersaoCIOT(out ok: Boolean; const d: Double): TVersaoCIOT;
function VersaoCIOTToint(const t: TVersaoCIOT): Integer;
function VersaoCIOTToDbl(const t: TVersaoCIOT): Double;

function TipoViagemCIOTToStr(const t: TpCIOTTipoViagem): string;
function TipoEmbalagemCIOTToStr(const t: TpCIOTTipoEmbalagem): string;
function TpPagamentoToStr(const t: TpCIOTTipoPagamento): string;
function TpUnMedMercToStr(const t: TpCIOTUnidadeDeMedidaDaMercadoria): string;
function TpVgTipoCalculoToStr(const t: TpCIOTViagemTipoDeCalculo): string;
function TpProporcaoToStr(const t: TpCIOTTipoProporcao): string;
function TpDifFreteToStr(const t: TpCIOTDiferencaFreteTipo): string;
function TpDiferencaFreteBCToStr(const t: TpCIOTDiferencaFreteBaseCalculo): string;
function TpCatPagToStr(const t: TpCIOTTipoCategoriaPagamento): string;

function StrToEnumIntegradora(out ok: Boolean; const s: String): TCIOTIntegradora;

implementation

uses
  typinfo, pcnConversao, pcnAuxiliar;

function LayOutToSchema(const t: TLayOutCIOT): TSchemaCIOT;
begin
  case t of
    LayCIOTOperacaoTransporte:    Result := schEnviar;
    LayCIOTRetEnviar: Result := schEnviarRetorno;
  else
    Result := schErro;
  end;
end;

function LayOutToServico(const t: TLayOutCIOT): String;
begin
  Result := EnumeradoToStr(t,
    ['CIOTOperacaoTransporte', 'CIOTRetEnviar'],
    [LayCIOTOperacaoTransporte, LayCIOTRetEnviar] );
end;

function ServicoToLayOut(out ok: Boolean; const s: String): TLayOutCIOT;
begin
  Result := StrToEnumerado(ok, s,
//  ['CIOTEnviar', 'CIOTRetEnviar'],
  ['CIOTOperacaoTransporte', 'CIOTRetEnviar'],
  [LayCIOTOperacaoTransporte, LayCIOTRetEnviar] );
end;

function SchemaCIOTToStr(const t: TSchemaCIOT): String;
begin
  Result := GetEnumName(TypeInfo(TSchemaCIOT), Integer( t ) );
  Result := copy(Result, 4, Length(Result)); // Remove prefixo "sch"
end;

function StrToSchemaCIOT(out ok: Boolean; const s: String): TSchemaCIOT;
var
  P: Integer;
  SchemaStr: String;
begin
  P := pos('_', s);
  if P > 0 then
    SchemaStr := copy(s, 1, P-1)
  else
    SchemaStr := s;

  if LeftStr(SchemaStr, 3) <> 'sch' then
    SchemaStr := 'sch' + SchemaStr;

  Result := TSchemaCIOT( GetEnumValue(TypeInfo(TSchemaCIOT), SchemaStr ) );
end;

function StrToVersaoCIOT(out ok: Boolean; const s: String): TVersaoCIOT;
begin
  Result := StrToEnumerado(ok, s, ['5.00'], [ve500]);
end;

function VersaoCIOTToStr(const t: TVersaoCIOT): String;
begin
  Result := EnumeradoToStr(t, ['5.00'], [ve500]);
end;

function DblToVersaoCIOT(out ok: Boolean; const d: Double): TVersaoCIOT;
begin
  ok := True;

  if d = 5.0 then
    Result := ve500
  else
  begin
    Result := ve500;
    ok := False;
  end;
end;

function VersaoCIOTToInt(const t: TVersaoCIOT): Integer;
begin
  case t of
    ve500: Result := 5;
  else
    Result := 0;
  end;
end;

function TipoViagemCIOTToStr(const t: TpCIOTTipoViagem): String;
begin
  Result := EnumeradoToStr(t, ['Padrao', 'TAC_Agregado', 'Frota'],
                              [Padrao, TAC_Agregado, Frota]);
end;

function VersaoCIOTToDbl(const t: TVersaoCIOT): Double;
begin
  case t of
    ve500: Result := 5;
  else
    Result := 0;
  end;
end;

function TipoEmbalagemCIOTToStr(const t: TpCIOTTipoEmbalagem): string;
begin
  case t of
    Nenhum:    Result := '';
    Bigbag:    Result := 'Bigbag';
    Pallet:    Result := 'Pallet';
    Granel:    Result := 'Granel';
    Container: Result := 'Container';
    Saco:      Result := 'Saco';
    Caixa:     Result := 'Caixa';
    Unitario:  Result := 'Unitario';
    Fardo:     Result := 'Fardo';
  end;
end;

function TpPagamentoToStr(const t: TpCIOTTipoPagamento): string;
begin
  result := EnumeradoToStr(t, ['TransferenciaBancaria', 'eFRETE'],
                              [TransferenciaBancaria, eFRETE]);
end;
function TpUnMedMercToStr(const t: TpCIOTUnidadeDeMedidaDaMercadoria): string;
begin
  result := EnumeradoToStr(t, ['Tonelada', 'Kg'],
                              [umTonelada, umKg]);
end;

function TpVgTipoCalculoToStr(const t: TpCIOTViagemTipoDeCalculo): string;
begin
  result := EnumeradoToStr(t, ['SemQuebra', 'QuebraSomenteUltrapassado', 'QuebraIntegral'],
                              [SemQuebra, QuebraSomenteUltrapassado, QuebraIntegral]);
end;

function TpProporcaoToStr(const t: TpCIOTTipoProporcao): string;
begin
  result := EnumeradoToStr(t, ['Nenhum', 'Porcentagem', 'ValorAbsoluto'],
                              [tpNenhum, tpPorcentagem, tpValorAbsoluto]);
end;

function TpDifFreteToStr(const t: TpCIOTDiferencaFreteTipo): string;
begin
  result := EnumeradoToStr(t,['SemDiferenca', 'SomenteUltrapassado', 'Integral'],
                             [SemDiferenca, SomenteUltrapassado, Integral]);
end;

function TpDiferencaFreteBCToStr(const t: TpCIOTDiferencaFreteBaseCalculo): string;
begin
  result := EnumeradoToStr(t, ['QuantidadeDesembarque', 'QuantidadeMenor'],
                              [QuantidadeDesembarque, QuantidadeMenor]);
end;

function TpCatPagToStr(const t: TpCIOTTipoCategoriaPagamento): string;
begin
  result := EnumeradoToStr(t, ['Adiantamento', 'Estadia', 'Quitacao', 'SemCategoria', 'Frota'],
                              [tcpAdiantamento, tcpEstadia, tcpQuitacao, tcpSemCategoria, tcpFrota]);
end;

function StrToEnumIntegradora(out ok: Boolean; const s: String): TCIOTIntegradora;
begin
  Result := StrToEnumerado(ok, s,
                          ['ieFrete', 'iRepom', 'iPamcard'],
                          [ieFrete, iRepom, iPamcard] );
end;

end.

