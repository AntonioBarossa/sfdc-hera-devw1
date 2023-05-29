@isTest
public with sharing class HDT_WS_InboundSolTst {
    
    @TestSetup
    static void setup(){

        HDT_UTL_DataFactoryTst.pClickCasePhase();
        HDT_UTL_DataFactoryTst.pClickOrderPhase();
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].id, 'Bozza');
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(2, true, accList[0].id);
        List<AccountContactRelation> accContRelations = new List<AccountContactRelation>();
        for (AccountContactRelation accContRelation : [SELECT id FROM AccountContactRelation WITH SECURITY_ENFORCED]){
            accContRelation.Roles = 'Other';
            accContRelations.add(accContRelation);
        }
        accContRelations[1].Roles = 'Titolare';
        update accContRelations;
        List<Pricebook2> pb = HDT_UTL_DataFactoryTst.createPricebook(1,true);
        List<Product2> productList = HDT_UTL_DataFactoryTst.createProduct2(2, false);
        productList[0].Name = 'Analisi Consumi';
        productList[0].Family = 'VAS Fatturabili';
        productList[0].ProductCode = 'VAS_AS_HERA';

        productList[1].Name = 'Prezzo Netto';
        productList[1].Family = 'Offerta commerciale';
        productList[1].ProductCode = 'PRZ_NTT';
        insert productList;


        productList  = [SELECT Id FROM Product2];
        Product2 prodOffer = [SELECT Id FROM Product2 where Family = 'Offerta commerciale'];
        pb = [SELECT Id from Pricebook2 WHERE isStandard = false LIMIT 1];
        Pricebook2 pbStandard = [SELECT Id from Pricebook2 WHERE isStandard = true LIMIT 1];
        List<PricebookEntry> pbe = HDT_UTL_DataFactoryTst.createPricebookEntry(productList, true, pb[0].Id,pbStandard.Id);
        SBQQ__ProductOption__c po = HDT_UTL_DataFactoryTst.createProductOption(productList[0].Id,productList[1].Id,true);
        List<BillingProfile__c> billingProfileList = HDT_UTL_DataFactoryTst.createBillingProfile(1,false, accList[0].Id);
        billingProfileList[0].InvoicingStreetName__c = 'Roma';
        billingProfileList[0].InvoicingStreetNumber__c = '15';
        billingProfileList[0].InvoicingStreetNumberExtension__c = '20100 ITALIA';
        billingProfileList[0].InvoicingCity__c = 'ROMA';
        billingProfileList[0].InvoicingProvince__c = 'RM';
        billingProfileList[0].InvoicingPostalCode__c = '10190';
        billingProfileList[0].InvoicingCountry__c = 'ITALIA';

        insert billingProfileList;

        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, false, accList[0].id);
        contractList[0].Status = 'Attivo';
        insert contractList;

        Contract contr = [SELECT Id FROM Contract LIMIT 1];

        List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);

        HDT_UTL_Constants constantsUtl = new HDT_UTL_Constants();
        String rtName =  constantsUtl.CASE_RECORDTYPE_DEVELOPERNAME_MOROSITA;
        String rtId = constantsUtl.CASE_RECORDTYPEID_MOROSITA;
        String rtIdOrder = constantsUtl.ORDER_RECORDTYPEID_VAS;
        String rtOrderName = constantsUtl.ORDER_RECORDTYPE_DEVELOPERNAME_VAS;
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Da Inviare', 'Bozza', rtId, rtName,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Comunicazione verso Heroku', 'Bozza', rtIdOrder, rtOrderName,'A','','','');

        SBQQ__Subscription__c subs = new SBQQ__Subscription__c(
            SBQQ__Contract__c = contr.Id, 
            SBQQ__Product__c = prodOffer.Id, 
            SBQQ__Quantity__c = 1, 
            SBQQ__Account__c = accList[0].Id,
            SBQQ__NetPrice__c = 100.2,
            SBQQ__SubscriptionEndDate__c = Date.Today());
        insert subs;

        /*SBQQ__ProductOption__c prodOption = new SBQQ__ProductOption__c();
        prodOption.SBQQ__ConfiguredSKU__c = prod.Id;
        prodOption.SBQQ__OptionalSKU__c = prod.Id;
        prodOption.SBQQ__Number__c = 1;
        prodOption.SBQQ__Quantity__c = null;
        prodOption.SBQQ__QuantityEditable__c = false;
        prodOption.SBQQ__Selected__c = false;
        prodOption.SBQQ__Feature__c = null;
        prodOption.SBQQ__Type__c = 'Component';
        insert prodOption;*/
    }

    @IsTest
    static void testGetCall(){

        Account acc = [SELECT Id FROM Account WITH SECURITY_ENFORCED LIMIT 1];
        
        //test
        Test.startTest();

        //setup for test
        RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();

        req.requestURI = 'services/apexrest/SolInboundServices';
		req.httpMethod = 'GET';
		req.params.put('ownerAccountId', acc.Id);

		RestContext.request = req;
		RestContext.response = res;

        HDT_WRP_SolContractVas result = HDT_WS_InboundSol.getContractVas();
        
        //assertions
        System.assert(result.listOfVas.size() > 0 , 'result.listOfVas.size()== 0 or result.listOfVas == null');
        
        Test.stopTest();
        
    }

    @IsTest
    static void testGetCallWithoutPermission(){
        
        //setup user without permissions
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' or Name='Utente standard'];
        User u = new User(
            Alias = 'standt', Email='standarduser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName=uniqueUserName);

        //query entity
        Account acc = [SELECT Id FROM Account WITH SECURITY_ENFORCED LIMIT 1];

        Test.startTest();
        System.runAs(u){

            //setup for test
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();

            req.requestURI = 'services/apexrest/SolInboundServices';
            req.httpMethod = 'GET';
            req.params.put('ownerAccountId', acc.Id);

            RestContext.request = req;
            RestContext.response = res;

            HDT_WRP_SolContractVas result = HDT_WS_InboundSol.getContractVas();
            
            //assertions
            System.assert(result.listOfVas.size() == 0 , 'result.listOfVas.size() > 0 or result.listOfVas == null');
        }
        Test.stopTest();
        
    }

    @IsTest
    static void testDoPostCompatibility(){

        Case cs = [SELECT Id FROM Case WITH SECURITY_ENFORCED LIMIT 1];
        
        //test
        Test.startTest();

        //setup for test
        RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();

        String reqString = '{ "method":"compatibility", "caseId":"'+ cs.Id +'", "phase":"Da Inviare" }';
        req.requestURI = 'services/apexrest/SolInboundServices';
		req.httpMethod = 'POST';
		req.requestBody = Blob.valueOf(reqString);  

		RestContext.request = req;
		RestContext.response = res;

        HDT_WS_InboundSol.doPost();
        res = RestContext.response;

        //assertions
        Case updatedCase = [SELECT Id, Phase__c FROM Case LIMIT 1];
        System.assertEquals('Da Inviare', updatedCase.Phase__c, 'Phase != Da Inviare');
        
        Test.stopTest();
        
    }

    @IsTest
    static void testDoPostInstallment(){
        
        Case cs = [SELECT Id, ContractAccountCode__c, DocumentNumber__c, BillNumber__c, AccountCode__c  FROM Case WITH SECURITY_ENFORCED LIMIT 1];
        //mock
        HttpResponse httpRes = new HttpResponse();
        httpRes.setHeader('Content-Type', 'application/json');
        httpRes.setBody('{"status":"success","correlationId":"2ded9f00-0c05-11ec-ae39-06cc66aef362","timestamp":"2021-09-02T17:48:13","prestazione":{"codCli":"1002647967","codContoContratto":"200008284449","posizioni":[{"xblnr":"500002727014","socEmittente":"1070","tipoDoc":"4C","totFattura":"32.22","residuo":"-32.22","totPagare":"-32.22","bmItemDt":"31/08/2021","bmEndDt":"20/09/2021","payment":"CLICKPAY","restituzioneCanoneRai":"0.0"},{"xblnr":"500002727014","socEmittente":"1070","tipoDoc":"4C","totFattura":"-32.0","residuo":"32.0","totPagare":"32.0","bmItemDt":"31/08/2021","bmEndDt":"20/10/2021","payment":"CLICKPAY","restituzioneCanoneRai":"-10.00"}]}}');
        httpRes.setStatusCode(200);
        httpRes.setStatus('OK');
        Test.setMock(HttpCalloutMock.class, new HDT_WS_InboundSolTstMock(httpRes));
        //test
        Test.startTest();

        //setup for test
        RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();

        String reqString = '{ "method":"installment", "caseId":"'+ cs.Id +'", "phase":"Da Inviare" }';
        req.requestURI = 'services/apexrest/SolInboundServices';
		req.httpMethod = 'POST';
		req.requestBody = Blob.valueOf(reqString);  

		RestContext.request = req;
		RestContext.response = res;

        HDT_WS_InboundSol.doPost();
        res = RestContext.response;

        //assertions
        DocumentSelected__c newDocSelected = [SELECT Id FROM DocumentSelected__c WHERE Case__c =: cs.Id LIMIT 1];
        System.assertNotEquals(null, newDocSelected, 'newDocSelected == null');
        
        Test.stopTest();
        
    }

    @IsTest
    static void testDoPostElse(){
        
        Case currentCase = [SELECT Id, PODPDRFormula__c, ContractCode__c FROM Case WITH SECURITY_ENFORCED LIMIT 1];

        //mock
        HttpResponse httpRes = new HttpResponse();
        httpRes.setHeader('Content-Type', 'application/json');
        httpRes.setBody('{"status":"success","correlationId":"65d9b870-1643-11ec-9817-022a9bf2c34e","timestamp":"2021-09-15T18:38:50","data":{"testata":{"esito":"OK"},"posizioni":[{"campo":"IMPOSTE","valore":"200008867681"},{"campo":"STAMPADEL501GAS","valore":"200008867681"},{"campo":"ACCISE","valore":"200008867681"},{"campo":"CA","valore":"200008867681"},{"campo":"PRESSIONE","valore":"200008867681"},{"campo":"CALIBRO1","valore":"200008867681"},{"campo":"DESCRFATTURACOLL","valore":"200008867681"},{"campo":"OPZIONE","valore":"200008867681"},{"campo":"MOTIVOBLOCCOCALCOLO","valore":"200008867681"},{"campo":"ANNOFABBRCONT","valore":"2021"},{"campo":"DATACESSAZIONE","valore":"20210930"}]}}');
        httpRes.setStatusCode(200);
        httpRes.setStatus('OK');
        Test.setMock(HttpCalloutMock.class, new HDT_WS_InboundSolTstMock(httpRes));
        //test
        Test.startTest();

        //setup for test
        RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();

        String reqString = '{ "method":"else", "caseId":"'+ currentCase.Id +'", "phase":"Da Inviare" }';
        req.requestURI = 'services/apexrest/SolInboundServices';
		req.httpMethod = 'POST';
		req.requestBody = Blob.valueOf(reqString);  

		RestContext.request = req;
		RestContext.response = res;

        HDT_WS_InboundSol.doPost();
        res = RestContext.response;

        //assertions
        System.assertNotEquals(null, res, 'res == null');
        Test.stopTest();
        
    }

    @isTest
    static void handleAnalisiConsumiTest(){
        Case currentCase = [SELECT Id, PODPDRFormula__c, ContractCode__c,AccountId FROM Case WITH SECURITY_ENFORCED LIMIT 1];
        Contact cont=[SELECT Id FROM Contact WHERE AccountId=:currentCase.AccountId WITH SECURITY_ENFORCED LIMIT 1];
        BillingProfile__c bill = [SELECT Id,ContractAccountCode__c from BillingProfile__c limit 1];
        //mock
        HttpResponse httpRes = new HttpResponse();
        httpRes.setHeader('Content-Type', 'application/json');
        httpRes.setBody('{"status":"success","correlationId":"65d9b870-1643-11ec-9817-022a9bf2c34e","timestamp":"2021-09-15T18:38:50","data":{"testata":{"esito":"OK"},"posizioni":[{"campo":"IMPOSTE","valore":"200008867681"},{"campo":"STAMPADEL501GAS","valore":"200008867681"},{"campo":"ACCISE","valore":"200008867681"},{"campo":"CA","valore":"200008867681"},{"campo":"PRESSIONE","valore":"200008867681"},{"campo":"CALIBRO1","valore":"200008867681"},{"campo":"DESCRFATTURACOLL","valore":"200008867681"},{"campo":"OPZIONE","valore":"200008867681"},{"campo":"MOTIVOBLOCCOCALCOLO","valore":"200008867681"},{"campo":"ANNOFABBRCONT","valore":"2021"},{"campo":"DATACESSAZIONE","valore":"20210930"}]}}');
        httpRes.setStatusCode(200);
        httpRes.setStatus('OK');
        Test.setMock(HttpCalloutMock.class, new HDT_WS_InboundSolTstMock(httpRes));
        //test
        Test.startTest();

        //setup for test
        RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();
        //Map<String,String> bdy=new Map<String,String>{'method'=>'analisiConsumi','caseId'=>'currentCase.Id','phase'=>'Da Inviare','accountId'=>currentCase.AccountId,'contactId'=>cont.Id};
        String reqString = '{ "method":"analisiConsumi", "caseId":"'+ currentCase.Id +'", "phase":"Da Inviare","accountId":"'+currentCase.AccountId+'","contactId":"'+cont.Id+'","contractAccount":"'+bill.ContractAccountCode__c+'"}';
        req.requestURI = 'services/apexrest/SolInboundServices';
		req.httpMethod = 'POST';
		req.requestBody = Blob.valueOf(reqString);  

		RestContext.request = req;
		RestContext.response = res;

        HDT_WS_InboundSol.doPost();
        res = RestContext.response;

        //assertions
        System.assertNotEquals(null, res, 'res == null');
        Test.stopTest();
    }

    /*@IsTest
    static void testAnalisiConsumiFirstCall(){
        Account acc = [SELECT Id from Account limit 1];
        Id titolareId;
        Id contactId;
        for (AccountContactRelation accContRel : [SELECT ContactId,Roles FROM AccountContactRelation WHERE AccountId = :acc.Id]){
             if ('Titolare'.equalsIgnoreCase(accContRel.Roles)){
                titolareId = accContRel.ContactId;
             }else {
                contactId = accContRel.ContactId;
             }
        }
        BillingProfile__c bill = [SELECT Id,ContractAccountCode__c from BillingProfile__c limit 1];
        Contract contr = [SELECT Id,SAPContractCode__c from Contract LIMIT 1];

        //mock
        HttpResponse httpRes = new HttpResponse();
        httpRes.setHeader('Content-Type', 'application/json');
        httpRes.setBody('{"status":"success","correlationId":"65d9b870-1643-11ec-9817-022a9bf2c34e","timestamp":"2021-09-15T18:38:50","data":{"testata":{"esito":"OK"},"posizioni":[{"campo":"IMPOSTE","valore":"200008867681"},{"campo":"STAMPADEL501GAS","valore":"200008867681"},{"campo":"ACCISE","valore":"200008867681"},{"campo":"CA","valore":"200008867681"},{"campo":"PRESSIONE","valore":"200008867681"},{"campo":"CALIBRO1","valore":"200008867681"},{"campo":"DESCRFATTURACOLL","valore":"200008867681"},{"campo":"OPZIONE","valore":"200008867681"},{"campo":"MOTIVOBLOCCOCALCOLO","valore":"200008867681"},{"campo":"ANNOFABBRCONT","valore":"2021"},{"campo":"DATACESSAZIONE","valore":"20210930"}]}}');
        httpRes.setStatusCode(200);
        httpRes.setStatus('OK');
        Test.setMock(HttpCalloutMock.class, new HDT_WS_InboundSolTstMock(httpRes));
        //test
        Test.startTest();

        //setup for test
        RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();

        String reqString = '{ "method":"analisiConsumi", "accountId":"'+ acc.Id +'", "contactId":"'+ contactId +'", "integrationId":"Integ_1", "source":"Web","contractAccount":"'+ bill.ContractAccountCode__c +'" }';
        req.requestURI = 'services/apexrest/SolInboundServices';
		req.httpMethod = 'POST';
		req.requestBody = Blob.valueOf(reqString);  

		RestContext.request = req;
		RestContext.response = res;

        HDT_WS_InboundSol.doPost();
        res = RestContext.response;
        //assertions
        System.assertNotEquals(null, res, 'res == null');
        Order ord = [SELECT Id,OrderNumber,Contact__c FROM Order where Sale__c != null limit 1];
        //System.assert(titolareId != ord.Contact__c,'Contatto settato non corretto');
        Order ord2 = [SELECT Id,OrderNumber FROM Order where Sale__c = null];
        delete ord2;
        reqString = '{ "numeroOccupanti":"1", "superficie":"40", "tipologiaAbitazione":"Appartamento", "proprietario":"Si","method":"analisiConsumi", "accountId":"'+ acc.Id +'", "contactId":"'+ contactId +'", "integrationId":"Integ_1", "serviceRequest":"'+ ord.OrderNumber +'","contractNumber":"'+ contr.SAPContractCode__c +'" }';
        req.requestURI = 'services/apexrest/SolInboundServices';
		req.httpMethod = 'POST';
		req.requestBody = Blob.valueOf(reqString);  

		RestContext.request = req;
		RestContext.response = res;

        HDT_WS_InboundSol.doPost();
        res = RestContext.response;
        Test.stopTest();
    }*/
    
    public class HDT_WS_InboundSolTstMock implements HttpCalloutMock{

        HttpResponse response = new HttpResponse();

        public HDT_WS_InboundSolTstMock(HttpResponse res){
            this.response = res;
        }
        public HttpResponse respond(HTTPRequest req){
            
            return response;

        }
    }

}