@isTest
public with sharing class HDT_SRV_DocumentSelectedManagerTst {
    
    //DEBUG
    public static final String TEST_NAME = 'HDT_SRV_DocumentSelectedManagerTst';
    
    //DATA
    private static HDT_UTL_Constants constants=new HDT_UTL_Constants();
    
    
    //TEST SETUP
    private static void mySetup(){
        List<Account> acc = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<BillingProfile__c> bpf = HDT_UTL_DataFactoryTst.createBillingProfile(1, true, acc[0].Id);
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, acc[0].Id, 'Bozza');
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, acc[0].Id);
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, acc[0].id);
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, true, acc[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);
        HDT_UTL_DataFactoryTst.pClickCasePhase();
    }
    
    
    
    //TESTS
    
    //execute
    
    //empty Input test
    @isTest
    private static void executeTest_NoInput() {
        
        //DEBUG
        String debugString = TEST_NAME + ' - executeTest_NoInput';
        System.debug(debugString);
        
        //SETUP
        
        //TESTING
        Object result = HDT_SRV_DocumentSelectedManager.execute(null);
        
        //ASSERTS
        System.assertEquals(null, result);
        
        
        //TESTING return null last switch else
        List<HDT_SRV_DocumentSelectedManager.HDT_WRP_DocumentSelectedRequest> inputs;
        inputs = new List<HDT_SRV_DocumentSelectedManager.HDT_WRP_DocumentSelectedRequest>();
        
        //TESTING
        //manageDocuments
        HDT_SRV_DocumentSelectedManager.HDT_WRP_DocumentSelectedRequest input;
        input = new HDT_SRV_DocumentSelectedManager.HDT_WRP_DocumentSelectedRequest();
        
        input.method = 'Test';   //TODO: TESTARE TUTTE LE ALTERNATIVE
        inputs.add(input);
        
        result = HDT_SRV_DocumentSelectedManager.execute(inputs);
        
        //ASSERTS
        System.assertEquals(null, result);
        
    }
    
    
    //manageDocuments - EC1L
    //NB: VIENE TESTATO ANCHE getDocumentsSelected PER CONVENIENZA
    @isTest
    private static void executeTest_manageDocuments_EC1L() {
        
        //DEBUG
        String debugString = TEST_NAME + ' - executeTest_manageDocuments_EC1L';
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
        
        priLevel.put('dataEmissione', '');
        priLevel.put('dataScadenza', '');
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
        
        input.method = 'manageDocuments';
        input.recordId = asf_1.Id;
        input.caseId = myCase.Id;
        input.createDocuments = true;
        
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
        
        //TESTING A CATENA DI getDocumentsSelected
        List<SObject> resultGDS = HDT_SRV_DocumentSelectedManager.getDocumentsSelected(caseResult.Id);
        
        //ASSERTS
        System.assertEquals(1, resultGDS.size());
        
        DocumentSelected__c docSel = (DocumentSelected__c) resultGDS[0];
        System.assertEquals('Numero Bollettino', docSel.Bill__c);
        System.assertEquals('Tipo Documento', docSel.Type__c);
        System.assertEquals(10.5, docSel.DocumentResidue__c);
        
        
    }
    
    
    //manageDocuments - InstallmentsView / EC7
    
    @isTest
    private static void executeTest_manageDocuments_InstallmentsView() {
        
        //DEBUG
        String debugString = TEST_NAME + ' - executeTest_manageDocuments_InstallmentsView';
        System.debug(debugString);
        
        //SETUP
        mySetup();
        Case myCase = [SELECT Id FROM Case];
        BillingProfile__c bpf = [SELECT Id, ContractAccountCode__c FROM BillingProfile__c];
        
        AccountStatementFilter__c asf_1 = new AccountStatementFilter__c();//FILTRO ESTRATTO CONTO
        asf_1.Context__c = 'InstallmentsView';
        
        
        //PREPARAZIONE REQUEST (INPUTS)
        
        Map<String,Object> secLevel = new Map<String,Object>();
        //secLevel.put('contratto', '');    //response.contractCode = contractCode;
        secLevel.put('testoDettaglio', 'Testo Dettaglio');
        secLevel.put('tipoDocumento', 'VR');
        secLevel.put('importo', 5.5);
        
        
        Map<String,Object> priLevel = new Map<String,Object>();
        
        priLevel.put('dataEmissione', '');
        priLevel.put('dataScadenza', '');
        priLevel.put('numeroDocumento', 'Numero Documento');
        priLevel.put('docOriginario', 'Numero Fattura');
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
        priLevel.put('secondoLivelloInformativoF2', secondoLivello);
        
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
        System.assertEquals(false, result.hasPartiteNonFatturate);
        
    }
    
    
    //manageDocuments - else (null)
    
    @isTest
    private static void executeTest_manageDocuments_null() {
        
        //DEBUG
        String debugString = TEST_NAME + ' - executeTest_manageDocuments_null';
        System.debug(debugString);
        
        //SETUP
        AccountStatementFilter__c asf_1 = new AccountStatementFilter__c();//FILTRO ESTRATTO CONTO
        asf_1.Context__c = '';
        asf_1.DocumentSelected__c = '';
        
        insert asf_1;
        
        
        List<HDT_SRV_DocumentSelectedManager.HDT_WRP_DocumentSelectedRequest> inputs;
        inputs = new List<HDT_SRV_DocumentSelectedManager.HDT_WRP_DocumentSelectedRequest>();
        
        //TESTING
        //manageDocuments
        HDT_SRV_DocumentSelectedManager.HDT_WRP_DocumentSelectedRequest input;
        input = new HDT_SRV_DocumentSelectedManager.HDT_WRP_DocumentSelectedRequest();
        
        input.method = 'manageDocuments';
        input.recordId = asf_1.Id;
        inputs.add(input);
        
        //TESTING
        List<HDT_SRV_DocumentSelectedManager.HDT_WRP_DocumentSelectedResponse> resultList;
        resultList = HDT_SRV_DocumentSelectedManager.execute(inputs);
        
        //ASSERTS
        System.assertEquals(null, resultList);
        
    }
    
    
    
    
    
    
    //manageDocumentsInformative - EC1Level / NoteVarIva
    
    @isTest
    private static void executeTest_manageDocumentsInformative_EC1Level() {
        
        //DEBUG
        String debugString = TEST_NAME + ' - executeTest_manageDocumentsInformative_EC1Level';
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
        
        priLevel.put('dataEmissione', '');
        priLevel.put('dataScadenza', '');
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
        
        input.method = 'manageDocumentsInformative';   //TODO: TESTARE TUTTE LE ALTERNATIVE
        input.recordId = asf_1.Id;
        input.caseId = myCase.Id;
        input.contesto = 'EC1Level';
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
        
    }
    
    
    
    //manageDocumentsInformative - else (manageDocumentsCreditViews)
    
    @isTest
    private static void executeTest_manageDocumentsInformative_else() {
        
        //DEBUG
        String debugString = TEST_NAME + ' - executeTest_manageDocumentsInformative_else';
        System.debug(debugString);
        
        //SETUP
        mySetup();
        Case myCase = [SELECT Id FROM Case];
        BillingProfile__c bpf = [SELECT Id, ContractAccountCode__c FROM BillingProfile__c];
        
        AccountStatementFilter__c asf_1 = new AccountStatementFilter__c();//FILTRO ESTRATTO CONTO
        asf_1.Context__c = 'InstallmentsView';
        
        
        //PREPARAZIONE REQUEST (INPUTS)
        
        Map<String,Object> secLevel = new Map<String,Object>();
        //secLevel.put('contratto', '');    //response.contractCode = contractCode;
        secLevel.put('testoDettaglio', 'Testo Dettaglio');
        secLevel.put('tipoDocumento', 'VR');
        secLevel.put('importo', 5.5);
        
        
        Map<String,Object> priLevel = new Map<String,Object>();
        
        priLevel.put('dataEmissione', '');
        priLevel.put('dataScadenza', '');
        priLevel.put('numeroDocumento', 'Numero Documento');
        priLevel.put('docOriginario', 'Numero Fattura');
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
        priLevel.put('secondoLivelloInformativoF2', secondoLivello);
        
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
        
        input.method = 'manageDocumentsInformative';   //TODO: TESTARE TUTTE LE ALTERNATIVE
        input.recordId = asf_1.Id;
        input.caseId = myCase.Id;
        input.contesto = 'Test';
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
        System.assertEquals(false, result.hasPartiteNonFatturate);
        
    }
    
    
    
    
    
    
    //manageDocumentsPaperless - 
    
    @isTest
    private static void executeTest_manageDocumentsPaperless() {
        
        //DEBUG
        String debugString = TEST_NAME + ' - executeTest_manageDocumentsPaperless';
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
        
        priLevel.put('dataEmissione', '');
        priLevel.put('dataScadenza', '');
        priLevel.put('posizione1', 'Posizione 1');
        priLevel.put('posizione2', 'Posizione 2');
        priLevel.put('posizione3', 'Posizione 3');
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
        
        input.method = 'manageDocumentsPaperless';   //TODO: TESTARE TUTTE LE ALTERNATIVE
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
        
    }
    
    
    
    //formatDate
    @isTest
    private static void formatDateTest() {
        
        //DEBUG
        String debugString = TEST_NAME + ' - formatDateTest';
        System.debug(debugString);
        
        //SETUP
        String inputDate = '10/09/2021';
        
        //TESTING
        Date result = HDT_SRV_DocumentSelectedManager.formatDate(inputDate);
        
        //ASSERTS
        System.assertEquals(Date.valueOf(2021+'-'+09+'-'+10), result);
        
        
    }

    
    
    //getRiferimentoFattura
    @isTest
    private static void getRiferimentoFatturaTest() {
        
        //DEBUG
        String debugString = TEST_NAME + ' - getRiferimentoFatturaTest';
        System.debug(debugString);
        
        //NULL TESTING
        String result = HDT_SRV_DocumentSelectedManager.getRiferimentoFattura(null);
        
        //ASSERTS
        System.assertEquals(null, result);
        
        
        //EMPTY TESTING
        Map<String,Object> secLevel = new Map<String,Object>();
        //secLevel.put('contratto', '');    //response.contractCode = contractCode;
        secLevel.put('riferimentoFattura', '');
        
        List<Object> secondoLivelloList = new List<Object>{secLevel};
        
        //TESTING
        result = HDT_SRV_DocumentSelectedManager.getRiferimentoFattura(secondoLivelloList);
        
        //ASSERTS
        System.assertEquals('', result);
        
        
        
        //NORMAL TESTING
        secLevel = new Map<String,Object>();
        //secLevel.put('contratto', '');    //response.contractCode = contractCode;
        secLevel.put('testoDettaglio', 'Testo Dettaglio');
        secLevel.put('tipoDocumento', 'VR');
        secLevel.put('importo', 5.5);
        secLevel.put('riferimentoFattura', 'Riferimento Fattura');
        
        secondoLivelloList = new List<Object>{secLevel};
        
        //TESTING
        result = HDT_SRV_DocumentSelectedManager.getRiferimentoFattura(secondoLivelloList);
        
        //ASSERTS
        System.assertEquals('Riferimento Fattura', result);
        
    }
    
    
}
