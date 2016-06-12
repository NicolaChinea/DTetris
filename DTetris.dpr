program DTetris;

uses
  Vcl.Forms,
  F_Main in 'F_Main.pas' {FMain},
  BloccoTetris in 'BloccoTetris.pas',
  U_Constant in 'U_Constant.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFMain, FMain);
  Application.Run;
end.
