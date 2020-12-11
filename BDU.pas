unit BDU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Db,
  IBODataset, IB_Components, IB_Access;

type
  TBDDM = class(TDataModule)
    EPFCIBODB: TIBODatabase;
    EPFC_DB_ANNEE_PREC: TIBODatabase;
    EPFC_DB_CHOICE: TIBODatabase;
    procedure DataModuleCreate(Sender: TObject);
  private
    { Déclarations privées }
    NomUtilisateur: string;
    MotDePasseUtilisateur: string;
    EstUneMoulinette: Boolean; // permet de bloquer les Message
    // d'avertissement de connexion aux base de données de Test pour tester le bon
    // fonctionnement des moulinettes.
    procedure CloseDB(Nom: TIBODatabase);
  public
    { Déclarations publiques }
    Bdd_Test: Boolean;
    function SelectAnneeScolaire(p_annee_scolaire: string = ''): Boolean; overload;
    procedure FixerUtilisateur(Nom, MotDePasse: string);
    function FermerConnexion: Boolean;
  end;

var
  BDDM: TBDDM;

implementation

uses
  StrUtils, GlobVarU;

{$R *.DFM}

function TBDDM.FermerConnexion: Boolean;
var
  Resultat: Boolean;
begin
  Resultat := True;
  try
    try
      CloseDB(EPFC_DB_ANNEE_PREC);
      CloseDB(EPFCIBODB);
    except
      showMessage('erreur lors de la fermeture des bases de données');
    end;
  finally
    if EPFCIBODB.Connected or EPFC_DB_ANNEE_PREC.Connected then
      Resultat := False;
    Result := Resultat;
  end;
end;

procedure TBDDM.CloseDB(Nom: TIBODatabase);
begin
  try
    Nom.Close;
  except
    // Cette exception risque de se produire souvent dans certains programmes
    // car ils n'utilisent pas tous les nombreuses bdd EFPFC_DB_ ...
    // aussi ils ne sont pas ouvert
    // On ne fait rien si cette exception se produit
    // (tentative de fermeture d'une bdd non connectée)
  end;
end;

procedure TBDDM.FixerUtilisateur(Nom, MotDePasse: string);
begin
  NomUtilisateur := Nom;
  MotDePasseUtilisateur := MotDePasse;
end;

function TBDDM.SelectAnneeScolaire(p_annee_scolaire: string = ''): Boolean;
// Ouvre les bases de données selon les variables globales GlobVars
var
  v_db_test: Boolean;
  v_databasename: string;
begin
  //Servira pour se connecter sur une seule db à la fois et en-dehors du fichier de config
  if p_annee_scolaire <> '' then
  begin
//      if not(TryStrToInt(p_annee_scolaire)) then
//        begin
//          ShowMessage('Le paramètre année n''est pas un entier'+#13#13
//          +'Contacter le SI pour signaler le problème'+#13#13+'Le programme va se fermer');
//          Application.Terminate;
//        end;

    v_db_test := GlobVars.TestMode;
    if v_db_test = True then
    begin
      v_databasename := 'astadbedev.admin.epfc.eu:c:\epfc' + p_annee_scolaire + 'Test.fdb';
    end
    else if v_db_test = False then
    begin
      v_databasename := 'isis:c:\epfc' + p_annee_scolaire + '.fdb';
    end;
    if epfc_db_choice.Connected then
    begin
      epfc_db_choice.Close();
    end;
    epfc_db_choice.DatabaseName := v_databasename;
    epfc_db_choice.Username := NomUtilisateur;
    epfc_db_choice.Password := MotDePasseUtilisateur;

    try
      epfc_db_choice.Open;
    except
      on E: Exception do
      begin
        showMessage('L''erreur suivante s''est produite: ' + E.Message + '. (Arrêt du programme)');
        Result := False;
        exit();
      end; // On
    end; // Except

    Result := True;
  end
    //Connexion aux DB en fonction du fichier de config json
  else if p_annee_scolaire = '' then
  begin
    EPFCIBODB.DatabaseName := GlobVars.DBFile;
    EPFCIBODB.Username := NomUtilisateur;
    EPFCIBODB.Password := MotDePasseUtilisateur;
    EPFC_DB_ANNEE_PREC.DatabaseName := GlobVars.PrecedDBFile;
    EPFC_DB_ANNEE_PREC.Username := NomUtilisateur;
    EPFC_DB_ANNEE_PREC.Password := MotDePasseUtilisateur;
        // petit test histoire d'être sûr de n'avoir aucune connection ouverte
    if EPFCIBODB.Connected or EPFC_DB_ANNEE_PREC.Connected then
    begin
      FermerConnexion;
    end;

    try
      EPFCIBODB.Open;
      EPFC_DB_ANNEE_PREC.Open;
    except
      on E: Exception do
      begin
        showMessage('L''erreur suivante s''est produite: ' + E.Message + '. (Arrêt du programme)');
        Result := False;
        exit();
      end; // On
    end; // Except
        {if (GlobVars.TestMode and (not GlobVars.Muet)) then
          showMessage('Attention base de données de test:' + #13 + GlobVars.DBFile +
            #13 + 'Ne rien encoder.' + #13 + 'Prévenir le service informatique.');
		}
    Result := True;
  end;
end;

procedure TBDDM.DataModuleCreate(Sender: TObject);
begin
  NomUtilisateur := 'SYSDBA';
  MotDePasseUtilisateur := 'epfccfpe';
  Bdd_Test := False;
  EstUneMoulinette := False;
end;

end.

