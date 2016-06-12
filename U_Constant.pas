unit U_Constant;

interface
type
  aGrid = Array[0..10, 0..22] of integer;

CONST

  BYT_VUOTO = 0;
  BYT_ANTEPRIMA_X = 0; //posizione X dell'anteprima
  BYT_ANTEPRIMA_Y = 40; //posizione Y dell'anteprima

  BYT_GRIGLIA_X = 72; //posizione X della griglia
  BYT_GRIGLIA_Y = 54; //posizione Y della griglia
  BYT_RIGHE     = 22; //numero di righe
  BYT_COLONNE   = 10; //numero di colonne
  BYT_LATO_QUADRATINO = 18; //dimensione lato del quadratino della griglia

  BYT_NUMBLOCCHI = 7; //numero di blocchi

  BYT_BLOCCO_J = 1; //tipo di blocco, J
  BYT_BLOCCO_L = 2; //tpo di blocco, L
  BYT_BLOCCO_Z = 3; //tipo di blocco, Z
  BYT_BLOCCO_S = 4; //tipo di blocco, S
  BYT_BLOCCO_T = 5; //tipo di blocco, T
  BYT_BLOCCO_I = 6; //tipo di blocco, I
  BYT_BLOCCO_O = 7; //tipo di blocco, O

  BYT_COLORE_ROSSO = 1; // 'colori dei quadratini
  BYT_COLORE_VIOLA = 2;
  BYT_COLORE_GIALLO = 3;
  BYT_COLORE_ARANCIO = 4;
  BYT_COLORE_AZZURRO = 5;
  BYT_COLORE_BLU = 6;
  BYT_COLORE_VERDE = 7;
  BYT_COLORE_GRIGIO = 8;

  BYT_DX = 1;
  BYT_SX = -1;
  BYT_GIU = 2;
  BYT_RDX = 3;
  BYT_RSX = 4;

implementation

end.
