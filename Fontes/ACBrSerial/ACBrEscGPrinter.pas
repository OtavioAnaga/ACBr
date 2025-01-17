{******************************************************************************}
{ Projeto: Componentes ACBr                                                    }
{  Biblioteca multiplataforma de componentes Delphi para intera��o com equipa- }
{ mentos de Automa��o Comercial utilizados no Brasil                           }

{ Direitos Autorais Reservados (c) 2004 Daniel Simoes de Almeida               }

{ Colaboradores nesse arquivo:                                                 }

{  Voc� pode obter a �ltima vers�o desse arquivo na pagina do  Projeto ACBr    }
{ Componentes localizado em      http://www.sourceforge.net/projects/acbr      }

{  Esta biblioteca � software livre; voc� pode redistribu�-la e/ou modific�-la }
{ sob os termos da Licen�a P�blica Geral Menor do GNU conforme publicada pela  }
{ Free Software Foundation; tanto a vers�o 2.1 da Licen�a, ou (a seu crit�rio) }
{ qualquer vers�o posterior.                                                   }

{  Esta biblioteca � distribu�da na expectativa de que seja �til, por�m, SEM   }
{ NENHUMA GARANTIA; nem mesmo a garantia impl�cita de COMERCIABILIDADE OU      }
{ ADEQUA��O A UMA FINALIDADE ESPEC�FICA. Consulte a Licen�a P�blica Geral Menor}
{ do GNU para mais detalhes. (Arquivo LICEN�A.TXT ou LICENSE.TXT)              }

{  Voc� deve ter recebido uma c�pia da Licen�a P�blica Geral Menor do GNU junto}
{ com esta biblioteca; se n�o, escreva para a Free Software Foundation, Inc.,  }
{ no endere�o 59 Temple Street, Suite 330, Boston, MA 02111-1307 USA.          }
{ Voc� tamb�m pode obter uma copia da licen�a em:                              }
{ http://www.opensource.org/licenses/gpl-license.php                           }

{ Daniel Sim�es de Almeida  -  daniel@djsystem.com.br  -  www.djsystem.com.br  }
{              Pra�a Anita Costa, 34 - Tatu� - SP - 18270-410                  }

{******************************************************************************}

{******************************************************************************
|* Historico
|*
|* 11/02/2019:  Daniel Sim�es de Almeida
|*   Inicio do desenvolvimento
******************************************************************************}

{$I ACBr.inc}

unit ACBrEscGPrinter;

interface

uses
  Classes, SysUtils,
  ACBrPosPrinter, ACBrEscPosEpson;

type

  { TACBrEscCustomPos }

  { TACBrEscGPrinter }

  TACBrEscGPrinter = class(TACBrEscPosEpson)
  protected
    procedure VerificarKeyCodes; override;
  public
    constructor Create(AOwner: TACBrPosPrinter);
  end;

implementation

uses
  strutils, math,
  ACBrUtil, ACBrConsts;

{ TACBrEscGPrinter }

constructor TACBrEscGPrinter.Create(AOwner: TACBrPosPrinter);
begin
  inherited Create(AOwner);

  fpModeloStr := 'EscGPrinter';

  {(*}
  with Cmd  do
  begin
    Beep := ESC + 'B' + #1 + #3;   // n - Refers to the number of buzzer times,
  end;
  {*)}
end;

procedure TACBrEscGPrinter.VerificarKeyCodes;
begin
  with fpPosPrinter.ConfigLogo do
  begin
    if (KeyCode1 <> 1) or (KeyCode2 <> 0) then
      raise EPosPrinterException.Create(fpModeloStr+' apenas aceitas KeyCode1=1, KeyCode2=0');
  end;
end;

end.

