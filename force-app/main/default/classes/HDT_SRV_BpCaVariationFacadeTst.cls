@isTest
public class HDT_SRV_BpCaVariationFacadeTst {
    
    @TestSetup
    static void setup(){

        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(2, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].id, 'Bozza');
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].Id);
        List<BillingProfile__c> billingProfileList = HDT_UTL_DataFactoryTst.createBillingProfile(1,true, accList[0].Id);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].id);
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCaseDocumentale(3, false, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);
        caseList[0].BillingProfile__c = billingProfileList[0].Id;
        caseList[0].XMLType__c = 'Sintetico';
        caseList[0].ElectronicInvoicingMethod__c = 'XML PA';
        caseList[1].BillingProfile__c = billingProfileList[0].Id;
        caseList[1].XMLType__c = 'Dettaglio';
        caseList[1].ElectronicInvoicingMethod__c = 'XML';
        caseList[2].BillingProfile__c = billingProfileList[0].Id;
        caseList[2].XMLType__c = '';
        caseList[2].VatNumber__c = '35435345331';
        caseList[2].VATGroup__c = '35435345331';
        caseList[2].VATGroupStartDate__c = Date.today();
        caseList[2].VATGroupEndDate__c = Date.today();
        insert caseList;

        HDT_UTL_DataFactoryTst.pClickCasePhase();

        HDT_UTL_Constants constantsUtl = new HDT_UTL_Constants();
        String rtName = constantsUtl.CASE_RECORDTYPE_DEVELOPERNAME_DOCUMENTALECOPIACONTRATTO;
        String rtId = constantsUtl.CASE_RECORDTYPEID_DOCUMENTALECOPIACONTRATTO;
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'In attesa Documentazione', 'Bozza', rtId, rtName,'A','','','');
    }

    @IsTest
    static void testExecutionFromFlow(){

        Case cs = [SELECT Id FROM Case LIMIT 1];
        
        Test.startTest();

        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"status":"success","correlationId":"65d9b870-1643-11ec-9817-022a9bf2c34e","timestamp":"2021-09-15T18:38:50","data":{"commenti":"KO","contoContrattuale":"200010530499","classeConto":"Z001","codiceCliente":"1002732959","societa":"HeraCommS.p.A.","dataEmissione":"31/08/2021","dataScadenza":"20/01/2022","podPdr":"IT001E56328467","importo":"0.0","residuo":"17.0","modalitaPagamento":"bollettinopostale","documento":"500002727012","bloccoAlSollecito":"B-PG-BLOCCOAVVISORICEVUTODALCL.AVVENUTOPAG","tipoDocumento":"RATE","contratto":"3020211479","settoreMerceologico":"Energiaelettrica","tipoTransazione":"EC1","idPrimoLivelloSAP":"00000000000000000000000000000000000000000000000001","oraIncassoRealTime":"00:00:00","loginId":"0-1"}}');
        response.setStatusCode(200);
        response.setStatus('OK');

        Test.setMock(HttpCalloutMock.class, new HDT_SRV_BpCaVariationFacadeTstMock(response));

        List<HDT_SRV_BpCaVariationFacade.HDT_WRP_InputBpCaFlow> inputsList = new List<HDT_SRV_BpCaVariationFacade.HDT_WRP_InputBpCaFlow>();
        HDT_SRV_BpCaVariationFacade.HDT_WRP_InputBpCaFlow inputs = new HDT_SRV_BpCaVariationFacade.HDT_WRP_InputBpCaFlow();
        inputs.recordId = cs.Id;
        inputsList.add(inputs);

        List<HDT_SRV_BpCaVariationFacade.HDT_WRP_OutputBpCaFlow> resultList = HDT_SRV_BpCaVariationFacade.executeFromFlow(inputsList);

        System.assert(resultList.size() > 0, 'resultList.size() == 0 or resultList == null');

        Test.stopTest();
        
    }

    public class HDT_SRV_BpCaVariationFacadeTstMock implements HttpCalloutMock{
        HttpResponse response;
        HDT_SRV_BpCaVariationFacadeTstMock(HttpResponse r){
            response = r;
        }
        public HTTPResponse respond(HTTPRequest request) {
            return response; 
        }
    
    }

    @IsTest
    static void testExecute(){

        Test.startTest();

        Case currentCase = [SELECT Id FROM Case LIMIT 1];

        Object obj = (Object) createArgs('HDT_InstallmentPlans', currentCase, 'MA3Disattivazioni');

        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"status":"success","correlationId":"65d9b870-1643-11ec-9817-022a9bf2c34e","timestamp":"2021-09-15T18:38:50","data":{"commenti":"KO","contoContrattuale":"200010530499","classeConto":"Z001","codiceCliente":"1002732959","societa":"HeraCommS.p.A.","dataEmissione":"31/08/2021","dataScadenza":"20/01/2022","podPdr":"IT001E56328467","importo":"0.0","residuo":"17.0","modalitaPagamento":"bollettinopostale","documento":"500002727012","bloccoAlSollecito":"B-PG-BLOCCOAVVISORICEVUTODALCL.AVVENUTOPAG","tipoDocumento":"RATE","contratto":"3020211479","settoreMerceologico":"Energiaelettrica","tipoTransazione":"EC1","idPrimoLivelloSAP":"00000000000000000000000000000000000000000000000001","oraIncassoRealTime":"00:00:00","loginId":"0-1","tipoAttivita":"Errore cons. eBSM"}}');
        response.setStatusCode(200);
        response.setStatus('OK');

        Test.setMock(HttpCalloutMock.class, new HDT_SRV_BpCaVariationFacadeTstMock(response));

        HDT_SRV_BpCaVariationFacade c = new HDT_SRV_BpCaVariationFacade();
        Object result = c.execute(obj);

        wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse resultObject = (wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse) result;

        System.assert(resultObject != null, 'result == null');
        System.assertEquals(true, resultObject.success, 'result.success != true');
        System.assertEquals('OK', resultObject.message, 'result.message != ok');
        
        Test.stopTest();
        
    }

    @IsTest
    static void testExecuteWithPraticaGestita(){

        Test.startTest();

        Case currentCase = [SELECT Id FROM Case LIMIT 1];

        Object obj = (Object) createArgs('HDT_InstallmentPlans', currentCase, 'MA3ModAnagrafiche');

        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"status":"success","correlationId":"65d9b870-1643-11ec-9817-022a9bf2c34e","timestamp":"2021-09-15T18:38:50","data":{"commenti":"KO","contoContrattuale":"200010530499","classeConto":"Z001","codiceCliente":"1002732959","societa":"HeraCommS.p.A.","dataEmissione":"31/08/2021","dataScadenza":"20/01/2022","podPdr":"IT001E56328467","importo":"0.0","residuo":"17.0","modalitaPagamento":"bollettinopostale","documento":"500002727012","bloccoAlSollecito":"B-PG-BLOCCOAVVISORICEVUTODALCL.AVVENUTOPAG","tipoDocumento":"RATE","contratto":"3020211479","settoreMerceologico":"Energiaelettrica","tipoTransazione":"EC1","idPrimoLivelloSAP":"00000000000000000000000000000000000000000000000001","oraIncassoRealTime":"00:00:00","loginId":"0-1","tipoAttivita":"Pratica gestita"}}');
        response.setStatusCode(200);
        response.setStatus('OK');

        Test.setMock(HttpCalloutMock.class, new HDT_SRV_BpCaVariationFacadeTstMock(response));

        HDT_SRV_BpCaVariationFacade c = new HDT_SRV_BpCaVariationFacade();
        Object result = c.execute(obj);

        wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse resultObject = (wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse) result;

        System.assert(resultObject != null, 'result == null');
        System.assertEquals(true, resultObject.success, 'result.success != false');
        System.assertEquals('OK', resultObject.message, 'result.message != KO');

        System.assert(result != null, 'result == null');
        
        Test.stopTest();
        
    }

    @IsTest
    static void testExecuteWithoutCommenti(){

        Test.startTest();

        Case currentCase = [SELECT Id FROM Case LIMIT 1];

        Object obj = (Object) createArgs('HDT_InstallmentPlans', currentCase, 'MA2DatiFiscali');

        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"status":"success","correlationId":"65d9b870-1643-11ec-9817-022a9bf2c34e","timestamp":"2021-09-15T18:38:50","data":{"contoContrattuale":"200010530499","classeConto":"Z001","codiceCliente":"1002732959","societa":"HeraCommS.p.A.","dataEmissione":"31/08/2021","dataScadenza":"20/01/2022","podPdr":"IT001E56328467","importo":"0.0","residuo":"17.0","modalitaPagamento":"bollettinopostale","documento":"500002727012","bloccoAlSollecito":"B-PG-BLOCCOAVVISORICEVUTODALCL.AVVENUTOPAG","tipoDocumento":"RATE","contratto":"3020211479","settoreMerceologico":"Energiaelettrica","tipoTransazione":"EC1","idPrimoLivelloSAP":"00000000000000000000000000000000000000000000000001","oraIncassoRealTime":"00:00:00","loginId":"0-1","tipoAttivita":"Pratica gestita"}}');
        response.setStatusCode(200);
        response.setStatus('OK');

        Test.setMock(HttpCalloutMock.class, new HDT_SRV_BpCaVariationFacadeTstMock(response));

        HDT_SRV_BpCaVariationFacade c = new HDT_SRV_BpCaVariationFacade();
        Object result = c.execute(obj);

        wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse resultObject = (wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse) result;

        System.assert(resultObject != null, 'result == null');
        System.assertEquals(true, resultObject.success, 'result.success != false');
        System.assertEquals('OK', resultObject.message, 'result.message != KO');
        
        Test.stopTest();
        
    }

    @IsTest
    static void testExecuteWithGruppoIva(){

        Test.startTest();

        Case currentCase = [SELECT Id FROM Case WHERE VatNumber__c <> '' LIMIT 1];

        Object obj = (Object) createArgs('HDT_InstallmentPlans', currentCase, 'GruppoIva');

        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"status":"success","correlationId":"65d9b870-1643-11ec-9817-022a9bf2c34e","timestamp":"2021-09-15T18:38:50","data":{"commenti":"KO","contoContrattuale":"200010530499","classeConto":"Z001","codiceCliente":"1002732959","societa":"HeraCommS.p.A.","dataEmissione":"31/08/2021","dataScadenza":"20/01/2022","podPdr":"IT001E56328467","importo":"0.0","residuo":"17.0","modalitaPagamento":"bollettinopostale","documento":"500002727012","bloccoAlSollecito":"B-PG-BLOCCOAVVISORICEVUTODALCL.AVVENUTOPAG","tipoDocumento":"RATE","contratto":"3020211479","settoreMerceologico":"Energiaelettrica","tipoTransazione":"EC1","idPrimoLivelloSAP":"00000000000000000000000000000000000000000000000001","oraIncassoRealTime":"00:00:00","loginId":"0-1","tipoAttivita":"Pratica gestita"}}');
        response.setStatusCode(200);
        response.setStatus('OK');

        Test.setMock(HttpCalloutMock.class, new HDT_SRV_BpCaVariationFacadeTstMock(response));

        HDT_SRV_BpCaVariationFacade c = new HDT_SRV_BpCaVariationFacade();
        Object result = c.execute(obj);

        wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse resultObject = (wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse) result;

        System.assert(resultObject != null, 'result == null');
        System.assertEquals(true, resultObject.success, 'result.success != false');
        System.assertEquals('OK', resultObject.message, 'result.message != KO');
        
        Test.stopTest();
        
    }

    @IsTest
    static void testExecuteWithCambioAmministratore(){

        Test.startTest();

        Case currentCase = [SELECT Id FROM Case WHERE XMLType__c = '' LIMIT 1];

        Object obj = (Object) createArgs('HDT_InstallmentPlans', currentCase, 'CambioAmministratore');

        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"status":"success","correlationId":"65d9b870-1643-11ec-9817-022a9bf2c34e","timestamp":"2021-09-15T18:38:50","data":{"commenti":"KO","contoContrattuale":"200010530499","classeConto":"Z001","codiceCliente":"1002732959","societa":"HeraCommS.p.A.","dataEmissione":"31/08/2021","dataScadenza":"20/01/2022","podPdr":"IT001E56328467","importo":"0.0","residuo":"17.0","modalitaPagamento":"bollettinopostale","documento":"500002727012","bloccoAlSollecito":"B-PG-BLOCCOAVVISORICEVUTODALCL.AVVENUTOPAG","tipoDocumento":"RATE","contratto":"3020211479","settoreMerceologico":"Energiaelettrica","tipoTransazione":"EC1","idPrimoLivelloSAP":"00000000000000000000000000000000000000000000000001","oraIncassoRealTime":"00:00:00","loginId":"0-1","tipoAttivita":"Pratica gestita"}}');
        response.setStatusCode(200);
        response.setStatus('OK');

        Test.setMock(HttpCalloutMock.class, new HDT_SRV_BpCaVariationFacadeTstMock(response));

        HDT_SRV_BpCaVariationFacade c = new HDT_SRV_BpCaVariationFacade();
        Object result = c.execute(obj);

        wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse resultObject = (wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse) result;

        System.assert(resultObject != null, 'result == null');
        System.assertEquals(true, resultObject.success, 'result.success != false');
        System.assertEquals('OK', resultObject.message, 'result.message != KO');
        
        Test.stopTest();
        
    }

    @IsTest
    static void testExecuteWithIndirizzoAmministratore(){

        Test.startTest();

        Case currentCase = [SELECT Id FROM Case WHERE XMLType__c = 'Dettaglio' LIMIT 1];

        Object obj = (Object) createArgs('HDT_InstallmentPlans', currentCase, 'IndirizzoAmministratore');

        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"status":"success","correlationId":"65d9b870-1643-11ec-9817-022a9bf2c34e","timestamp":"2021-09-15T18:38:50","data":{"commenti":"KO","contoContrattuale":"200010530499","classeConto":"Z001","codiceCliente":"1002732959","societa":"HeraCommS.p.A.","dataEmissione":"31/08/2021","dataScadenza":"20/01/2022","podPdr":"IT001E56328467","importo":"0.0","residuo":"17.0","modalitaPagamento":"bollettinopostale","documento":"500002727012","bloccoAlSollecito":"B-PG-BLOCCOAVVISORICEVUTODALCL.AVVENUTOPAG","tipoDocumento":"RATE","contratto":"3020211479","settoreMerceologico":"Energiaelettrica","tipoTransazione":"EC1","idPrimoLivelloSAP":"00000000000000000000000000000000000000000000000001","oraIncassoRealTime":"00:00:00","loginId":"0-1","tipoAttivita":"Pratica gestita"}}');
        response.setStatusCode(200);
        response.setStatus('OK');

        Test.setMock(HttpCalloutMock.class, new HDT_SRV_BpCaVariationFacadeTstMock(response));

        HDT_SRV_BpCaVariationFacade c = new HDT_SRV_BpCaVariationFacade();
        Object result = c.execute(obj);

        wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse resultObject = (wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse) result;

        System.assert(resultObject != null, 'result == null');
        System.assertEquals(true, resultObject.success, 'result.success != false');
        System.assertEquals('OK', resultObject.message, 'result.message != KO');
        
        Test.stopTest();
        
    }

    @IsTest
    static void testExecuteWithMA3DisattivazioniDettaglio(){

        Test.startTest();

        Case currentCase = [SELECT Id FROM Case WHERE XMLType__c = 'Dettaglio' LIMIT 1];

        Object obj = (Object) createArgs('HDT_InstallmentPlans', currentCase, 'MA3Disattivazioni');

        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"status":"success","correlationId":"65d9b870-1643-11ec-9817-022a9bf2c34e","timestamp":"2021-09-15T18:38:50","data":{"commenti":"KO","contoContrattuale":"200010530499","classeConto":"Z001","codiceCliente":"1002732959","societa":"HeraCommS.p.A.","dataEmissione":"31/08/2021","dataScadenza":"20/01/2022","podPdr":"IT001E56328467","importo":"0.0","residuo":"17.0","modalitaPagamento":"bollettinopostale","documento":"500002727012","bloccoAlSollecito":"B-PG-BLOCCOAVVISORICEVUTODALCL.AVVENUTOPAG","tipoDocumento":"RATE","contratto":"3020211479","settoreMerceologico":"Energiaelettrica","tipoTransazione":"EC1","idPrimoLivelloSAP":"00000000000000000000000000000000000000000000000001","oraIncassoRealTime":"00:00:00","loginId":"0-1","tipoAttivita":"Pratica gestita"}}');
        response.setStatusCode(200);
        response.setStatus('OK');

        Test.setMock(HttpCalloutMock.class, new HDT_SRV_BpCaVariationFacadeTstMock(response));

        HDT_SRV_BpCaVariationFacade c = new HDT_SRV_BpCaVariationFacade();
        Object result = c.execute(obj);

        wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse resultObject = (wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse) result;

        System.assert(resultObject != null, 'result == null');
        System.assertEquals(true, resultObject.success, 'result.success != false');
        System.assertEquals('OK', resultObject.message, 'result.message != KO');
        
        Test.stopTest();
        
    }

    @IsTest
    static void testExecuteWithDatiContatto(){

        Test.startTest();

        Case currentCase = [SELECT Id FROM Case WHERE XMLType__c = 'Sintetico' LIMIT 1];

        Object obj = (Object) createArgs('HDT_InstallmentPlans', currentCase, 'DatiContatto');

        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"status":"success","correlationId":"65d9b870-1643-11ec-9817-022a9bf2c34e","timestamp":"2021-09-15T18:38:50","data":{"commenti":"KO","contoContrattuale":"200010530499","classeConto":"Z001","codiceCliente":"1002732959","societa":"HeraCommS.p.A.","dataEmissione":"31/08/2021","dataScadenza":"20/01/2022","podPdr":"IT001E56328467","importo":"0.0","residuo":"17.0","modalitaPagamento":"bollettinopostale","documento":"500002727012","bloccoAlSollecito":"B-PG-BLOCCOAVVISORICEVUTODALCL.AVVENUTOPAG","tipoDocumento":"RATE","contratto":"3020211479","settoreMerceologico":"Energiaelettrica","tipoTransazione":"EC1","idPrimoLivelloSAP":"00000000000000000000000000000000000000000000000001","oraIncassoRealTime":"00:00:00","loginId":"0-1","tipoAttivita":"Pratica gestita"}}');
        response.setStatusCode(200);
        response.setStatus('OK');

        Test.setMock(HttpCalloutMock.class, new HDT_SRV_BpCaVariationFacadeTstMock(response));

        HDT_SRV_BpCaVariationFacade c = new HDT_SRV_BpCaVariationFacade();
        Object result = c.execute(obj);

        wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse resultObject = (wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse) result;

        System.assert(resultObject != null, 'result == null');
        System.assertEquals(true, resultObject.success, 'result.success != false');
        System.assertEquals('OK', resultObject.message, 'result.message != KO');
        
        Test.stopTest();
        
    }

    @IsTest
    static void getGenericRecords(){

        Case cs = [SELECT Id FROM Case WITH SECURITY_ENFORCED LIMIT 1];
        
        String fields = 'Id,Account.CustomerCode__c,CaseNumber,XMLType__c,ElectronicInvoiceCertifiedEmailAddress__c,OfficeSubjectCode__c,ElectronicInvoicingMethod__c, CareOf__c,BillSendingMethod__c,InvoiceEmail__c,InvoiceCertifiedEmailAddress__c,BillingProfile__r.ContractAccountCode__c, InvoicingCity__c, InvoicingCityCode__c, InvoicingCountry__c, InvoicingPlace__c, InvoicingPostalCode__c, InvoicingProvince__c, InvoicingStreetCode__c, InvoicingStreetName__c, InvoicingStreetNumber__c, InvoicingStreetNumberExtension__c ,IsInvoicingVerified__c';
        String objectName = 'Case';
        String conditions = 'Id = \''+cs.Id+'\'';

        Test.startTest();

        List<sObject> sObjectList = HDT_QR_GenericQuery.getGenericRecords(fields, objectName, conditions);

        System.assert(sObjectList.size() > 0, 'sObjectList.size() == 0 or sObjectList == null');

        Test.stopTest();
        
    }

    //al momento il metodo updateFuture sulla classe HDT_SRV_BpCaVariationFacade è private, capire se si può impostare public in modo da coprire anche quelle righe
    // @IsTest
    // static void testFutureUpdate(){

    //     Case currentCase = [SELECT Id, TecnicalPhase__c FROM Case LIMIT 1];
    //     System.debug('TecnicalPhase__c Before Update: ' + currentCase.TecnicalPhase__c);
        
    //     currentCase.TecnicalPhase__c = 'Esito OK da SAP';
        
    //     Test.startTest();

    //     String serializedCase = JSON.serialize(currentCase);

    //     HDT_SRV_BpCaVariationFacade.updateFuture(serializedCase);

    //     Case caseAfter = [SELECT Id, TecnicalPhase__c FROM Case LIMIT 1];

    //     System.debug('TecnicalPhase__c After Update: ' + caseAfter.TecnicalPhase__c);
    //     System.assertEquals('Esito OK da SAP', caseAfter.TecnicalPhase__c, 'Errore in fase di aggiornamento del Record');
        
    //     Test.stopTest();
        
    // }

    //metodo che crea gli argomenti da passare al method execute della classe HDT_SRV_BpCaVariationFacade
    public static Map<String, Object> createArgs (String method, Case currentCase, String requestType){

        String methodUsed = method;
        Map<String, Object> args = new Map<String,Object>();

        Map<String,String> params = new Map<String,String>();
        params.put('requestType', requestType);
        Object parameters = (Object) params;

        Case newCase = new Case();
        newCase.Id = currentCase.Id;
        args.put('method',methodUsed);
        args.put('sender', currentCase);
        args.put('parameters', parameters);

        return args;

    }

}
