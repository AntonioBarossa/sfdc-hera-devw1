public with sharing class HDT_UTL_ServiceCatalogOrFilterProcess {
    public static Map<String,Map<String,List<String>>> mapCaseFilter = new Map<String,Map<String,List<String>>>
    { 
    'Fiscale' => new Map<String,List<String>>
        {
            'Cluster__c' => new List<String>
                {'Reclami','Fatturazione'}
        },
    'AnnullamentoContratti' => new Map<String,List<String>>
        {
            'Cluster__c' => new List<String>
                {'Reclami','Preventivi', 'Variazioni', 'Generiche Attivazioni'},
            'Type' => new List<String>
                {'Gestione Calamità', 'Informative','Comunicazione di Fallimento','Comportamento Venditori HC'}
        },
    'ContrattoNonRichiesto' => new Map<String,List<String>>
        {
            'Cluster__c' => new List<String>
                {'Reclami','Preventivi','Generiche Attivazioni'},
            'Type' => new List<String>
                {'Comportamento Venditori HC'}
        },
    'Autoletturadacliente' => new Map<String,List<String>>
        {
            'Type' => new List<String>
                {'Verifica Dati al DL','Rettifica Consumi','Reclamo Scritto/Rich. Info', 'Consumo Anomalo Idrico'}
        },
    'AllineamentoCanoneRai' => new Map<String,List<String>>
        {
            'Cluster__c' => new List<String>
                {'Reclami','Preventivi'},
            'Type' => new List<String>
                {'Gestione Calamità', 'Reclamo Scritto/Rich. Info'}
        },
    'SospensioneCanoneRaiCalamita' => new Map<String,List<String>>
        {
            'Cluster__c' => new List<String>
                {'Reclami','Preventivi'},
            'Type' => new List<String>
                {'Gestione Calamità','Reclamo Scritto/Rich. Info'}
        },
    'CambioUsoFittizio' => new Map<String,List<String>>
        {
            'Cluster__c' => new List<String>
                {'Reclami','Fatturazione','Variazioni','Generiche Attivazioni','Canone Rai'}
        },
    'ContrattiBonusCommerciale' => new Map<String,List<String>>
        {
            'Cluster__c' => new List<String>
                {'Reclami', 'Fatturazione', 'Variazioni', 'Annullamento', 'Disattivazioni'}, 
            'Type' => new List<String>
                {'Comportamento Venditori HC'}
        },
    'ContrattiModificaContrattoPreAttivazione' => new Map<String,List<String>>
        {
            'Cluster__c' => new List<String>
                {'Generiche Attivazioni', 'Preventivi'}
        },
    'DocumentaleCopiaContrattoFirmatoNonRicevuto' => new Map<String,List<String>>
        {
            'Cluster__c' => new List<String>
                {'Reclami', 'Disattivazioni', 'Annullamento'}
        },
    'ChiusuraContatore' => new Map<String,List<String>>
        {
            'Cluster__c' => new List<String>
                {'Reclami', 'Preventivi', 'Variazioni'}, 
            'Type' => new List<String>
                {'Comportamento Venditori HC', 'Gestione Calamità', 'Informative', 'Annullamento Contratti', 'Comunicazione di Fallimento'}
        },
    'RecessoperAltriMotivi' => new Map<String,List<String>>
        {
            'Cluster__c' => new List<String>
                {'Reclami', 'Preventivi', 'Morosità'}
        },
    'RecessoperRifiutoVoltura' => new Map<String,List<String>>
        {
            'Cluster__c' => new List<String>
                {'Reclami'}
        },
    'RecessosuRichestaCliente' => new Map<String,List<String>>
        {
            'Cluster__c' => new List<String>
                {'Reclami'}, 
            'Type' => new List<String>
                {'Comportamento Venditori HC'}
        },
    'VotiveModenaCessazione' => new Map<String,List<String>>
        {
            'Cluster__c' => new List<String>
                {'Reclami'}
        },
    'GestioneBonusSociale' => new Map<String,List<String>>
        {
            'Cluster__c' => new List<String>
                {'Reclami'}, 
            'Type' => new List<String>
                {'Gestione Calamità'}
        },
    'InversionedelContatore' => new Map<String,List<String>>
        {
            'Cluster__c' => new List<String>
                {'Reclami', 'Preventivi'}
        },
    'RicostruzioneConsumi' => new Map<String,List<String>>
        {
            'Cluster__c' => new List<String>
                {'Reclami', 'Preventivi'}, 
            'Type' => new List<String>
                {'Gestione Calamità', 'Verifica GDM'}
        },
    'RitornoaFatturazioneBimestraleMensile' => new Map<String,List<String>>
        {
            'Cluster__c' => new List<String>
                {'Reclami'}
        },
    'SollecitoEmissioneBolletta' => new Map<String,List<String>>
        {
            'Cluster__c' => new List<String>
                {'Reclami', 'Preventivi'}, 
            'Type' => new List<String>
                {'Gestione Calamità'}
        },
    'TestoContrattoinBolletta' => new Map<String,List<String>>
        {
            'Type' => new List<String>
                {'Reclamo Scritto/Rich. Info'}
        },
    'UnificazioneSeparazioneBPCABolletta' => new Map<String,List<String>>
        {
            'Cluster__c' => new List<String>
                {'Reclami', 'Preventivi'}, 
            'Type' => new List<String>
                {'Gestione Calamità'}
        },
    'VerificaTitolaritaPODPDR' => new Map<String,List<String>>
        {
            'Cluster__c' => new List<String>
                {'Reclami', 'Preventivi'}, 
            'Type' => new List<String>
                {'Gestione Calamità'}
        },
    'ErrorediFatturazione' => new Map<String,List<String>>
        {
            'Cluster__c' => new List<String>
                {'Reclami', 'Preventivi'}, 
            'Type' => new List<String>
                {'Gestione Calamità'}
        },
    'PrescrizioneFatture' => new Map<String,List<String>>
        {
            'Cluster__c' => new List<String>
                {'Reclami'}
        },
    'RettificaConsumi' => new Map<String,List<String>>
        {
            'Cluster__c' => new List<String>
                {'Reclami', 'Segnalazioni'},
            'Type' => new List<String>
                {'Consumo Anomalo Idrico'}
        },
    'CadutaLineaChiamataMuta' => new Map<String,List<String>>
        {
            'Cluster__c' => new List<String>
                {'Reclami', 'Preventivi'}, 
            'Type' => new List<String>
                {'Gestione Calamità'}
        },
    'ComunicazionediFallimento' => new Map<String,List<String>>
        {
            'Cluster__c' => new List<String>
                {'Reclami', 'Preventivi'}, 
            'Type' => new List<String>
                {'Gestione Calamità'}
        },
    'ErroreChiamata' => new Map<String,List<String>>
        {
            'Cluster__c' => new List<String>
                {'Reclami', 'Preventivi'}, 
            'Type' => new List<String>
                {'Gestione Calamità'}
        },
    'PagamentoClickPay' => new Map<String,List<String>>
        {
            'Cluster__c' => new List<String>
                {'Reclami', 'Preventivi'}, 
            'Type' => new List<String>
                {'Gestione Calamità'}
        },
    'PagamentoOnline' => new Map<String,List<String>>
        {
            'Cluster__c' => new List<String>
                {'Reclami', 'Preventivi'}, 
            'Type' => new List<String>
                {'Gestione Calamità'}
        },
    'ModificaAlert' => new Map<String,List<String>>
        {
            'Cluster__c' => new List<String>
                {'Reclami', 'Preventivi'}, 
            'Type' => new List<String>
                {'Gestione Calamità', 'Errore di Fatturazione'}
        },
    'DisassociazioneUtenteWeb' => new Map<String,List<String>>
        {
            'Cluster__c' => new List<String>
                {'Reclami', 'Preventivi'}, 
            'Type' => new List<String>
                {'Gestione Calamità', 'Errore di Fatturazione'}
        },
    'EsercizioDirittiPrivacy' => new Map<String,List<String>>
        {
            'Cluster__c' => new List<String>
                {'Reclami', 'Preventivi'}, 
            'Type' => new List<String>
                {'Gestione Calamità', 'Errore di Fatturazione'}
        },
    'ModificaPrivacy' => new Map<String,List<String>>
        {
            'Cluster__c' => new List<String>
                {'Reclami', 'Preventivi'}, 
            'Type' => new List<String>
                {'Gestione Calamità'}
        },
    'Richiestaparere' => new Map<String,List<String>>
        {
            'Cluster__c' => new List<String>
                {'Reclami', 'Preventivi'}, 
            'Type' => new List<String>
                {'Gestione Calamità', 'Errore di Fatturazione'}
        },
    'VariazioneAnagraficaCliente' => new Map<String,List<String>>
        {
            'Cluster__c' => new List<String>
                {'Reclami', 'Preventivi'}, 
            'Type' => new List<String>
                {'Gestione Calamità', 'Errore di Fatturazione','Unificazione/Separazione BP-CA-Bolletta'}
        },
    'VariazionesuAmministratore' => new Map<String,List<String>>
        {
            'Cluster__c' => new List<String>
                {'Reclami', 'Preventivi'}, 
            'Type' => new List<String>
                {'Gestione Calamità', 'Errore di Fatturazione','Unificazione/Separazione BP-CA-Bolletta'}
        },
    'GestioneDisalimentabilita' => new Map<String,List<String>>
        {
            'Cluster__c' => new List<String>
                {'Reclami', 'Preventivi', 'Morosità'}, 
            'Type' => new List<String>
                {'Gestione Calamità'}
        },
    'BloccoSollecitoInteressi' => new Map<String,List<String>>
        {
            'Cluster__c' => new List<String>
                {'Reclami'}
        },
    'ComunicazionePagamento' => new Map<String,List<String>>
        {
            'Type' => new List<String>
                {'Reclamo Scritto/Rich. Info'}
        },
    'DoppiPagamenti/Incassi' => new Map<String,List<String>>
        {
            'Cluster__c' => new List<String>
                {'Reclami'}
        },
    'AttivazioneClickPay' => new Map<String,List<String>>
        {
            'Cluster__c' => new List<String>
                {'Reclami', 'Preventivi'}, 
            'Type' => new List<String>
                {'Gestione Calamità'}
        },
    'Paperless' => new Map<String,List<String>>
        {
            'Type' => new List<String>
                {'Reclamo Scritto/Rich. Info'}
        },
    'RevocaDomiciliazione' => new Map<String,List<String>>
        {
            'Cluster__c' => new List<String>
                {'Reclami'}
        },
    'RichiestaDomiciliazione' => new Map<String,List<String>>
        {
            'Cluster__c' => new List<String>
                {'Reclami', 'Preventivi'}, 
            'Type' => new List<String>
                {'Unificazione/Separazione BP-CA-Bolletta'}
        },
    'VariazioneDomiciliazione' => new Map<String,List<String>>
        {
            'Cluster__c' => new List<String>
                {'Reclami'}
        },
    'SegnalazioniVAS' => new Map<String,List<String>>
        {
            'Cluster__c' => new List<String>
                {'Reclami'}
        },
    'AggiuntaAttacco' => new Map<String,List<String>>
        {
            'Cluster__c' => new List<String>
                {'Reclami', 'Preventivi'}
        },
    'ModificaImpianto' => new Map<String,List<String>>
        {
            'Cluster__c' => new List<String>
                {'Reclami', 'Preventivi'}
        },
    'EmissioneImpulsi' => new Map<String,List<String>>
        {
            'Cluster__c' => new List<String>
                {'Reclami', 'Preventivi'}
        },
    'VariazionePortata' => new Map<String,List<String>>
        {
            'Cluster__c' => new List<String>
                {'Reclami', 'Preventivi'}
        },
    'NuovoImpianto' => new Map<String,List<String>>
        {
            'Cluster__c' => new List<String>
                {'Reclami', 'Preventivi'}
        },
    'Istruttoria' => new Map<String,List<String>>
        {
            'Cluster__c' => new List<String>
                {'Reclami'}
        },
    'ModificaImpianto' => new Map<String,List<String>>
    {
        'Cluster__c' => new List<String>
            {'Reclami', 'Preventivi'}
    },
    'RimozioneImpianto' => new Map<String,List<String>>
    {
        'Cluster__c' => new List<String>
            {'Reclami', 'Preventivi'}
    },
    'RipristinoFornituraInterrotta' => new Map<String,List<String>>
        {
            'Cluster__c' => new List<String>
                {'Reclami', 'Preventivi'}
        },
    'SpostamentoContatore' => new Map<String,List<String>>
        {
            'Cluster__c' => new List<String>
                {'Reclami', 'Preventivi'}
        },
    'UnificazionePOD' => new Map<String,List<String>>
        {
            'Cluster__c' => new List<String>
                {'Reclami', 'Preventivi'}
        },
    'VariazioneFase' => new Map<String,List<String>>
        {
            'Cluster__c' => new List<String>
                {'Reclami', 'Preventivi'}
        },
    'RimozioneImpianto' => new Map<String,List<String>>
        {
            'Cluster__c' => new List<String>
                {'Reclami', 'Preventivi'}
        },
    'VariazionePotenza' => new Map<String,List<String>>
        {
            'Cluster__c' => new List<String>
                {'Reclami', 'Preventivi'}
        },
    'VariazioneTensione' => new Map<String,List<String>>
        {
            'Cluster__c' => new List<String>
                {'Reclami', 'Preventivi'}
        },
    'SpostamentoVotiveModena' => new Map<String,List<String>>
        {
            'Cluster__c' => new List<String>
                {'Reclami', 'Preventivi'}
        },
    'ComportamentoAltriVenditori' => new Map<String,List<String>>
        {
            'Type' => new List<String>
                {'Reclamo Scritto/Rich. Info', 'Switch Out SII','Recesso su Richiesta Cliente'}
        },
    'ComportamentoVenditoriHC' => new Map<String,List<String>>
        {
            'Cluster__c' => new List<String>
                {'Fatturazione'},
            'Type' => new List<String>
                {'Reclamo Scritto/Rich. Info', 'Condizioni Contrattuali Errate'}
        },
    'ReclamoScrittoRichInfo' => new Map<String,List<String>>
        {
            'Type' => new List<String>
                {'Ricostruzione Consumi'}
        },
    'VerificaDatialDL' => new Map<String,List<String>>
        {
            'Cluster__c' => new List<String>
                {'Reclami', 'Preventivi', 'Morosità', 'Variazioni', 'Annullamento', 'Verifiche','Autolettura'},
            'Type' => new List<String>
                {'Ricostruzione Consumi', 'Gestione Calamità', 'Rettifica Consumi', 'Prescrizione Fatture', 'Inversione del Contatore'}
        },
    'VotiveModenaContestazioneFattura' => new Map<String,List<String>>
        {
            'Type' => new List<String>
                {'Ricostruzione Consumi', 'Reclamo Scritto/Rich. Info'}
        },
    'Cambiocontatorenonregistrato' => new Map<String,List<String>>
        {
            'Cluster__c' => new List<String>
                {'Reclami', 'Preventivi', 'Fatturazione'}
        },
    'CondizioniContrattualiErrate' => new Map<String,List<String>>
        {
            'Cluster__c' => new List<String>
                {'Reclami', 'Preventivi', 'Fatturazione'}
        },
    'Dichiarazionediintento' => new Map<String,List<String>>
        {
            'Cluster__c' => new List<String>
                {'Reclami','Fatturazione'}
        },
    'GestioneCalamita' => new Map<String,List<String>>
        {
            'Cluster__c' => new List<String>
                {'Reclami'}
        },
    'MancataTeleletturalettura' => new Map<String,List<String>>
        {
            'Cluster__c' => new List<String>
                {'Reclami', 'Preventivi', 'Fatturazione'}
        },
    'MarcaturaUsoPdR' => new Map<String,List<String>>
        {
            'Cluster__c' => new List<String>
                {'Reclami'}
        },
    'ModificaLayoutdidettaglio' => new Map<String,List<String>>
        {
            'Cluster__c' => new List<String>
            {'Reclami', 'Fatturazione'}
        },
    'ModificaPortaleSOLGestioneEnergia' => new Map<String,List<String>>
        {
            'Cluster__c' => new List<String>
            {'Reclami'}
        },
    'ModificaTariffaResidenteNonResidente' => new Map<String,List<String>>
        {
            'Cluster__c' => new List<String>
                {'Reclami', 'Preventivi'},
            'Type' => new List<String>
                {'Condizioni Contrattuali Errate'}
        },
    'ModificaAzzeramentoConsumoAnnuo' => new Map<String,List<String>>
        {
            'Cluster__c' => new List<String>
                {'Reclami', 'Preventivi'},
            'Type' => new List<String>
                {'Gestione Calamità', 'Marcatura/Uso PdR', 'Modifica Tariffa Residente/Non Residente' }
        },
    'BPCAerratacategoria' => new Map<String,List<String>>
        {
            'Cluster__c' => new List<String>
                {'Reclami', 'Preventivi'}
        },
    'DettaglioBolletta' => new Map<String,List<String>>
        {
            'Cluster__c' => new List<String>
                {'Reclami', 'Fatturazione'}
        },
    'SplitPayment' => new Map<String,List<String>>
        {
            'Cluster__c' => new List<String>
                {'Reclami'}
        },
    'Variazioneindirizzodifornitura' => new Map<String,List<String>>
        {
            'Cluster__c' => new List<String>
                {'Reclami', 'Fatturazione'}
        },
    'ConsegnacopiachiaveGdM' => new Map<String,List<String>>
        {
            'Cluster__c' => new List<String>
                {'Reclami', 'Preventivi'}
        },
    'RichiestaLetturaCliente' => new Map<String,List<String>>
        {
            'Cluster__c' => new List<String>
                {'Reclami', 'Preventivi'}
        },
    'SostContatoreCliente' => new Map<String,List<String>>
        {
            'Cluster__c' => new List<String>
                {'Reclami', 'Preventivi'}
        },
    'VerificaFugaIdrica' => new Map<String,List<String>>
        {
            'Cluster__c' => new List<String>
                {'Segnalazioni'},
            'Type' => new List<String>
                {'Consumo Anomalo Idrico'}
        },
    'VerificaGdm' => new Map<String,List<String>>
        {
            'Cluster__c' => new List<String>
                {'Reclami', 'Preventivi', 'Fatturazione'}
        },
    'VerificaInterna' => new Map<String,List<String>>
    {
        'Cluster__c' => new List<String>
            {'Reclami', 'Preventivi', 'Fatturazione'}
    },
    'VerificaIntegritaSigilli' => new Map<String,List<String>>
    {
        'Cluster__c' => new List<String>
            {'Reclami', 'Preventivi', 'Fatturazione'}
    },
    'InterventiConVerifica' => new Map<String,List<String>>
    {
        'Cluster__c' => new List<String>
            {'Reclami', 'Preventivi', 'Fatturazione'}
    },
    'VerificaRotturaImpiantoCliente' => new Map<String,List<String>>
    {
        'Cluster__c' => new List<String>
            {'Reclami', 'Preventivi', 'Fatturazione'}
    },
    'adesionerinunciafondofughe' => new Map<String,List<String>>
        {
            'Cluster__c' => new List<String>
                {'Reclami','Fatturazione'}
        },
    'modificaunitaimmobiliaricomponenti' => new Map<String,List<String>>
        {
            'Cluster__c' => new List<String>
                {'Reclami','Fatturazione'}
        },
    'esenzionemodificafognatura' => new Map<String,List<String>>
        {
            'Cluster__c' => new List<String>
                {'Reclami','Fatturazione'}
        },
        'letturaacquaavvisocliente' => new Map<String,List<String>>
        {
            'Cluster__c' => new List<String>
                {'Segnalazioni'}
        },
    'cessazionescarichiproduttivi' => new Map<String,List<String>>
        {
            'Cluster__c' => new List<String>
                {'Reclami', 'Variazioni'},
                'Type' => new List<String>
                {'Gestione Calamità', 'Informative','Comunicazione di Fallimento','Annullamento Contratti'}
        },
    'VerificaTensionePressione' => new Map<String,List<String>>
        {
            'Cluster__c' => new List<String>
                {'Reclami', 'Preventivi', 'Fatturazione'}
        },
    'VolturaTecnica' => new Map<String,List<String>>
        {
            'Cluster__c' => new List<String>
                {'Reclami', 'Preventivi', 'Fatturazione', 'Morosità', 'Variazioni'},
            'Type' => new List<String>
                {'Unificazione/Separazione BP-CA-Bolletta','Allineamento Canone Rai'}
        },
    'Cessazione' => new Map<String,List<String>>
        {
            'Type' => new List<String>
                {'Reclamo Scritto/Rich. Info', 'Cessazione Post Accertamento'}
        },
    'CessazionePostAccertamento' => new Map<String,List<String>>
        {
            'Type' => new List<String>
                {'Reclamo Scritto/Rich. Info'}
        },
    'CessazioneTari' => new Map<String,List<String>>
        {
            'Type' => new List<String>
                {'Reclamo Scritto/Rich. Info', 'Cessazione Post Accertamento' } 
        },
    'ModificaPostAccertamento' => new Map<String,List<String>>
        {
            'Type' => new List<String>
                {'Reclamo Scritto/Rich. Info'}
        },      
    'ModificaDatiContrattualiTari' => new Map<String,List<String>>
        {
            'Type' => new List<String>
                {'Reclamo Scritto/Rich. Info', 'Errore di Fatturazione','Modifica post accertamento' } 
        },
    'RipetiSegnalazione' => new Map<String,List<String>>
        {
            'Type' => new List<String>
                {'Segnalazioni Ambientali'} 
        },
    'RipetiRitiro' => new Map<String,List<String>>
        {
            'Type' => new List<String>
                {'Gestione Rifiuti'} 
        },
    'PagamentoUnicoAnnualeTari' => new Map<String,List<String>>
        {
            'Type' => new List<String>
                {'Reclamo Scritto/Rich. Info','Modifica Tariffa Residente/Non Residente'}
        }
    };

    public static Map<String,Map<String,List<String>>> mapAccountStatementFilter = new Map<String,Map<String,List<String>>>
    { 
    'ComunicazionePagamento' => new Map<String,List<String>>
        {
            'Context__c' => new List<String>
                {'EC1L','InstallmentsView', 'Paperless'}
        },
    'PromessaPagamentoEnte' => new Map<String,List<String>>
        {
            'Context__c' => new List<String>
                {'EC1L','InstallmentsView','Paperless'}
        }
    };

    public static Boolean caseFilter(sObject sb, String method){
        boolean res = true;
        if(mapCaseFilter.get(method) != null){
            Map<String,List<String>> condictionOr = mapCaseFilter.get(method);
            if(condictionOr != null && !condictionOr.keyset().isEmpty()){
                Boolean r = false;
                for(String key : condictionOr.keyset()){
                    if(!r){
                        List<String> valori = condictionOr.get(key);
                        if(sb.get(key) != null && valori.contains((String) sb.get(key))){
                            r = true;
                            break;
                        }
                    }else{
                        break;
                    }
                }
                res = r;
            }
        }
        return res;
    }

    public static Boolean servicePointFilter(sObject sb, String method){
        if ('RipristinoFornituraInterrotta'.equalsIgnoreCase(method)){
            try{
                Id recordId = sb.get('Id') != null ? (Id)sb.get('Id') : null;
                HDT_QR_ServicePoint qrServicePoint = new HDT_QR_ServicePoint(); 
                ServicePoint__c sr = qrServicePoint.getRecordById(recordId,'SapContractStatus__c')[0];
                return 'Cessato'.equalsIgnoreCase(sr.SapContractStatus__c);
            }catch (Exception e){
                return false;
            }
        }
        return true;
    }

    public static Boolean accountStatementFilter(sObject sb, String method){
        boolean res = true;
        //fix
        if(method == 'PianoRateizzazione'){
            HDT_QR_Case caseQr = new HDT_QR_Case();
            String accountFilterId = (String)sb.get('Id');
            System.debug('****1:' + sb);
            System.debug('****2:' + accountFilterId);
            List<AccountStatementFilter__c> act = HDT_QR_AccountStatement.getFilter(accountFilterId);
            if(act != null && !act.isEmpty()){
                List<Case> listCase = caseQr.getCaseByAccountid(act[0].Account__c,new Set<String>{'Storno Rateizzazione'});
                if(listCase != null && !listCase.isEmpty()){
                    res = true;
                }
                else{
                    //String s = (String)sb.get('IsInstallment__c');
                    if(act[0].IsInstallment__c == false){
                        res = true;
                    }
                    else{
                        res = false;
                    }
                }
            }
            else{
                res = false;
            }
        }
        else if(mapAccountStatementFilter.get(method) != null){
            Map<String,List<String>> condictionOr = mapAccountStatementFilter.get(method);
            if(condictionOr != null && !condictionOr.keyset().isEmpty()){
                Boolean r = false;
                for(String key : condictionOr.keyset()){
                    if(!r){
                        List<String> valori = condictionOr.get(key);
                        if(sb.get(key) != null && valori.contains((String) sb.get(key))){
                            r = true;
                            break;
                        }
                    }else{
                        break;
                    }
                }
                res = r;
            }
        }
        return res;
    }

    public static Boolean checkSalesTari(String saleId, String method)
    {
        Boolean res = false;
        Boolean checkTari = false;
        Boolean checkStandard = false;
        List<SBQQ__QuoteLine__c> quoteLines = [SELECT Id, ServicePoint__c, ServicePoint__r.CommoditySector__c 
        FROM SBQQ__QuoteLine__c 
        WHERE SBQQ__Quote__r.Sale__c = :saleId
        WITH SECURITY_ENFORCED];

        for(SBQQ__QuoteLine__c quoteLine : quoteLines)
        {
            if(quoteLine.ServicePoint__c != null && quoteLine.ServicePoint__r.CommoditySector__c.equalsIgnoreCase('Ambiente'))
            {
                checkTari = true;
            }
            else if(quoteLine.ServicePoint__c != null && !quoteLine.ServicePoint__r.CommoditySector__c.equalsIgnoreCase('Ambiente'))
            {
                checkStandard = true;
            }
            
        }

        if(method.equalsIgnoreCase('tari') && checkTari)
        {
            res = true;
        }
        else if(method.equalsIgnoreCase('standard') && checkStandard)
        {
            res = true;
        }
        return res;
    }
}