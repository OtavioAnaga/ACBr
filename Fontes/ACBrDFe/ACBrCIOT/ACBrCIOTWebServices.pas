
{$I ACBr.inc}

unit ACBrCIOTWebServices;

interface

uses
  Classes, SysUtils,
  ACBrDFe, ACBrDFeWebService,
  ACBrCIOTContratos, ACBrCIOTConfiguracoes,
  pcnAuxiliar, pcnConversao, pcnConversaoCIOT, pcnCIOT, pcnRetEnvCIOT;

const
  CURL_WSDL = '';

type

  { TCIOTWebService }

  TCIOTWebService = class(TDFeWebService)
  private
  protected
    FPStatus: TStatusACBrCIOT;
    FPLayout: TLayOutCIOT;
    FPConfiguracoesCIOT: TConfiguracoesCIOT;

    function ExtrairModeloChaveAcesso(AChaveCIOT: String): String;

  protected
    procedure InicializarServico; override;
    procedure DefinirEnvelopeSoap; override;
    procedure DefinirURL; override;
    function GerarVersaoDadosSoap: String; override;
    procedure EnviarDados; override;
    procedure FinalizarServico; override;

  public
    constructor Create(AOwner: TACBrDFe); override;
    procedure Clear; override;

    property Status: TStatusACBrCIOT read FPStatus;
    property Layout: TLayOutCIOT read FPLayout;
  end;

  { TCIOTEnviar }

  TCIOTEnviar = class(TCIOTWebService)
  private
    FContratos: TContratos;
    FRetornoEnvio: TRetornoEnvio;
    FCodRetorno: Integer;
  protected
    procedure DefinirServicoEAction; override;
    procedure DefinirDadosMsg; override;
    function TratarResposta: Boolean; override;

    function GerarMsgLog: String; override;
    function GerarMsgErro(E: Exception): String; override;
  public
    constructor Create(AOwner: TACBrDFe; AContratos: TContratos);
      reintroduce; overload;
    destructor Destroy; override;
    procedure Clear; override;

    property RetornoEnvio: TRetornoEnvio read FRetornoEnvio;
    property CodRetorno: Integer         read FCodRetorno     write FCodRetorno;
  end;


  { TCIOTEnvioWebService }

  TCIOTEnvioWebService = class(TCIOTWebService)
  private
    FXMLEnvio: String;
    FPURLEnvio: String;
    FVersao: String;
    FSoapActionEnvio: String;
  protected
    procedure DefinirURL; override;
    procedure DefinirServicoEAction; override;
    procedure DefinirDadosMsg; override;
    function TratarResposta: Boolean; override;

    function GerarMsgErro(E: Exception): String; override;
    function GerarVersaoDadosSoap: String; override;
  public
    constructor Create(AOwner: TACBrDFe); override;
    destructor Destroy; override;
    function Executar: Boolean; override;
    procedure Clear; override;

    property XMLEnvio: String read FXMLEnvio write FXMLEnvio;
    property URLEnvio: String read FPURLEnvio write FPURLEnvio;
    property SoapActionEnvio: String read FSoapActionEnvio write FSoapActionEnvio;
  end;

  { TWebServices }

  TWebServices = class
  private
    FACBrCIOT: TACBrDFe;
    FCIOTEnviar: TCIOTEnviar;
    FEnvioWebService: TCIOTEnvioWebService;
  public
    constructor Create(AOwner: TACBrDFe); overload;
    destructor Destroy; override;

    function Envia: Boolean;

    property ACBrCIOT: TACBrDFe read FACBrCIOT write FACBrCIOT;
    property CIOTEnviar: TCIOTEnviar read FCIOTEnviar write FCIOTEnviar;
    property EnvioWebService: TCIOTEnvioWebService read FEnvioWebService write FEnvioWebService;
  end;

implementation

uses
  StrUtils, Math,
  ACBrUtil, ACBrCIOT,
  pcnGerador, pcnLeitor,
  pcnCIOTW;

{ TCIOTWebService }

constructor TCIOTWebService.Create(AOwner: TACBrDFe);
begin
  inherited Create(AOwner);

  FPConfiguracoesCIOT := TConfiguracoesCIOT(FPConfiguracoes);
  FPLayout := LayCIOTOperacaoTransporte;
  FPStatus := stCIOTIdle;

  FPSoapVersion := 'soap12';
  FPHeaderElement := '';
  FPBodyElement := '';
  FPSoapEnvelopeAtributtes := 'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" '+
                              'xmlns:xsd="http://www.w3.org/2001/XMLSchema" '+
                              'xmlns:soap12="http://www.w3.org/2003/05/soap-envelope/"';
end;

procedure TCIOTWebService.Clear;
begin
  inherited Clear;

  FPStatus := stCIOTIdle;
  FPMimeType := 'text/xml';
  FPDFeOwner.SSL.UseCertificateHTTP := True;
end;

function TCIOTWebService.ExtrairModeloChaveAcesso(AChaveCIOT: String): String;
begin
  AChaveCIOT := OnlyNumber(AChaveCIOT);
  if ValidarChave('CIOT' + AChaveCIOT) then
    Result := copy(AChaveCIOT, 21, 2)
  else
    Result := '';
end;

procedure TCIOTWebService.InicializarServico;
begin
  { Sobrescrever apenas se necess�rio }
  inherited InicializarServico;

  TACBrCIOT(FPDFeOwner).SetStatus(FPStatus);
end;

procedure TCIOTWebService.DefinirEnvelopeSoap;
var
  Texto: String;
begin
  {$IFDEF FPC}
   Texto := '<' + ENCODING_UTF8 + '>';    // Envelope j� est� sendo montado em UTF8
  {$ELSE}
   Texto := '';  // Isso for�ar� a convers�o para UTF8, antes do envio
  {$ENDIF}

  FPDadosMsg := RemoverDeclaracaoXML(FPDadosMsg);

  Texto := Texto + '<' + FPSoapVersion + ':Envelope ' + FPSoapEnvelopeAtributtes + '>';
//  Texto := Texto + '<' + FPSoapVersion + ':Header/>';
  Texto := Texto + '<' + FPSoapVersion + ':Body>';
//  Texto := Texto + '<' + FPBodyElement + '>';
  Texto := Texto + FPDadosMsg;
//  Texto := Texto + '</' + FPBodyElement + '>';
  Texto := Texto + '</' + FPSoapVersion + ':Body>';
  Texto := Texto + '</' + FPSoapVersion + ':Envelope>';

  FPEnvelopeSoap := Texto;
end;

procedure TCIOTWebService.DefinirURL;
var
  Versao: Double;
begin
  { sobrescrever apenas se necess�rio.
    Voc� tamb�m pode mudar apenas o valor de "FLayoutServico" na classe
    filha e chamar: Inherited;     }

  Versao := 0;
  FPVersaoServico := '';
  FPURL := '';

  TACBrCIOT(FPDFeOwner).LerServicoDeParams(FPLayout, Versao, FPURL);
  FPVersaoServico := FloatToString(Versao, '.', '0.00');
end;

function TCIOTWebService.GerarVersaoDadosSoap: String;
begin
  { Sobrescrever apenas se necess�rio }

  if EstaVazio(FPVersaoServico) then
    FPVersaoServico := TACBrCIOT(FPDFeOwner).LerVersaoDeParams(FPLayout);

  Result := '<versaoDados>' + FPVersaoServico + '</versaoDados>';
end;

procedure TCIOTWebService.FinalizarServico;
begin
  { Sobrescrever apenas se necess�rio }

  TACBrCIOT(FPDFeOwner).SetStatus(stCIOTIdle);
end;

procedure TCIOTWebService.EnviarDados;
Var
  Tentar, Tratado: Boolean;
begin
  { sobrescrever apenas se necess�rio.
    Voc� tamb�m pode mudar apenas o valor de "FLayoutServico" na classe
    filha e chamar: Inherited;     }

  FPRetWS := '';
  FPRetornoWS := '';
  Tentar := True;

  FPEnvelopeSoap := UTF8ToNativeString(FPEnvelopeSoap);

  while Tentar do
  begin
    Tentar := False;
    Tratado := False;

    // Tem Certificado carregado ?
    if (FPConfiguracoes.Certificados.NumeroSerie <> '') then
      if FPConfiguracoes.Certificados.VerificarValidade then
        if (FPDFeOwner.SSL.CertDataVenc < Now) then
          GerarException(ACBrStr('Data de Validade do Certificado j� expirou: ' +
                                 FormatDateBr(FPDFeOwner.SSL.CertDataVenc)));

    try
      FPRetornoWS := FPDFeOwner.SSL.Enviar(FPEnvelopeSoap, FPURL, FPSoapAction, FPMimeType);
    except
      if Assigned(FPDFeOwner.OnTransmitError) then
        FPDFeOwner.OnTransmitError(FPDFeOwner.SSL.HTTPResultCode,
                                   FPDFeOwner.SSL.InternalErrorCode,
                                   FPURL, FPEnvelopeSoap, FPSoapAction,
                                   Tentar, Tratado);

      if not (Tentar or Tratado) then
        raise;
    end;
  end;
end;

{ TCIOTEnvioWebService }

constructor TCIOTEnvioWebService.Create(AOwner: TACBrDFe);
begin
  inherited Create(AOwner);

  FPStatus := stCIOTEnvioWebService;
end;

destructor TCIOTEnvioWebService.Destroy;
begin
  inherited Destroy;
end;

function TCIOTEnvioWebService.Executar: Boolean;
begin
  Result := inherited Executar;
end;

procedure TCIOTEnvioWebService.Clear;
begin
  inherited Clear;

  FVersao := '';
end;

procedure TCIOTEnvioWebService.DefinirURL;
begin
  FPURL := FPURLEnvio;
end;

procedure TCIOTEnvioWebService.DefinirServicoEAction;
begin
  FPServico := FPSoapAction;
end;

procedure TCIOTEnvioWebService.DefinirDadosMsg;
var
  LeitorXML: TLeitor;
begin
  LeitorXML := TLeitor.Create;
  try
    LeitorXML.Arquivo := FXMLEnvio;
    LeitorXML.Grupo := FXMLEnvio;
    FVersao := LeitorXML.rAtributo('versao')
  finally
    LeitorXML.Free;
  end;

  FPDadosMsg := FXMLEnvio;
end;

function TCIOTEnvioWebService.TratarResposta: Boolean;
begin
  FPRetWS := SeparaDados(FPRetornoWS, 'soap:Body');
  Result := True;
end;

function TCIOTEnvioWebService.GerarMsgErro(E: Exception): String;
begin
  Result := ACBrStr('WebService: '+FPServico + LineBreak +
                    '- Inativo ou Inoperante tente novamente.');
end;

function TCIOTEnvioWebService.GerarVersaoDadosSoap: String;
begin
  Result := '<versaoDados>' + FVersao + '</versaoDados>';
end;

{ TWebServices }

constructor TWebServices.Create(AOwner: TACBrDFe);
begin
  FACBrCIOT := TACBrCIOT(AOwner);

  FCIOTEnviar := TCIOTEnviar.Create(FACBrCIOT, TACBrCIOT(FACBrCIOT).Contratos);

  FEnvioWebService := TCIOTEnvioWebService.Create(FACBrCIOT);
end;

destructor TWebServices.Destroy;
begin
  FCIOTEnviar.Free;
  FEnvioWebService.Free;

  inherited Destroy;
end;

function TWebServices.Envia: Boolean;
begin
  if not CIOTEnviar.Executar then
    CIOTEnviar.GerarException( CIOTEnviar.Msg );

  Result := True;
end;

{ TCIOTEnviar }

procedure TCIOTEnviar.Clear;
begin
  inherited Clear;

  FPStatus := stCIOTEnviar;
  FPLayout := LayCIOTOperacaoTransporte;
  FPArqEnv := 'ped-CIOT';
  FPArqResp := 'res-CIOT';

  FCodRetorno := 0;

  if Assigned(FRetornoEnvio) then
    FRetornoEnvio.Free;

  FRetornoEnvio := TRetornoEnvio.Create;
end;

constructor TCIOTEnviar.Create(AOwner: TACBrDFe; AContratos: TContratos);
begin
  inherited Create(AOwner);

  FContratos := AContratos;
end;

procedure TCIOTEnviar.DefinirDadosMsg;
begin
  FPDadosMsg := FContratos.Items[0].XMLAssinado;
end;

procedure TCIOTEnviar.DefinirServicoEAction;
var
  Servico, Acao: String;
begin
  Servico  := 'http://schemas.ipc.adm.br/efrete/pef/';

  case FContratos.Items[0].CIOT.Integradora.Operacao of
    opObterPdf:           Acao := 'ObterOperacaoTransportePdf';
    opAdicionar:          Acao := 'AdicionarOperacaoTransporte';
    opRetificar:          Acao := 'RetificarOperacaoTransporte';
    opCancelar:           Acao := 'CancelarOperacaoTransporte';
    opAdicionarViagem:    Acao := 'AdicionarViagem';
    opAdicionarPagamento: Acao := 'AdicionarPagamento';
    opCancelarPagamento:  Acao := 'CancelarPagamento';
    opEncerrar:           Acao := 'EncerrarOperacaoTransporte';
  end;

  FPServico := CURL_WSDL + Acao;
//  FPURL := FPServico;
  FPSoapAction := Servico + Acao;
end;

destructor TCIOTEnviar.Destroy;
begin
  FRetornoEnvio.Free;

  inherited Destroy;
end;

function TCIOTEnviar.GerarMsgErro(E: Exception): String;
begin
  Result := ACBrStr('WebService Enviar Documento:' + LineBreak +
                    '- Inativo ou Inoperante tente novamente.');
end;

function TCIOTEnviar.GerarMsgLog: String;
var
  xMsg: String;
begin
  xMsg := '';

  if CodRetorno <> 0 then
  begin
    xMsg := Format(ACBrStr('Controle Negocial:' + LineBreak +
                           ' Codigo Retorno: %s ' + LineBreak +
                           ' Mensagem: %s ' + LineBreak),
                 [CodRetorno,
                  FPMsg]);
  end;

  Result := xMsg;
end;

function TCIOTEnviar.TratarResposta: Boolean;
begin
  FPRetWS := SeparaDados(FPRetornoWS, 'soapenv:Body');

  RetornoEnvio.Integradora := FPConfiguracoesCIOT.Geral.Integradora;
  RetornoEnvio.Leitor.Arquivo := ParseText(FPRetWS);
  RetornoEnvio.LerXml;

  FPMsg := '';
  CodRetorno := StrToInt(RetornoEnvio.RetEnvio.DadosRet.ControleNegocial.CodRetorno);

  if CodRetorno <> 0 then
    FPMsg := RetornoEnvio.RetEnvio.DadosRet.ControleNegocial.Retorno;

  Result := (StrToInt(RetornoEnvio.RetEnvio.CodRetorno) = 0);
end;

end.
