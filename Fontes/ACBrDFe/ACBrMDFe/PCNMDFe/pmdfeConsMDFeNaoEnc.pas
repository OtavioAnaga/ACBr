{******************************************************************************}
{ Projeto: Componente ACBrMDFe                                                 }
{  Biblioteca multiplataforma de componentes Delphi                            }
{                                                                              }
{  Voc� pode obter a �ltima vers�o desse arquivo na pagina do Projeto ACBr     }
{ Componentes localizado em http://www.sourceforge.net/projects/acbr           }
{                                                                              }
{                                                                              }
{  Esta biblioteca � software livre; voc� pode redistribu�-la e/ou modific�-la }
{ sob os termos da Licen�a P�blica Geral Menor do GNU conforme publicada pela  }
{ Free Software Foundation; tanto a vers�o 2.1 da Licen�a, ou (a seu crit�rio) }
{ qualquer vers�o posterior.                                                   }
{                                                                              }
{  Esta biblioteca � distribu�da na expectativa de que seja �til, por�m, SEM   }
{ NENHUMA GARANTIA; nem mesmo a garantia impl�cita de COMERCIABILIDADE OU      }
{ ADEQUA��O A UMA FINALIDADE ESPEC�FICA. Consulte a Licen�a P�blica Geral Menor}
{ do GNU para mais detalhes. (Arquivo LICEN�A.TXT ou LICENSE.TXT)              }
{                                                                              }
{  Voc� deve ter recebido uma c�pia da Licen�a P�blica Geral Menor do GNU junto}
{ com esta biblioteca; se n�o, escreva para a Free Software Foundation, Inc.,  }
{ no endere�o 59 Temple Street, Suite 330, Boston, MA 02111-1307 USA.          }
{ Voc� tamb�m pode obter uma copia da licen�a em:                              }
{ http://www.opensource.org/licenses/lgpl-license.php                          }
{                                                                              }
{ Daniel Sim�es de Almeida  -  daniel@djsystem.com.br  -  www.djsystem.com.br  }
{              Pra�a Anita Costa, 34 - Tatu� - SP - 18270-410                  }
{                                                                              }
{******************************************************************************}

{*******************************************************************************
|* Historico
|*
|* 01/08/2012: Italo Jurisato Junior
|*  - Doa��o do componente para o Projeto ACBr
*******************************************************************************}

{$I ACBr.inc}

unit pmdfeConsMDFeNaoEnc;

interface

uses
  SysUtils, Classes,
  pcnAuxiliar, pcnConversao, pcnGerador, ACBrUtil, pmdfeConversaoMDFe,
  pcnConsts;

type

  TConsMDFeNaoEnc = class(TObject)
  private
    FGerador: TGerador;
    FtpAmb: TpcnTipoAmbiente;
    FCNPJCPF: String;
    FVersao: String;
  public
    constructor Create;
    destructor Destroy; override;
    function GerarXML: Boolean;
    property Gerador: TGerador       read FGerador write FGerador;
    property tpAmb: TpcnTipoAmbiente read FtpAmb   write FtpAmb;
    property CNPJCPF: String         read FCNPJCPF write FCNPJCPF;
    property Versao: String          read FVersao  write FVersao;
  end;

implementation

{ TConsMDFeNaoEnc }

constructor TConsMDFeNaoEnc.Create;
begin
  inherited Create;
  FGerador := TGerador.Create;
end;

destructor TConsMDFeNaoEnc.Destroy;
begin
  FGerador.Free;
  inherited;
end;

function TConsMDFeNaoEnc.GerarXML: Boolean;
begin
  Gerador.ArquivoFormatoXML := '';

  Gerador.wGrupo('consMDFeNaoEnc ' + NAME_SPACE_MDFE + ' versao="' + Versao + '"');
  Gerador.wCampo(tcStr, 'CP03', 'tpAmb', 01, 01, 1, tpAmbToStr(FtpAmb), DSC_TPAMB);
  Gerador.wCampo(tcStr, 'CP04', 'xServ', 24, 24, 1, ACBrStr('CONSULTAR N�O ENCERRADOS'), DSC_XSERV);
  Gerador.wCampoCNPJCPF('CP05', 'CP05a', OnlyNumber(FCNPJCPF));
//  Gerador.wCampo(tcEsp, 'CP05', 'CNPJ ', 14, 14, 1, OnlyNumber(FCNPJCPF), DSC_CNPJ);
  Gerador.wGrupo('/consMDFeNaoEnc');

  Result := (Gerador.ListaDeAlertas.Count = 0);
end;

end.

