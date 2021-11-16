/**
 * @author Luca Molino (luca.molino@dunegroup.it)
 * @date 07/10/2021
 * @description HDT_SRV_SalesManager test Class
 * @history Luca Molino – 07/10/2021 – Created Class
 */
@isTest
public class HDT_SRV_SalesManagerTst {

    private static HDT_SRV_SalesManager srvSalesManager = new HDT_SRV_SalesManager();
    private static HDT_UTL_Constants utlConstants = new HDT_UTL_Constants();
    
    public class HDT_WS_VasServiceMock implements HTTPCalloutMock {

        private final Integer SUCCESS_CODE = 201;
        private final String SUCCESS_BODY = '{"statusCode":201,"status":"success","exceptionMessage":null,"errorDetails":null,"body":null,"timestamp":"2021-11-05T12:47:32","data":null,"correlationId":"292ceab0-3e2e-11ec-81bb-0263debc6266"}';

        private final Integer ERROR_CODE = 502;
        private final String ERROR_BODY = '{"statusCode":502,"status":"failed","exceptionMessage":null,"errorDetails":[{"message":"Cod. offerta non mappato. Verifica custom","code":"BAD_GATEWAY","additionalInfo":"HTTP POST on resource ... failed with status code 502."}],"body":null,"timestamp":"2021-10-26T15:42:56","data":null,"correlationId":"a02866e0-3662-11ec-81bb-0263debc6266"}';

        private Boolean isSuccess;

        public HDT_WS_VasServiceMock(Boolean isSuccess) {
            this.isSuccess = isSuccess;
        }

        public HTTPResponse respond(HTTPRequest request){
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            if (isSuccess) {
                response.setStatusCode(SUCCESS_CODE);
                response.setBody(SUCCESS_BODY);
            }
            else {
                response.setStatusCode(ERROR_CODE);
                response.setBody(ERROR_BODY);
            }
            return response;
        }
    }

    @testSetup
    public static void setup(){

        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(utlConstants.HERA_SYSTEM_ADMINISTRATOR_NAME);
 
        User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
    
        internalUser.UserPermissionsMarketingUser=true;
    
        insert internalUser;  
        System.runAs(internalUser){
            List<Account> accounts=HDT_UTL_DataFactoryTst.createAccountBusiness(1, false, 'HERA COMM', 'Azienda', 'Aziende SME');
            accounts[0].ActiveMonitoring__c=false;
            accounts[0].Name='INRETE DIST. ENER.-13R0000000';
            accounts[0].LastName__c='INRETE DIST. ENER.-13R0000000';
            insert accounts;

            List<Contact> contacts = HDT_UTL_DataFactoryTst.createContact(1, true, accounts[0].Id);

            List<Order> orders = HDT_UTL_DataFactoryTst.createOrder(1, false, accounts[0].Id, 'Bozza');
            orders[0].RecordTypeId = utlConstants.ORDER_RECORDTYPEID_VAS;
			orders[0].EffectiveDate = Date.today();
            orders[0].Contact__c = contacts[0].Id;
            insert orders;

            List<Contact> contact = HDT_UTL_DataFactoryTst.createContact(1,true,accounts[0].Id);
            List<ServicePoint__c> spList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
            List<Contract> contract = HDT_UTL_DataFactoryTst.createContract(1, true, accounts[0].Id);

            List<Case> cases = HDT_UTL_DataFactoryTst.createCase(1, false, accounts[0].Id,contact[0].Id,spList[0].Id,contract[0].Id,orders[0].Id);
            cases[0].RecordTypeId = utlConstants.CASE_RECORDTYPEID_POST_SALES_VAS;
            cases[0].Order__c = orders[0].Id;
            insert cases;
            
            HDT_UTL_DataFactoryTst.pClickInstance();
            HDT_UTL_DataFactoryTst.pClickOrderPhase();
            HDT_UTL_DataFactoryTst.pClickCasePhase();

            HDT_UTL_DataFactoryTst.newPhaseTransition('In attesa conferma cliente','Bozza',utlConstants.ORDER_RECORDTYPEID_VAS,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_VAS);
            HDT_UTL_DataFactoryTst.newPhaseTransition('Comunicazione Motore VAS','Bozza',utlConstants.ORDER_RECORDTYPEID_VAS,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_VAS);
            HDT_UTL_DataFactoryTst.newPhaseTransition('Comunicazione verso Motore VAS OK','Bozza',utlConstants.ORDER_RECORDTYPEID_VAS,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_VAS);
            HDT_UTL_DataFactoryTst.newPhaseTransition('Comunicazione verso Motore VAS KO','Bozza',utlConstants.ORDER_RECORDTYPEID_VAS,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_VAS);
            HDT_UTL_DataFactoryTst.newPhaseTransition('Ko prodotto vas','Bozza',utlConstants.ORDER_RECORDTYPEID_VAS,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_VAS);

            HDT_UTL_DataFactoryTst.newPhaseTransition('Comunicazione verso Motore VAS OK','Bozza',utlConstants.CASE_RECORDTYPEID_POST_SALES_VAS,utlConstants.CASE_RECORDTYPE_DEVELOPERNAME_POST_SALES_VAS);
            HDT_UTL_DataFactoryTst.newPhaseTransition('Comunicazione verso Motore VAS KO','Bozza',utlConstants.CASE_RECORDTYPEID_POST_SALES_VAS,utlConstants.CASE_RECORDTYPE_DEVELOPERNAME_POST_SALES_VAS);
        }

        HDT_UTL_DataFactoryTst.createWebServiceCredential('MulesoftSalesforceUser', 'testPassword', 'testUsername');
        HDT_UTL_DataFactoryTst.createWebServiceConfiguration('VAS.Activation','https://hera/vas-engine/activations', 'POST', 'MulesoftSalesforceUser');
        HDT_UTL_DataFactoryTst.createWebServiceConfiguration('VAS.Deactivation','https://hera/vas-engine/activations', 'DELETE', 'MulesoftSalesforceUser');
        HDT_UTL_DataFactoryTst.createWebServiceConfiguration('VAS.Service26','https://hera/activations/catalog-attributes', 'POST', 'MulesoftSalesforceUser');
    }

    /**
    * @description Testing activation
    * @author gabriele.rota@webresults.it | 2021-11-10 
    **/
    @isTest
    public static void activationOkTest(){

        Order originalOrder = [SELECT Id FROM Order LIMIT 1];

        Map<String, Object> argsMap = new Map<String, Object>();
        argsMap.put('method', 'activation');
        argsMap.put('sender', originalOrder);

        Test.setMock(HttpCalloutMock.class, new HDT_WS_VasServiceMock(true));
        Test.startTest();
        new HDT_SRV_SalesManager().execute(argsMap);
        Test.stopTest();
        
        Order updatedOrder = [SELECT Phase__c FROM Order LIMIT 1];
        System.assertEquals('Comunicazione verso Motore VAS OK', updatedOrder.Phase__c, 'Order Phase is not correct');
        System.assertNotEquals('Comunicazione verso Motore VAS KO', updatedOrder.Phase__c, 'Order Phase is not correct');
    }

    /**
    * @description Testing activation error
    * @author gabriele.rota@webresults.it | 2021-11-10 
    **/
    @isTest
    public static void activationKoTest(){

        Order originalOrder = [SELECT Id FROM Order LIMIT 1];

        Map<String, Object> argsMap = new Map<String, Object>();
        argsMap.put('method', 'activation');
        argsMap.put('sender', originalOrder);

        Test.setMock(HttpCalloutMock.class, new HDT_WS_VasServiceMock(false));
        Test.startTest();
        new HDT_SRV_SalesManager().execute(argsMap);
        Test.stopTest();
        
        Order updatedOrder = [SELECT Phase__c FROM Order LIMIT 1];
        System.assertEquals('Ko prodotto vas', updatedOrder.Phase__c, 'Order Phase is not correct');
        System.assertNotEquals('Comunicazione verso Motore VAS OK', updatedOrder.Phase__c, 'Order Phase is not correct');
    }

    /**
    * @description Testing deactivation
    * @author gabriele.rota@webresults.it | 2021-11-10 
    **/
    @isTest
    public static void deactivationOkTest(){

        Case originalCase = [SELECT Id FROM Case LIMIT 1];

        Map<String, Object> argsMap = new Map<String, Object>();
        argsMap.put('method', 'deactivation');
        argsMap.put('sender', originalCase);

        Test.setMock(HttpCalloutMock.class, new HDT_WS_VasServiceMock(true));
        Test.startTest();
        new HDT_SRV_SalesManager().execute(argsMap);
        Test.stopTest();
        
        Case updatedCase = [SELECT Phase__c FROM Case LIMIT 1];
        System.assertEquals('Comunicazione verso Motore VAS OK', updatedCase.Phase__c, 'Case Phase is not correct');
        System.assertNotEquals('Comunicazione verso Motore VAS KO', updatedCase.Phase__c, 'Case Phase is not correct');
    }

    /**
    * @description Testing deactivation error
    * @author gabriele.rota@webresults.it | 2021-11-10 
    **/
    @isTest
    public static void deactivationKoTest(){

        Case originalCase = [SELECT Id FROM Case LIMIT 1];

        Map<String, Object> argsMap = new Map<String, Object>();
        argsMap.put('method', 'deactivation');
        argsMap.put('sender', originalCase);

        Test.setMock(HttpCalloutMock.class, new HDT_WS_VasServiceMock(false));
        Test.startTest();
        new HDT_SRV_SalesManager().execute(argsMap);
        Test.stopTest();
        
        Case updatedCase = [SELECT Phase__c FROM Case LIMIT 1];
        System.assertEquals('Comunicazione verso Motore VAS KO', updatedCase.Phase__c, 'Case Phase is not correct');
        System.assertNotEquals('Comunicazione verso Motore VAS OK', updatedCase.Phase__c, 'Case Phase is not correct');
    }

    /**
    * @description Testing service 26
    * @author gabriele.rota@webresults.it | 2021-11-10 
    **/
    @isTest
    public static void serviceTwentySixTest(){

        Order originalOrder = [SELECT Id FROM Order LIMIT 1];

        Map<String, Object> argsMap = new Map<String, Object>();
        argsMap.put('method', 'service26');
        argsMap.put('sender', originalOrder);

        Test.setMock(HttpCalloutMock.class, new HDT_WS_VasServiceMock(true));
        Test.startTest();
        new HDT_SRV_SalesManager().execute(argsMap);
        Test.stopTest();
        
        List<wrts_prcgvr__Log__c> logs = [SELECT Id FROM wrts_prcgvr__Log__c];
        System.assertEquals(1, logs.size(), 'Logs have not been saved');
        System.assertNotEquals(true, logs.isEmpty(), 'Logs have not been saved');
    }

    /**
    * @description Testing phase update
    * @author gabriele.rota@webresults.it | 2021-11-10 
    **/
    @isTest
    public static void updatePhaseTest(){

        Order originalOrder = [SELECT VASType__c FROM Order LIMIT 1];

        Map<String, Object> argsMap = new Map<String, Object>();
        argsMap.put('method', 'updatePhase');
        argsMap.put('sender', originalOrder);

        Test.startTest();
        new HDT_SRV_SalesManager().execute(argsMap);
        Test.stopTest();
        
        Order updatedOrder = [SELECT Phase__c FROM Order LIMIT 1];
        System.assertEquals('Comunicazione Motore VAS', updatedOrder.Phase__c, 'Order Phase is not correct');
        System.assertNotEquals('In attesa tempi di ripensamento', updatedOrder.Phase__c, 'Order Phase is not correct');
    }

    /**
    * @description Testing contracted switch
    * @author gabriele.rota@webresults.it | 2021-11-10 
    **/
    @isTest
    public static void contractedTest(){

        Order originalOrder = [SELECT Id FROM Order LIMIT 1];

        Map<String, Object> argsMap = new Map<String, Object>();
        argsMap.put('method', 'contracted');
        argsMap.put('sender', originalOrder);

        Test.startTest();
        new HDT_SRV_SalesManager().execute(argsMap);
        Test.stopTest();
        
        Order updatedOrder = [SELECT SBQQ__Contracted__c FROM Order LIMIT 1];
        System.assertEquals(true, updatedOrder.SBQQ__Contracted__c, 'Contracted has not been updated');
        System.assertNotEquals(false, updatedOrder.SBQQ__Contracted__c, 'Contracted has not been updated');
    }
}