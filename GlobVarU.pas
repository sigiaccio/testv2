unit GlobVarU;

interface

uses
  SysUtils, IOUtils, JSON, Dialogs, Forms, Winapi.Windows, regularExpressions,
  System.StrUtils;


// const

type
  TGlobVars = class
  private
    // procedure Load();
    { Déclarations privées }
  public
    AnneeScolaireCourante, AnneeScolairePrecedente: string;
    TestMode, Muet, mode_administrateur, SSL: Boolean;
    DBFile, DelphiReportPath, HTMLReportPath: String;
    PrecedDBFile: String;
    PrecedDelphiReportPath: String;
    PrecedHTMLReportPath: String;
    AR_database, AR_hostname, AR_ReportPath, AR_HTMLPath: String;
    Prefixe_DB, Mail_DRH, Smtp, Mdp_Mail_DRH, Mail_DRH_test, Mdp_Mail_DRH_test: String;
    Taux_SU_CG_CalculJustificationPPB, Taux_SU_CS_CalculJustificationPPB, Taux_SU_CT_CalculJustificationPPB, Taux_SS_CG_CalculJustificationPPB, Taux_SS_CS_CalculJustificationPPB, Taux_SS_CT_CalculJustificationPPB, Taux_SI_CG_CalculJustificationPPB,
      Taux_SI_CS_CalculJustificationPPB, Taux_SI_CT_CalculJustificationPPB: String;
    PathFichierExcellViergeFse, PathProDataVierge, PathVerifDonFse: String;
    Path_Save_Prodata: String;
    Mdp_smtp, User_smtp: String;
    Port_smtp: String;
    // VB 18/05/16 : les types des variables ont été choisies sur base de ce que les anciennes constantes de l'unit
    // constCalcPayementU retournait dans la unit CalcPayements0405U. Ceci afin d'être sûr que le calcul du prix
    // serait toujours correct.
    v_montant_frais_administratif: Currency;
    v_di_secondaire, v_di_superieur, v_di_forfaitaire, v_dis_maximum: Extended;
    v_di_nbr_periode_max, v_di_nbr_periode_max_secondaire, v_di_nbr_periode_max_superieur: SmallInt;
    v_directeur_inscription: string;
    v_url_extranet, eid_directory: string;
    carte_etudiant_frs: String;
    carte_etudiant_sujet: String;
    carte_etudiant_from: String;
    carte_etudiant_replyTo: String;
    v_ects, v_nb_heures_semaines_secondaire, v_nb_heures_semaines_superieure: Double;
    v_anneeSD : Integer;
    v_anneeJJ : Integer;
    constructor Create();
  end;

var
  GlobVars: TGlobVars;

implementation

constructor TGlobVars.Create();
(*
  begin
  TGlobVars.Load();
  end;

  procedure TGlobVars.Load();

*) var
  I: integer;
  ConfigFileName, ConfigText: string;
  JSonConfig, JSonSingleConfig: TJSONObject;
  JSonPair: TJSONPair;
  GotIt: Boolean;
  v_log_error: string;
  v_error: Boolean;
  regexprTestMode: TRegEx;
  matchTestMode: TMatch;

begin
  { init config file name }
  ConfigFileName := extractfilepath(Application.ExeName) + 'AppConfig.json';

  //Variables gestion des erreurs
  v_error := False;
  v_log_error := 'Problème rencontrée dans le fichier de configuration Json situé ' + ConfigFileName + #13#10;

  { check si config file forcé avec un parametre dans le raccourci du programme}
  I := 1;
  while I <= ParamCount do
  begin
    if LowerCase(ParamStr(I)) = '-configfile' then
      ConfigFileName := ParamStr(I + 1);
    inc(I);
  end;

  if FileExists(ConfigFileName) = False then
  begin
    ShowMessage('Erreur ligne de commande: Fichier de configuration "' + ConfigFileName + '" inexistant (execution terminée).');
    Halt;
  end;

  { Chargement fichier de config }
  try
    ConfigText := TFile.ReadAllText(ConfigFileName);
  except
    ShowMessage('Erreur ligne de commande: Problème au chargement du fichier de configuration');
    Halt;
  end;

  try
    JSonConfig := TJSONObject.ParseJSONValue(ConfigText, True,True) as TJSONObject;
  except
    on E: Exception do
    begin
      ShowMessage('Problème dans le fichier Json au niveau de sa structure');
    end
  end;

  if JSonConfig = nil then
  begin
    ShowMessage('Erreur: contenu du fichier de configuration"' + ConfigFileName + '" incorrect. (execution terminée)');
    Halt;
  end;

  // Annee Courante
  JSonPair := JSonConfig.Get('IdAnneeCourante');
  if JSonPair = nil then
  begin
    ShowMessage('Erreur: Le fichier de configuration"' + ConfigFileName + '" est incorrect - tag "IdAnneeCourante" manquant. (execution terminée)');
    Halt;
  end;
  AnneeScolaireCourante := JSonPair.JsonValue.Value;
  v_anneeSD := StrToInt(LeftStr(AnneeScolaireCourante,4));
  v_anneeJJ := v_anneeSD+1;

  // Mode Muet (moulinette)
  Muet := False;
  JSonPair := JSonConfig.Get('Muet');
  if JSonPair <> nil then
  begin
    Muet := (LowerCase(JSonPair.JsonValue.Value) = 'true');
  end;

  // Mode SSL
  SSL := False;
  JSonPair := JSonConfig.Get('SSL');
  if JSonPair <> nil then
  begin
    SSL := (LowerCase(JSonPair.JsonValue.Value) = 'true');
  end;

  // Gestion Prix

  JSonPair := JSonConfig.Get('montant_frais_administratif');
  if JSonPair <> nil then
  begin
    v_montant_frais_administratif := StrToFloat(JSonPair.JsonValue.Value);
  end
  else if JSonPair = nil then
  begin
    v_error := True;
    v_log_error := v_log_error + #13#10 + '- Donnée montant frais administratif manquante';
  end;

  JSonPair := JSonConfig.Get('DI_secondaire');
  if JSonPair <> nil then
  begin
    v_di_secondaire := StrToFloat(JSonPair.JsonValue.Value);
  end
  else if JSonPair = nil then
  begin
    v_error := True;
    v_log_error := v_log_error + #13#10 + '- Donnée DI Secondaire manquante';
  end;

  JSonPair := JSonConfig.Get('DI_superieur');
  if JSonPair <> nil then
  begin
    v_di_superieur := StrToFloat(JSonPair.JsonValue.Value);
  end
  else if JSonPair = nil then
  begin
    v_error := True;
    v_log_error := v_log_error + #13#10 + '- Donnée DI Supérieur manquante';
  end;

  JSonPair := JSonConfig.Get('DI_forfaitaire');
  if JSonPair <> nil then
  begin
    v_di_forfaitaire := StrToFloat(JSonPair.JsonValue.Value);
  end
  else if JSonPair = nil then
  begin
    v_error := True;
    v_log_error := v_log_error + #13#10 + '- Donnée DI forfaitaire manquante';
  end;

  JSonPair := JSonConfig.Get('DI_nombre_periode_max');
  if JSonPair <> nil then
  begin
    v_di_nbr_periode_max := StrToInt(JSonPair.JsonValue.Value);
  end
  else if JSonPair = nil then
  begin
    v_error := True;
    v_log_error := v_log_error + #13#10 + '- Donnée DI nombre période maximal manquante';
  end;

  JSonPair := JSonConfig.Get('DI_nombre_periode_max_secondaire');
  if JSonPair <> nil then
  begin
    v_di_nbr_periode_max_secondaire := StrToInt(JSonPair.JsonValue.Value);
  end
  else if JSonPair = nil then
  begin
    v_error := True;
    v_log_error := v_log_error + #13#10 + '- Donnée DI nombre période maximal secondaire manquante';
  end;

  JSonPair := JSonConfig.Get('DI_nombre_periode_max_superieur');
  if JSonPair <> nil then
  begin
    v_di_nbr_periode_max_superieur := StrToInt(JSonPair.JsonValue.Value);
  end
  else if JSonPair = nil then
  begin
    v_error := True;
    v_log_error := v_log_error + #13#10 + '- Donnée DI nombre période maximal supérieur manquante';
  end;

  JSonPair := JSonConfig.Get('DIS_maximum');
  if JSonPair <> nil then
  begin
    v_dis_maximum := StrToFloat(JSonPair.JsonValue.Value);
  end
  else if JSonPair = nil then
  begin
    v_error := True;
    v_log_error := v_log_error + #13#10 + '- Donnée DIS maximum manquante';
  end;

  // Fin gestion prix

  // Données pour les documents HTML
  JSonPair := JSonConfig.Get('directeur_inscriptions');
  if JSonPair <> nil then
  begin
    v_directeur_inscription := JSonPair.JsonValue.Value;
  end
  else if JSonPair = nil then
  begin
    v_error := True;
    v_log_error := v_log_error + #13#10 + '- Donnée Directeur inscriptions manquante';
  end;

  // url extranet
  JSonPair := JSonConfig.Get('url_extranet');
  if JSonPair <> nil then
  begin
    v_url_extranet := JSonPair.JsonValue.Value;
  end
  else if JSonPair = nil then
  begin
    v_error := True;
    v_log_error := v_log_error + #13#10 + '- Donnée url extranet manquante';
  end;

  //

  // Taux pour le calcul du montant justifiable (part publique belge) par DOC_2 organique (NO_IMPLANT = 1)
  // JSonPair := JSonConfig.Get('TauxCalculJustifPPB_SU');

  // Taux pour le calcul du montant justifiable (part publique belge) par DOC_2 organique (NO_IMPLANT = 1)
  JSonPair := JSonConfig.Get('TauxCalculJustifPPB_CG_SU');
  if JSonPair <> nil then
  begin
    Taux_SU_CG_CalculJustificationPPB := JSonPair.JsonValue.Value;
  end;

  // Taux pour le calcul du montant justifiable (part publique belge) par DOC_2 organique (NO_IMPLANT = 1)
  JSonPair := JSonConfig.Get('TauxCalculJustifPPB_CS_SU');
  if JSonPair <> nil then
  begin
    Taux_SU_CS_CalculJustificationPPB := JSonPair.JsonValue.Value;
  end;

  // Taux pour le calcul du montant justifiable (part publique belge) par DOC_2 organique (NO_IMPLANT = 1)
  JSonPair := JSonConfig.Get('TauxCalculJustifPPB_CT_SU');
  if JSonPair <> nil then
  begin
    Taux_SU_CT_CalculJustificationPPB := JSonPair.JsonValue.Value;
  end;

  // Taux pour le calcul du montant justifiable (part publique belge) par DOC_2 organique (NO_IMPLANT = 1)
  JSonPair := JSonConfig.Get('TauxCalculJustifPPB_CG_SS');
  if JSonPair <> nil then
  begin
    Taux_SS_CG_CalculJustificationPPB := JSonPair.JsonValue.Value;
  end;

  // Taux pour le calcul du montant justifiable (part publique belge) par DOC_2 organique (NO_IMPLANT = 1)
  JSonPair := JSonConfig.Get('TauxCalculJustifPPB_CS_SS');
  if JSonPair <> nil then
  begin
    Taux_SS_CS_CalculJustificationPPB := JSonPair.JsonValue.Value;
  end;

  // Taux pour le calcul du montant justifiable (part publique belge) par DOC_2 organique (NO_IMPLANT = 1)
  JSonPair := JSonConfig.Get('TauxCalculJustifPPB_CT_SS');
  if JSonPair <> nil then
  begin
    Taux_SS_CT_CalculJustificationPPB := JSonPair.JsonValue.Value;
  end;

  // Taux pour le calcul du montant justifiable (part publique belge) par DOC_2 organique (NO_IMPLANT = 1)
  JSonPair := JSonConfig.Get('TauxCalculJustifPPB_CG_SI');

  if JSonPair <> nil then
  begin
    Taux_SI_CG_CalculJustificationPPB := JSonPair.JsonValue.Value;
  end;

  // Taux pour le calcul du montant justifiable (part publique belge) par DOC_2 organique (NO_IMPLANT = 1)
  JSonPair := JSonConfig.Get('TauxCalculJustifPPB_CS_SI');
  if JSonPair <> nil then
  begin
    Taux_SI_CS_CalculJustificationPPB := JSonPair.JsonValue.Value;
  end;

  // Taux pour le calcul du montant justifiable (part publique belge) par DOC_2 organique (NO_IMPLANT = 1)
  JSonPair := JSonConfig.Get('TauxCalculJustifPPB_CT_SI');
  if JSonPair <> nil then
  begin
    Taux_SI_CT_CalculJustificationPPB := JSonPair.JsonValue.Value;
  end;

  JSonPair := JSonConfig.Get('Path_Fichier_Excell_vierge_FSE');
  if JSonPair <> nil then
  begin
    PathFichierExcellViergeFse := JSonPair.JsonValue.Value;
  end;

  JSonPair := JSonConfig.Get('Path_Prodata_vierge_FSE');
  if JSonPair <> nil then
  begin
    PathProDataVierge := JSonPair.JsonValue.Value;
  end;

  JSonPair := JSonConfig.Get('Path_VerifDon_FSE');
  if JSonPair <> nil then
  begin
    PathVerifDonFse := JSonPair.JsonValue.Value;
  end;

  // Chargement Config Annee Courante
  JSonPair := JSonConfig.Get('Configs');
  if JSonPair = nil then
  begin
    ShowMessage('Erreur: Le fichier de configuration"' + ConfigFileName + '" est incorrect - tag "Configs" manquant. (execution terminée)');
    Halt;
  end;

  GotIt := False;

  for I := 0 to TJSonArray(JSonPair.JsonValue).count - 1 do
  begin
    JSonSingleConfig := TJSonArray(JSonPair.JsonValue).items[I] as TJSONObject;
    try
      if (JSonSingleConfig.Get('Id').JsonValue.Value = AnneeScolaireCourante) then
      begin
        AnneeScolairePrecedente := JSonSingleConfig.Get('IdAnneePrecedente').JsonValue.Value;
        DBFile := JSonSingleConfig.Get('DBFile').JsonValue.Value;
        DelphiReportPath := JSonSingleConfig.Get('ReportPath').JsonValue.Value;
        HTMLReportPath := JSonSingleConfig.Get('HTMLPath').JsonValue.Value;
        GotIt := True;
        break;
      end; // if
    except // on E: Exception do
      ShowMessage('Erreur: Le fichier de configuration"' + ConfigFileName + '" est incorrect - problème dans "Configs". (execution terminée)');
      Halt;
    end; // try
  end; // for

  if not GotIt then // Config trouvée ?
  begin
    ShowMessage('Erreur: Le fichier de configuration"' + ConfigFileName + '" est incorrect - configuration "' + AnneeScolaireCourante + '" manquante. (execution terminée)');
    Halt;
  end; // if

  // Chargement Config Annee Précédente
  GotIt := False;
  for I := 0 to TJSonArray(JSonPair.JsonValue).count - 1 do
  begin
    JSonSingleConfig := TJSonArray(JSonPair.JsonValue).items[I] as TJSONObject;
    try
      if (JSonSingleConfig.Get('Id').JsonValue.Value = AnneeScolairePrecedente) then
      begin
        PrecedDBFile := JSonSingleConfig.Get('DBFile').JsonValue.Value;
        PrecedDelphiReportPath := JSonSingleConfig.Get('ReportPath').JsonValue.Value;
        PrecedHTMLReportPath := JSonSingleConfig.Get('HTMLPath').JsonValue.Value;
        GotIt := True;
        break;
      end; // if
    except // on E: Exception do
      ShowMessage('Erreur: Le fichier de configuration"' + ConfigFileName + '" est incorrect - problème dans "Configs" pour l''année précédente. (execution terminée)');
      Halt;
    end; // try
  end; // for

  if not GotIt then // Config trouvée ?
  begin
    ShowMessage('Erreur: Le fichier de configuration"' + ConfigFileName + '" est incorrect - configuration annee précédente"' + AnneeScolairePrecedente + '" manquante. (execution terminée)');
    Halt;
  end; // if

  // Archive database
  AR_database := '';
  JSonPair := JSonConfig.Get('AR_database');
  if JSonPair <> nil then
  begin
    AR_database := JSonPair.JsonValue.Value;
  end;

  // Archive hostname
  AR_hostname := '';
  JSonPair := JSonConfig.Get('AR_hostname');
  if JSonPair <> nil then
  begin
    AR_hostname := JSonPair.JsonValue.Value;
  end;

  // Archive reportpath
  AR_ReportPath := '';
  JSonPair := JSonConfig.Get('AR_ReportPath');
  if JSonPair <> nil then
  begin
    AR_ReportPath := JSonPair.JsonValue.Value;
  end;

  // Archive HTMLPath
  AR_HTMLPath := '';
  JSonPair := JSonConfig.Get('AR_HTMLPath');
  if JSonPair <> nil then
  begin
    AR_HTMLPath := JSonPair.JsonValue.Value;
  end;

  // Prefixe_DB

  Prefixe_DB := '';
  JSonPair := JSonConfig.Get('Prefixe_DB');
  if JSonPair <> nil then
  begin
    Prefixe_DB := JSonPair.JsonValue.Value;
  end;

  Mail_DRH := '';
  JSonPair := JSonConfig.Get('Mail_DRH');
  if JSonPair <> nil then
  begin
    Mail_DRH := JSonPair.JsonValue.Value;
  end;

  Smtp := '';
  JSonPair := JSonConfig.Get('smtp');
  if JSonPair <> nil then
  begin
    Smtp := JSonPair.JsonValue.Value;
  end;

  Mdp_Mail_DRH := '';
  JSonPair := JSonConfig.Get('Mdp_Mail_DRH');
  if JSonPair <> nil then
  begin
    Mdp_Mail_DRH := JSonPair.JsonValue.Value;
  end;

  Mail_DRH_test := '';
  JSonPair := JSonConfig.Get('Mail_DRH_test');
  if JSonPair <> nil then
  begin
    Mail_DRH_test := JSonPair.JsonValue.Value;
  end;

  Mdp_Mail_DRH_test := '';
  JSonPair := JSonConfig.Get('Mdp_Mail_DRH_test');
  if JSonPair <> nil then
  begin
    Mdp_Mail_DRH_test := JSonPair.JsonValue.Value;
  end;

  Mdp_smtp := '';
  JSonPair := JSonConfig.Get('Mdp_smtp');
  if JSonPair <> nil then
  begin
    Mdp_smtp := JSonPair.JsonValue.Value;
  end;

  User_smtp := '';
  JSonPair := JSonConfig.Get('User_smtp');
  if JSonPair <> nil then
  begin
    User_smtp := JSonPair.JsonValue.Value;
  end;

  Port_smtp := '';
  JSonPair := JSonConfig.Get('port_smtp');
  if JSonPair <> nil then
  begin
    Port_smtp := JSonPair.JsonValue.Value;
  end;

  // AF : allocations familiales
  // url extranet
  JSonPair := JSonConfig.Get('url_extranet');
  if JSonPair <> nil then
  begin
    v_url_extranet := JSonPair.JsonValue.Value;
  end
  else if JSonPair = nil then
  begin
    v_error := True;
    v_log_error := v_log_error + #13#10 + '- Donnée url extranet manquante';
  end;

  JSonPair := JSonConfig.Get('v_ects');
  if JSonPair <> nil then
  begin
    v_ects := StrToFloat(JSonPair.JsonValue.Value);
  end
  else if JSonPair = nil then
  begin
    v_error := True;
    v_log_error := v_log_error + #13#10 + '- Donnée ''ECTS'' manquante';
  end;

  JSonPair := JSonConfig.Get('v_nb_heures_semaines_secondaire');
  if JSonPair <> nil then
  begin
    v_nb_heures_semaines_secondaire := StrToFloat(JSonPair.JsonValue.Value);
  end
  else if JSonPair = nil then
  begin
    v_error := True;
    v_log_error := v_log_error + #13#10 + '- Donnée ''nb_heures_semaines_secondaire'' manquante';
  end;

  JSonPair := JSonConfig.Get('v_nb_heures_semaines_superieure');
  if JSonPair <> nil then
  begin
    v_nb_heures_semaines_superieure := StrToFloat(JSonPair.JsonValue.Value);
  end
  else if JSonPair = nil then
  begin
    v_error := True;
    v_log_error := v_log_error + #13#10 + '- Donnée ''nb_heures_semaines_superieure'' manquante';
  end;
  // FIN AF : allocations familiales

  // Mode administrateur
  mode_administrateur := False;
  JSonPair := JSonConfig.Get('Mode_administrateur');
  if JSonPair <> nil then
  begin
    mode_administrateur := (LowerCase(JSonPair.JsonValue.Value) = 'true');
  end;

  Path_Save_Prodata := '';
  JSonPair := JSonConfig.Get('Path_Save_Prodata');
  if JSonPair <> nil then
  begin
    Path_Save_Prodata := JSonPair.JsonValue.Value;
  end;

  // EID directory : définir le répertoire où sont stockés les photos des cartes d'identité
  JSonPair := JSonConfig.Get('eid_directory');
  if JSonPair <> nil then
  begin
    eid_directory := JSonPair.JsonValue.Value;
  end
  else if JSonPair = nil then
  begin
    v_error := True;
    v_log_error := v_log_error + #13#10 + '- Donnée ''eid_directory'' manquante';
  end;

    // carte_etudiant_frs : définit l'email du fournisseur
  JSonPair := JSonConfig.Get('carte_etudiant_frs');
  if JSonPair <> nil then
  begin
    carte_etudiant_frs := JSonPair.JsonValue.Value;
  end
  else if JSonPair = nil then
  begin
    v_error := True;
    v_log_error := v_log_error + #13#10 + '- Donnée ''carte_etudiant_frs'' manquante';
  end;

  // carte_etudiant_sujet : définit le sujet de l'email
  JSonPair := JSonConfig.Get('carte_etudiant_sujet');
  if JSonPair <> nil then
  begin
    carte_etudiant_sujet := JSonPair.JsonValue.Value;
  end
  else if JSonPair = nil then
  begin
    v_error := True;
    v_log_error := v_log_error + #13#10 + '- Donnée ''carte_etudiant_sujet'' manquante';
  end;

  // carte_etudiant_from : définit le from de l'email
  JSonPair := JSonConfig.Get('carte_etudiant_from');
  if JSonPair <> nil then
  begin
    carte_etudiant_from := JSonPair.JsonValue.Value;
  end
  else if JSonPair = nil then
  begin
    v_error := True;
    v_log_error := v_log_error + #13#10 + '- Donnée ''carte_etudiant_from'' manquante';
  end;

  // carte_etudiant_replyTo : définit le replyTo de l'email pour répondre
  JSonPair := JSonConfig.Get('carte_etudiant_replyTo');
  if JSonPair <> nil then
  begin
    carte_etudiant_replyTo := JSonPair.JsonValue.Value;
  end
  else if JSonPair = nil then
  begin
    v_error := True;
    v_log_error := v_log_error + #13#10 + '- Donnée ''carte_etudiant_replyTo'' manquante';
  end;


  // Mode Test - will read the database path and search for the string Test
  // OutputDebugString('GlobVarU.TestMode - set by the db path, not anymore by the config.Test ');
  regexprTestMode := TRegEx.Create('epfc[0-9]{4}Test-?[a-zA-Z]*.fdb', [roIgnoreCase]);
  // Filter on db name
  // epfc0000Test.fdb
  // epfc0000Test-aaaa.fdb
  // epfc0000Test-aa.fdb

  matchTestMode := regexprTestMode.match(DBFile);
  if not matchTestMode.Success then
  begin
    // prod mode
    TestMode := False;
  end
  else
  begin
    // debug mode;
    TestMode := True;
  end;

  // Affichage de l'ensemble des erreurs
  if v_error = True then
  begin
    v_log_error := v_log_error + #13#10#13#10 + 'Merci de contacter le SI.'#13#10#13#10 + 'Le programme va se fermer';
    ShowMessage(v_log_error);
    Halt;
  end;

  JSonConfig.Free;

end;

end.
