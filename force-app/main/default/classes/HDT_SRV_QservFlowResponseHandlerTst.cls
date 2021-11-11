@isTest
public with sharing class HDT_SRV_QservFlowResponseHandlerTst {
    
    @TestSetup
    static void setup(){
        
        List<Account> accList  = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].id);
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true); 
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].id);
        List<Order> ordListInc = HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].Id, 'Bozza');
		List<Case> listCase =  HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].Id, contactList[0].Id, servPointList[0].Id, contractList[0].Id, ordListInc[0].Id);
        HDT_UTL_DataFactoryTst.pClickCasePhase();

        HDT_UTL_Constants constantsUtl = new HDT_UTL_Constants();
        String rtName = 'HDT_RT_GenericheAttivazioni';
        String rtId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_GenericheAttivazioni').getRecordTypeId();
    }

    @IsTest
    static void testFlowRequestHandler(){

        //setup
        Case currentCase = [SELECT PODPdrFormula__c, AccountFiscalCodeFormula__c, CaseNumber, Description, DiscardDescription__c, VatNumber__c FROM Case WITH SECURITY_ENFORCED LIMIT 1];

        //mock webservice call

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"responses":[{"header":{"requestId":"","requestTimestamp":null,"requestType":"CREA_RIC","fields":[{"fieldType":"TEXT","name":"PROCESS_CATEGORY","value":"postsales"}]},"code":null,"description":null,"objects":[{"fields":[{"fieldType":"TEXT","name":"ANNOTAZIONI","value":"PROVA_NEW_FLOW"},{"fieldType":"TEXT","name":"result","value":"OK"},{"fieldType":"TEXT","name":"requestId","value":""},{"fieldType":"TEXT","name":"errorMessage","value":""},{"fieldType":"TEXT","name":"rifRich","value":"00002349"},{"fieldType":"TEXT","name":"RECORD_ID","value":""},{"fieldType":"TEXT","name":"FASE","value":"Esito OK da DL"},{"fieldType":"TEXT","name":"DES_ERR_AEEG","value":"001"}],"id":null,"name":null,"objectType":null,"objects":null}]}]}');
        res.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, new HDT_SRV_QservHandlerMock(res));
        
        //start test
        Test.startTest();

        List<HDT_SRV_QservHandler.HDT_SRV_FlowInputRequest> inputs = new List<HDT_SRV_QservHandler.HDT_SRV_FlowInputRequest>();
        HDT_SRV_QservHandler.HDT_SRV_FlowInputRequest input = new HDT_SRV_QservHandler.HDT_SRV_FlowInputRequest();
        input.currentCase = currentCase;
        inputs.add(input);

        List<String> resultList = HDT_SRV_QservHandler.flowRequestHandler(inputs);

        //assert
        System.assert(resultList.size() > 0, 'resultList.size() = 0 or resultList = null');

        Test.stopTest();
        
    }

    @IsTest
    static void testFlowResponseHandler(){
        
        //setup
        String response = '{"responses":[{"objects":[{"objectType":null,"objects":null,"name":null,"id":null,"fields":[{"value":"PROVA_NEW_FLOW","rds":null,"rdo":null,"name":"ANNOTAZIONI","fieldType":"TEXT"},{"value":"OK","rds":null,"rdo":null,"name":"result","fieldType":"TEXT"},{"value":"","rds":null,"rdo":null,"name":"requestId","fieldType":"TEXT"},{"value":"","rds":null,"rdo":null,"name":"errorMessage","fieldType":"TEXT"},{"value":"00002349","rds":null,"rdo":null,"name":"rifRich","fieldType":"TEXT"},{"value":"","rds":null,"rdo":null,"name":"RECORD_ID","fieldType":"TEXT"},{"value":"Esito OK da DL","rds":null,"rdo":null,"name":"FASE","fieldType":"TEXT"},{"value":"001","rds":null,"rdo":null,"name":"DES_ERR_AEEG","fieldType":"TEXT"}]}],"header":{"requestType":"CREA_RIC","requestTimeStamp":null,"requestId":"","fields":[{"value":"postsales","rds":null,"rdo":null,"name":"PROCESS_CATEGORY","fieldType":"TEXT"}]},"description":null,"code":null}]}';
        Case currentCase = [SELECT PODPdrFormula__c, AccountFiscalCodeFormula__c, CaseNumber, Description, DiscardDescription__c, VatNumber__c FROM Case WITH SECURITY_ENFORCED LIMIT 1];

        //start test
        Test.startTest();

        List<HDT_SRV_QservFlowResponseHandler.HDT_SRV_FlowInputResponse> inputs = new List<HDT_SRV_QservFlowResponseHandler.HDT_SRV_FlowInputResponse>();
        HDT_SRV_QservFlowResponseHandler.HDT_SRV_FlowInputResponse input = new HDT_SRV_QservFlowResponseHandler.HDT_SRV_FlowInputResponse();
        input.currentCase = currentCase;
        input.deserializedResponse = response;
        inputs.add(input);

        HDT_SRV_QservFlowResponseHandler.flowResponseHandler(inputs);

        Test.stopTest();

        //assert
        Case updatedCase = [SELECT Description FROM Case WITH SECURITY_ENFORCED LIMIT 1];
        System.assertEquals('PROVA_NEW_FLOW', updatedCase.Description, 'Description != PROVA_NEW_FLOW');
        
    }

    @IsTest
    static void testFlowResponseHandlerKo(){
        
        //setup
        String response = '{"responses":[{"objects":[{"objectType":null,"objects":null,"name":null,"id":null,"fields":[{"value":"PROVA_NEW_FLOW","rds":null,"rdo":null,"name":"ANNOTAZIONI","fieldType":"TEXT"},{"value":"OK","rds":null,"rdo":null,"name":"result","fieldType":"TEXT"},{"value":"","rds":null,"rdo":null,"name":"requestId","fieldType":"TEXT"},{"value":"","rds":null,"rdo":null,"name":"errorMessage","fieldType":"TEXT"},{"value":"00002349","rds":null,"rdo":null,"name":"rifRich","fieldType":"TEXT"},{"value":"","rds":null,"rdo":null,"name":"RECORD_ID","fieldType":"TEXT"},{"value":"Esito KO da DL","rds":null,"rdo":null,"name":"FASE","fieldType":"TEXT"},{"value":"001","rds":null,"rdo":null,"name":"DES_ERR_AEEG","fieldType":"TEXT"}]}],"header":{"requestType":"CREA_RIC","requestTimeStamp":null,"requestId":"","fields":[{"value":"postsales","rds":null,"rdo":null,"name":"PROCESS_CATEGORY","fieldType":"TEXT"}]},"description":null,"code":null}]}';
        Case currentCase = [SELECT PODPdrFormula__c, AccountFiscalCodeFormula__c, CaseNumber, Description, DiscardDescription__c, VatNumber__c FROM Case WITH SECURITY_ENFORCED LIMIT 1];

        //start test
        Test.startTest();

        List<HDT_SRV_QservFlowResponseHandler.HDT_SRV_FlowInputResponse> inputs = new List<HDT_SRV_QservFlowResponseHandler.HDT_SRV_FlowInputResponse>();
        HDT_SRV_QservFlowResponseHandler.HDT_SRV_FlowInputResponse input = new HDT_SRV_QservFlowResponseHandler.HDT_SRV_FlowInputResponse();
        input.currentCase = currentCase;
        input.deserializedResponse = response;
        inputs.add(input);

        HDT_SRV_QservFlowResponseHandler.flowResponseHandler(inputs);

        Test.stopTest();

        //assert
        Case updatedCase = [SELECT Description FROM Case WITH SECURITY_ENFORCED LIMIT 1];
        System.assertEquals(null, updatedCase.Description, 'Description != ');
        
    }

    @IsTest
    static void testFlowResponseHandlerError(){

        //setup
        String response = '{"responses":[{"objects":[{"objectType":null,"objects":null,"name":null,"id":null,"fields":[{"value":"PROVA_NEW_FLOW","rds":null,"rdo":null,"name":"ANNOTAZIONI","fieldType":"TEXT"},{"value":"OK","rds":null,"rdo":null,"name":"result","fieldType":"TEXT"},{"value":"","rds":null,"rdo":null,"name":"requestId","fieldType":"TEXT"},{"value":"","rds":null,"rdo":null,"name":"errorMessage","fieldType":"TEXT"},{"value":"00002349","rds":null,"rdo":null,"name":"rifRich","fieldType":"TEXT"},{"value":"","rds":null,"rdo":null,"name":"RECORD_ID","fieldType":"TEXT"},{"value":"Esito KO da DL","rds":null,"rdo":null,"name":"FASE","fieldType":"TEXT"},{"value":"001","rds":null,"rdo":null,"name":"DES_ERR_AEEG","fieldType":"TEXT"}]}],"header":{"requestType":"CREA_RIC","requestTimeStamp":null,"requestId":"","fields":[{"value":"postsales","rds":null,"rdo":null,"name":"PROCESS_CATEGORY","fieldType":"TEXT"}]},"description":null,"code":null}]}';
        
        //start test
        Test.startTest();

        List<HDT_SRV_QservFlowResponseHandler.HDT_SRV_FlowInputResponse> inputs = new List<HDT_SRV_QservFlowResponseHandler.HDT_SRV_FlowInputResponse>();
        HDT_SRV_QservFlowResponseHandler.HDT_SRV_FlowInputResponse input = new HDT_SRV_QservFlowResponseHandler.HDT_SRV_FlowInputResponse();
        input.currentCase = null;
        input.deserializedResponse = response;
        inputs.add(input);

        try {
            HDT_SRV_QservFlowResponseHandler.flowResponseHandler(inputs);
        } catch (Exception e) {
            //assert
            System.assertNotEquals(null, e.getMessage(), 'Exception expected');
        }

        Test.stopTest();
        
    }


}
