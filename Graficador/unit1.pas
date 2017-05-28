unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, TAGraph, TASeries, Forms, Controls, Graphics,
  Dialogs, StdCtrls, Grids, ExtCtrls, ColorBox, parser, TAChartUtils, Math;

type

  { TForm1 }

  TForm1 = class(TForm)
    ColorBox2: TColorBox;
    minpoly: TEdit;
    maxpoly: TEdit;
    iteratorpoly: TEdit;
    Label3: TLabel;
    Label4: TLabel;
    polinomio: TEdit;
    InterInput: TLabeledEdit;
    ShowPoints: TCheckBox;
    ShowValues: TCheckBox;
    ColorBox1: TColorBox;
    Ejey: TConstantLine;
    Ejex: TConstantLine;
    FuncionGrafica: TLineSeries;
    PoliGrafica: TLineSeries;
    maximoVal: TEdit;
    Iteration: TEdit;
    minimoVal: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    ObtenerPolinomio: TButton;
    AgregarHist: TButton;
    QuitarHist: TButton;
    GraficarPolinomio: TButton;
    GraficarFuncion: TButton;
    Grafica: TChart;
    FuncionText: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    Panel1: TPanel;
    InterAns: TLabeledEdit;
    LagrangeRb: TRadioButton;
    NewtonRb: TRadioButton;
    Historial: TStringGrid;
    procedure AgregarHistClick(Sender: TObject);
    procedure GraficarFuncionClick(Sender: TObject);
    procedure GraficarPolinomioClick(Sender: TObject);
    procedure ObtenerPolinomioClick(Sender: TObject);
    procedure QuitarHistClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;
  Parse: MathParser;

implementation

{$R *.lfm}

{ TForm1 }

function newtonCoef(a, b:integer):Real;
begin
  if a=b then newtonCoef := StrToFloat(Form1.Historial.Cols[a+1][1])
  else newtonCoef:= (newtonCoef(a+1,b) - newtonCoef(a,b-1))/(StrToFloat(Form1.Historial.Cols[b+1][0])-StrToFloat(Form1.Historial.Cols[a+1][0]));
end;


procedure TForm1.GraficarFuncionClick(Sender: TObject);
var val: Real;
var minval: Real;
var maxval: Real;
var iter: Real;
var x: Real;
begin
  Parse.evaluate('e=2.718281828459');
  Parse.evaluate('pi=3.141592653589');
  FuncionGrafica.Clear;
  FuncionGrafica.LinePen.Color:=ColorBox1.Colors[ColorBox1.ItemIndex];
  FuncionGrafica.ShowPoints := ShowPoints.Checked;
  if ShowValues.Checked then FuncionGrafica.Marks.Style:=smsValue
  else FuncionGrafica.Marks.Style:=smsNone;

  minval := StrToFloat(minimoVal.Text);
  maxval := StrToFloat(maximoVal.Text);
  iter := StrToFloat(Iteration.Text);
  x:=minval;
  while x <= maxval do
  begin
    x:=RoundTo(x,-6);
    Parse.evaluate(concat('x=',FloatToStr(x)));
    val := StrToFloat(Parse.evaluate(FuncionText.Text));
    FuncionGrafica.AddXY(x,val);
    x := x+iter;
  end;
end;

procedure TForm1.AgregarHistClick(Sender: TObject);
begin
  if (LagrangeRb.Checked) and (Historial.ColCount=7) then
  begin
    ShowMessage('No es recomendable tener mas de 6 valores con Lagrange');
  end;
  Historial.ColCount:=Historial.ColCount+1;
end;

procedure TForm1.GraficarPolinomioClick(Sender: TObject);
var xarr: array of string;
var farr: array of string;
var lagrange: array of string;
var polynom: string;
var i: integer;
var j: integer;
var cont:integer;
var val: Real;
var minval: Real;
var maxval: Real;
var iter: Real;
var x: Real;
begin
  SetLength(xarr,Historial.ColCount-1);
  SetLength(farr,Historial.ColCount-1);
  SetLength(lagrange,Historial.ColCount-1);
  polynom:='';
  for i:=1 to Historial.ColCount-1 do
  begin
    xarr[i-1] := Historial.Cols[i][0];
    farr[i-1] := Historial.Cols[i][1];
  end;
  if LagrangeRb.Checked then
  begin
  for i:=0 to Historial.ColCount-2 do
  begin
    //ShowMessage(concat(IntToStr(i),xarr[i]));
    polynom:=concat(polynom,farr[i],'*');
    //ShowMessage(concat(polynom,'.'));
    cont:=0;
    for j:=0 to Historial.ColCount-2 do
    begin
      if(i <> j) then
      begin
        polynom:=concat(polynom,'((x-',xarr[j],')/(',xarr[i],'-',xarr[j],'))');
        cont:=cont+1;
        if cont < Historial.ColCount - 2 then polynom:=Concat(polynom,'*');
      end;
      //ShowMessage(polynom);
    end;
    if i < Historial.ColCount-2 then polynom:=concat(polynom,'+');
    //ShowMessage(concat(polynom,';'));
  end;
  end
  else if NewtonRb.Checked then
  begin
    for i:=0 to Historial.ColCount-2 do
    begin
      //ShowMessage(IntToStr(i));
      polynom:=Concat(polynom,FloatToStr(newtonCoef(0,i)));
      if i<>0 then polynom:=Concat(polynom,'*');
      j:=0;
      while j <= i-1 do
      begin
        polynom:=Concat(polynom,'(x-',xarr[j],')');
        if j < i-1 then polynom:=Concat(polynom,'*');
        j:=j+1;
      end;
      if i < Historial.ColCount-2 then polynom:=Concat(polynom,'+');
    end;
  end;
  Polinomio.Text:=polynom;
  PoliGrafica.Clear;
  PoliGrafica.LinePen.Color:=ColorBox1.Colors[ColorBox2.ItemIndex];
  PoliGrafica.ShowPoints := ShowPoints.Checked;
  if ShowValues.Checked then PoliGrafica.Marks.Style:=smsValue
  else PoliGrafica.Marks.Style:=smsNone;

  minval := StrToFloat(minpoly.Text);
  maxval := StrToFloat(maxpoly.Text);
  iter := StrToFloat(iteratorpoly.Text);
  x:=minval;
  while x <= maxval do
  begin
    x:=RoundTo(x,-6);
    Parse.evaluate(concat('x=',FloatToStr(x)));
    val := StrToFloat(Parse.evaluate(polynom));
    PoliGrafica.AddXY(x,val);
    x := x+iter;
  end;

end;


procedure TForm1.ObtenerPolinomioClick(Sender: TObject);
var xarr: array of string;
var farr: array of string;
var lagrange: array of string;
var polynom: string;
var i: integer;
var j: integer;
var cont:integer;
begin
  SetLength(xarr,Historial.ColCount-1);
  SetLength(farr,Historial.ColCount-1);
  SetLength(lagrange,Historial.ColCount-1);
  polynom:='';
  for i:=1 to Historial.ColCount-1 do
  begin
    xarr[i-1] := Historial.Cols[i][0];
    farr[i-1] := Historial.Cols[i][1];
  end;
  if LagrangeRb.Checked then
  begin
  for i:=0 to Historial.ColCount-2 do
  begin
    //ShowMessage(concat(IntToStr(i),xarr[i]));
    polynom:=concat(polynom,farr[i],'*');
    //ShowMessage(concat(polynom,'.'));
    cont:=0;
    for j:=0 to Historial.ColCount-2 do
    begin
      if(i <> j) then
      begin
        polynom:=concat(polynom,'((x-',xarr[j],')/(',xarr[i],'-',xarr[j],'))');
        cont:=cont+1;
        if cont < Historial.ColCount - 2 then polynom:=Concat(polynom,'*');
      end;
      //ShowMessage(polynom);
    end;
    if i < Historial.ColCount-2 then polynom:=concat(polynom,'+');
    //ShowMessage(concat(polynom,';'));
  end;
  Polinomio.Text:=polynom;
  end
  else if NewtonRb.Checked then
  begin
    for i:=0 to Historial.ColCount-2 do
    begin
      //ShowMessage(IntToStr(i));
      polynom:=Concat(polynom,FloatToStr(newtonCoef(0,i)));
      if i<>0 then polynom:=Concat(polynom,'*');
      j:=0;
      while j <= i-1 do
      begin
        polynom:=Concat(polynom,'(x-',xarr[j],')');
        if j < i-1 then polynom:=Concat(polynom,'*');
        j:=j+1;
      end;
      if i < Historial.ColCount-2 then polynom:=Concat(polynom,'+');
    end;
  end;
  Polinomio.Text:=polynom;
  if InterInput.Text<>'' then
  begin
    parse.evaluate(concat('x=',InterInput.Text));
    InterAns.Text:=Parse.evaluate(polynom);
  end;
end;

procedure TForm1.QuitarHistClick(Sender: TObject);
begin
  if Historial.ColCount=1 then exit;
  Historial.DeleteCol(Historial.ColCount-1);
end;

end.

