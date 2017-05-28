unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, parser, math;

type

  { TForm1 }

  TForm1 = class(TForm)
    ButtonIntegrar: TButton;
    AnswerOutput: TEdit;
    ParamN: TEdit;
    Label3: TLabel;
    ParamA: TEdit;
    ParamB: TEdit;
    FuncionInput: TLabeledEdit;
    Label1: TLabel;
    Label2: TLabel;
    procedure ButtonIntegrarClick(Sender: TObject);
    function CalcularIntegral(func:string; a,b,h:double;n:integer):double;
    function Xi(a,i,h:double):double;
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;
  ParseMatematico: MathParser;

implementation

{$R *.lfm}

{ TForm1 }


function TForm1.Xi(a,i,h:double):double;
begin
  Xi:=a+i*h;
end;

function TForm1.CalcularIntegral(func:string; a,b,h:double;n:integer):double;
var sumatoria:double;
var fa,fb:double;
var itr:integer;
begin
  (*Primero evaluamos para fa*)
  ParseMatematico.evaluate(concat('x=',FloatToStr(Xi(a,0,h))));
  fa:=StrToFloat(ParseMatematico.evaluate(func));
  (*Luego evaluamos para fb *)
  ParseMatematico.evaluate(concat('x=',FloatToStr(Xi(a,n,h))));
  fb:=StrToFloat(ParseMatematico.evaluate(func));
  (*Luego evaluamos para la sumatoria*)
  sumatoria:=0;
  for itr:=1 to n-1 do
  begin
    ParseMatematico.evaluate(concat('x=',FloatToStr(Xi(a,itr,h))));
    sumatoria := sumatoria + StrToFloat(ParseMatematico.evaluate(func));
  end;
  CalcularIntegral := h*(((fa+fb)/2) + sumatoria);
  roundto(CalcularIntegral,10);
end;

procedure TForm1.ButtonIntegrarClick(Sender: TObject);
var h:double;
var ans:double;
begin
  h := (StrToFloat(ParamB.Text)-StrToFloat(ParamA.Text))/StrToFloat(ParamN.Text);
  ans := CalcularIntegral(FuncionInput.Text, StrToFloat(ParamA.Text), StrToFloat(ParamB.Text),h,StrToInt(ParamN.Text));
  AnswerOutput.Text:=FloatToStr(ans);
end;

end.

