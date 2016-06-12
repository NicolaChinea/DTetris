unit F_Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Imaging.pngimage,MMSystem,
  System.Generics.Collections,
  Vcl.Menus,BloccoTetris,U_Constant, Vcl.MPlayer, Vcl.StdCtrls;

type
  TBlockList = TList<TBloccoTetris>;
  TRectList = TList<TImage>;
  TStatList = TList<TPanel>;
  TFMain = class(TForm)
    pFondo: TPanel;
    MainMenu1: TMainMenu;
    Gioco1: TMenuItem;
    Inizio1: TMenuItem;
    testanteprima1: TMenuItem;
    Timer: TTimer;
    Uscita1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure Inizio1Click(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Uscita1Click(Sender: TObject);
    Function CreaImmagine(nTop, nLeft, nWidth, nHeight: Integer; oGraphic: TGraphic; lClear: Boolean = False): TImage;
    Procedure ClearImg(oImg: TImage);
  private
    { Private declarations }
    oSuono: TSuono;
    a: TPoint;
    cshrLineeFatte: Integer; //  AS Short 'numero di linee fatte in totale
    cshrLineeRound: Integer; //  AS Short 'numero di linee per completamento round
    cintPunteggio: Integer; //  AS Integer 'punteggio

    cbytSfondo: Integer; // AS Byte 'memorizza il numero di sfondo in uso
    cbytRound: Integer; // 'numero di round
    sndEffettoSonoro: Array [1..6] of string; // 'oggetti della collezione Suono
 //   cBloccoTipo: Array[1..8] of TBloccoTetris; //tipi di blocco
    oPanelStat: TStatList;
    oTypeBlock: TBlockList;
    oRect: TRectList;
    picSfondo: Array[0..3] of TImage;

    cbytGrigliaAttuale: aGrid;// Array[0..10, 0..22] of Integer; //colonna (x),riga (y)
    cbytGrigliaPrecedente: aGrid; //Array[0..10, 0..22] of Integer;

    drwSfondo: TImage;
    drwAnteprima: TImage;
    drwGriglia: TImage;

    cBloccoSuccessivo: TBloccoTetris;
    cBloccoAttuale: TBloccoTetris; // 'blocco attuale in movimento
    cBloccoPosizionePrecedente: TBloccoTetris; // 'posizione precedente del blocco attuale in movimento
    cBloccoRipristino: TBloccoTetris; // 'copia del blocco attuale per ripristino in caso di movimento in posizione non ammessa
    FUNCTION funcMuoviBlocco(shrDirezione: Integer): Boolean;
    Procedure SetupBlock(bytTipo, bytColore: Integer; shrQ1, shrQ2, shrQ3, shrQ4, shrPR: TPoint);
    procedure subDisegnaQuadratino(drwObj: TImage; shrXY: TPoint; oBlockImgPar: TImage);
    procedure subBloccoAnteprima;
    FUNCTION funcVerificaLimitiBlocco(QX, QY: Integer): Boolean;
    procedure subRuotaQuadretto(NQ: Integer; QX, QY, RX, RY,
      shrDirezione: Integer);
    procedure subDisegnaBlocco(blnPrimoBlocco: Boolean);
    procedure subAggiornaGriglia;
    function subNuovoBlocco: Boolean;
    procedure mnuGiocoNuovo_Click;
    procedure subNuovoRound(Sender: TObject);
    procedure subProcessoInCorso(blnStato: Boolean);
    procedure subVerificaLinee;
    procedure subAggiornaScritteStato(strScrittaPunteggioParziale,
      strPunteggioParziale: String);

  public
    { Public declarations }
  end;

var
  FMain: TFMain;



implementation

{$R *.dfm}

procedure TFMain.ClearImg(oImg: TImage);
begin
  with oImg.Canvas do
  begin
    Brush.Color := clblack;
    Brush.Style := bsSolid;
    FillRect(Rect(0, 0, oImg.Width, oImg.Height));
  end;
end;

function TFMain.CreaImmagine(nTop, nLeft, nWidth, nHeight: Integer;
  oGraphic: TGraphic; lClear: Boolean): TImage;
begin
  Result := TImage.Create(Self);
  Result.Parent := pFondo;
  Result.Left := nLeft;
  Result.Top := nTop;
  Result.Width := nWidth;
  Result.Height := nHeight;
  if Assigned(oGraphic) then
    Result.Canvas.Draw(0,0, oGraphic);
  if lClear then
  begin
    with Result.Canvas do
    begin
      Brush.Color := clblack;
      Brush.Style := bsSolid;
      FillRect(Rect(0, 0, Result.Width, Result.Height));
    end;
  end;
end;

procedure TFMain.FormCreate(Sender: TObject);
Var i: Integer;
    oImage: TImage;
    oPanel: TPanel;
begin
  oSuono := TSuono.Create;
  oSuono.Load;
  cintPunteggio := 0;

  oRect := TRectList.Create;
  oTypeBlock := TBlockList.Create;
  oPanelStat := TStatList.Create;
  FOR i := 0 TO 8 do
  begin
    oImage := TImage.Create(Self);
    oImage.Picture.LoadFromFile('tetris_blocco' + i.ToString + '.png');
    oRect.Add(oImage);
  end;

  FOR i := 0 TO 2 do
  begin
    picSfondo[i]  := TImage.Create(Self);
    picSfondo[i].Picture.LoadFromFile('tetris_sfondo' + (i+1).ToString + '.png');
  end;

  FOR i := 0 TO 7 do
  begin
    oPanel  := TPanel.Create(Self);
    oPanel.ParentBackground := False;
    oPanel.Parent := pFondo;
    oPanel.Left := 527 + (18 * (i - 1));
    oPanel.Top := 450;
    oPanel.Width := BYT_LATO_QUADRATINO;
    oPanel.Visible := FALSE;
    oPanel.ParentColor := False;
    case i of
      BYT_COLORE_ROSSO: oPanel.Color := clRed;
      BYT_COLORE_VERDE : oPanel.Color := RGB(65, 186, 0);
      BYT_COLORE_BLU : oPanel.Color := RGB(0, 68, 222) ;
      BYT_COLORE_GIALLO : oPanel.Color := RGB(222, 186, 0);
      BYT_COLORE_VIOLA : oPanel.Color := RGB(222, 0, 222);
      BYT_COLORE_AZZURRO : oPanel.Color := RGB(0, 186, 145);
      BYT_COLORE_ARANCIO : oPanel.Color := RGB(255, 149, 0) ;
    end;
    oPanelStat.Add(oPanel);
  end;

  Width := 766;
  Height := 583;
  Caption := ' - DTETRIS -';

  drwSfondo := CreaImmagine(0, 0, 751, 540, picSfondo[0].Picture.Graphic);
  //    picGameOver.Picture = Picture.Load("./tetris_gameover.png")
  drwAnteprima := CreaImmagine(BYT_ANTEPRIMA_Y, BYT_ANTEPRIMA_X - (3 * BYT_LATO_QUADRATINO),
                               7 * BYT_LATO_QUADRATINO, 2 * BYT_LATO_QUADRATINO, Nil, True);
  drwGriglia := CreaImmagine(BYT_GRIGLIA_Y, BYT_GRIGLIA_X,
                             BYT_LATO_QUADRATINO * BYT_COLONNE, BYT_LATO_QUADRATINO * BYT_RIGHE, Nil, True);

  SetupBlock(0,0,Point(0,0),Point(0,0),Point(0,0),Point(0,0),Point(0,0)); //dummy
  SetupBlock(BYT_BLOCCO_J, BYT_COLORE_GIALLO, Point(4, 1), Point(5, 1), Point(6, 1), Point(4, 0), Point(5, 1));
  SetupBlock(BYT_BLOCCO_L, BYT_COLORE_VIOLA, Point(4, 1), Point(5, 1), Point(6, 1), Point(6, 0), Point(5, 1));
  SetupBlock(BYT_BLOCCO_Z, BYT_COLORE_ARANCIO, Point(4, 0), Point(5, 0), Point(5, 1), Point(6, 1), Point(5, 1));
  SetupBlock(BYT_BLOCCO_S, BYT_COLORE_AZZURRO, Point(5, 0), Point(6, 0), Point(4, 1), Point(5, 1), Point(5, 1));
  SetupBlock(BYT_BLOCCO_T, BYT_COLORE_VERDE, Point(4, 1), Point(5, 1), Point(6, 1), Point(5, 0), Point(5, 1));
  SetupBlock(BYT_BLOCCO_I, BYT_COLORE_ROSSO, Point(3, 1), Point(4, 1), Point(5, 1), Point(6, 1), Point(5, 1));
  SetupBlock(BYT_BLOCCO_O, BYT_COLORE_BLU, Point(4, 1), Point(5, 1), Point(4, 0), Point(5, 0), Point(4, 0));
end;

Procedure TFMain.SetupBlock(bytTipo, bytColore: Integer; shrQ1, shrQ2, shrQ3, shrQ4, shrPR: TPoint);
Var oBlockLocal: TBloccoTetris;
begin
  oBlockLocal := TBloccoTetris.Create;
  oBlockLocal.Tipo := bytTipo;
  oBlockLocal.Colore := bytColore;
  oBlockLocal.Q1 := shrQ1;
  oBlockLocal.Q2 := shrQ2;
  oBlockLocal.Q3 := shrQ3;
  oBlockLocal.Q4 := shrQ4;
  oBlockLocal.PR := shrPR;
  oTypeBlock.add(oBlockLocal);
end;

Procedure TFMain.subVerificaLinee;
Var
  i, j: Integer;
  h: Integer;
  k: Integer;
  bytLineeCompletate: Integer;
  blnLinea: Boolean;
  strScrittaPunteggioParziale: String;
  shrPunteggioParziale: Integer;
begin
//'inizio processo
  subProcessoInCorso(True);
  shrPunteggioParziale := 0;
  bytLineeCompletate := 0;
  for i := 0 TO (BYT_RIGHE - 1) do
  begin
    blnLinea := TRUE;
    for j := 0 TO (BYT_COLONNE - 1) do
      blnLinea := blnLinea AND (cbytGrigliaAttuale[j, i] <> BYT_VUOTO);

    IF blnLinea = True THEN
    begin
      bytLineeCompletate := bytLineeCompletate+1;
      oSuono.Play(5);
      FOR j := 0 TO (BYT_COLONNE - 1) do
        cbytGrigliaAttuale[j, i] := BYT_COLORE_GRIGIO;

      subAggiornaGriglia;
      Sleep(1000);
      for h := i downto 1 do
      begin
        for k := 0 TO (BYT_COLONNE - 1) do
        begin
          if h > 1 then
            cbytGrigliaAttuale[k, h] := cbytGrigliaAttuale[k, (h - 1)]
          else
            cbytGrigliaAttuale[k, h] := BYT_VUOTO;
        end;
      end;
    end;
  end;

  CASE bytLineeCompletate of
    1: begin
         strScrittaPunteggioParziale := 'SIMPLE';
         shrPunteggioParziale := 50;
       end;
    2: begin
         strScrittaPunteggioParziale := 'DOBLE';
         shrPunteggioParziale := 150 ;
       end;
    3: begin
         strScrittaPunteggioParziale := 'TRIPLE';
         shrPunteggioParziale := 400;
       end;
    4: begin
         strScrittaPunteggioParziale := 'TETRIS';
         shrPunteggioParziale := 900;
       end;
  end;

  cintPunteggio := cintPunteggio + (shrPunteggioParziale);
  cshrLineeFatte := cshrLineeFatte + bytLineeCompletate;
  cshrLineeRound := cshrLineeRound - bytLineeCompletate;
  IF cshrLineeRound < 0 THEN cshrLineeRound := 0;
    subAggiornaScritteStato(strScrittaPunteggioParziale, shrPunteggioParziale.ToString);
  subProcessoInCorso(FALSE);

end;

procedure TFMain.subAggiornaScritteStato(strScrittaPunteggioParziale, strPunteggioParziale: String);
Var stringa: String;
//    Classifica: CClassifica; //'classifica
Begin

  ClearImg(drwSfondo);
  drwSfondo.Canvas.Font.Name := 'Verdana';
  drwSfondo.Canvas.Font.Style := [fsBold];
  drwSfondo.Canvas.Font.Size := 12;
  drwSfondo.Canvas.Font.Color := clRed;
  drwSfondo.Canvas.Draw(0,0, picSfondo[(cbytSfondo - 1)].Picture.Graphic);
//'visualizza il numero di linee del round
  if cshrLineeRound < 10 then
    stringa := '0' + cshrLineeRound.ToString
  else
    stringa := cshrLineeRound.ToString;

  drwSfondo.Canvas.TextOut(328, 315, stringa);
  drwSfondo.Canvas.TextOut((268 -  drwSfondo.Canvas.TextWidth(cintPunteggio.ToString)), 485, cintPunteggio.ToString); //'punteggio
  drwSfondo.Canvas.TextOut((268 - drwSfondo.Canvas.TextWidth(cshrLineeFatte.ToString)), 503, cshrLineeFatte.ToString);

//'Visualizza la scritta del punteggio parziale guadagnato

{  if strPunteggioParziale.ToInteger <> 0 THEN
  begin
    Draw.Font.Size = 20
    Draw.ForeColor = Color.DarkBlue
    Draw.Text((strScrittaPunteggioParziale & "     " & strPunteggioParziale), 80, 445)
    tmrPunteggioParziale.Enabled = TRUE //'timer per rimuovere la scritta
  end;


//'visualizza l'highscore
    Draw.Font.Size = 22
    Draw.ForeColor = Color.RGB(0, 0, 138)
    Classifica.Posizione = 1
    IF Classifica.Punteggio <> NULL THEN
        IF cintPunteggio < CInt(Classifica.Punteggio) OR cintPunteggio = 0 THEN
            stringa = Classifica.Punteggio
        ELSE
            stringa = Str(cintPunteggio)
        ENDIF
    ELSE
        stringa = Str(cintPunteggio)
    ENDIF
    Draw.Text(stringa, (375 - ((Draw.TextWidth(stringa)) / 2)), 428)
 }
//'visualizza il numero del round
  if cbytRound > 0 then
  begin
    drwSfondo.Canvas.Font.Size := 18;
    drwSfondo.Canvas.Brush.Color := $00949594;
    drwSfondo.Canvas.Font.Color := clNavy;
    drwSfondo.Canvas.TextOut((400 - drwSfondo.Canvas.TextWidth(cshrLineeRound.ToString) div 2), 461, cbytRound.ToString);
  end;

//'visualizza il numero di linee mancanti in colonna sx
  drwSfondo.Canvas.Font.Size := 22;
  drwSfondo.Canvas.Font.Style := [];
  if (cshrLineeRound <= 5) and (cshrLineeRound > 0) THEN //'linee in colonna sx
  begin
    drwSfondo.Canvas.Font.Color := clRed;
    drwSfondo.Canvas.TextOut((27 - drwSfondo.Canvas.TextWidth(cshrLineeRound.ToString) div 2), 144 + ((5 - cshrLineeRound) * 63), cshrLineeRound.ToString);
  end;

//'visualizza la scritta stats
{
    Draw.ForeColor = Color.White
    Draw.Font.Size = 22
    Draw.Font.Bold = TRUE
    Draw.Font.Name = "Arial"
    IF cbytRound > 0 THEN Draw.Text("STADO", 558, 115)
}
end;

procedure TFMain.TimerTimer(Sender: TObject);
Var
  c, r: Integer; // 'contatori per (c)olonna e (r)iga
  y: Integer; // AS Integer 'punto piu' alto del puzzle
  intBonus: Integer; // AS Integer 'bonus di round vinto
//     Classifica AS CClassifica 'classifica
begin
  IF funcMuoviBlocco(BYT_GIU) = FALSE THEN
  begin
    subVerificaLinee;
    IF cshrLineeRound <= 0 THEN
    begin
      subProcessoInCorso(True);
      timer.Enabled := False;
      subAggiornaGriglia;
      oSuono.StopPlay;
//                'visualizza la scritta di round vinto
//                    lblInizioRound.Text = "HECHO\nYA"
//                    lblInizioRound.Visible = TRUE
//                'suono di vittoria round
      oSuono.Play(4); //              Gioco.Suono[4].Play
//                'tendina
//                    WAIT 2
//                    lblInizioRound.Text = "BONOS PARA\nEL\nPUZZLE"
//                    WAIT 0.6
//                        'determina il punto piu' alto del puzzle
      y := 0;
      FOR r := 2 TO (BYT_RIGHE - 1) do
      begin
        FOR c := 0 TO (BYT_COLONNE - 1) do
        begin
          IF cbytGrigliaAttuale[c, r] <> BYT_VUOTO THEN
            y := r;
          IF y > 0 THEN BREAK;
        end;
        IF y > 0 THEN BREAK;
      end;
//                      'visualizza la tendina
      FOR r := 2 TO (y - 1) do
      begin
        FOR c := 0 TO (BYT_COLONNE - 1) do
          cbytGrigliaAttuale[c, r] := BYT_COLORE_GRIGIO;

        cintPunteggio := cintPunteggio + (5 * (y - 1));
        intBonus := intBonus + (5 * (y - 1));
        sleep(5);
        subAggiornaGriglia;
      //subAggiornaScritteStato;
      end;
      subAggiornaScritteStato('BONOS', (intBonus.ToString));
      Sleep(15);
//                'se e' stata completata una terzina di rounds, visualizza l'animazione omino
      IF (cbytRound >= 3) AND ((cbytRound MOD 3) = 0) THEN
      begin //
        oSuono.PlayFile('base' + (cbytSfondo + 4).ToString + '.mp2');
               { WITH movAnimazione
                    .Path = ("./tetris_balletto" & Str(cbytSfondo) & ".gif")
                    .Raise
                    .Visible = TRUE
                    .Playing = TRUE
                END WITH

                IF cbytSfondo = 3 THEN
                    WAIT 14.5
                ELSE
                    WAIT 10.5
                ENDIF
                }
               // movAnimazione.Visible = FALSE
      end;
       // 'avvia il prossimo round
      subNuovoRound(Nil);
      exit;
    END;
//        'verifica se perso
    IF (cBloccoAttuale.Q1.Y < 1) OR
       (cBloccoAttuale.Q2.Y < 1) OR
       (cBloccoAttuale.Q3.Y < 1) OR
       (cBloccoAttuale.Q4.Y < 1) THEN
    begin
//              'inizio processo
      subProcessoInCorso(TRUE);
//            'ferma il tempo
      timer.Enabled := FALSE;
//                'visualizza game over
      oSuono.StopPlay; //              Music.Stop
//                    picGameOver.Visible = TRUE
      oSuono.Play(3);
//                    Gioco.Suono[3].Play
//                'se il giocatore e' in classifica aggiornala e visualizzala
//                        Classifica = NEW CClassifica
//                    Classifica.DeterminaPosizioneRaggiunta(cintPunteggio) 'determina la posizione raggiunta
{                    IF Classifica.Posizione > 0 THEN 'se e' entrato in classifica
                'scala la classifica attuale
                    Classifica.ScalaClassifica(Classifica.Posizione)
                'inserisci i dati del giocatore
                    Classifica.Nome = "chiedi"
                    Classifica.Round = Str(cbytRound)
                    Classifica.Punteggio = Str(cintPunteggio)
                'visualizza la classifica
                        WAIT 1
                    Classifica.Visualizza
            ENDIF
}
//                'chiedi se fare un'altra partita

{                  SELECT Message.Question("otra partida?", "&Si", "&No")
                CASE 1
                    mnuGiocoNuovo_Click 'inizia una nuova partita
                CASE 2
                    ME.Close 'chiudi il gioco
'                            FMain.Show 'torna alla FMain
            END SELECT
        'esci dalla routine
            RETURN
}
    end;
//        'punteggio per il blocco posizionato
{            IF Not tmrPunteggioParziale.Enabled  THEN
    begin
        intBonus := 2 * (Int(Rnd(1, (BYT_NUMBLOCCHI + 1))) * cbytRound);
        cintPunteggio := cintPunteggio + intBonus;
                subAggiornaScritteStato("            ", Str(intBonus))
    END;
}
//        'suono di ancoraggio blocco
//            Gioco.Suono[1].Play
//        'aspetta che eventuali processi in corso (drop linee) si concludano
//            REPEAT
//            UNTIL ME.Mouse <> Mouse.WAIT
//        'round 7-8-9, 19-20-21, 25 in poi: possibile inserimento quadratino aggiuntivo
{            IF (cbytRound >= 7) AND (cbytRound <= 9) THEN subAggiungiQuadratino(15);
    IF (cbytRound >= 10) AND (cbytRound <= 12) THEN subAggiungiRiga(8);
    IF (cbytRound >= 19) AND (cbytRound <= 21) THEN subAggiungiQuadratino(25);
    IF (cbytRound >= 22) AND (cbytRound <= 24) THEN subAggiungiRiga(12);
    IF cbytRound >= 25) THEN
    begin
        subAggiungiQuadratino(30);
        subAggiungiRiga(15);
    END;
*}
//        'nuovo blocco
      subNuovoBlocco;
    END;

end;

procedure TFMain.Uscita1Click(Sender: TObject);
begin
  Close;
end;

procedure TFMain.subDisegnaQuadratino(drwObj:TImage; shrXY: TPoint; oBlockImgPar:TImage);
Var X, Y: Integer;
begin
  X := shrXY.X * BYT_LATO_QUADRATINO;
  Y := shrXY.Y * BYT_LATO_QUADRATINO;
  drwObj.canvas.Draw(X, Y, oBlockImgPar.Picture.Graphic);
END;

procedure TFMain.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var a: Integer;
begin
  CASE Key of
    VK_ESCAPE:  Close;
    VK_LEFT: funcMuoviBlocco(BYT_SX);
    VK_RIGHT: funcMuoviBlocco(BYT_DX);
    VK_DOWN: funcMuoviBlocco(BYT_GIU);
    VK_UP: funcMuoviBlocco(BYT_RSX);
//'        CASE 4131 'alt
//'            funcMuoviBlocco(BYT_RDX)
  END ;
end;

Procedure  TFMain.subDisegnaBlocco(blnPrimoBlocco: Boolean);
var c, r:Integer; // 'contatori per (c)olonna e (r)iga
begin
//'se il blocco e' in movimento cancellane la posizione precedente
  IF blnPrimoBlocco = FALSE THEN
  begin
    cbytGrigliaAttuale[cBloccoPosizionePrecedente.Q1.X, cBloccoPosizionePrecedente.Q1.Y] := BYT_VUOTO;
    cbytGrigliaAttuale[cBloccoPosizionePrecedente.Q2.X, cBloccoPosizionePrecedente.Q2.Y] := BYT_VUOTO;
    cbytGrigliaAttuale[cBloccoPosizionePrecedente.Q3.X, cBloccoPosizionePrecedente.Q3.Y] := BYT_VUOTO;
    cbytGrigliaAttuale[cBloccoPosizionePrecedente.Q4.X, cBloccoPosizionePrecedente.Q4.Y] := BYT_VUOTO;
  end;

//'imposta i nuovi valori della griglia per il blocco
  cbytGrigliaAttuale[cBloccoAttuale.Q1.X, cBloccoAttuale.Q1.Y] := cBloccoAttuale.Colore;
  cbytGrigliaAttuale[cBloccoAttuale.Q2.X, cBloccoAttuale.Q2.Y] := cBloccoAttuale.Colore;
  cbytGrigliaAttuale[cBloccoAttuale.Q3.X, cBloccoAttuale.Q3.Y] := cBloccoAttuale.Colore;
  cbytGrigliaAttuale[cBloccoAttuale.Q4.X, cBloccoAttuale.Q4.Y] := cBloccoAttuale.Colore;

//'memorizza la posizione attuale come posizione precedente per essere cancellata a movimento avvenuto
  cBloccoAttuale.SetBuffer;
  cBloccoPosizionePrecedente.Q1 := cBloccoAttuale.Q1;
  cBloccoPosizionePrecedente.Q2 := cBloccoAttuale.Q2;
  cBloccoPosizionePrecedente.Q3 := cBloccoAttuale.Q3;
  cBloccoPosizionePrecedente.Q4 := cBloccoAttuale.Q4;

//'aggiorna la griglia e disegna il blocco
  subAggiornaGriglia;
end;

Procedure TFMain.subAggiornaGriglia;
Var
  c, r: Integer; // 'contatori per (c)olonna e (r)iga
  oPoint: TPoint;
Begin
  FOR r := 0 TO (BYT_RIGHE - 1) do
    FOR c := 0 TO (BYT_COLONNE - 1) do
    begin
      IF cbytGrigliaPrecedente[c, r] <> cbytGrigliaAttuale[c, r] THEN
      begin
        oPoint.X := c;
        oPoint.Y := r;
        subDisegnaQuadratino(drwGriglia, oPoint, oRect.Items[cbytGrigliaAttuale[c, r]]);
        cbytGrigliaPrecedente[c, r] := cbytGrigliaAttuale[c, r];
      END;
    end;
END;

Procedure TFMain.subRuotaQuadretto(NQ: Integer; QX, QY, RX, RY, shrDirezione: Integer);
Var
  X: Integer;
  Y: Integer;
begin
{
  IF shrDirezione = BYT_RDX THEN
    shrDirezione := BYT_SX;
  IF shrDirezione = BYT_RSX THEN
    shrDirezione := BYT_DX;

  X := shrDirezione * (QY - RY) + RX;
  Y := (0 - shrDirezione) * (QX - RX) + RY;

  CASE NQ of
    1:begin
        cBloccoAttuale.Q1.X := X;
        cBloccoAttuale.Q1.Y := Y;
      end;
    2:begin
        cBloccoAttuale.Q2.X := X;
        cBloccoAttuale.Q2.Y := Y;
      end;
    3:begin
        cBloccoAttuale.Q3.X := X;
        cBloccoAttuale.Q3.Y := Y;
      end;
    4:begin
        cBloccoAttuale.Q4.X := X;
        cBloccoAttuale.Q4.Y := Y;
      end;
  end;
}
end;

Function TFMain.subNuovoBlocco: Boolean;
Var n: Integer; // 'numero random
begin
  cBloccoAttuale.Tipo := cBloccoSuccessivo.Tipo;
  cBloccoAttuale.Colore := cBloccoSuccessivo.Colore;
  cBloccoAttuale.Q1 := cBloccoSuccessivo.Q1;
  cBloccoAttuale.Q2 := cBloccoSuccessivo.Q2;
  cBloccoAttuale.Q3 := cBloccoSuccessivo.Q3;
  cBloccoAttuale.Q4 := cBloccoSuccessivo.Q4;
  cBloccoAttuale.PR := cBloccoSuccessivo.PR;

//'visualizza il blocco attuale
  subDisegnaBlocco(True);

//'aggiorna le stats
   oPanelStat.Items[cBloccoAttuale.Colore].Visible := True;
   oPanelStat.Items[cBloccoAttuale.Colore].Top := oPanelStat.Items[cBloccoAttuale.Colore].Top - 8;
   oPanelStat.Items[cBloccoAttuale.Colore].Height := oPanelStat.Items[cBloccoAttuale.Colore].Height + 8;
//'sorteggia il blocco successivo
  subBloccoAnteprima;
END;

FUNCTION TFMain.funcMuoviBlocco(shrDirezione: Integer): Boolean;
Var mov: Boolean; // 'movimento
begin
  if not timer.Enabled Then
    exit;

  cBloccoAttuale.Clone;
  cBloccoAttuale.Move(shrDirezione);
  mov := cBloccoAttuale.Check(cbytGrigliaAttuale);
  if not mov then
    cBloccoAttuale.Reset
  else
    subDisegnaBlocco(False);

  Result := mov;
END;

FUNCTION TFMain.funcVerificaLimitiBlocco(QX, QY: Integer): Boolean;
begin
  IF (QY > (BYT_RIGHE - 1)) OR (QY < 0) OR (QX > (BYT_COLONNE - 1)) OR (QX < 0) then
    Result := False
  else if ((QX = cBloccoRipristino.Q1.X) AND (QY = cBloccoRipristino.Q1.Y)) OR
          ((QX = cBloccoRipristino.Q2.X) AND (QY = cBloccoRipristino.Q2.Y)) OR
          ((QX = cBloccoRipristino.Q3.X) AND (QY = cBloccoRipristino.Q3.Y)) OR
          ((QX = cBloccoRipristino.Q4.X) AND (QY = cBloccoRipristino.Q4.Y)) THEN
    Result := True

  else if cbytGrigliaAttuale[QX, QY] <> BYT_VUOTO then
    Result := False
  else
    Result := True;
end;


procedure TFMain.Inizio1Click(Sender: TObject);
begin
  mnuGiocoNuovo_Click;
end;

procedure TFMain.subNuovoRound(Sender: TObject);
Var r,c,i: Integer;
    oPoint: Tpoint;
begin
  subProcessoInCorso(True);
  ClearImg(drwAnteprima);
  ClearImg(drwGriglia);

  FOR r := 0 TO (BYT_RIGHE - 1) do
    FOR c := 0 TO (BYT_COLONNE - 1) do
    begin
      cbytGrigliaAttuale[c, r] := BYT_VUOTO;
      cbytGrigliaPrecedente[c, r] := BYT_VUOTO;
      oPoint.X := c;
      oPoint.Y := r;
      subDisegnaQuadratino(drwGriglia, oPoint, oRect.Items[0]) //'picture vuota
    end;
  if not assigned(cBloccoAttuale) then
    cBloccoAttuale := TBloccoTetris.Create;
  if not assigned(cBloccoPosizionePrecedente) then
    cBloccoPosizionePrecedente := TBloccoTetris.Create;
  if not assigned(cBloccoRipristino) then
    cBloccoRipristino := TBloccoTetris.Create;
  if not assigned(cBloccoSuccessivo) then
    cBloccoSuccessivo := TBloccoTetris.Create;

  IF (cbytRound MOD 3) = 0 then //'il numero di round non e' ancora stato incrementato!
  begin
    for i := 1 to 7 do
    begin
      oPanelStat.Items[i].Visible := FALSE;
      oPanelStat.Items[i].Height := 0;
      oPanelStat.Items[i].Top := BYT_GRIGLIA_Y + (BYT_LATO_QUADRATINO * BYT_RIGHE);
    end;
  end;
  cbytRound := cbytRound + 1;

  CASE cbytRound of
     1: cshrLineeRound := 5;
     2: cshrLineeRound := 10;
     3: cshrLineeRound := 12;
     4: cshrLineeRound := 10;
     5: cshrLineeRound := 13;
     6: cshrLineeRound := 16;
    else //'dal settimo round in poi il numero di linee e' 12-15-18 a rotazione
      Case (cbytRound MOD 3) of
        1: cshrLineeRound := 12;
        2: cshrLineeRound := 15;
        0: cshrLineeRound := 18;//18;
      end;
  end;
//    'velocita'
  IF cbytRound > 8 THEN
    Timer.Interval := 210
  ELSE
    Timer.Interval := 550 - (cbytRound * 60);

  if (cbytRound MOD 15) = 4 then
  begin
    i := 1;
    for r := (BYT_RIGHE - 9) TO (BYT_RIGHE - 1)  do
    begin
      cbytGrigliaAttuale[0, r] := i;
      cbytGrigliaAttuale[9, r] := i;
      i := i + 1;
      if i > BYT_NUMBLOCCHI then
        i := 1
    end;
  end;
//        'round 5, 20, ecc
  IF (cbytRound MOD 15) = 5 THEN
  begin
    cbytGrigliaAttuale[1, 21] := BYT_COLORE_VERDE;
    cbytGrigliaAttuale[6, 21] := BYT_COLORE_BLU;
    cbytGrigliaAttuale[3, 20] := BYT_COLORE_ARANCIO;
    cbytGrigliaAttuale[8, 20] := BYT_COLORE_ROSSO;
    cbytGrigliaAttuale[5, 19] := BYT_COLORE_AZZURRO;
    cbytGrigliaAttuale[2, 18] := BYT_COLORE_BLU;
    cbytGrigliaAttuale[6, 18] := BYT_COLORE_GIALLO;
    cbytGrigliaAttuale[7, 18] := BYT_COLORE_VIOLA;
    cbytGrigliaAttuale[1, 17] := BYT_COLORE_ROSSO;
    cbytGrigliaAttuale[4, 17] := BYT_COLORE_VERDE;
  END;
     //   'round 6, 21, ecc
  IF (cbytRound MOD 15) = 6 THEN
  begin
      FOR r := (BYT_RIGHE - 6) downto (BYT_RIGHE - 1) do
      begin
        FOR c := (21 - r) TO (r - 12) do
             cbytGrigliaAttuale[c, r] := Integer(Random(BYT_NUMBLOCCHI )+ 1);

      end;
  END;
  cbytGrigliaAttuale[2, (BYT_RIGHE - 1)] := BYT_VUOTO;
  cbytGrigliaAttuale[7, (BYT_RIGHE - 1)] := BYT_VUOTO;
  cbytGrigliaAttuale[3, (BYT_RIGHE - 2)] := BYT_VUOTO;
  cbytGrigliaAttuale[6, (BYT_RIGHE - 2)] := BYT_VUOTO;
  cbytGrigliaAttuale[4, (BYT_RIGHE - 3)] := BYT_VUOTO;
  cbytGrigliaAttuale[5, (BYT_RIGHE - 3)] := BYT_VUOTO;
//        'round 13, 28, ecc
  IF (cbytRound MOD 15) = 13 THEN
  begin
    i := 1;
    FOR r := (BYT_RIGHE - 5) downto (BYT_RIGHE - 1) do
    begin
      cbytGrigliaAttuale[0, r] := i;
      cbytGrigliaAttuale[9, r] := i;
      i := i + 1;
    end;
    FOR r := (BYT_RIGHE - 4) downto (BYT_RIGHE - 2) do
    begin
      cbytGrigliaAttuale[1, r] := i;
      cbytGrigliaAttuale[8, r] := i;
      i := i +1;
      IF i > BYT_NUMBLOCCHI THEN
        i := 1;
    end;
    cbytGrigliaAttuale[2, (BYT_RIGHE - 3)] := i;
    cbytGrigliaAttuale[7, (BYT_RIGHE - 3)] := i;
  END;
// 'round 14, 29, ecc
  IF (cbytRound MOD 15) = 14 THEN
  begin
    cbytGrigliaAttuale[4, (BYT_RIGHE - 2)] := BYT_COLORE_BLU;
    cbytGrigliaAttuale[5, (BYT_RIGHE - 2)] := BYT_COLORE_VIOLA;
    cbytGrigliaAttuale[2, (BYT_RIGHE - 4)] := BYT_COLORE_AZZURRO;
    cbytGrigliaAttuale[7, (BYT_RIGHE - 4)] := BYT_COLORE_ROSSO;
    cbytGrigliaAttuale[4, (BYT_RIGHE - 6)] := BYT_COLORE_VERDE;
    cbytGrigliaAttuale[5, (BYT_RIGHE - 6)] := BYT_COLORE_GIALLO;
  END;
// 'round 15, 30, ecc
  IF (cbytRound >= 15) AND ((cbytRound MOD 15) = 0) THEN
  begin
    cbytGrigliaAttuale[0, (BYT_RIGHE - 1)] := BYT_COLORE_BLU;
    cbytGrigliaAttuale[7, (BYT_RIGHE - 1)] := BYT_COLORE_GIALLO;
    cbytGrigliaAttuale[1, (BYT_RIGHE - 2)] := BYT_COLORE_BLU;
    cbytGrigliaAttuale[8, (BYT_RIGHE - 2)] := BYT_COLORE_GIALLO;
    cbytGrigliaAttuale[2, (BYT_RIGHE - 3)] := BYT_COLORE_BLU;
    cbytGrigliaAttuale[9, (BYT_RIGHE - 3)] := BYT_COLORE_GIALLO;
    cbytGrigliaAttuale[3, (BYT_RIGHE - 4)] := BYT_COLORE_BLU;
    cbytGrigliaAttuale[6, (BYT_RIGHE - 4)] := BYT_COLORE_VERDE;
    cbytGrigliaAttuale[7, (BYT_RIGHE - 5)] := BYT_COLORE_VERDE;
    cbytGrigliaAttuale[1, (BYT_RIGHE - 6)] := BYT_COLORE_ROSSO;
    cbytGrigliaAttuale[8, (BYT_RIGHE - 6)] := BYT_COLORE_VERDE;
    cbytGrigliaAttuale[2, (BYT_RIGHE - 7)] := BYT_COLORE_ROSSO;
  END;
// 'round 16, 31, ecc
  IF (cbytRound >= 15) AND ((cbytRound MOD 15) = 1) THEN
  begin
    cbytGrigliaAttuale[0, (BYT_RIGHE - 1)] := BYT_COLORE_ROSSO;
    cbytGrigliaAttuale[1, (BYT_RIGHE - 1)] := BYT_COLORE_ROSSO;
    cbytGrigliaAttuale[3, (BYT_RIGHE - 1)] := BYT_COLORE_VERDE;
    cbytGrigliaAttuale[5, (BYT_RIGHE - 1)] := BYT_COLORE_VERDE;
    cbytGrigliaAttuale[6, (BYT_RIGHE - 1)] := BYT_COLORE_BLU;
    cbytGrigliaAttuale[7, (BYT_RIGHE - 1)] := BYT_COLORE_BLU;
    cbytGrigliaAttuale[2, (BYT_RIGHE - 2)] := BYT_COLORE_ROSSO;
    cbytGrigliaAttuale[3, (BYT_RIGHE - 2)] := BYT_COLORE_VERDE;
    cbytGrigliaAttuale[5, (BYT_RIGHE - 2)] := BYT_COLORE_VERDE;
    cbytGrigliaAttuale[8, (BYT_RIGHE - 2)] := BYT_COLORE_BLU;
    cbytGrigliaAttuale[1, (BYT_RIGHE - 3)] := BYT_COLORE_ROSSO;
    cbytGrigliaAttuale[3, (BYT_RIGHE - 3)] := BYT_COLORE_VERDE;
    cbytGrigliaAttuale[4, (BYT_RIGHE - 3)] := BYT_COLORE_VERDE;
    cbytGrigliaAttuale[5, (BYT_RIGHE - 3)] := BYT_COLORE_VERDE;
    cbytGrigliaAttuale[7, (BYT_RIGHE - 3)] := BYT_COLORE_BLU;
    cbytGrigliaAttuale[0, (BYT_RIGHE - 4)] := BYT_COLORE_ROSSO;
    cbytGrigliaAttuale[3, (BYT_RIGHE - 4)] := BYT_COLORE_VERDE;
    cbytGrigliaAttuale[5, (BYT_RIGHE - 4)] := BYT_COLORE_VERDE;
    cbytGrigliaAttuale[6, (BYT_RIGHE - 4)] := BYT_COLORE_BLU;
    cbytGrigliaAttuale[1, (BYT_RIGHE - 5)] := BYT_COLORE_ROSSO;
    cbytGrigliaAttuale[2, (BYT_RIGHE - 5)] := BYT_COLORE_ROSSO;
    cbytGrigliaAttuale[4, (BYT_RIGHE - 5)] := BYT_COLORE_VERDE;
    cbytGrigliaAttuale[7, (BYT_RIGHE - 5)] := BYT_COLORE_BLU;
    cbytGrigliaAttuale[8, (BYT_RIGHE - 5)] := BYT_COLORE_BLU;
  END;
    //    'round 17, 32, ecc
  IF (cbytRound >= 15) AND ((cbytRound MOD 15) = 2) THEN
  begin
    cbytGrigliaAttuale[0, (BYT_RIGHE - 1)] := BYT_COLORE_ROSSO;
    cbytGrigliaAttuale[1, (BYT_RIGHE - 1)] := BYT_COLORE_ROSSO;
    cbytGrigliaAttuale[2, (BYT_RIGHE - 1)] := BYT_COLORE_ROSSO;
    cbytGrigliaAttuale[3, (BYT_RIGHE - 1)] := BYT_COLORE_VERDE;
    cbytGrigliaAttuale[6, (BYT_RIGHE - 1)] := BYT_COLORE_BLU;
    cbytGrigliaAttuale[8, (BYT_RIGHE - 1)] := BYT_COLORE_BLU;
    cbytGrigliaAttuale[0, (BYT_RIGHE - 2)] := BYT_COLORE_ROSSO;
    cbytGrigliaAttuale[2, (BYT_RIGHE - 2)] := BYT_COLORE_ROSSO;
    cbytGrigliaAttuale[3, (BYT_RIGHE - 2)] := BYT_COLORE_VERDE;
    cbytGrigliaAttuale[6, (BYT_RIGHE - 2)] := BYT_COLORE_BLU;
    cbytGrigliaAttuale[8, (BYT_RIGHE - 2)] := BYT_COLORE_BLU;
    cbytGrigliaAttuale[0, (BYT_RIGHE - 3)] := BYT_COLORE_ROSSO;
    cbytGrigliaAttuale[1, (BYT_RIGHE - 3)] := BYT_COLORE_ROSSO;
    cbytGrigliaAttuale[2, (BYT_RIGHE - 3)] := BYT_COLORE_ROSSO;
    cbytGrigliaAttuale[3, (BYT_RIGHE - 3)] := BYT_COLORE_VERDE;
    cbytGrigliaAttuale[4, (BYT_RIGHE - 3)] := BYT_COLORE_VERDE;
    cbytGrigliaAttuale[6, (BYT_RIGHE - 3)] := BYT_COLORE_BLU;
    cbytGrigliaAttuale[8, (BYT_RIGHE - 3)] := BYT_COLORE_BLU;
    cbytGrigliaAttuale[0, (BYT_RIGHE - 4)] := BYT_COLORE_ROSSO;
    cbytGrigliaAttuale[3, (BYT_RIGHE - 4)] := BYT_COLORE_VERDE;
    cbytGrigliaAttuale[6, (BYT_RIGHE - 4)] := BYT_COLORE_BLU;
    cbytGrigliaAttuale[7, (BYT_RIGHE - 4)] := BYT_COLORE_BLU;
    cbytGrigliaAttuale[8, (BYT_RIGHE - 4)] := BYT_COLORE_BLU;
    cbytGrigliaAttuale[0, (BYT_RIGHE - 5)] := BYT_COLORE_ROSSO;
    cbytGrigliaAttuale[1, (BYT_RIGHE - 5)] := BYT_COLORE_ROSSO;
    cbytGrigliaAttuale[2, (BYT_RIGHE - 5)] := BYT_COLORE_ROSSO;
    cbytGrigliaAttuale[3, (BYT_RIGHE - 5)] := BYT_COLORE_VERDE;
    cbytGrigliaAttuale[4, (BYT_RIGHE - 5)] := BYT_COLORE_VERDE;
    cbytGrigliaAttuale[5, (BYT_RIGHE - 5)] := BYT_COLORE_VERDE;
    cbytGrigliaAttuale[6, (BYT_RIGHE - 5)] := BYT_COLORE_BLU;
    cbytGrigliaAttuale[8, (BYT_RIGHE - 5)] := BYT_COLORE_BLU;
  END;
//  'round 18, 33, ecc
  IF (cbytRound >= 15) AND ((cbytRound MOD 15) = 3) THEN
  begin
    cbytGrigliaAttuale[0, (BYT_RIGHE - 1)] := BYT_COLORE_ROSSO;
    cbytGrigliaAttuale[2, (BYT_RIGHE - 1)] := BYT_COLORE_ROSSO;
    cbytGrigliaAttuale[3, (BYT_RIGHE - 1)] := BYT_COLORE_VERDE;
    cbytGrigliaAttuale[4, (BYT_RIGHE - 1)] := BYT_COLORE_VERDE;
    cbytGrigliaAttuale[6, (BYT_RIGHE - 1)] := BYT_COLORE_BLU;
    cbytGrigliaAttuale[7, (BYT_RIGHE - 1)] := BYT_COLORE_BLU;
    cbytGrigliaAttuale[0, (BYT_RIGHE - 2)] := BYT_COLORE_ROSSO;
    cbytGrigliaAttuale[1, (BYT_RIGHE - 2)] := BYT_COLORE_ROSSO;
    cbytGrigliaAttuale[3, (BYT_RIGHE - 2)] := BYT_COLORE_VERDE;
    cbytGrigliaAttuale[5, (BYT_RIGHE - 2)] := BYT_COLORE_VERDE;
    cbytGrigliaAttuale[6, (BYT_RIGHE - 2)] := BYT_COLORE_BLU;
    cbytGrigliaAttuale[8, (BYT_RIGHE - 2)] := BYT_COLORE_BLU;
    cbytGrigliaAttuale[0, (BYT_RIGHE - 3)] := BYT_COLORE_ROSSO;
    cbytGrigliaAttuale[1, (BYT_RIGHE - 3)] := BYT_COLORE_ROSSO;
    cbytGrigliaAttuale[2, (BYT_RIGHE - 3)] := BYT_COLORE_ROSSO;
    cbytGrigliaAttuale[3, (BYT_RIGHE - 3)] := BYT_COLORE_VERDE;
    cbytGrigliaAttuale[4, (BYT_RIGHE - 3)] := BYT_COLORE_VERDE;
    cbytGrigliaAttuale[5, (BYT_RIGHE - 3)] := BYT_COLORE_VERDE;
    cbytGrigliaAttuale[6, (BYT_RIGHE - 3)] := BYT_COLORE_BLU;
    cbytGrigliaAttuale[8, (BYT_RIGHE - 3)] := BYT_COLORE_BLU;
    cbytGrigliaAttuale[0, (BYT_RIGHE - 4)] := BYT_COLORE_ROSSO;
    cbytGrigliaAttuale[2, (BYT_RIGHE - 4)] := BYT_COLORE_ROSSO;
    cbytGrigliaAttuale[3, (BYT_RIGHE - 4)] := BYT_COLORE_VERDE;
    cbytGrigliaAttuale[5, (BYT_RIGHE - 4)] := BYT_COLORE_VERDE;
    cbytGrigliaAttuale[6, (BYT_RIGHE - 4)] := BYT_COLORE_BLU;
    cbytGrigliaAttuale[8, (BYT_RIGHE - 4)] := BYT_COLORE_BLU;
    cbytGrigliaAttuale[0, (BYT_RIGHE - 5)] := BYT_COLORE_ROSSO;
    cbytGrigliaAttuale[1, (BYT_RIGHE - 5)] := BYT_COLORE_ROSSO;
    cbytGrigliaAttuale[2, (BYT_RIGHE - 5)] := BYT_COLORE_ROSSO;
    cbytGrigliaAttuale[3, (BYT_RIGHE - 5)] := BYT_COLORE_VERDE;
    cbytGrigliaAttuale[4, (BYT_RIGHE - 5)] := BYT_COLORE_VERDE;
    cbytGrigliaAttuale[6, (BYT_RIGHE - 5)] := BYT_COLORE_BLU;
    cbytGrigliaAttuale[7, (BYT_RIGHE - 5)] := BYT_COLORE_BLU;
  END;
  subAggiornaScritteStato('','');

  subAggiornaGriglia;
  subBloccoAnteprima;
  subNuovoBlocco;

//    'se inizia una nuova terzina suono relativo
//        'IF cbytRound > 3 AND (cbytRound MOD 3 = 1) THEN Gioco.Suono[2].Play
//    'visualizza l'anteprima
//        subBloccoAnteprima
//    'pausa di inizio round, poi nascondi la scritta iniziale
     sleep(1000);
//        lblInizioRound.Visible = FALSE
//    'nuovo blocco
//        subNuovoBlocco
//    'avvia la base

  FOR i := 1 TO 4 do
  begin
    IF ((cbytRound MOD i) = 0) THEN
      oSuono.PlayFile('base' + i.ToString + '.mp2');
  end;

  //  'inizia la caduta del blocco
  Timer.Enabled := True;

//'fine processo
  subProcessoInCorso(FALSE);
end;

procedure TFMain.subProcessoInCorso(blnStato: Boolean);
begin
{    SELECT CASE blnStato
        CASE TRUE
            ME.Mouse = mouse.Wait
'            mnuGiocoNuovo.Enabled = FALSE
 '           mnuGiocoPausa.Enabled = FALSE
    '        mnuFileSalva.Enabled = FALSE
'            mnuGiocoCambia.Enabled = FALSE
'            mnuClassificaVisualizza.Enabled = FALSE
'            mnuClassificaResetta.Enabled = FALSE
'            mnuAiutoRegole.Enabled = FALSE
'            mnuAiutoInformazioni.Enabled = FALSE
        CASE FALSE
            ME.Mouse = mouse.Default
'            mnuGiocoNuovo.Enabled = TRUE
'            mnuGiocoPausa.Enabled = TRUE
    '        mnuFileSalva.Enabled = TRUE
'            mnuGiocoCambia.Enabled = TRUE
'            mnuClassificaVisualizza.Enabled = TRUE
'            mnuClassificaResetta.Enabled = TRUE
'            mnuAiutoRegole.Enabled = TRUE
'            mnuAiutoInformazioni.Enabled = TRUE
    END SELECT
}
END;

procedure TFMain.subBloccoAnteprima;
var n:Integer; //numero random
begin
  RANDOMIZE;
  n := (Integer(Random(BYT_NUMBLOCCHI )+ 1));
  if not Assigned(cBloccoSuccessivo) then
    cBloccoSuccessivo := TBloccoTetris.Create;
  cBloccoSuccessivo.Tipo := oTypeBlock.Items[n].Tipo;
  cBloccoSuccessivo.Colore := oTypeBlock.Items[n].Colore;
  cBloccoSuccessivo.Q1 := oTypeBlock.Items[n].Q1;
  cBloccoSuccessivo.Q2 := oTypeBlock.Items[n].Q2;
  cBloccoSuccessivo.Q3 := oTypeBlock.Items[n].Q3;
  cBloccoSuccessivo.Q4 := oTypeBlock.Items[n].Q4;
  cBloccoSuccessivo.PR := oTypeBlock.Items[n].PR;
  drwAnteprima.Picture := nil;
  ClearImg(drwAnteprima);

  subDisegnaQuadratino(drwAnteprima, cBloccoSuccessivo.Q1, oRect.Items[cBloccoSuccessivo.Colore]);
  subDisegnaQuadratino(drwAnteprima, cBloccoSuccessivo.Q2, oRect.Items[cBloccoSuccessivo.Colore]);
  subDisegnaQuadratino(drwAnteprima, cBloccoSuccessivo.Q3, oRect.Items[cBloccoSuccessivo.Colore]);
  subDisegnaQuadratino(drwAnteprima, cBloccoSuccessivo.Q4, oRect.Items[cBloccoSuccessivo.Colore]);
end;

Procedure TFMain.mnuGiocoNuovo_Click;
Var
  i:Integer;
begin
//'reset
    //'numero di sfondo
        cbytSfondo := 1;
    //'numero di round
        cbytRound := 0;
    //'punteggio
        cintPunteggio := 0;
    //'numero linee fatte
        cshrLineeFatte := 0;
    //'picture di game over
//        picGameOver.Visible := FALSE;
    //'ferma il tempo
        Timer.Enabled := FALSE;
//    'ferma la base


//avvia il primo round
    subNuovoRound(Nil);

end;

end.
