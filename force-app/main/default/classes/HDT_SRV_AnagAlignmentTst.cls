@isTest
public class HDT_SRV_AnagAlignmentTst {

    @TestSetup
    static void setup(){

        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(2, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, false);
        servPointList[0].CommoditySector__c = 'Gas';
        servPointList[0].Account__c = accList[1].Id;
        servPointList[0].SupplyType__c = 'A-Domestico';
        servPointList[0].Disconnectable__c = 'No';
        servPointList[0].DisconnectibilityType__c = 'Rilevanza continuità serv. GAS';
        insert servPointList;

        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, false, accList[0].id, 'Bozza');
        ordList[0].DistributorPracticeCode__c = 'A00000000288_DL';
        ordList[0].ExciseGAS__c = 'Imposta Usi Domestici (Cod. G_ICD)';
        ordList[0].ServicePoint__c = servPointList[0].Id;
        ordList[0].SupplyState__c = 'AQ';
        ordList[0].Type = 'New';
        ordList[0].ProcessType__c='Prima Attivazione Ele';
        insert ordList;

        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].Id);
        AccountContactRelation accContRel = HDT_UTL_DataFactoryTst.createAccountContactRelation(true, accList[1].Id, contactList[0].Id);

        List<BillingProfile__c> billingProfileList = HDT_UTL_DataFactoryTst.createBillingProfile(1,true, accList[0].Id);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, false, accList[0].id);
        contractList[0].Status = 'Attivo';
        insert contractList;

        List<Contract> contractListTwo = HDT_UTL_DataFactoryTst.createContract(1, true, accList[1].id);
        contractListTwo[0].ServicePoint__c = servPointList[0].Id;
        contractListTwo[0].Status = 'Attivo';

        update contractListTwo;

        ServicePoint__c svPoint = [SELECT Id FROM ServicePoint__c LIMIT 1];

        List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, false, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);
        caseList[0].BillingProfile__c = billingProfileList[0].Id;
        caseList[0].RecordTypeId  = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_AllineamentoAnagrafica').getRecordTypeId();
        caseList[0].ServicePoint__c  = svPoint.Id;
        insert caseList;
        
        HDT_UTL_DataFactoryTst.pClickCasePhase();
        
        HDT_UTL_Constants constantsUtl = new HDT_UTL_Constants();
        String rtName = 'HDT_RT_AllineamentoAnagrafica';
        String rtId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_AllineamentoAnagrafica').getRecordTypeId();
        String rtIdsosp = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_SospensioneRiattivazione').getRecordTypeId();

        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Da Inviare', 'Bozza', rtId, rtName,'A','','','');
		HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'In Lavorazione SAP', 'Bozza', rtIdsosp, 'HDT_RT_SospensioneRiattivazione','A','','','');

    }

    @IsTest
    static void testHandleAnagAlignment(){

        Case cs = [Select Id FROM Case LIMIT 1];
        
        Test.startTest();

        HDT_SRV_AnagAlignment.HDT_UTL_AnagAlignmentFlowInputs inputs = new HDT_SRV_AnagAlignment.HDT_UTL_AnagAlignmentFlowInputs();
        inputs.inputCase = cs;
        inputs.context = 'ALLINEAMENTO_CANONE_RAI';

        List<HDT_SRV_AnagAlignment.HDT_UTL_AnagAlignmentFlowInputs> inputsList = new List<HDT_SRV_AnagAlignment.HDT_UTL_AnagAlignmentFlowInputs>();
        inputsList.add(inputs);

        List<String> results = HDT_SRV_AnagAlignment.handleAnagAlignment(inputsList);

        System.assert(results.size() > 0, 'results.size() > 0 or results == null');

        Test.stopTest();
        
    }

    @IsTest
    static void testUpdateAnagAlignmentCaseServiceCatalog(){

        Case cs = [Select Id, AccountId, ContactId, CommodityFormula__c, CausalCode__c, ServicePoint__c FROM Case LIMIT 1];
        
        Test.startTest();

        HDT_SRV_AnagAlignment.HDT_UTL_AnagAlignmentFlowInputs inputs = new HDT_SRV_AnagAlignment.HDT_UTL_AnagAlignmentFlowInputs();
        inputs.inputCase = cs;
        inputs.context = 'SERVICE_CATALOG';

        List<HDT_SRV_AnagAlignment.HDT_UTL_AnagAlignmentFlowInputs> inputsList = new List<HDT_SRV_AnagAlignment.HDT_UTL_AnagAlignmentFlowInputs>();
        inputsList.add(inputs);

        List<String> results = HDT_SRV_AnagAlignment.handleAnagAlignment(inputsList);

        System.assert(results.size() > 0, 'results.size() > 0 or results == null');

        Test.stopTest();
        
    }

    @IsTest
    static void testUpdateAnagAlignmentCaseVarMarcaturaUsoPdr(){

        Case cs = [Select Id, AccountId, ContactId, CommodityFormula__c, CausalCode__c, ServicePoint__c FROM Case LIMIT 1];
        
        Test.startTest();

        HDT_SRV_AnagAlignment.HDT_UTL_AnagAlignmentFlowInputs inputs = new HDT_SRV_AnagAlignment.HDT_UTL_AnagAlignmentFlowInputs();
        inputs.inputCase = cs;
        inputs.context = 'VARIAZIONI_MARCATURA_USO_PDR';

        List<HDT_SRV_AnagAlignment.HDT_UTL_AnagAlignmentFlowInputs> inputsList = new List<HDT_SRV_AnagAlignment.HDT_UTL_AnagAlignmentFlowInputs>();
        inputsList.add(inputs);

        List<String> results = HDT_SRV_AnagAlignment.handleAnagAlignment(inputsList);

        System.assert(results.size() > 0, 'results.size() > 0 or results == null');

        Test.stopTest();
        
    }

    @IsTest
    static void testUpdateAnagAlignmentCaseVarIndFornitura(){

        Case cs = [Select Id, AccountId, ContactId, CommodityFormula__c, CausalCode__c, ServicePoint__c FROM Case LIMIT 1];
        
        Test.startTest();

        HDT_SRV_AnagAlignment.HDT_UTL_AnagAlignmentFlowInputs inputs = new HDT_SRV_AnagAlignment.HDT_UTL_AnagAlignmentFlowInputs();
        inputs.inputCase = cs;
        inputs.context = 'VARIAZIONI_INDIRIZZO_FORNITURA';

        List<HDT_SRV_AnagAlignment.HDT_UTL_AnagAlignmentFlowInputs> inputsList = new List<HDT_SRV_AnagAlignment.HDT_UTL_AnagAlignmentFlowInputs>();
        inputsList.add(inputs);

        List<String> results = HDT_SRV_AnagAlignment.handleAnagAlignment(inputsList);

        System.assert(results.size() > 0, 'results.size() > 0 or results == null');

        Test.stopTest();
        
    }

    @IsTest
    static void testUpdateAnagAlignmentCaseVarTariffaResNonRes(){

        Case cs = [Select Id, AccountId, ContactId, CommodityFormula__c, CausalCode__c, ServicePoint__c FROM Case LIMIT 1];
        
        Test.startTest();

        HDT_SRV_AnagAlignment.HDT_UTL_AnagAlignmentFlowInputs inputs = new HDT_SRV_AnagAlignment.HDT_UTL_AnagAlignmentFlowInputs();
        inputs.inputCase = cs;
        inputs.context = 'VARIAZIONI_TARIFFA_RES_NONRES';

        List<HDT_SRV_AnagAlignment.HDT_UTL_AnagAlignmentFlowInputs> inputsList = new List<HDT_SRV_AnagAlignment.HDT_UTL_AnagAlignmentFlowInputs>();
        inputsList.add(inputs);

        List<String> results = HDT_SRV_AnagAlignment.handleAnagAlignment(inputsList);

        System.assert(results.size() > 0, 'results.size() > 0 or results == null');

        Test.stopTest();
        
    }

    @IsTest
    static void testHandleAnagAlignmentHeroku(){

        ServicePoint__c servPoint = [SELECT Id, ServicePointCode__c FROM ServicePoint__c LIMIT 1];

        List<HDT_WRP_MrrRequest.HDT_WRP_Field> fieldList = new List<HDT_WRP_MrrRequest.HDT_WRP_Field>();
        fieldList = createFieldsList(fieldList, '0200','VS2', 'A01', servPoint.ServicePointCode__c, 'A00000000288_DL', '');

        HDT_WRP_HerokuPostSalesManager herokuWrapper = new HDT_WRP_HerokuPostSalesManager(fieldList);

        Test.startTest();

        Case cs = HDT_SRV_AnagAlignment.handleAnagAlignmentHeroku(herokuWrapper);

        System.assert(cs != null, 'cs == null');
        System.assert(cs.Id != null, 'cs.Id == null');

        Test.stopTest();
        
    }

    @IsTest
    static void testHandleAnagAlignmentHerokuWithEmptyPratDistr(){

        ServicePoint__c servPoint = [SELECT Id, ServicePointCode__c FROM ServicePoint__c LIMIT 1];

        List<HDT_WRP_MrrRequest.HDT_WRP_Field> fieldList = new List<HDT_WRP_MrrRequest.HDT_WRP_Field>();
        fieldList = createFieldsList(fieldList, '0200', 'VS2', 'A01', servPoint.ServicePointCode__c, '', '');

        HDT_WRP_HerokuPostSalesManager herokuWrapper = new HDT_WRP_HerokuPostSalesManager(fieldList);

        Test.startTest();

        Case cs = HDT_SRV_AnagAlignment.handleAnagAlignmentHeroku(herokuWrapper);

        System.assert(cs != null, 'cs == null');

        Test.stopTest();
        
    }

    @IsTest
    static void testHandleAnagAlignmentHerokuN02(){

        ServicePoint__c servPoint = [SELECT Id, ServicePointCode__c FROM ServicePoint__c LIMIT 1];

        List<HDT_WRP_MrrRequest.HDT_WRP_Field> fieldList = new List<HDT_WRP_MrrRequest.HDT_WRP_Field>();
        fieldList = createFieldsList(fieldList, '0200', 'VS2', 'N02', servPoint.ServicePointCode__c, 'A00000000288_DL', '');
        
        HDT_WRP_HerokuPostSalesManager herokuWrapper = new HDT_WRP_HerokuPostSalesManager(fieldList);
        
        Test.startTest();

        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"status":"success","correlationId":"65d9b870-1643-11ec-9817-022a9bf2c34e","timestamp":"2021-09-15T18:38:50","data":{"testata":{"esito":"OK"},"posizioni":[{"campo":"PRESSIONE","valore":"200008867681"}]}}');
        response.setStatusCode(200);
        response.setStatus('OK');
        
        Test.setMock(HttpCalloutMock.class, new HDT_SRV_AnagAlignmentTstMock(response));

        Case cs = HDT_SRV_AnagAlignment.handleAnagAlignmentHeroku(herokuWrapper);

        System.assert(cs != null, 'cs == null');
        System.assert(cs.Id != null, 'cs.Id == null');

        Test.stopTest();
        
    }

        @IsTest
    static void testHandleAnagAlignmentHerokuA02(){

        ServicePoint__c servPoint = [SELECT Id, Name, ServicePointCode__c FROM ServicePoint__c LIMIT 1];
        system.debug('servPoint --> '+servPoint);
        List<HDT_WRP_MrrRequest.HDT_WRP_Field> fieldList = new List<HDT_WRP_MrrRequest.HDT_WRP_Field>();
        fieldList = createFieldsList(fieldList, '0200', 'VS2', 'A02', servPoint.Name, 'A00000000288_DL', '');
        
        HDT_WRP_HerokuPostSalesManager herokuWrapper = new HDT_WRP_HerokuPostSalesManager(fieldList);
        system.debug('herokuWrapper --> '+herokuWrapper);
        Test.startTest();

        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"status":"success","correlationId":"65d9b870-1643-11ec-9817-022a9bf2c34e","timestamp":"2021-09-15T18:38:50","data":{"testata":{"esito":"OK"},"posizioni":[{"campo":"PRESSIONE","valore":"200008867681"}]}}');
        response.setStatusCode(200);
        response.setStatus('OK');
        
        Test.setMock(HttpCalloutMock.class, new HDT_SRV_AnagAlignmentTstMock(response));

        Case cs = HDT_SRV_AnagAlignment.handleAnagAlignmentHeroku(herokuWrapper);

        System.assert(cs != null, 'cs == null');
        System.assert(cs.Id != null, 'cs.Id == null');

        Test.stopTest();
        
    }
    
    @IsTest
    static void testHandleAnagAlignmentHerokuF01(){

        ServicePoint__c servPoint = [SELECT Id, ServicePointCode__c FROM ServicePoint__c LIMIT 1];

        List<HDT_WRP_MrrRequest.HDT_WRP_Field> fieldList = new List<HDT_WRP_MrrRequest.HDT_WRP_Field>();
        fieldList = createFieldsList(fieldList,'0200','VS2', 'F01', servPoint.ServicePointCode__c,'A00000000288_DL','');
        
        HDT_WRP_HerokuPostSalesManager herokuWrapper = new HDT_WRP_HerokuPostSalesManager(fieldList);
        
        Test.startTest();

        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"status":"success","correlationId":"65d9b870-1643-11ec-9817-022a9bf2c34e","timestamp":"2021-09-15T18:38:50","data":{"testata":{"esito":"OK"},"posizioni":[{"campo":"IMPOSTE","valore":"200008867681"},{"campo":"STAMPADEL501GAS","valore":"200008867681"},{"campo":"ACCISE","valore":"200008867681"},{"campo":"CA","valore":"200008867681"},{"campo":"PRESSIONE","valore":"200008867681"},{"campo":"CALIBRO1","valore":"200008867681"},{"campo":"DESCRFATTURACOLL","valore":"200008867681"},{"campo":"OPZIONE","valore":"200008867681"},{"campo":"MOTIVOBLOCCOCALCOLO","valore":"200008867681"},{"campo":"ANNOFABBRCONT","valore":"2021"},{"campo":"DATACESSAZIONE","valore":"20210930"}]}}');
        response.setStatusCode(200);
        response.setStatus('OK');
        
        Test.setMock(HttpCalloutMock.class, new HDT_SRV_AnagAlignmentTstMock(response));

        Case cs = HDT_SRV_AnagAlignment.handleAnagAlignmentHeroku(herokuWrapper);

        System.assert(cs != null, 'cs == null');
        System.assert(cs.Id == null, 'cs.Id != null');

        Test.stopTest();
        
    }

    @IsTest
    static void testHandleResponse(){

        ServicePoint__c servPoint = [SELECT Id, ServicePointCode__c FROM ServicePoint__c LIMIT 1];
        Case currentCase = [SELECT Id, Type, ServicePoint__c,CommodityFormula__c,Commodity__c FROM Case LIMIT 1];

        Test.startTest();

        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"status":"success","correlationId":"65d9b870-1643-11ec-9817-022a9bf2c34e","timestamp":"2021-09-15T18:38:50","data":{"testata":{"esito":"OK"},"posizioni":[{"campo":"IMPOSTE","valore":"200008867681"},{"campo":"STAMPADEL501GAS","valore":"200008867681"},{"campo":"ACCISE","valore":"200008867681"},{"campo":"CA","valore":"200008867681"},{"campo":"PRESSIONE","valore":"200008867681"},{"campo":"CALIBRO1","valore":"200008867681"},{"campo":"DESCRFATTURACOLL","valore":"200008867681"},{"campo":"OPZIONE","valore":"200008867681"},{"campo":"MOTIVOBLOCCOCALCOLO","valore":"200008867681"},{"campo":"ANNOFABBRCONT","valore":"2021"},{"campo":"DATACESSAZIONE","valore":"20210930"}]}}');
        response.setStatusCode(200);
        response.setStatus('OK');
        
        Test.setMock(HttpCalloutMock.class, new HDT_SRV_AnagAlignmentTstMock(response));

        String serializedResponse = HDT_WS_ArricchimentoDatiTemp.submitRequest(servPoint.ServicePointCode__c, null);

        Case cs = HDT_UTL_DataEnrichmentPostSales.handleResponse(serializedResponse, currentCase);

        System.assert(cs != null, 'cs == null');
        System.assert(cs.Id != null, 'cs.Id == null');

        Test.stopTest();
        
    }

    @IsTest
    static void testHandleAnagAlignmentSObject(){


        Case cs = [Select Id, AccountId, ContactId, CommodityFormula__c, CausalCode__c, ServicePoint__c FROM Case LIMIT 1];

        Test.startTest();

        List<Case> results = HDT_SRV_AnagAlignment.handleAnagAlignment(cs, HDT_SRV_AnagAlignment.HDT_ENU_AnagAlignmentContext.SERVICE_CATALOG);
        System.assert(results.size() > 0, 'results.size() > 0 or results == null');

        List<Case> resVarFiscale = HDT_SRV_AnagAlignment.handleAnagAlignment(cs, HDT_SRV_AnagAlignment.HDT_ENU_AnagAlignmentContext.VARIAZIONI_FISCALE);
        System.assert(resVarFiscale.size() > 0, 'resVarFiscale.size() > 0 or resVarFiscale == null');

        Test.stopTest();
        
    }


    @IsTest
    static void testHandleAnagAlignmentSObjectVarAnagrCli(){

        Case cs = [Select Id, AccountId, ContactId, CommodityFormula__c, CausalCode__c, ServicePoint__c FROM Case LIMIT 1];

        Test.startTest();

        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"status":"success","correlationId":"65d9b870-1643-11ec-9817-022a9bf2c34e","timestamp":"2021-09-15T18:38:50","data":{"testata":{"esito":"OK"},"posizioni":[{"campo":"PRESSIONE","valore":"200008867681"}]}}');
        response.setStatusCode(200);
        response.setStatus('OK');

        Test.setMock(HttpCalloutMock.class, new HDT_SRV_AnagAlignmentTstMock(response));

        List<Case> resVarAnagraficaCli = HDT_SRV_AnagAlignment.handleAnagAlignment(cs, HDT_SRV_AnagAlignment.HDT_ENU_AnagAlignmentContext.VARIAZIONE_ANAGRAFICA_CLIENTE);
        System.assert(resVarAnagraficaCli.size() > 0, 'resVarAnagraficaCli.size() > 0 or resVarAnagraficaCli == null');

        Test.stopTest();
        
    }

    @IsTest
    static void testFindRegionalAdditional(){
        
        Test.startTest();

        HDT_QR_AnagAlignment a = new HDT_QR_AnagAlignment();

        Double result = a.findRegionalAdditional('', '', '');

        System.assertEquals(0, result, 'result != 0');

        Test.stopTest();
        
    }

    @IsTest
    static void testFindServicePointByCodeNull(){
        
        Test.startTest();

        HDT_QR_AnagAlignment a = new HDT_QR_AnagAlignment();
        ServicePoint__c srvPoint = a.findServicePointByCode('');

        System.assertEquals(null, srvPoint, 'srvPoint != null');

        Test.stopTest();
        
    }
    
        @IsTest
    static void testFindOrderByDistributorPracticeCode(){
        
        Test.startTest();

        HDT_QR_AnagAlignment a = new HDT_QR_AnagAlignment();
        Order srvPoint = a.findOrderByDistributorPracticeCode('');

        System.assertEquals(null, srvPoint, 'srvPoint != null');

        Test.stopTest();
        
    }

    @IsTest
    static void testSubmitRequestFlow(){
        
        Test.startTest();

        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"status":"success","correlationId":"65d9b870-1643-11ec-9817-022a9bf2c34e","timestamp":"2021-09-15T18:38:50","data":{"testata":{"esito":"OK"},"posizioni":[{"campo":"PRESSIONE","valore":"200008867681"}]}}');
        response.setStatusCode(200);
        response.setStatus('OK');

        Test.setMock(HttpCalloutMock.class, new HDT_SRV_AnagAlignmentTstMock(response));

        HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoFlowInputs inputs = new HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoFlowInputs();
        inputs.contractCode = 'codiceContratto';
        inputs.pod = 'podProva';

        List<HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoFlowInputs> request = new List<HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoFlowInputs>();
        request.add(inputs);

        List<String> resultsList = HDT_WS_ArricchimentoDatiTemp.submitRequestFlow(request);

        System.assert(resultsList.size() > 0, 'resultsList.size() == 0 or resultsList == null');

        Test.stopTest();
        
    }

    public class HDT_SRV_AnagAlignmentTstMock implements HttpCalloutMock{
        HttpResponse response;
        HDT_SRV_AnagAlignmentTstMock(HttpResponse r){
            response = r;
        }
        public HTTPResponse respond(HTTPRequest request) {
            return response; 
        }
    
    }

    public static List<HDT_WRP_MrrRequest.HDT_WRP_Field> createFieldsList(List<HDT_WRP_MrrRequest.HDT_WRP_Field> fieldList, String codFlusso, String codServizio, String codPrestazione, String codPresa, String codPratDistr, String reqId){

        HDT_WRP_MrrRequest.HDT_WRP_Field f1 = new HDT_WRP_MrrRequest.HDT_WRP_Field();
        HDT_WRP_MrrRequest.HDT_WRP_Field f2 = new HDT_WRP_MrrRequest.HDT_WRP_Field();
        HDT_WRP_MrrRequest.HDT_WRP_Field f3 = new HDT_WRP_MrrRequest.HDT_WRP_Field();
        HDT_WRP_MrrRequest.HDT_WRP_Field f4 = new HDT_WRP_MrrRequest.HDT_WRP_Field();
        HDT_WRP_MrrRequest.HDT_WRP_Field f5 = new HDT_WRP_MrrRequest.HDT_WRP_Field();
        HDT_WRP_MrrRequest.HDT_WRP_Field f6 = new HDT_WRP_MrrRequest.HDT_WRP_Field();

        f1.name = 'COD_FLUSSO';
        f1.value = codFlusso;
        f2.name = 'COD_SERVIZIO';
        f2.value = codServizio;
        f3.name = 'COD_PRESTAZIONE';
        f3.value = codPrestazione;
        f4.name = 'COD_PRESA';
        f4.value = codPresa;
        f5.name = 'COD_PRAT_DISTR';
        f5.value = codPratDistr;
        f6.name = 'requestId';
        f6.value = reqId;
        
        fieldList.add(f1);
        fieldList.add(f2);
        fieldList.add(f3);
        fieldList.add(f4);
        fieldList.add(f5);
        fieldList.add(f6);

        return fieldList;

    }

}