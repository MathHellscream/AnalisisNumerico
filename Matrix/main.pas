program main;
{$mode objfpc}{$H+}
uses parser;

var Ans:string;
var Parse:Mathparser;
var ShowMatrix:string;
begin
  Parse := Mathparser.Create;
  Ans := Parse.evaluate('2*adj([1+1,0,1;3,0,0;5,1,1])');
  writeln(ans);

end.
