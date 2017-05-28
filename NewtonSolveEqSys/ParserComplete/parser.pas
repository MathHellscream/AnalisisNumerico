{
  Math Parser
  Created by MathHellscream
}
unit parser;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,
  StrUtils, Math,Contnrs;

type Matriz = Class
  public
    nombre:String;
    filas:integer;
    columnas:integer;
    data:array of array of double;
    constructor Create(fil,col:integer; nom:string);overload;
    function ProductoM(matrix2:Matriz):Matriz;
    function ProductoE(esc:double):Matriz;
    function DivisionE(esc:double):Matriz;
    function Suma(matrix2:Matriz):Matriz;
    function Resta(matrix2:Matriz):Matriz;
    function Potencia(expo:Integer):Matriz;
    function Determinante():double;
    function Transpuesta():Matriz;
    function Inversa():Matriz;
    function Adjunta():Matriz;
    procedure PrintM();
end;

generic TA<Matriz> = class(TObjectList)
end;
ListofMatriz = specialize TA <Matriz>;

type MathParser = Class
  private

  Stack: TStringList;
  ansStack: TStringList;
  variables: TStringList;
  tmpMatrix: ListofMatriz;
  varval: TStringList;
  operatorStack: TStringList;
  public
  constructor Create;overload;
  function evaluate(Texteq : String):string;
  procedure PrintStack();
  procedure PushValue(val: String);
  procedure InfixToPostfix();
  procedure printPostfix();
  function solve():string;
  function Precedence(a:char):integer;
  function elements(func: string):integer;
  function elementsMatrix(func:string):integer;
  function giveValue(func:string; arr: array of double):string;
  function giveValueMatrix(func:string; mArray:array of string):string;
  function solOperator(op: string; first:string; second:string):string;
  function SpecChar(a:char):boolean;
  function Letter(a:char):boolean;
  function NumberOrPoint(a:char):boolean;
  function Number(a:char):boolean;
  procedure cleanAll();
end;

implementation
(*Matrix Implementation*)

procedure Matriz.PrintM();
var i,j:integer;
begin
  for i:=0 to filas-1 do
    begin
      for j:=0 to columnas-1 do
      begin
        write(data[i][j],' ')
      end;
      writeln('');
    end;
end;

constructor Matriz.Create(fil,col:integer;nom:String);
begin
  nombre:=nom;
  filas:=fil;
  columnas:=col;
  SetLength(data,fil,col);
end;

function Matriz.Suma(matrix2:Matriz):Matriz;
var ansMatrix:Matriz;
var i,j:integer;
begin
  ansMatrix := Matriz.Create(filas,columnas,nombre);
  for i:=low(ansMatrix.data) to high(ansMatrix.data) do
    begin
      for j:=low(ansMatrix.data[i]) to high(ansMatrix.data[i]) do ansMatrix.data[i][j]:=data[i][j] + matrix2.data[i][j];
    end;
  Suma:=ansMatrix;
end;

function Matriz.Resta(matrix2:Matriz):Matriz;
var ansMatrix:Matriz;
var i,j:integer;
begin
  ansMatrix:=Matriz.Create(filas,columnas,nombre);
  for i:=low(ansMatrix.data) to high(ansMatrix.data) do
    begin
      for j:=low(ansMatrix.data[i]) to high(ansMatrix.data[i]) do ansMatrix.data[i][j]:=data[i][j] - matrix2.data[i][j];
    end;
  Resta:=ansMatrix;
end;

function Matriz.ProductoM(matrix2:Matriz):Matriz;
var ansMatrix:Matriz;
var i,j,k:integer;
begin
  ansMatrix := Matriz.Create(Filas,matrix2.columnas,nombre);
  for i:=low(ansMatrix.data) to high(ansMatrix.data) do
    begin
      for j:=low(ansMatrix.data[i]) to high(ansMatrix.data[i]) do
        begin
          ansMatrix.data[i][j]:=0;
        end;
    end;

  for i:=low(ansMatrix.data) to high(ansMatrix.data) do
    begin
      for j:=low(ansMatrix.data[i]) to high(ansMatrix.data[i]) do
        begin
          for k:= low(matrix2.data) to high(matrix2.data) do ansMatrix.data[i][j]:= ansMatrix.data[i][j] + data[i][k]*matrix2.data[k][j];
        end;
    end;
  self.PrintM();
  matrix2.PrintM();
  ansMatrix.PrintM();
  ProductoM:=ansMatrix;
end;

function Matriz.Potencia(expo:integer):Matriz;
var ansMatrix:Matriz;
var i:integer;
begin
  ansMatrix:=Matriz.Create(filas,columnas,nombre);
  ansMatrix.data:=data;
  for i:=0 to expo-1 do ansMatrix:=ansMatrix.ProductoM(self);
  Potencia:=ansMatrix;
end;

function Matriz.ProductoE(esc:double):Matriz;
var ansMatrix:Matriz;
var i,j:integer;
begin
  ansMatrix:=Matriz.Create(filas,columnas,nombre);
  for i:=low(ansMatrix.data) to high(ansMatrix.data) do
    begin
      for j:=low(ansMatrix.data[i]) to high(ansMatrix.data[i]) do ansMatrix.data[i][j]:=data[i][j]*esc;
    end;
  ProductoE:=ansMatrix;
end;

function Matriz.DivisionE(esc:double):Matriz;
var ansMatrix:Matriz;
var i,j:integer;
begin
  ansMatrix:=Matriz.Create(filas,columnas,nombre);
  for i:=low(ansMatrix.data) to high(ansMatrix.data) do
    begin
      for j:=low(ansMatrix.data[i]) to high(ansMatrix.data[i]) do ansMatrix.data[i][j]:=data[i][j]/esc;
    end;
  DivisionE:=ansMatrix;
end;

function Matriz.Determinante():double;
var i,j,k:integer;
var newMatrix:Matriz;
begin
  Determinante:=0;
  if (filas=1) and (columnas=1) then
    begin
      Determinante := self.data[0][0];
      exit;
    end;
  newMatrix:=Matriz.Create(filas-1,columnas-1,nombre);
  for k:=low(data[0]) to high(data[0]) do
    begin
      for i:=low(data) to high(data) do
        begin
          if i=0 then continue;
          for j:=low(data[i]) to high(data[i]) do
            begin
              if j=k then continue;
              if j < k then
                begin
                  newMatrix.data[i-1][j] := data[i][j]
                end;
              if j > k then
                begin
                  newMatrix.data[i-1][j-1] := data[i][j]
                end;
            end;
        end;
        Determinante:= Determinante + ((-1)**k)*data[0][k] * newMatrix.Determinante();
    end;

end;

function Matriz.Transpuesta():Matriz;
var ansMatrix:Matriz;
var i,j:integer;
begin
  ansMatrix:=Matriz.Create(columnas,filas,nombre);
  for i:=0 to columnas-1 do
    begin
      for j:=0 to filas-1 do ansMatrix.data[i][j]:=data[j][i];
    end;
    Transpuesta:=ansMatrix;
end;

function Matriz.Adjunta():Matriz;
var i,j,k,l:integer;
var newMatrix,ansMatrix:Matriz;
begin
  ansMatrix:=Matriz.Create(filas,columnas,nombre);
  newMatrix:=Matriz.Create(filas-1,columnas-1,nombre);
  for k:=low(data) to high(data) do
    begin
      for l:=low(data[k]) to high(data[k]) do
        begin
          for i:=low(data) to high(data) do
            begin
              if i=l then continue;
              for j:=low(data[i]) to high(data[i]) do
                begin
                  if j=k then continue;
                  if (i < l) and (j < k) then newMatrix.data[i][j]:=data[j][i];
                  if (i > l) and (j > k) then newMatrix.data[i-1][j-1]:=data[j][i];
                  if (i < l) and (j > k) then newMatrix.data[i][j-1]:=Data[j][i];
                  if (i > l) and (j < k) then newMatrix.data[i-1][j]:=data[j][i];
                end;
            end;
          ansMatrix.data[k][l] := ((-1)**(k+l+2))*newMatrix.Determinante();
        end;
    end;
    Adjunta:=ansMatrix;
end;

function Matriz.Inversa():Matriz;
begin
  Inversa := Self.Adjunta().Transpuesta().DivisionE(self.Determinante());
end;

operator + (matrix1:matriz;matrix2:matriz)ansMat:matriz;
begin
  ansMat := matrix1.Suma(matrix2);
end;

operator - (matrix1:matriz;matrix2:matriz)ansMat:matriz;
begin
  ansMat := matrix1.Resta(matrix2);
end;

operator * (matrix1:matriz;matrix2:matriz)ansMat:matriz;
begin
  ansMat := matrix1.ProductoM(matrix2);
end;

operator * (matrix1:matriz;pot:real)ansMat:matriz;
begin
  writeln('mR');
  matrix1.PrintM();
  ansMat := matrix1.ProductoE(pot);
end;

operator * (pot:real;matrix1:matriz)ansMat:matriz;
begin
  ansMat := matrix1.ProductoE(pot);
end;

operator / (matrix1:matriz;pot:real)ansMat:matriz;
begin
  ansMat := matrix1.DivisionE(pot);
end;

operator ** (matrix1:matriz;pot:real)ansMat:matriz;
begin
  ansMat := matrix1.Potencia(round(pot));
end;

(*Parser Implementation*)

constructor MathParser.Create();
begin
  Stack := TStringList.Create;
  ansStack := TStringList.Create;
  variables := TStringList.Create;
  varval := TStringList.Create;
  operatorStack := TStringList.Create;
  tmpMatrix := ListofMatriz.Create;
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

function MathParser.Number(a:char):boolean;
begin
  if (ord(a)>=48) and (ord(a)<=57) then Number := true
  else Number:=false;
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

function MathParser.giveValue(func:string ;arr: array of double):string;
begin
  if func = 'sin(' then giveValue := floattostr(sin(arr[0]))
  else if func = 'cos(' then giveValue := floattostr(cos(arr[0]))
  else if func = 'tan(' then giveValue := floattostr(tan(arr[0]))
  else if func = 'sinh(' then giveValue := floattostr(sinh(arr[0]))
  else if func = 'cosh(' then giveValue := floattostr(cosh(arr[0]))
  else if func = 'tanh(' then giveValue := floattostr(tanh(arr[0]))
  else if func = 'power(' then giveValue := floattostr(power(arr[0],arr[1]))
  else if func = 'ln(' then giveValue := floattostr(ln(arr[0]));
end;

function MathParser.elementsMatrix(func:string):integer;
begin
  if func='inv(' then elementsMatrix:=1;
  if func='adj(' then elementsMatrix:=1;
  if func='det(' then elementsMatrix:=1;
  if func='tran(' then elementsMatrix:=1;
end;
function MathParser.giveValueMatrix(func:string; mArray:array of string):string;
var nomb:string;
var j:integer;
begin
  nomb:=mArray[0];
  giveValueMatrix:=nomb;
  if func='inv(' then
    begin
      for j:=0 to tmpMatrix.Count-1 do
        begin
          if matriz(tmpMatrix[j]).nombre=nomb then
            begin
              tmpMatrix[j] := TObject(matriz(tmpMatrix[j]).Inversa);

              break;
            end;
        end;
    end;
  if func='adj(' then
    begin
      for j:=0 to tmpMatrix.Count-1 do
        begin
          if matriz(tmpMatrix[j]).nombre=nomb then
            begin
              tmpMatrix[j] := TObject(matriz(tmpMatrix[j]).Adjunta);
              break;
            end;
        end;
    end;
  if func='det(' then
    begin
      for j:=0 to tmpMatrix.Count-1 do
        begin
          if matriz(tmpMatrix[j]).nombre=nomb then
            begin
              giveValueMatrix:=floattostr(matriz(tmpMatrix[j]).Determinante());
              break;
            end;
        end;
    end;
  if func='tran(' then
    begin
      for j:=0 to tmpMatrix.Count-1 do
        begin
          if matriz(tmpMatrix[j]).nombre=nomb then
            begin
              tmpMatrix[j] := TObject(matriz(tmpMatrix[j]).Transpuesta());
              break;
            end;
        end;
    end;
end;

function MathParser.solOperator(op: string; first:string; second:string):string;
var i,j:integer;
begin
  //ShowMessage(concat('values',op,floattostr(first),floattostr(second)));
  if (NumberOrPoint(first[1])) and (NumberOrPoint(second[1])) then
    begin

  if op='+' then solOperator := floattostr(strtofloat(first) + strtofloat(second))
  else if op='-' then solOperator := floattostr(strtofloat(first) - strtofloat(second))
  else if op='/' then solOperator := floattostr(strtofloat(first) / strtofloat(second))
  else if op='*' then solOperator := floattostr(strtofloat(first) * strtofloat(second))
  else if op='^' then solOperator := floattostr(strtofloat(first) ** strtofloat(second))
  else if op='%' then solOperator := floattostr(strtofloat(first) * strtofloat(second))
    end
  else if (letter(first[1])) and (letter(second[1])) then
    begin

      for i:=0 to tmpMatrix.Count-1 do
        begin
          if matriz(tmpMatrix[i]).nombre=first then
            begin
              for j:=0 to tmpMatrix.Count-1 do
                begin
                  if matriz(tmpMatrix[j]).nombre=second then
                    begin
                      if op='+' then tmpMatrix[i] := TObject(matriz(tmpMatrix[i]) + matriz(tmpMatrix[j]));
                      if op='-' then tmpMatrix[i] := TObject(matriz(tmpMatrix[i]) - matriz(tmpMatrix[j]));
                      if op='*' then tmpMatrix[i] := TObject(matriz(tmpMatrix[i]) * matriz(tmpMatrix[j]));
                      solOperator:=matriz(tmpMatrix[i]).nombre;
                      break;
                    end;
                end;
              break;
            end;
        end;
    end
  else if (letter(first[1])) then
    begin

      for i:=0 to tmpMatrix.Count-1 do
        begin
          if matriz(tmpMatrix[i]).nombre=first then
            begin
              if op='/' then tmpMatrix[i] := TObject(matriz(tmpMatrix[i]) / strtofloat(second))
              else if op='*' then tmpMatrix[i] := TObject(matriz(tmpMatrix[i]) * strtofloat(second))
              else if op='^' then tmpMatrix[i] := TObject(matriz(tmpMatrix[i]) ** strtofloat(second))
              else if op='%' then tmpMatrix[i] := TObject(matriz(tmpMatrix[i]) * strtofloat(second));
              solOperator:=matriz(tmpMatrix[i]).nombre;
              break;
            end;
        end;
    end
    else if (letter(second[1])) then
      begin
        for i:=0 to tmpMatrix.Count-1 do
          begin
            if matriz(tmpMatrix[i]).nombre=second then
              begin
                writeln(matriz(tmpMatrix[i]).nombre);
                if op='*' then tmpMatrix[i] := TObject(matriz(tmpMatrix[i]) * strtofloat(first))
                else if op='%' then tmpMatrix[i] := TObject(matriz(tmpMatrix[i]) * strtofloat(first));
                solOperator:=matriz(tmpMatrix[i]).nombre;
                break;
              end;
          end;
      end;
end;

function MathParser.evaluate(Texteq : String) : String;
var Texto,tex1,tex2: String;
var i,j: integer;
var anss:string;
var flag:boolean;
var answer:Matriz;
var imp:double;
begin
  stack.Clear;
  operatorStack.Clear;
  ansStack.Clear;
  Texto:=Texteq;
  (*Tratar de borrar esto*)
  (*Texto := DelSpace(Texteq);*)
  (* Lo que buscamos es que nuestro paarser primero borre los espacios pero fuera de la matriz y ya dentro
  haga un analisis sobre que espacio borrar y q espacio no debe borrar, tomando en cuenta que la matriz
  se separa por espacios(cols) o commas(cols), y por punto y commas(rows)*)

  (*Primero cada vez que encontremos un '[' abierto signifcara que estamos iniciando una mtriz y debemos
  realizar el analisis hasta que encontremos un ']' que cierra la matriz*)
  flag := false;
  i:=1;
  while(i<=Texto.length) do
    begin
      if Texto[i] = '[' then
        begin
          flag:=true;
        end
      else if Texto[i]=']' then flag:=false
      else if Texto[i] = ' ' then
        begin
          while (i+1<=Texto.length) and (Texto[i+1]=' ') do Delete(Texto,i+1,1);
          if flag=false then
            begin
              Delete(Texto,i,1);
              i:=i-1;
            end
          else
            begin
              (*writeln('<>');
              writeln((Texto[i-1]));
              writeln((Texto[i]));
              writeln((Texto[i+1]));
              writeln('</>');*)
              if ((Number(Texto[i-1])) or (letter(Texto[i-1])) or (Texto[i-1]=')')) and ((Number(Texto[i+1])) or (letter(Texto[i+1])) or (Texto[i+1]='(')) then Texto[i]:=','
              else if ((Number(Texto[i-1])) or (letter(Texto[i-1])) or (Texto[i-1]=')')) and ((Texto[i+1]='-') and ((Number(Texto[i+2])) or (letter(Texto[i+2]) or (Texto[i+2]='(')))) then Texto[i]:=','
              else if ((Number(Texto[i-1])) or (letter(Texto[i-1])) or (Texto[i-1]=')')) and ((Texto[i+1]='+') and ((Number(Texto[i+2])) or (letter(Texto[i+2]) or (Texto[i+2]='(')))) then Texto[i]:=',';
            end;
        end;
        i:=i+1;
    end;
  Texto := DelSpace(Texto);
  writeln(Texto);
  (*Hacer Cambios para los espacios, y para las matrices*)
  i := 1;
  while i <= Texto.length do
     begin
       if (Texto[i]='-') and ((i=1) or (Texto[i-1]='(') or (SpecChar(Texto[i-1]))) and (not NumberOrPoint(Texto[i+1])) then
       begin

         Tex1:=copy(Texto,1,i-1);
         Tex2:=copy(Texto,i+1,Texto.Length-i);
         Texto := concat(Tex1,'(-1)%',Tex2);

         continue;
       end;
       if (Texto[i]='+') and ((i=1) or (Texto[i-1]='(') or (SpecChar(Texto[i-1]))) and (not NumberOrPoint(Texto[i+1])) then
       begin

         Tex1:=copy(Texto,1,i-1);
         Tex2:=copy(Texto,i+1,Texto.Length-i);
         Texto := concat(Tex1,'(1)%',Tex2);

         continue;
       end;
       if ((NumberOrPoint(Texto[i])) or (letter(Texto[i]))) or (((Texto[i]='+') or (Texto[i]='-')) and ((i=1) or (SpecChar(Texto[i-1]) or (Texto[i-1]='(') or (Texto[i-1]=',') or (Texto[i-1]=';')))) then
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
       else if (Texto[i]=',') or (Texto[i]=';') then PushValue(Texto[i])
       else if (Texto[i]='[') or (Texto[i]=']') then PushValue(Texto[i])
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
  if (NumberOrPoint(anss[1])) and (isinfinite(strtofloat(anss))) then evaluate := 'No dividir entre zero >:v'
  else if (NumberOrPoint(anss[1])) and (isnan(strtofloat(anss))) then evaluate := 'Alguna operacion invalida'
  else
    begin
      evaluate:=anss;
      if letter(evaluate[1]) then
        begin
          for i:=0 to tmpMatrix.Count-1 do
            begin
              if matriz(tmpMatrix[i]).nombre=anss then
                begin
                answer:=matriz(tmpMatrix[i]);
                break;
                end;
            end;
            evaluate:='[';
            for i:=0 to answer.filas-1 do
              begin
                for j := 0 to answer.columnas-1 do
                  begin
                    imp:=answer.data[i][j];
                    imp:=roundto(imp,-5);
                    if floattostr(imp)[1]<>'-' then evaluate:=concat(evaluate,' ');
                    evaluate:=concat(evaluate,floattostr(imp));
                    if (j= answer.columnas-1) and (i<>answer.filas-1) then evaluate:= concat(evaluate,ansichar(#10),' ')
                    else if (j= answer.columnas-1) and (i=answer.filas-1) then evaluate:= concat(evaluate,']')
                    else evaluate:= concat(evaluate,' ');
                  end;
              end;
            evaluate[evaluate.length] := ']';
        end
        else
        begin
          begin
            evaluate:=anss;
          end;
        end;

    end;
end;

procedure MathParser.InfixToPostfix();
var i: integer;
var commas:integer;
var pcommas:integer;
var nummatrix:integer;
begin
  commas:=0;
  pcommas:=0;
  nummatrix:=0;
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
    (*Aqui haremos el postfix de matrices*)
    else if (Stack[i][1]='[') then
      begin
        commas:=0;
        pcommas:=0;
        operatorStack.Add(concat('tmpMatrix',inttostr(nummatrix)));
        operatorStack.Add(Stack[i]);
      end
    else if(Stack[i][1]=',') then
    begin
      commas:=commas+1;
      while (operatorStack[operatorStack.count-1] <> '((') and (operatorStack[operatorStack.count-1] <> '[') do
      begin

        ansStack.Add(operatorStack[operatorStack.Count-1]);
        operatorStack.Delete(operatorStack.Count-1);
      end;
    end
    else if(Stack[i][1]=';') then
    begin
      pcommas:=pcommas+1;
      while (operatorStack[operatorStack.count-1] <> '[') do
      begin

        ansStack.Add(operatorStack[operatorStack.Count-1]);
        operatorStack.Delete(operatorStack.Count-1);
      end;
    end
    else if(Stack[i][1] = ']') then
    begin
      tmpMatrix.Add(Matriz.Create(pcommas+1,round(commas/(pcommas+1)+1),concat('tmpMatrix',inttostr(nummatrix))));
      nummatrix:=nummatrix+1;
      while (operatorStack[operatorStack.count-1] <> '[') do
      begin
        ansStack.Add(operatorStack[operatorStack.Count-1]);
        operatorStack.Delete(operatorStack.Count-1);
      end;
      if operatorStack[operatorStack.count-1]='[' then
      begin
        operatorStack.Delete(operatorStack.Count-1);
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

function MathParser.solve():string;
var i,j,k,pos,col,row:integer;
var val:string;
var arr:array of real;
var arrM:array of string;
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
    end;
    for i:=0 to ansStack.Count-1 do
  begin
    //if operatorStack.Count > 0  then ShowMessage(operatorStack[operatorStack.Count-1]);
    if (NumberOrPoint(ansStack[i][ansStack[i].Length])) and (not Letter(ansStack[i][1])) then
    begin
      operatorStack.Add(ansStack[i]);
    end
    else if SpecChar(ansStack[i][ansStack[i].Length]) then
    begin
      val := solOperator(ansStack[i],operatorStack[operatorStack.Count-2],operatorStack[operatorStack.Count-1]);
      operatorStack.Delete(operatorStack.Count-1);
      operatorStack.Delete(operatorStack.Count-1);
      operatorStack.add(val);
    end
    else if copy(ansStack[i],1,9) = 'tmpMatrix' then
      begin

        for j:=0 to tmpMatrix.Count-1 do
          begin
            if matriz(tmpMatrix[j]).nombre=ansStack[i] then
              begin
                col := matriz(tmpMatrix[j]).columnas;
                row := matriz(tmpMatrix[j]).filas;
                k:=col*row-1;

                while k>=0 do
                  begin
                    matriz(tmpMatrix[j]).data[floor(k/col)][k mod col] := strtofloat(operatorStack[operatorStack.Count-1]);
                    operatorStack.Delete(operatorStack.Count-1);
                    k:=k-1;
                  end;
                operatorStack.add(ansStack[i]);
                break;
              end;
          end;
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
      if (ansStack[i]='inv(') or (ansStack[i]='det(') or (ansStack[i]='adj(') or (ansStack[i]='tran(') then
        begin
          writeln(ansStack[i],'*');
          SetLength(arrM,elementsMatrix(ansStack[i]));
          j:= elementsMatrix(ansStack[i]) - 1;
          writeln(j);
          while j >=0 do
          begin
            //ShowMessage(inttostr(operatorStack.Count));
            arrM[j] := operatorStack[operatorStack.Count-1];
            operatorStack.Delete(operatorStack.Count-1);
            j:= j-1;
          end;
          writeln('val');
          val := giveValueMatrix(ansStack[i],arrM);
          operatorStack.Add(val);
        end
      else
      begin
      while j >=0 do
      begin
        //ShowMessage(inttostr(operatorStack.Count));
        arr[j] := strToFloat(operatorStack[operatorStack.Count-1]);
        operatorStack.Delete(operatorStack.Count-1);
        j:= j-1;
      end;
      val := giveValue(ansStack[i],arr);
      operatorStack.Add(val);
      end;
    end;
  end;
  solve := operatorStack[operatorStack.Count-1];
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
