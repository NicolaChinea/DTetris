unit BloccoTetris;

interface
uses System.Classes, System.SysUtils, MMSystem, U_Constant, Winapi.Windows;
type
  TSuono = class
    Private
    fSound: TStringList;
    public
      Constructor Create;
      Destructor Destroy;
      Procedure Play(nSound: Integer);
      Procedure StopPlay;
      Procedure Load;
      Procedure PlayFile(sFile:String);
      Property Sound: TStringList read fSound write fSound;
  end;
type
  TBloccoTetris = class
  private
    fColore: Integer;
    fTipo: Integer;
    fQ1: TPoint;
    fQ2: TPoint;
    fQ3: TPoint;
    fQ4: TPoint;
    fPR: TPoint;

    fCloneColore: Integer;
    fCloneTipo: Integer;
    fCloneQ1: TPoint;
    fCloneQ2: TPoint;
    fCloneQ3: TPoint;
    fCloneQ4: TPoint;
    fClonePR: TPoint;

    fBufferColore: Integer;
    fBufferTipo: Integer;
    fBufferQ1: TPoint;
    fBufferQ2: TPoint;
    fBufferQ3: TPoint;
    fBufferQ4: TPoint;
    fBufferPR: TPoint;

    function GetQ1: TPoint;
    procedure SetQ1(const Value: TPoint);


    { Private declarations }
  public
    { Public declarations }
    Constructor create(bytTipo, bytColore, shrQ1_X, shrQ1_Y, shrQ2_X,
                       shrQ2_Y, shrQ3_X, shrQ3_Y, shrQ4_X, shrQ4_Y, shrPR_X, shrPR_Y: Integer);Overload;
    Constructor create();Overload;
    Procedure Clear;
    Procedure Clone;
    Procedure SetBuffer;
    Procedure Reset;
    Function Check(nVarPar: aGrid): Boolean;
    Procedure Move(nDirection: Integer);
    Procedure Turn(nDirection: Integer);
    PROPERTY Tipo: Integer Read fTipo write fTipo;
    PROPERTY Colore: Integer Read fColore write fColore; //colore
    PROPERTY Q1: TPoint Read GetQ1 write SetQ1;
    PROPERTY Q2: TPoint Read fQ2 write fQ2;
    PROPERTY Q3: TPoint Read fQ3 write fQ3;
    PROPERTY Q4: TPoint Read fQ4 write fQ4;
    PROPERTY PR: TPoint Read fPR write fPR;

  end;

implementation

{ TBloccoTetris }

//uses U_Constant;

function TBloccoTetris.Check(nVarPar: aGrid): Boolean;
begin
  Result := True;

  IF ((fQ1.Y > (BYT_RIGHE - 1)) OR (fQ1.Y < 0) OR (fQ1.X > (BYT_COLONNE - 1)) OR (fQ1.X < 0)) or
     ((fQ2.Y > (BYT_RIGHE - 1)) OR (fQ2.Y < 0) OR (fQ2.X > (BYT_COLONNE - 1)) OR (fQ2.X < 0)) or
     ((fQ3.Y > (BYT_RIGHE - 1)) OR (fQ3.Y < 0) OR (fQ3.X > (BYT_COLONNE - 1)) OR (fQ3.X < 0)) or
     ((fQ4.Y > (BYT_RIGHE - 1)) OR (fQ4.Y < 0) OR (fQ4.X > (BYT_COLONNE - 1)) OR (fQ4.X < 0)) then
    Result := False

  else if (((fQ1.X = fCloneQ1.X) AND (fQ1.Y = fCloneQ1.Y)) OR
          ((fQ1.X = fCloneQ2.X) AND (fQ1.Y = fCloneQ2.Y)) OR
          ((fQ1.X = fCloneQ3.X) AND (fQ1.Y = fCloneQ3.Y)) OR
          ((fQ1.X = fCloneQ4.X) AND (fQ1.Y = fCloneQ4.Y))) or

          (((fQ2.X = fCloneQ1.X) AND (fQ2.Y = fCloneQ1.Y)) OR
          ((fQ2.X = fCloneQ2.X) AND (fQ2.Y = fCloneQ2.Y)) OR
          ((fQ2.X = fCloneQ3.X) AND (fQ2.Y = fCloneQ3.Y)) OR
          ((fQ2.X = fCloneQ4.X) AND (fQ2.Y = fCloneQ4.Y))) or

          (((fQ3.X = fCloneQ1.X) AND (fQ3.Y = fCloneQ1.Y)) OR
          ((fQ3.X = fCloneQ2.X) AND (fQ3.Y = fCloneQ2.Y)) OR
          ((fQ3.X = fCloneQ3.X) AND (fQ3.Y = fCloneQ3.Y)) OR
          ((fQ3.X = fCloneQ4.X) AND (fQ3.Y = fCloneQ4.Y))) or

          (((fQ4.X = fCloneQ1.X) AND (fQ4.Y = fCloneQ1.Y)) OR
          ((fQ4.X = fCloneQ2.X) AND (fQ4.Y = fCloneQ2.Y)) OR
          ((fQ4.X = fCloneQ3.X) AND (fQ4.Y = fCloneQ3.Y)) OR
          ((fQ4.X = fCloneQ4.X) AND (fQ4.Y = fCloneQ4.Y)))  THEN
    Result := True

  else if (nVarPar[fQ1.X, fQ1.Y] <> BYT_VUOTO) or
          (nVarPar[fQ2.X, fQ2.Y] <> BYT_VUOTO) or
          (nVarPar[fQ3.X, fQ3.Y] <> BYT_VUOTO) or
          (nVarPar[fQ4.X, fQ4.Y] <> BYT_VUOTO) then
    Result := False
  else
    Result := True;

end;

procedure TBloccoTetris.Clear;
begin
// reset class property
  fColore := 0;
  fTipo := 0;
  fPR.X := 0;
  fPR.Y := 0;
  fQ2.X := 0;
  fQ3.X := 0;
  fQ2.Y := 0;
  fQ3.Y := 0;
  fQ1.X := 0;
  fQ1.Y := 0;
  fQ4.X := 0;
  fQ4.Y := 0;
end;

{ Suono }

constructor TSuono.Create;
begin
  fSound := TStringList.Create;
end;

destructor TSuono.Destroy;
begin
  FreeAndNil(fSound);
end;

procedure TSuono.Load;
Var
  i: Integer; // 'contatore
begin
  sndPlaySound(nil, 0); // Stops the sound
//'carica gli effetti sonori
{            '1  Effetto41.wav -> ancoraggio blocco
            '2  Effetto42.wav -> inizio nuova terzina di rounds
            '3  Effetto43.wav -> game over
            '4  Effetto44.wav -> vittoria round
            '5  Effetto14.wav -> riga
            '6  Effetto20.wav -> quadratino/riga aggiunti
}
  FOR i := 41 TO 44 do
    fSound.Add('effetto' + i.ToString + '.wav');
  fSound.Add('effetto14.wav');
  fSound.Add('effetto20.wav');
end;

procedure TSuono.PlayFile(sFile: String);
begin
  StopPlay;
//  sndPlaySound(PChar(sFile), SND_NODEFAULT Or SND_ASYNC Or SND_LOOP);
end;

procedure TSuono.Play(nSound: Integer);
begin
//  sndPlaySound(PChar(fSound[nSound]), SND_NODEFAULT Or SND_ASYNC Or SND_LOOP);
end;

procedure TSuono.StopPlay;
begin
  sndPlaySound(nil, 0); // Stops the sound
end;

procedure TBloccoTetris.Clone;
begin
  fCloneColore := fColore;
  fCloneTipo   := fTipo;
  fCloneQ1   := fQ1;
  fCloneQ2   := fQ2;
  fCloneQ3   := fQ3;
  fCloneQ4   := fQ4;
  fClonePR   := fPR;
end;

constructor TBloccoTetris.create;
begin
//
end;

constructor TBloccoTetris.create(bytTipo, bytColore, shrQ1_X, shrQ1_Y, shrQ2_X,
  shrQ2_Y, shrQ3_X, shrQ3_Y, shrQ4_X, shrQ4_Y, shrPR_X, shrPR_Y: Integer);
begin
  Tipo := bytTipo;
  Colore := bytColore;
  fQ1.X := shrQ1_X;
  fQ1.Y := shrQ1_Y;
  fQ2.X := shrQ2_X;
  fQ2.Y := shrQ2_Y;
  fQ3.X := shrQ3_X;
  fQ3.Y := shrQ3_Y;
  fQ4.X := shrQ4_X;
  fQ4.Y := shrQ4_Y;
  fPR.X := shrPR_X;
  fPR.Y := shrPR_Y;
end;


procedure TBloccoTetris.SetBuffer;
begin
  fBufferColore := fColore;
  fBufferTipo   := fTipo;
  fBufferQ1.X   := fQ1.X;
  fBufferQ1.Y   := fQ1.Y;
  fBufferQ2.X   := fQ2.X;
  fBufferQ2.Y   := fQ2.Y;
  fBufferQ3.X   := fQ3.X;
  fBufferQ3.Y   := fQ3.Y;
  fBufferQ4.X   := fQ4.X;
  fBufferQ4.Y   := fQ4.Y;
  fBufferPR.X   := fPR.X;
  fBufferPR.Y   := fPR.Y;

end;

procedure TBloccoTetris.SetQ1(const Value: TPoint);
begin
  fQ1 := Value
end;

function TBloccoTetris.GetQ1: TPoint;
begin
  result := fQ1;
end;

procedure TBloccoTetris.Move(nDirection: Integer);
begin
  CASE nDirection of
    BYT_SX, BYT_DX:
    begin
      fQ1.X := fQ1.X + nDirection;
      fQ2.X := fQ2.X + nDirection;
      fQ3.X := fQ3.X + nDirection;
      fQ4.X := fQ4.X + nDirection;
      fPR.X := fPR.X + nDirection;
    end;
    BYT_GIU:
    begin
      fQ1.Y := fQ1.Y + 1;
      fQ2.Y := fQ2.Y + 1;
      fQ3.Y := fQ3.Y + 1;
      fQ4.Y := fQ4.Y + 1;
      fPR.Y := fPR.Y + 1;
    end;
    BYT_RSX, BYT_RDX: // 'rotazione sinistra, destra
    begin
      IF Tipo <> BYT_BLOCCO_O THEN
        turn(nDirection);
    end;
  END;

end;

procedure TBloccoTetris.Reset;
begin
  fColore := fCloneColore;
  fTipo   := fCloneTipo;
  fQ1   := fCloneQ1;
  fQ2   := fCloneQ2;
  fQ3   := fCloneQ3;
  fQ4   := fCloneQ4;
  fPR   := fClonePR;
end;


procedure TBloccoTetris.Turn(nDirection: Integer);
Var
  X: Integer;
  Y: Integer;
  nDir: Integer;
begin
  IF nDirection = BYT_RDX THEN
    nDir := BYT_SX;
  IF nDirection = BYT_RSX THEN
    nDir := BYT_DX;

  X := nDir * (Q1.Y - PR.Y) + PR.X;
  Y := (0 - nDir) * (Q1.X - PR.X) + PR.Y;
  fQ1.X := X;
  fQ1.Y := Y;

  X := nDir * (Q2.Y - PR.Y) + PR.X;
  Y := (0 - nDir) * (Q2.X - PR.X) + PR.Y;
  fQ2.X := X;
  fQ2.Y := Y;

  X := nDir * (Q3.Y - PR.Y) + PR.X;
  Y := (0 - nDir) * (Q3.X - PR.X) + PR.Y;
  fQ3.X := X;
  fQ3.Y := Y;

  X := nDir * (Q4.Y - PR.Y) + PR.X;
  Y := (0 - nDir) * (Q4.X - PR.X) + PR.Y;
  fQ4.X := X;
  fQ4.Y := Y;

end;

end.
