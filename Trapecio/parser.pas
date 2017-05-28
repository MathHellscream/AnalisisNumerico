{Created by MathHellscream}
unit parser;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,
  StrUtils, Math;

type MathParser = Class
  private
  Stack: TStringList;
  ansStack: TStringList;
  variables: TStringList;
  varval: TStringList;
  operatorStack: TStringList;
  public
  constructor Create;overload;
  function evaluate(Texteq : String):string;
  procedure PrintStack();
  procedure PushValue(val: String);
  procedure InfixToPostfix();
  procedure printPostfix();
  function solve():double;
  function Precedence(a:char):integer;
  function elements(func: string):integer;
  function giveValue(func:string ;arr: array of double):double;
  function solOperator(op: string; first:double; second:double):double;
  function SpecChar(a:char):boolean;
  function Letter(a:char):boolean;
  function NumberOrPoint(a:char):boolean;
  procedure cleanAll();
end;

implementation

constructor MathParser.Create();
begin
  Stack := TStringList.Create;
  ansStack := TStringList.Create;
  variables := TStringList.Create;
  varval := TStringList.Create;
  operatorStack := TStringList.Create;
end;

procedure MathParser.cleanAll();
begin
  Stack.Clear;
  ansStack.Clear;
  variables.Clear;
  varval.clear;
  operatorStack.Clear;
end;

procedure MathParser.PushValue(val: String);
var value: string;
begin
  value:=val;
  stack.Add(value);
end;

function MathParser.SpecChar(a:char):boolean;
begin
  if (a = '*') or (a = '+') or (a = '/') or (a = '=') or (a = '-') or (a = '^') or (a='%')then
  begin
    SpecChar := true;
    exit;
  end;
  SpecChar:=false;
end;

function MathParser.Letter(a:char):boolean;
begin
  if ((ord(a)>=65) and (ord(a)<=90)) or ((ord(a)>=97) and (ord(a)<=122)) then
  begin
    letter:=true;

    exit;
  end;
  letter:=false;
end;

function MathParser.NumberOrPoint(a:char):boolean;
begin
  if ord(a)=46 then NumberOrPoint:=true
  else if (ord(a)>=48) and (ord(a)<=57) then NumberOrPoint := true
  else NumberOrPoint:=false;
end;

function MathParser.Precedence(a:char):integer;
begin
  if (a = '+') or (a = '-') then Precedence := 1
  else if (a = '*') or (a = '/') then Precedence := 2
  else if (a = '^') then Precedence:=3
  else if (a = '%') then Precedence:=100;
end;

function MathParser.elements(func: string):integer;
begin
  if func = 'sin(' then elements := 1
  else if func = 'cos(' then elements := 1
  else if func = 'tan(' then elements := 1
  else if func = 'sinh(' then elements := 1
  else if func = 'cosh(' then elements := 1
  else if func = 'tanh(' then elements := 1
  else if func = 'power(' then elements := 2
  else if func = 'ln(' then elements:=1;
end;

function MathParser.giveValue(func:string ;arr: array of double):double;
begin
  if func = 'sin(' then giveValue := sin(arr[0])
  else if func = 'cos(' then giveValue := cos(arr[0])
  else if func = 'tan(' then giveValue := tan(arr[0])
  else if func = 'sinh(' then giveValue := sinh(arr[0])
  else if func = 'cosh(' then giveValue := cosh(arr[0])
  else if func = 'tanh(' then giveValue := tanh(arr[0])
  else if func = 'power(' then giveValue := power(arr[0],arr[1])
  else if func = 'ln(' then giveValue := ln(arr[0]);
end;

function MathParser.solOperator(op: string; first:double; second:double):double;
begin
  //ShowMessage(concat('values',op,floattostr(first),floattostr(second)));
  if op='+' then solOperator := first + second
  else if op='-' then solOperator := first - second
  else if op='/' then solOperator := first / second
  else if op='*' then solOperator := first * second
  else if op='^' then solOperator := first ** second
  else if op='%' then solOperator := first * second;
end;

function MathParser.evaluate(Texteq : String) : String;
var Texto,tex1,tex2: String;
var i,j: integer;
var anss:Real;
begin
  stack.Clear;
  operatorStack.Clear;
  ansStack.Clear;
  (*Tratar de borrar esto*)
  Texto := DelSpace(Texteq);
  i := 1;
  (*Hacer Cambios para los espacios, y para las matrices*)
  while i <= Texto.length do
     begin
       if (Texto[i]='-') and ((i=1) or (Texto[i-1]='(') or (SpecChar(Texto[i-1]))) and (not NumberOrPoint(Texto[i+1])) then
       begin

         Tex1:=copy(Texto,1,i-1);
         Tex2:=copy(Texto,i+1,Texto.Length-i);
         Texto := concat(Tex1,'(-1)%',Tex2);

         continue;
       end;
       if ((NumberOrPoint(Texto[i])) or (letter(Texto[i]))) or (((Texto[i]='+') or (Texto[i]='-')) and ((i=1) or (SpecChar(Texto[i-1]) or (Texto[i-1]='(')))) then
       begin
         j:=i;
         if (not NumberOrPoint(Texto[j])) or (not letter(Texto[j])) then j := j+1;
         while (j<=Texto.length) and ((NumberOrPoint(Texto[j])) or (letter(Texto[j]))) do
            begin
              {ShowMessage(Texto[j]);}
              j := j+1;
              {ShowMessage(concat(Texto[j],': ', inttostr(ord(Texto[j]))));}
            end;
         if (j<= Texto.Length) and (Texto[j]='(') then j := j + 1;
         PushValue(copy(Texto,i,j-i));
         {ShowMessage(concat('Push: ',copy(Texto,i,j-i)));}
         i:=j-1;

       end
       else if SpecChar(Texto[i]) then
       begin
       PushValue(Texto[i]);
       end
       else if(Texto[i]=',') then PushValue(Texto[i])
       else if (Texto[i]='(') or (Texto[i]=')') then
       begin
       PushValue(Texto[i]);
       end;
       i := i+1;
     end;
  InfixToPostfix();
  i:= ansStack.Count-1;
  PrintStack();
  //ShowMessage('llegue a solve');
  anss:= solve();
  //ShowMessage('salio a solve');
  if isinfinite(anss) then evaluate := 'No dividir entre zero >:v'
  else if isnan(anss) then evaluate := 'Alguna operacion invalida'
  else evaluate:=floattostr(anss);
end;

procedure MathParser.InfixToPostfix();
var i: integer;
begin
  for i:= 0 to Stack.Count-1 do
  begin
    if (NumberOrPoint(Stack[i][Stack[i].Length])) and (not Letter(Stack[i][1])) then ansStack.Add(Stack[i])
    else if (Letter(Stack[i][1])) and (Stack[i][Stack[i].Length] <> '(') then ansStack.Add(Stack[i])
    else if SpecChar(Stack[i][Stack[i].Length]) then
    begin
      while ((operatorStack.Count > 0) and (SpecChar(operatorStack[operatorStack.Count-1][1]))) and (Precedence(operatorStack[operatorStack.Count-1][1]) >= Precedence(Stack[i][1])) do
         begin
           ansStack.Add(operatorStack[operatorStack.Count-1]);
           operatorStack.Delete(operatorStack.Count-1);
         end;
      operatorStack.Add(Stack[i]);
    end
    else if (Letter(Stack[i][1])) and (Stack[i][Stack[i].Length]='(') then
    begin
      operatorStack.Add(Stack[i]);
      operatorStack.Add('((');
    end
    else if(Stack[i][1]=',') then
    begin
      while operatorStack[operatorStack.count-1] <> '((' do
      begin
        ansStack.Add(operatorStack[operatorStack.Count-1]);
        operatorStack.Delete(operatorStack.Count-1);
      end;
    end
    else if (Stack[i][1]='(') then operatorStack.Add('(')
    else if(Stack[i][1] = ')') then
    begin
      while (operatorStack[operatorStack.count-1] <> '((') and (operatorStack[operatorStack.count-1] <> '(') do
      begin
        ansStack.Add(operatorStack[operatorStack.Count-1]);
        operatorStack.Delete(operatorStack.Count-1);
      end;
      if operatorStack[operatorStack.count-1]='(' then operatorStack.Delete(operatorStack.Count-1)
      else if operatorStack[operatorStack.count-1]='((' then
      begin
        operatorStack.Delete(operatorStack.Count-1);
        ansStack.Add(operatorStack[operatorStack.Count-1]);
        operatorStack.Delete(operatorStack.Count-1);
      end;
    end;
  end;

  while operatorStack.Count > 0 do
  begin
    ansStack.Add(operatorStack[operatorStack.Count-1]);
    operatorStack.Delete(operatorStack.Count-1);
  end;
  printPostfix();
end;

function MathParser.solve():double;
var i,j,pos:integer;
var val:real;
var arr:array of real;
begin
  operatorStack.Clear;
  if ansStack[ansStack.Count-1] = '='then
  begin
    pos:=-1;
    for i:=0 to variables.count-1 do
    begin
      if variables[i] = ansStack[0] then
      begin
        pos:=i;
        break;
      end;
    end;
    if pos=-1 then
    begin
    variables.Add(ansStack[0]);
    varval.Add(ansStack[1]);
    end
    else
    begin
      varval[pos]:=ansStack[1]
    end;
    exit;
  end;
  for i:=0 to ansStack.Count-1 do
  begin
    //if operatorStack.Count > 0  then ShowMessage(operatorStack[operatorStack.Count-1]);
    if (NumberOrPoint(ansStack[i][ansStack[i].Length])) and (not Letter(ansStack[i][1])) then
    begin
      operatorStack.Add(ansStack[i])
    end
    else if SpecChar(ansStack[i][ansStack[i].Length]) then
    begin
      val := solOperator(ansStack[i],strToFloat(operatorStack[operatorStack.Count-2]),strToFloat(operatorStack[operatorStack.Count-1]));
      operatorStack.Delete(operatorStack.Count-1);
      operatorStack.Delete(operatorStack.Count-1);
      operatorStack.add(FloatToStr(val));
    end
    else if (Letter(ansStack[i][1])) and (ansStack[i][ansStack[i].Length]<>'(') then
    begin
      j:=0;
      pos:=-1;
      while j<variables.Count do
      begin
        if variables[j] = ansStack[i] then
        begin
          pos:=j;
          break;
        end;
        j:=j+1;
      end;
      if pos<>-1 then operatorStack.Add(varval[pos])
      else
        begin
          Writeln('No available variable');
          exit;
        end;
    end
    else if (Letter(ansStack[i][1])) and (ansStack[i][ansStack[i].Length]='(') then
    begin
      SetLength(arr,elements(ansStack[i]));
      j:= elements(ansStack[i]) - 1;
      //ShowMessage(concat(ansStack[i],' ',inttostr(j)));
      while j >=0 do
      begin
        //ShowMessage(inttostr(operatorStack.Count));
        arr[j] := strToFloat(operatorStack[operatorStack.Count-1]);
        operatorStack.Delete(operatorStack.Count-1);
        j:= j-1;
      end;
      val := giveValue(ansStack[i],arr);
      operatorStack.Add(FloatToStr(val));
    end;
    solve := strtofloat(operatorStack[operatorStack.Count-1]);
  end;
end;

procedure MathParser.PrintStack();
var answ:string;
var i:integer;
begin
  i:=0;
  answ:='';
  while i < stack.Count do
     begin
       answ := concat(answ,stack[i],', ');
       i:=i+1;
     end;
  writeln(answ);
end;

procedure MathParser.printPostfix();
var answ:string;
var i:integer;
begin
  i:=0;
  answ:='';
  while i < ansstack.Count do
     begin
       answ := concat(answ,ansstack[i],', ');
       i:=i+1;
     end;
  writeln(answ);
end;

end.
