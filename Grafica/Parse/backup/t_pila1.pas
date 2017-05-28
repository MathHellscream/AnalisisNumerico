unit t_Pila1;
interface
{$mode objfpc}{$H+}
uses
   Classes, SysUtils, crt,dialogs;
 const
   MAX_PILA=100;
 type
      tpila =class
  private
            cima : Integer;
            Elementos : Array[1..MAX_PILA] of real;
 public
     Procedure crear();
     Procedure vacia();
     function EsPilaVacia() : Integer;
     Function llena() : Boolean;
     Function cimas() : real;
     Procedure push(elem : real);
    Procedure pop();

end;

 implementation
 Procedure tpila.crear();
 begin
      cima := 0;
 end;
 Procedure tpila.vacia();
 begin
      cima :=0;
 end;
 function tpila.EsPilaVacia() : Integer;
 begin
      if cima=0 then
         EsPilaVacia:=1
      else
         EsPilaVacia:=0;
 end;
 Function tpila.llena() : Boolean;
 begin
      llena := cima = MAX_PILA
 end;
 Function tpila.cimas() : real;
 begin
    try
     cimas:= elementos[ cima ];

      except
       ShowMessage( 'Upss' );

    end;
 end;

 Procedure tpila.push(elem : real);
 begin
      Inc(cima);
      elementos[cima] := elem
 end;
 Procedure tpila.pop();
 begin
      //elem := pila.elementos[pila.cima];
      dec(cima)
 end;

end.



