program Project1;

uses
  Vcl.Forms,
  compareAnciennete in 'compareAnciennete.pas' {Form1},
  BDU in 'BDU.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
