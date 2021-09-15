@isTest
public with sharing class HDT_SRV_DocumentSelectedManagerTst {
    
    //DEBUG
    public static final String TEST_NAME = 'HDT_SRV_DocumentSelectedManagerTst';
    
    //DATA
    private static HDT_UTL_Constants constants=new HDT_UTL_Constants();
    
    
    //TEST SETUP
    private static void mySetup(){
        //TODO: POSSIBILE CHE VADA INSTALLATO PCLICK
        List<Account> acc = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<BillingProfile__c> bpf = HDT_UTL_DataFactoryTst.createBillingProfile(1, true, acc[0].Id);
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, acc[0].Id, 'Bozza');
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, acc[0].Id);
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, acc[0].id);
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, true, acc[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);
    }
    
    
    
    //TESTS
    
    //execute
    //TODO: SPEZZARE METODO IN PIù METODI. TROPPO COMPLESSO TESTARE IN UN COLPO SOLO.
    
            
        //TODO: REIMPIEGARE IN METODI FUTURI PER AUMENTO COPERTURA TEST
        
        /*
        AccountStatementFilter__c asf_2 = new AccountStatementFilter__c();//FILTRO ESTRATTO CONTO
        asf_2.Context__c = 'InstallmentsView';
        
        AccountStatementFilter__c asf_3 = new AccountStatementFilter__c();//FILTRO ESTRATTO CONTO
        //asf_3.Context__c = 'InstallmentsView';
        */
    
    //manageDocuments - EC1L
    
    @isTest
    private static void executeTest() {
        
        //DEBUG
        String debugString = TEST_NAME + ' - executeTest';
        System.debug(debugString);
        
        //SETUP
        mySetup();
        Case myCase = [SELECT Id FROM Case];
        BillingProfile__c bpf = [SELECT Id, ContractAccountCode__c FROM BillingProfile__c];
        
        AccountStatementFilter__c asf_1 = new AccountStatementFilter__c();//FILTRO ESTRATTO CONTO
        asf_1.Context__c = 'EC1L';
        
        
        //PREPARAZIONE REQUEST (INPUTS)
        
        Map<String,Object> secLevel = new Map<String,Object>();
        //secLevel.put('contratto', '');    //response.contractCode = contractCode;
        secLevel.put('testoDettaglio', 'Testo Dettaglio');
        secLevel.put('tipoDocumento', 'VR');
        secLevel.put('importo', 5.5);
        
        
        Map<String,Object> priLevel = new Map<String,Object>();
        
        priLevel.put('dataEmissione', Date.today());
        priLevel.put('dataScadenza', Date.today().addDays(1));
        priLevel.put('dataEmissione', Date.today());
        priLevel.put('numeroDocumento', 'Numero Documento');
        priLevel.put('numeroFattura', 'Numero Fattura');
        priLevel.put('contratto', 'CONTRATTO');//response.contractCode = contractCode;
        priLevel.put('contoContrattuale', bpf.ContractAccountCode__c);
        priLevel.put('modalitaPagamento', 'Metodo Pagamento');
        priLevel.put('residuo', 10.5);
        priLevel.put('importo', 109.5);
        priLevel.put('societa', 'HERA COMM');
        priLevel.put('totaleCopertina', 20.5);
        priLevel.put('numeroBollettino', 'Numero Bollettino');
        priLevel.put('tipoDocumento', 'Tipo Documento');
        priLevel.put('dilazione', 'Dilazione');
        priLevel.put('modalitaPagamento', 'Modalità Pagamento');
        priLevel.put('nome', true);
        priLevel.put('nome', true);
        
        List<Object> secondoLivello = new List<Object>{secLevel};
        priLevel.put('secondoLivelloInformativo', secondoLivello);
        
        //STRINGIFY
        List<Object> myObj = new List<Object>{priLevel};
        asf_1.DocumentSelected__c = JSON.serialize(myObj);
        
        insert asf_1;
        
        
        
        List<HDT_SRV_DocumentSelectedManager.HDT_WRP_DocumentSelectedRequest> inputs;
        inputs = new List<HDT_SRV_DocumentSelectedManager.HDT_WRP_DocumentSelectedRequest>();
        
        //TESTING
        //manageDocuments
        HDT_SRV_DocumentSelectedManager.HDT_WRP_DocumentSelectedRequest input;
        input = new HDT_SRV_DocumentSelectedManager.HDT_WRP_DocumentSelectedRequest();
        
        input.method = 'manageDocuments';   //TODO: TESTARE TUTTE LE ALTERNATIVE
        input.recordId = asf_1.Id;
        input.caseId = myCase.Id;
        input.createDocuments = true;
        
        //input.contesto = 'EC1Level';      //TODO: TESTARE ELSE
        
        inputs.add(input);
        
        //ASF 1 - manageDocuments
        
        
        //TESTING
        List<HDT_SRV_DocumentSelectedManager.HDT_WRP_DocumentSelectedResponse> resultList;
        resultList = HDT_SRV_DocumentSelectedManager.execute(inputs);
        HDT_SRV_DocumentSelectedManager.HDT_WRP_DocumentSelectedResponse result = resultList[0];
        
        
        //RETRIEVING DATA
        
        //DocumentSelected__c
        DocumentSelected__c docResult = [SELECT Id, Name FROM DocumentSelected__c];
        
        //CASE UPDATED
        Case caseResult = [SELECT Id FROM Case];
        
        
        //ASSERTS
        System.assertEquals('Numero Fattura', docResult.Name);
        
        System.assertEquals(caseResult.Id, result.caseRecord.Id);
        System.assertEquals('CONTRATTO', result.contractCode);
        System.assertEquals('Testo Dettaglio', result.tipoDocumento);
        
        
        //ASF 2 - manageDocumentsCreditViews
        
        
        //ASF 3 - null
        
        
        
        
        //manageDocumentsInformative
        //inputs contesto - 'EC1Level','NoteVarIva' - else

        
        //manageDocumentsPaperless
        
        
    }
    
    
    
    //manageDocuments - InstallmentsView / EC7
    
    
    
    
    //manageDocuments - else (null)
    
    
    
    
    //manageDocumentsInformative - EC1Level / NoteVarIva
    
    
    
    
    //manageDocumentsInformative - else (manageDocumentsCreditViews)
    
    
    
    
    //manageDocumentsPaperless - 
    
    
    
    
    //else (return null)
    
    
    
}
