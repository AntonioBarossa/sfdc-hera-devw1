@isTest
public with sharing class HDT_SRV_DocumentSelectedManagerTst {
    
    //DEBUG
    public static final String TEST_NAME = 'HDT_SRV_DocumentSelectedManagerTst';
    
    //DATA
    private static HDT_UTL_Constants constants=new HDT_UTL_Constants();
    
    
    //TEST SETUP
    
    
    
    //TESTS
    
    //execute
    //TODO: SPEZZARE METODO IN PIù METODI. TROPPO COMPLESSO TESTARE IN UN COLPO SOLO.
    private static void executeTest() {
        
        //DEBUG
        String debugString = TEST_NAME + ' - executeTest';
        System.debug(debugString);
        
        //SETUP
        
        //INSERIRE SETUP FINO A CREAZIONE CASE.
        //POSSIBILE CHE VADA INSTALLATO PCLICK
        
        
        
        AccountStatementFilter__c asf_1 = new AccountStatementFilter__c();//FILTRO ESTRATTO CONTO
        asf_1.Context__c = 'EC1L';

        //DocumentSelected__c
        /*

        //TODO: PER PRIMO E SECONDO LIVELLO CERCARE DI ADEGUARSI A UN RECORD ESISTENTE COME SUGGERITO.
        
        [
            {
                //"codiceCliente":"1005421319",
                "contoContrattuale":"200008265851",
                //"classeConto":"Z001",
                "dataEmissione":"19/12/2018",
                "dataScadenza":"16/01/2019",
                "dilazione":"NO",
                //"idPrimoLivelloSAP":"00000000000000000000000000000000000000000000000001",
                "importo":"212.92",
                "modalitaPagamento":"BOLLETTINO",
                //"modalitaPagamentoCA":"bollettino postale",
                "numeroBollettino":"4201708006748191",
                "numeroFattura":"0000411810736024",
                //"rateizzato":"SI",
                "residuo":"140.0",
                "societa":"Hera Comm S.p.A.",
                //"sollecitato":"NO",
                "tipoDocumento":"CALCOLO CONTRATTI ATTIVI",
                "totaleCopertina":"212.92",
                //"loginId":"0-1",
                "secondoLivelloInformativo":[
                    {
                        "contratto":"3016591573",
                        //"dataEmissionePianoRata":"15/01/2019",
                        //"dataRegistrazione":"19/12/2018",
                        //"documento":"104002246842",
                        "importo":"71.16",
                        //"pianoRate":"500002431609",
                        //"residuo":"0.0",
                        //"scadenza":"2019-01-16",
                        //"settoreMerceologico":"Energia elettrica",
                        "testoDettaglio":"CALCOLO CONTRATTI ATTIVI",
                        "tipoDocumento":"2F",
                        //"idSecondoLivelloSAP":"00000000000000000000000000000000000000000000000001"
                    },
                    {
                        "contratto":"3016959569",
                        //"dataEmissionePianoRata":"15/01/2019",
                        //"dataRegistrazione":"19/12/2018",
                        //"documento":"104002246842",
                        "importo":"68.83",
                        //"pianoRate":"500002431609",
                        //"residuo":"0.0",
                        //"scadenza":"2019-01-16",
                        //"settoreMerceologico":"Gas",
                        "testoDettaglio":"CALCOLO CONTRATTI ATTIVI",
                        "tipoDocumento":"2F",
                        //"idSecondoLivelloSAP":"00000000000000000000000000000000000000000000000002"
                    },
                    {
                        "contratto":"3016959569",
                        //"dataEmissionePianoRata":"15/01/2019",
                        //"dataRegistrazione":"19/12/2018",
                        //"documento":"104002246842",
                        "importo":"0.01",
                        //"pianoRate":"500002431609",
                        //"residuo":"0.0",
                        //"scadenza":"2019-01-16",
                        //"settoreMerceologico":"Gas",
                        "testoDettaglio":"CALCOLO CONTRATTI ATTIVI",
                        "tipoDocumento":"2F",
                        //"idSecondoLivelloSAP":"00000000000000000000000000000000000000000000000003"
                    }
                ],
                //"id":"00000000000000000000000000000000000000000000000001"
            }
        ]
        
        Map<String,Object> primolivello = (Map<String, Object>)primoLivelloList[0];
        List<Object> secondoLivelloList = (List<Object>)primolivello.get('secondoLivelloInformativo');
        Map<String, Object> secondoLivello = (Map<String, Object>) secondoLivelloList[0];
        
        */
        
        AccountStatementFilter__c asf_2 = new AccountStatementFilter__c();//FILTRO ESTRATTO CONTO
        asf_2.Context__c = 'InstallmentsView';
        
        AccountStatementFilter__c asf_3 = new AccountStatementFilter__c();//FILTRO ESTRATTO CONTO
        //asf_3.Context__c = 'InstallmentsView';
        
        insert new List<AccountStatementFilter__c>{asf_1, asf_2, asf_3};
        
        
        List<HDT_SRV_DocumentSelectedManager.HDT_WRP_DocumentSelectedRequest> inputs;
        inputs = new List<HDT_SRV_DocumentSelectedManager.HDT_WRP_DocumentSelectedRequest>();

        
        //TESTING
        //manageDocuments
        HDT_SRV_DocumentSelectedManager.HDT_WRP_DocumentSelectedRequest input;
        input = new HDT_SRV_DocumentSelectedManager.HDT_WRP_DocumentSelectedRequest();
        input.recordId = recordId;
        input.method = 'manageDocuments';
        input.caseId = '';
        
        //ASF 1 - manageDocuments
        
        
        //ASF 2 - manageDocumentsCreditViews
        
        
        //ASF 3 - null
        
        
        
        
        //manageDocumentsInformative
        //inputs contesto - 'EC1Level','NoteVarIva' - else

        
        //manageDocumentsPaperless
        
        
    }
    
}
