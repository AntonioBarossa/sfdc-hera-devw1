/**
 * @author Lucas da Silva Fernandes (lucas.dasilva@engdb.com.br)
 * @date 01/10/2021
 * @description HDT_UTL_NotifVas Test Classes
 * @history Lucas Fernandes 01/10/2021 – Created Class
 */
@isTest
public with sharing class HDT_UTL_LeadProcessTst {
    
    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();
	
	@TestSetup
    static void setup(){
        
        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
        User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
        internalUser.UserPermissionsMarketingUser=true;
        insert internalUser;
 
        System.runAs(internalUser) {
 
            List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, false, 'HERA COMM', 'Azienda', 'Aziende SME');
            accList[0].Code__c = 'codeTest';
            insert accList;

            MacroActivityEasyCIM__c maeC = new MacroActivityEasyCIM__c(
                Name = 'maeTest'
            );
            insert maeC;
            
            List<Campaign> cmpList = HDT_UTL_DataFactoryTst.createCampaign(2, false);
            cmpList[0].Name = 'LEAD CALLBACK';
            cmpList[0].AssignmentType__c = 'Manuale';
            cmpList[0].MacroActivityEasyCIM__c = maeC.Id;
            cmpList[0].Category__c = 'Campagna Outbound';
            cmpList[0].Channel__c = 'Bolletta';
            cmpList[0].ReitekIntegrationTechnology__c ='Web Service';
            cmpList[1].Name = 'LEAD WINBACK';
            cmpList[1].AssignmentType__c = 'Manuale';
            cmpList[1].MacroActivityEasyCIM__c = maeC.Id;
            cmpList[1].Category__c = 'Campagna Outbound';
            cmpList[1].Channel__c = 'Bolletta';
            insert cmpList;

            HDT_UTL_DataFactoryTst.createContentVersion(1, true, 'titleTest', 'dataTest', 'pathTest');

            List<Individual> indList = HDT_UTL_DataFactoryTst.createIndividual(1, true);

            HDT_UTL_DataFactoryTst.createContactPointEmail(1, true, indList[0].Id);
        }
    }
	
	@isTest
    public static void testFormCallback() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){

            HDT_WS_HTTPServiceCallMock mock = new HDT_WS_HTTPServiceCallMock();
            Test.setMock(HttpCalloutMock.class, mock); 
            Test.startTest();

            HDT_WRP_MrrRequest.HDT_WRP_Field field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            List<HDT_WRP_MrrRequest.HDT_WRP_Field> fieldList = new List<HDT_WRP_MrrRequest.HDT_WRP_Field>();
            
            field.name = 'COMPANYOWNER';
            field.value = 'MMS';
            fieldList.add(field);
			
            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'NOMEMACROACTIVITYEASYCIM';
            field.value = 'maeTest';
            fieldList.add(field);
            
            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'CELLULARE';
            field.value = '01981516381';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'CONSENSOMARKETING';
            field.value = 'SI';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'VERSINFOMARKET';
            field.value = 'privacyVersionTest';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'FONTECONSENSOMRK';
            field.value = 'Webform callback';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'INIZIATIVACONSMARK';
            field.value = 'sito standard';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'COMPANYCONSENSOMARKETING';
            field.value = 'MMS';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'FONTE';
            field.value = 'Webform callback';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'DETTAGLIOFONTE';
            field.value = 'sito standard';
            fieldList.add(field);
            
            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'AGENZIA';
            field.value = 'codeTest';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'D_O_RICONTATTO';
            field.value = '2021-10-01 T20:Z03:58';
            fieldList.add(field);
            
            HDT_WRP_MrrRequest.HDT_WRP_Object objects = new HDT_WRP_MrrRequest.HDT_WRP_Object();
            objects.fields = fieldList;

            List<HDT_WRP_MrrRequest.HDT_WRP_Object> objectsList = new List<HDT_WRP_MrrRequest.HDT_WRP_Object>();
            objectsList.add(objects);

            HDT_WRP_MrrRequest.HDT_WRP_Request request = new HDT_WRP_MrrRequest.HDT_WRP_Request();
            request.objects = objectsList;
            
            HDT_WRP_MrrResponse.HDT_WRP_Response mrrResponseItem = new HDT_WRP_MrrResponse.HDT_WRP_Response();
            mrrResponseItem.objects = new List<HDT_WRP_MrrResponse.HDT_WRP_Object>();

            HDT_WRP_MrrResponse.HDT_WRP_Object responseObjects = new HDT_WRP_MrrResponse.HDT_WRP_Object();
            responseObjects.fields = new List<HDT_WRP_MrrResponse.HDT_WRP_Field>(); 

            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            req.requestURI = 'https://na11.salesforce.com';
            req.httpMethod = 'POST';
            RestContext.request = req;
            RestContext.response = res;

            HDT_WRP_MrrResponse.HDT_WRP_Response mrrResponseLeadProcess = HDT_UTL_LeadProcess.formCallback(request, mrrResponseItem, responseObjects);
            
            Test.stopTest();

            System.assertEquals(false, mrrResponseLeadProcess.objects.isEmpty(), 'Response filled');
            System.assertNotEquals(true, mrrResponseLeadProcess.objects.isEmpty(), 'Response empty');
        }
    }
	
    @isTest
    public static void testFormCallbackEmptyCampaign() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){

            HDT_WS_HTTPServiceCallMock mock = new HDT_WS_HTTPServiceCallMock();
            Test.setMock(HttpCalloutMock.class, mock); 
            Test.startTest();

            List<Campaign> cmpList = [SELECT Id FROM Campaign WHERE Channel__c = 'Bolletta'];
            delete cmpList;

            HDT_WRP_MrrRequest.HDT_WRP_Field field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            List<HDT_WRP_MrrRequest.HDT_WRP_Field> fieldList = new List<HDT_WRP_MrrRequest.HDT_WRP_Field>();
            
            field.name = 'COMPANYOWNER';
            field.value = 'MMS';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'CELLULARE';
            field.value = '01981516381';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'CONSENSOMARKETING';
            field.value = 'SI';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'VERSINFOMARKET';
            field.value = 'privacyVersionTest';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'FONTECONSENSOMRK';
            field.value = 'Webform callback';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'INIZIATIVACONSMARK';
            field.value = 'sito standard';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'COMPANYCONSENSOMARKETING';
            field.value = 'MMS';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'FONTE';
            field.value = 'Webform callback';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'DETTAGLIOFONTE';
            field.value = 'sito standard';
            fieldList.add(field);
            
            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'AGENZIA';
            field.value = 'codeTest';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'D_O_RICONTATTO';
            field.value = '2021-10-01 T20:Z03:58';
            fieldList.add(field);
            
            HDT_WRP_MrrRequest.HDT_WRP_Object objects = new HDT_WRP_MrrRequest.HDT_WRP_Object();
            objects.fields = fieldList;

            List<HDT_WRP_MrrRequest.HDT_WRP_Object> objectsList = new List<HDT_WRP_MrrRequest.HDT_WRP_Object>();
            objectsList.add(objects);

            HDT_WRP_MrrRequest.HDT_WRP_Request request = new HDT_WRP_MrrRequest.HDT_WRP_Request();
            request.objects = objectsList;
            
            HDT_WRP_MrrResponse.HDT_WRP_Response mrrResponseItem = new HDT_WRP_MrrResponse.HDT_WRP_Response();
            mrrResponseItem.objects = new List<HDT_WRP_MrrResponse.HDT_WRP_Object>();

            HDT_WRP_MrrResponse.HDT_WRP_Object responseObjects = new HDT_WRP_MrrResponse.HDT_WRP_Object();
            responseObjects.fields = new List<HDT_WRP_MrrResponse.HDT_WRP_Field>(); 

            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            req.requestURI = 'https://na11.salesforce.com';
            req.httpMethod = 'POST';
            RestContext.request = req;
            RestContext.response = res;

            HDT_WRP_MrrResponse.HDT_WRP_Response mrrResponseLeadProcess = HDT_UTL_LeadProcess.formCallback(request, mrrResponseItem, responseObjects);
            
            Test.stopTest();

            System.assertEquals(false, mrrResponseLeadProcess.objects.isEmpty(), 'Response filled');
            System.assertNotEquals(true, mrrResponseLeadProcess.objects.isEmpty(), 'Response empty');
        }
    }

    @isTest
    public static void testFormCallbackIsValidatedFalse() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){

            HDT_WS_HTTPServiceCallMock mock = new HDT_WS_HTTPServiceCallMock();
            Test.setMock(HttpCalloutMock.class, mock); 
            Test.startTest();

            HDT_WRP_MrrRequest.HDT_WRP_Field field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            List<HDT_WRP_MrrRequest.HDT_WRP_Field> fieldList = new List<HDT_WRP_MrrRequest.HDT_WRP_Field>();
            
            field.name = 'COMPANYOWNER';
            field.value = 'MMS';
            fieldList.add(field);
            
            HDT_WRP_MrrRequest.HDT_WRP_Object objects = new HDT_WRP_MrrRequest.HDT_WRP_Object();
            objects.fields = fieldList;

            List<HDT_WRP_MrrRequest.HDT_WRP_Object> objectsList = new List<HDT_WRP_MrrRequest.HDT_WRP_Object>();
            objectsList.add(objects);

            HDT_WRP_MrrRequest.HDT_WRP_Request request = new HDT_WRP_MrrRequest.HDT_WRP_Request();
            request.objects = objectsList;
            
            HDT_WRP_MrrResponse.HDT_WRP_Response mrrResponseItem = new HDT_WRP_MrrResponse.HDT_WRP_Response();
            mrrResponseItem.objects = new List<HDT_WRP_MrrResponse.HDT_WRP_Object>();

            HDT_WRP_MrrResponse.HDT_WRP_Object responseObjects = new HDT_WRP_MrrResponse.HDT_WRP_Object();
            responseObjects.fields = new List<HDT_WRP_MrrResponse.HDT_WRP_Field>(); 

            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            req.requestURI = 'https://na11.salesforce.com';
            req.httpMethod = 'POST';
            RestContext.request = req;
            RestContext.response = res;

            HDT_WRP_MrrResponse.HDT_WRP_Response mrrResponseLeadProcess = HDT_UTL_LeadProcess.formCallback(request, mrrResponseItem, responseObjects);
            
            Test.stopTest();

            System.assertEquals(false, mrrResponseLeadProcess.objects.isEmpty(), 'Response filled');
            System.assertNotEquals(true, mrrResponseLeadProcess.objects.isEmpty(), 'Response empty');
        }
    }
    
    @isTest
    public static void testFormCallbackRequestObjectsEmpty() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){

            HDT_WS_HTTPServiceCallMock mock = new HDT_WS_HTTPServiceCallMock();
            Test.setMock(HttpCalloutMock.class, mock); 
            Test.startTest();

            HDT_WRP_MrrRequest.HDT_WRP_Request request = new HDT_WRP_MrrRequest.HDT_WRP_Request();
            request.objects = null;

            HDT_WRP_MrrResponse.HDT_WRP_Response mrrResponseItem = new HDT_WRP_MrrResponse.HDT_WRP_Response();
            mrrResponseItem.objects = new List<HDT_WRP_MrrResponse.HDT_WRP_Object>();

            HDT_WRP_MrrResponse.HDT_WRP_Object responseObjects = new HDT_WRP_MrrResponse.HDT_WRP_Object();
            responseObjects.fields = new List<HDT_WRP_MrrResponse.HDT_WRP_Field>(); 

            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            req.requestURI = 'https://na11.salesforce.com';
            req.httpMethod = 'POST';
            RestContext.request = req;
            RestContext.response = res;

            HDT_WRP_MrrResponse.HDT_WRP_Response mrrResponseLeadProcess = HDT_UTL_LeadProcess.formCallback(request, mrrResponseItem, responseObjects);
            
            Test.stopTest();

            System.assertEquals(false, mrrResponseLeadProcess.objects.isEmpty(), 'Response filled');
            System.assertNotEquals(true, mrrResponseLeadProcess.objects.isEmpty(), 'Response empty');
        }
    }

    @isTest
    public static void testFormWinback() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){

            HDT_WS_HTTPServiceCallMock mock = new HDT_WS_HTTPServiceCallMock();
            Test.setMock(HttpCalloutMock.class, mock); 
            Test.startTest();

            HDT_WRP_MrrRequest.HDT_WRP_Field field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            List<HDT_WRP_MrrRequest.HDT_WRP_Field> fieldList = new List<HDT_WRP_MrrRequest.HDT_WRP_Field>();
            
            field.name = 'COMPANYOWNER';
            field.value = 'MMS';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'NOMEMACROACTIVITYEASYCIM';
            field.value = 'maeTest';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'CELLULARE';
            field.value = '01981516381';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'CONSENSOMARKETING';
            field.value = 'SI';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'VERSINFOMARKET';
            field.value = 'privacyVersionTest';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'FONTECONSENSOMRK';
            field.value = 'Webform callback';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'INIZIATIVACONSMARK';
            field.value = 'sito standard';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'COMPANYCONSENSOMARKETING';
            field.value = 'MMS';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'FONTE';
            field.value = 'Webform callback';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'DETTAGLIOFONTE';
            field.value = 'sito standard';
            fieldList.add(field);
            
            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'AGENZIA';
            field.value = 'codeTest';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'D_O_RICONTATTO';
            field.value = '2021-10-01 T20:Z03:58';
            fieldList.add(field);
            
            HDT_WRP_MrrRequest.HDT_WRP_Object objects = new HDT_WRP_MrrRequest.HDT_WRP_Object();
            objects.fields = fieldList;

            List<HDT_WRP_MrrRequest.HDT_WRP_Object> objectsList = new List<HDT_WRP_MrrRequest.HDT_WRP_Object>();
            objectsList.add(objects);

            HDT_WRP_MrrRequest.HDT_WRP_Request request = new HDT_WRP_MrrRequest.HDT_WRP_Request();
            request.objects = objectsList;
            
            HDT_WRP_MrrResponse.HDT_WRP_Response mrrResponseItem = new HDT_WRP_MrrResponse.HDT_WRP_Response();
            mrrResponseItem.objects = new List<HDT_WRP_MrrResponse.HDT_WRP_Object>();

            HDT_WRP_MrrResponse.HDT_WRP_Object responseObjects = new HDT_WRP_MrrResponse.HDT_WRP_Object();
            responseObjects.fields = new List<HDT_WRP_MrrResponse.HDT_WRP_Field>(); 

            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            req.requestURI = 'https://na11.salesforce.com';
            req.httpMethod = 'POST';
            RestContext.request = req;
            RestContext.response = res;

            HDT_WRP_MrrResponse.HDT_WRP_Response mrrResponseLeadProcess = HDT_UTL_LeadProcess.formWinback(request, mrrResponseItem, responseObjects);
            
            Test.stopTest();

            System.assertEquals(false, mrrResponseLeadProcess.objects.isEmpty(), 'Response filled');
            System.assertNotEquals(true, mrrResponseLeadProcess.objects.isEmpty(), 'Response empty');
        }
    }
	
    @isTest
    public static void testFormWinbackEmptyCampaign() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){

            HDT_WS_HTTPServiceCallMock mock = new HDT_WS_HTTPServiceCallMock();
            Test.setMock(HttpCalloutMock.class, mock); 
            Test.startTest();

            List<Campaign> cmpList = [SELECT Id FROM Campaign WHERE Channel__c = 'Bolletta'];
            delete cmpList;

            HDT_WRP_MrrRequest.HDT_WRP_Field field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            List<HDT_WRP_MrrRequest.HDT_WRP_Field> fieldList = new List<HDT_WRP_MrrRequest.HDT_WRP_Field>();
            
            field.name = 'COMPANYOWNER';
            field.value = 'MMS';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'CELLULARE';
            field.value = '01981516381';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'CONSENSOMARKETING';
            field.value = 'SI';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'VERSINFOMARKET';
            field.value = 'privacyVersionTest';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'FONTECONSENSOMRK';
            field.value = 'Webform callback';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'INIZIATIVACONSMARK';
            field.value = 'sito standard';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'COMPANYCONSENSOMARKETING';
            field.value = 'MMS';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'FONTE';
            field.value = 'Webform callback';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'DETTAGLIOFONTE';
            field.value = 'sito standard';
            fieldList.add(field);
            
            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'AGENZIA';
            field.value = 'codeTest';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'D_O_RICONTATTO';
            field.value = '2021-10-01 T20:Z03:58';
            fieldList.add(field);
            
            HDT_WRP_MrrRequest.HDT_WRP_Object objects = new HDT_WRP_MrrRequest.HDT_WRP_Object();
            objects.fields = fieldList;

            List<HDT_WRP_MrrRequest.HDT_WRP_Object> objectsList = new List<HDT_WRP_MrrRequest.HDT_WRP_Object>();
            objectsList.add(objects);

            HDT_WRP_MrrRequest.HDT_WRP_Request request = new HDT_WRP_MrrRequest.HDT_WRP_Request();
            request.objects = objectsList;
            
            HDT_WRP_MrrResponse.HDT_WRP_Response mrrResponseItem = new HDT_WRP_MrrResponse.HDT_WRP_Response();
            mrrResponseItem.objects = new List<HDT_WRP_MrrResponse.HDT_WRP_Object>();

            HDT_WRP_MrrResponse.HDT_WRP_Object responseObjects = new HDT_WRP_MrrResponse.HDT_WRP_Object();
            responseObjects.fields = new List<HDT_WRP_MrrResponse.HDT_WRP_Field>(); 

            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            req.requestURI = 'https://na11.salesforce.com';
            req.httpMethod = 'POST';
            RestContext.request = req;
            RestContext.response = res;

            HDT_WRP_MrrResponse.HDT_WRP_Response mrrResponseLeadProcess = HDT_UTL_LeadProcess.formWinback(request, mrrResponseItem, responseObjects);
            
            Test.stopTest();

            System.assertEquals(false, mrrResponseLeadProcess.objects.isEmpty(), 'Response filled');
            System.assertNotEquals(true, mrrResponseLeadProcess.objects.isEmpty(), 'Response empty');
        }
    }

    @isTest
    public static void testFormWinbackIsValidatedFalse() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){

            HDT_WS_HTTPServiceCallMock mock = new HDT_WS_HTTPServiceCallMock();
            Test.setMock(HttpCalloutMock.class, mock); 
            Test.startTest();

            HDT_WRP_MrrRequest.HDT_WRP_Field field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            List<HDT_WRP_MrrRequest.HDT_WRP_Field> fieldList = new List<HDT_WRP_MrrRequest.HDT_WRP_Field>();
            
            field.name = 'COMPANYOWNER';
            field.value = 'MMS';
            fieldList.add(field);
            
            HDT_WRP_MrrRequest.HDT_WRP_Object objects = new HDT_WRP_MrrRequest.HDT_WRP_Object();
            objects.fields = fieldList;

            List<HDT_WRP_MrrRequest.HDT_WRP_Object> objectsList = new List<HDT_WRP_MrrRequest.HDT_WRP_Object>();
            objectsList.add(objects);

            HDT_WRP_MrrRequest.HDT_WRP_Request request = new HDT_WRP_MrrRequest.HDT_WRP_Request();
            request.objects = objectsList;
            
            HDT_WRP_MrrResponse.HDT_WRP_Response mrrResponseItem = new HDT_WRP_MrrResponse.HDT_WRP_Response();
            mrrResponseItem.objects = new List<HDT_WRP_MrrResponse.HDT_WRP_Object>();

            HDT_WRP_MrrResponse.HDT_WRP_Object responseObjects = new HDT_WRP_MrrResponse.HDT_WRP_Object();
            responseObjects.fields = new List<HDT_WRP_MrrResponse.HDT_WRP_Field>(); 

            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            req.requestURI = 'https://na11.salesforce.com';
            req.httpMethod = 'POST';
            RestContext.request = req;
            RestContext.response = res;

            HDT_WRP_MrrResponse.HDT_WRP_Response mrrResponseLeadProcess = HDT_UTL_LeadProcess.formWinback(request, mrrResponseItem, responseObjects);
            
            Test.stopTest();

            System.assertEquals(false, mrrResponseLeadProcess.objects.isEmpty(), 'Response filled');
            System.assertNotEquals(true, mrrResponseLeadProcess.objects.isEmpty(), 'Response empty');
        }
    }

    @isTest
    public static void testFormWinbackRequestObjectsEmpty() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){

            HDT_WS_HTTPServiceCallMock mock = new HDT_WS_HTTPServiceCallMock();
            Test.setMock(HttpCalloutMock.class, mock); 
            Test.startTest();

            HDT_WRP_MrrRequest.HDT_WRP_Request request = new HDT_WRP_MrrRequest.HDT_WRP_Request();
            request.objects = null;
            
            HDT_WRP_MrrResponse.HDT_WRP_Response mrrResponseItem = new HDT_WRP_MrrResponse.HDT_WRP_Response();
            mrrResponseItem.objects = new List<HDT_WRP_MrrResponse.HDT_WRP_Object>();

            HDT_WRP_MrrResponse.HDT_WRP_Object responseObjects = new HDT_WRP_MrrResponse.HDT_WRP_Object();
            responseObjects.fields = new List<HDT_WRP_MrrResponse.HDT_WRP_Field>(); 

            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            req.requestURI = 'https://na11.salesforce.com';
            req.httpMethod = 'POST';
            RestContext.request = req;
            RestContext.response = res;

            HDT_WRP_MrrResponse.HDT_WRP_Response mrrResponseLeadProcess = HDT_UTL_LeadProcess.formWinback(request, mrrResponseItem, responseObjects);
            
            Test.stopTest();

            System.assertEquals(false, mrrResponseLeadProcess.objects.isEmpty(), 'Response filled');
            System.assertNotEquals(true, mrrResponseLeadProcess.objects.isEmpty(), 'Response empty');
        }
    }

    @isTest
    public static void testFormCaricBoll() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){

            HDT_WS_HTTPServiceCallMock mock = new HDT_WS_HTTPServiceCallMock();
            Test.setMock(HttpCalloutMock.class, mock); 
            Test.startTest();

            HDT_WRP_MrrRequest.HDT_WRP_Field field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            List<HDT_WRP_MrrRequest.HDT_WRP_Field> fieldList = new List<HDT_WRP_MrrRequest.HDT_WRP_Field>();
            
            field.name = 'COMPANYOWNER';
            field.value = 'MMS';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'NOMEMACROACTIVITYEASYCIM';
            field.value = 'maeTest';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'CELLULARE';
            field.value = '01981516381';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'CONSENSOMARKETING';
            field.value = 'SI';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'VERSINFOMARKET';
            field.value = 'privacyVersionTest';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'FONTECONSENSOMRK';
            field.value = 'Webform callback';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'INIZIATIVACONSMARK';
            field.value = 'sito standard';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'COMPANYCONSENSOMARKETING';
            field.value = 'MMS';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'FONTE';
            field.value = 'Webform callback';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'DETTAGLIOFONTE';
            field.value = 'sito standard';
            fieldList.add(field);
            
            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'AGENZIA';
            field.value = 'codeTest';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'D_O_RICONTATTO';
            field.value = '2021-10-01 T20:Z03:58';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'FILE';
            field.value = String.valueOf([SELECT Id FROM ContentVersion WHERE Title = 'titleTest'].Id);
            fieldList.add(field);
            
            HDT_WRP_MrrRequest.HDT_WRP_Object objects = new HDT_WRP_MrrRequest.HDT_WRP_Object();
            objects.fields = fieldList;

            List<HDT_WRP_MrrRequest.HDT_WRP_Object> objectsList = new List<HDT_WRP_MrrRequest.HDT_WRP_Object>();
            objectsList.add(objects);

            HDT_WRP_MrrRequest.HDT_WRP_Request request = new HDT_WRP_MrrRequest.HDT_WRP_Request();
            request.objects = objectsList;
            
            HDT_WRP_MrrResponse.HDT_WRP_Response mrrResponseItem = new HDT_WRP_MrrResponse.HDT_WRP_Response();
            mrrResponseItem.objects = new List<HDT_WRP_MrrResponse.HDT_WRP_Object>();

            HDT_WRP_MrrResponse.HDT_WRP_Object responseObjects = new HDT_WRP_MrrResponse.HDT_WRP_Object();
            responseObjects.fields = new List<HDT_WRP_MrrResponse.HDT_WRP_Field>(); 

            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            req.requestURI = 'https://na11.salesforce.com';
            req.httpMethod = 'POST';
            RestContext.request = req;
            RestContext.response = res;

            HDT_WRP_MrrResponse.HDT_WRP_Response mrrResponseLeadProcess = HDT_UTL_LeadProcess.formCaricBoll(request, mrrResponseItem, responseObjects);
            
            Test.stopTest();

            System.assertEquals(false, mrrResponseLeadProcess.objects.isEmpty(), 'Response filled');
            System.assertNotEquals(true, mrrResponseLeadProcess.objects.isEmpty(), 'Response empty');
        }
    }
	
    @isTest
    public static void testFormCaricBollEmptyCampaign() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){

            HDT_WS_HTTPServiceCallMock mock = new HDT_WS_HTTPServiceCallMock();
            Test.setMock(HttpCalloutMock.class, mock); 
            Test.startTest();

            List<Campaign> cmpList = [SELECT Id FROM Campaign WHERE Channel__c = 'Bolletta'];
            delete cmpList;

            HDT_WRP_MrrRequest.HDT_WRP_Field field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            List<HDT_WRP_MrrRequest.HDT_WRP_Field> fieldList = new List<HDT_WRP_MrrRequest.HDT_WRP_Field>();
            
            field.name = 'COMPANYOWNER';
            field.value = 'MMS';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'CELLULARE';
            field.value = '01981516381';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'CONSENSOMARKETING';
            field.value = 'SI';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'VERSINFOMARKET';
            field.value = 'privacyVersionTest';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'FONTECONSENSOMRK';
            field.value = 'Webform callback';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'INIZIATIVACONSMARK';
            field.value = 'sito standard';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'COMPANYCONSENSOMARKETING';
            field.value = 'MMS';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'FONTE';
            field.value = 'Webform callback';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'DETTAGLIOFONTE';
            field.value = 'sito standard';
            fieldList.add(field);
            
            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'AGENZIA';
            field.value = 'codeTest';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'D_O_RICONTATTO';
            field.value = '2021-10-01 T20:Z03:58';
            fieldList.add(field);
            
            HDT_WRP_MrrRequest.HDT_WRP_Object objects = new HDT_WRP_MrrRequest.HDT_WRP_Object();
            objects.fields = fieldList;

            List<HDT_WRP_MrrRequest.HDT_WRP_Object> objectsList = new List<HDT_WRP_MrrRequest.HDT_WRP_Object>();
            objectsList.add(objects);

            HDT_WRP_MrrRequest.HDT_WRP_Request request = new HDT_WRP_MrrRequest.HDT_WRP_Request();
            request.objects = objectsList;
            
            HDT_WRP_MrrResponse.HDT_WRP_Response mrrResponseItem = new HDT_WRP_MrrResponse.HDT_WRP_Response();
            mrrResponseItem.objects = new List<HDT_WRP_MrrResponse.HDT_WRP_Object>();

            HDT_WRP_MrrResponse.HDT_WRP_Object responseObjects = new HDT_WRP_MrrResponse.HDT_WRP_Object();
            responseObjects.fields = new List<HDT_WRP_MrrResponse.HDT_WRP_Field>(); 

            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            req.requestURI = 'https://na11.salesforce.com';
            req.httpMethod = 'POST';
            RestContext.request = req;
            RestContext.response = res;

            HDT_WRP_MrrResponse.HDT_WRP_Response mrrResponseLeadProcess = HDT_UTL_LeadProcess.formCaricBoll(request, mrrResponseItem, responseObjects);
            
            Test.stopTest();

            System.assertEquals(false, mrrResponseLeadProcess.objects.isEmpty(), 'Response filled');
            System.assertNotEquals(true, mrrResponseLeadProcess.objects.isEmpty(), 'Response empty');
        }
    }

    @isTest
    public static void testFormCaricBollIsValidatedFalse() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){

            HDT_WS_HTTPServiceCallMock mock = new HDT_WS_HTTPServiceCallMock();
            Test.setMock(HttpCalloutMock.class, mock); 
            Test.startTest();

            HDT_WRP_MrrRequest.HDT_WRP_Field field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            List<HDT_WRP_MrrRequest.HDT_WRP_Field> fieldList = new List<HDT_WRP_MrrRequest.HDT_WRP_Field>();
            
            field.name = 'COMPANYOWNER';
            field.value = 'MMS';
            fieldList.add(field);
            
            HDT_WRP_MrrRequest.HDT_WRP_Object objects = new HDT_WRP_MrrRequest.HDT_WRP_Object();
            objects.fields = fieldList;

            List<HDT_WRP_MrrRequest.HDT_WRP_Object> objectsList = new List<HDT_WRP_MrrRequest.HDT_WRP_Object>();
            objectsList.add(objects);

            HDT_WRP_MrrRequest.HDT_WRP_Request request = new HDT_WRP_MrrRequest.HDT_WRP_Request();
            request.objects = objectsList;
            
            HDT_WRP_MrrResponse.HDT_WRP_Response mrrResponseItem = new HDT_WRP_MrrResponse.HDT_WRP_Response();
            mrrResponseItem.objects = new List<HDT_WRP_MrrResponse.HDT_WRP_Object>();

            HDT_WRP_MrrResponse.HDT_WRP_Object responseObjects = new HDT_WRP_MrrResponse.HDT_WRP_Object();
            responseObjects.fields = new List<HDT_WRP_MrrResponse.HDT_WRP_Field>(); 

            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            req.requestURI = 'https://na11.salesforce.com';
            req.httpMethod = 'POST';
            RestContext.request = req;
            RestContext.response = res;

            HDT_WRP_MrrResponse.HDT_WRP_Response mrrResponseLeadProcess = HDT_UTL_LeadProcess.formCaricBoll(request, mrrResponseItem, responseObjects);
            
            Test.stopTest();

            System.assertEquals(false, mrrResponseLeadProcess.objects.isEmpty(), 'Response filled');
            System.assertNotEquals(true, mrrResponseLeadProcess.objects.isEmpty(), 'Response empty');
        }
    }

    @isTest
    public static void testFormCaricBollRequestObjectsEmpty() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){

            HDT_WS_HTTPServiceCallMock mock = new HDT_WS_HTTPServiceCallMock();
            Test.setMock(HttpCalloutMock.class, mock); 
            Test.startTest();

            HDT_WRP_MrrRequest.HDT_WRP_Request request = new HDT_WRP_MrrRequest.HDT_WRP_Request();
            request.objects = null;
            
            HDT_WRP_MrrResponse.HDT_WRP_Response mrrResponseItem = new HDT_WRP_MrrResponse.HDT_WRP_Response();
            mrrResponseItem.objects = new List<HDT_WRP_MrrResponse.HDT_WRP_Object>();

            HDT_WRP_MrrResponse.HDT_WRP_Object responseObjects = new HDT_WRP_MrrResponse.HDT_WRP_Object();
            responseObjects.fields = new List<HDT_WRP_MrrResponse.HDT_WRP_Field>(); 

            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            req.requestURI = 'https://na11.salesforce.com';
            req.httpMethod = 'POST';
            RestContext.request = req;
            RestContext.response = res;

            HDT_WRP_MrrResponse.HDT_WRP_Response mrrResponseLeadProcess = HDT_UTL_LeadProcess.formCaricBoll(request, mrrResponseItem, responseObjects);
            
            Test.stopTest();

            System.assertEquals(false, mrrResponseLeadProcess.objects.isEmpty(), 'Response filled');
            System.assertNotEquals(true, mrrResponseLeadProcess.objects.isEmpty(), 'Response empty');
        }
    }

    @isTest
    public static void testFormHvac() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){

            HDT_WS_HTTPServiceCallMock mock = new HDT_WS_HTTPServiceCallMock();
            Test.setMock(HttpCalloutMock.class, mock); 
            Test.startTest();

            HDT_WRP_MrrRequest.HDT_WRP_Field field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            List<HDT_WRP_MrrRequest.HDT_WRP_Field> fieldList = new List<HDT_WRP_MrrRequest.HDT_WRP_Field>();
            
            field.name = 'COMPANYOWNER';
            field.value = 'MMS';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'NOMEMACROACTIVITYEASYCIM';
            field.value = 'maeTest';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'CELLULARE';
            field.value = '01981516381';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'CONSENSOMARKETING';
            field.value = 'SI';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'VERSINFOMARKET';
            field.value = 'privacyVersionTest';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'FONTECONSENSOMRK';
            field.value = 'Webform callback';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'INIZIATIVACONSMARK';
            field.value = 'sito standard';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'COMPANYCONSENSOMARKETING';
            field.value = 'MMS';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'FONTE';
            field.value = 'Webform callback';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'DETTAGLIOFONTE';
            field.value = 'sito standard';
            fieldList.add(field);
            
            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'AGENZIA';
            field.value = 'codeTest';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'D_O_RICONTATTO';
            field.value = '2021-10-01 T20:Z03:58';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'FILE';
            field.value = String.valueOf([SELECT Id FROM ContentVersion WHERE Title = 'titleTest'].Id);
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'EMAIL';
            field.value = 'my@test.com';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'COMUNE';
            field.value = 'Gotham';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'NOME';
            field.value = 'firstName';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'COGNOME';
            field.value = 'lastName';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'CAP';
            field.value = '83542';
            fieldList.add(field);
            
            HDT_WRP_MrrRequest.HDT_WRP_Object objects = new HDT_WRP_MrrRequest.HDT_WRP_Object();
            objects.fields = fieldList;

            List<HDT_WRP_MrrRequest.HDT_WRP_Object> objectsList = new List<HDT_WRP_MrrRequest.HDT_WRP_Object>();
            objectsList.add(objects);

            HDT_WRP_MrrRequest.HDT_WRP_Request request = new HDT_WRP_MrrRequest.HDT_WRP_Request();
            request.objects = objectsList;
            
            HDT_WRP_MrrResponse.HDT_WRP_Response mrrResponseItem = new HDT_WRP_MrrResponse.HDT_WRP_Response();
            mrrResponseItem.objects = new List<HDT_WRP_MrrResponse.HDT_WRP_Object>();

            HDT_WRP_MrrResponse.HDT_WRP_Object responseObjects = new HDT_WRP_MrrResponse.HDT_WRP_Object();
            responseObjects.fields = new List<HDT_WRP_MrrResponse.HDT_WRP_Field>(); 

            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            req.requestURI = 'https://na11.salesforce.com';
            req.httpMethod = 'POST';
            RestContext.request = req;
            RestContext.response = res;

            HDT_WRP_MrrResponse.HDT_WRP_Response mrrResponseLeadProcess = HDT_UTL_LeadProcess.formHvac(request, mrrResponseItem, responseObjects);
            
            Test.stopTest();

            System.assertEquals(false, mrrResponseLeadProcess.objects.isEmpty(), 'Response filled');
            System.assertNotEquals(true, mrrResponseLeadProcess.objects.isEmpty(), 'Response empty');
        }
    }
	
    @isTest
    public static void testFormHvacEmptyCampaign() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){

            HDT_WS_HTTPServiceCallMock mock = new HDT_WS_HTTPServiceCallMock();
            Test.setMock(HttpCalloutMock.class, mock); 
            Test.startTest();

            List<Campaign> cmpList = [SELECT Id FROM Campaign WHERE Channel__c = 'Bolletta'];
            delete cmpList;

            HDT_WRP_MrrRequest.HDT_WRP_Field field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            List<HDT_WRP_MrrRequest.HDT_WRP_Field> fieldList = new List<HDT_WRP_MrrRequest.HDT_WRP_Field>();
            
            field.name = 'COMPANYOWNER';
            field.value = 'MMS';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'CELLULARE';
            field.value = '01981516381';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'CONSENSOMARKETING';
            field.value = 'SI';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'VERSINFOMARKET';
            field.value = 'privacyVersionTest';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'FONTECONSENSOMRK';
            field.value = 'Webform callback';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'INIZIATIVACONSMARK';
            field.value = 'sito standard';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'COMPANYCONSENSOMARKETING';
            field.value = 'MMS';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'FONTE';
            field.value = 'Webform callback';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'DETTAGLIOFONTE';
            field.value = 'sito standard';
            fieldList.add(field);
            
            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'AGENZIA';
            field.value = 'codeTest';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'D_O_RICONTATTO';
            field.value = '2021-10-01 T20:Z03:58';
            fieldList.add(field);
            
            HDT_WRP_MrrRequest.HDT_WRP_Object objects = new HDT_WRP_MrrRequest.HDT_WRP_Object();
            objects.fields = fieldList;

            List<HDT_WRP_MrrRequest.HDT_WRP_Object> objectsList = new List<HDT_WRP_MrrRequest.HDT_WRP_Object>();
            objectsList.add(objects);

            HDT_WRP_MrrRequest.HDT_WRP_Request request = new HDT_WRP_MrrRequest.HDT_WRP_Request();
            request.objects = objectsList;
            
            HDT_WRP_MrrResponse.HDT_WRP_Response mrrResponseItem = new HDT_WRP_MrrResponse.HDT_WRP_Response();
            mrrResponseItem.objects = new List<HDT_WRP_MrrResponse.HDT_WRP_Object>();

            HDT_WRP_MrrResponse.HDT_WRP_Object responseObjects = new HDT_WRP_MrrResponse.HDT_WRP_Object();
            responseObjects.fields = new List<HDT_WRP_MrrResponse.HDT_WRP_Field>(); 

            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            req.requestURI = 'https://na11.salesforce.com';
            req.httpMethod = 'POST';
            RestContext.request = req;
            RestContext.response = res;

            HDT_WRP_MrrResponse.HDT_WRP_Response mrrResponseLeadProcess = HDT_UTL_LeadProcess.formHvac(request, mrrResponseItem, responseObjects);
            
            Test.stopTest();

            System.assertEquals(false, mrrResponseLeadProcess.objects.isEmpty(), 'Response filled');
            System.assertNotEquals(true, mrrResponseLeadProcess.objects.isEmpty(), 'Response empty');
        }
    }

    @isTest
    public static void testFormHvacIsValidatedFalse() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){

            HDT_WS_HTTPServiceCallMock mock = new HDT_WS_HTTPServiceCallMock();
            Test.setMock(HttpCalloutMock.class, mock); 
            Test.startTest();

            HDT_WRP_MrrRequest.HDT_WRP_Field field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            List<HDT_WRP_MrrRequest.HDT_WRP_Field> fieldList = new List<HDT_WRP_MrrRequest.HDT_WRP_Field>();
            
            field.name = 'COMPANYOWNER';
            field.value = 'MMS';
            fieldList.add(field);
            
            HDT_WRP_MrrRequest.HDT_WRP_Object objects = new HDT_WRP_MrrRequest.HDT_WRP_Object();
            objects.fields = fieldList;

            List<HDT_WRP_MrrRequest.HDT_WRP_Object> objectsList = new List<HDT_WRP_MrrRequest.HDT_WRP_Object>();
            objectsList.add(objects);

            HDT_WRP_MrrRequest.HDT_WRP_Request request = new HDT_WRP_MrrRequest.HDT_WRP_Request();
            request.objects = objectsList;
            
            HDT_WRP_MrrResponse.HDT_WRP_Response mrrResponseItem = new HDT_WRP_MrrResponse.HDT_WRP_Response();
            mrrResponseItem.objects = new List<HDT_WRP_MrrResponse.HDT_WRP_Object>();

            HDT_WRP_MrrResponse.HDT_WRP_Object responseObjects = new HDT_WRP_MrrResponse.HDT_WRP_Object();
            responseObjects.fields = new List<HDT_WRP_MrrResponse.HDT_WRP_Field>(); 

            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            req.requestURI = 'https://na11.salesforce.com';
            req.httpMethod = 'POST';
            RestContext.request = req;
            RestContext.response = res;

            HDT_WRP_MrrResponse.HDT_WRP_Response mrrResponseLeadProcess = HDT_UTL_LeadProcess.formHvac(request, mrrResponseItem, responseObjects);
            
            Test.stopTest();

            System.assertEquals(false, mrrResponseLeadProcess.objects.isEmpty(), 'Response filled');
            System.assertNotEquals(true, mrrResponseLeadProcess.objects.isEmpty(), 'Response empty');
        }
    }

    @isTest
    public static void testFormHvacRequestObjectsEmpty() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){

            HDT_WS_HTTPServiceCallMock mock = new HDT_WS_HTTPServiceCallMock();
            Test.setMock(HttpCalloutMock.class, mock); 
            Test.startTest();

            HDT_WRP_MrrRequest.HDT_WRP_Request request = new HDT_WRP_MrrRequest.HDT_WRP_Request();
            request.objects = null;
            
            HDT_WRP_MrrResponse.HDT_WRP_Response mrrResponseItem = new HDT_WRP_MrrResponse.HDT_WRP_Response();
            mrrResponseItem.objects = new List<HDT_WRP_MrrResponse.HDT_WRP_Object>();

            HDT_WRP_MrrResponse.HDT_WRP_Object responseObjects = new HDT_WRP_MrrResponse.HDT_WRP_Object();
            responseObjects.fields = new List<HDT_WRP_MrrResponse.HDT_WRP_Field>(); 

            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            req.requestURI = 'https://na11.salesforce.com';
            req.httpMethod = 'POST';
            RestContext.request = req;
            RestContext.response = res;

            HDT_WRP_MrrResponse.HDT_WRP_Response mrrResponseLeadProcess = HDT_UTL_LeadProcess.formHvac(request, mrrResponseItem, responseObjects);
            
            Test.stopTest();

            System.assertEquals(false, mrrResponseLeadProcess.objects.isEmpty(), 'Response filled');
            System.assertNotEquals(true, mrrResponseLeadProcess.objects.isEmpty(), 'Response empty');
        }
    }

    @isTest
    public static void testFormSol() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){

            HDT_WS_HTTPServiceCallMock mock = new HDT_WS_HTTPServiceCallMock();
            Test.setMock(HttpCalloutMock.class, mock); 
            Test.startTest();

            HDT_WRP_MrrRequest.HDT_WRP_Field field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            List<HDT_WRP_MrrRequest.HDT_WRP_Field> fieldList = new List<HDT_WRP_MrrRequest.HDT_WRP_Field>();
            
            field.name = 'COMPANYOWNER';
            field.value = 'MMS';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'NOMEMACROACTIVITYEASYCIM';
            field.value = 'maeTest';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'CELLULARE';
            field.value = '01981516381';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'CONSENSOMARKETING';
            field.value = 'SI';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'VERSINFOMARKET';
            field.value = 'privacyVersionTest';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'FONTECONSENSOMRK';
            field.value = 'Webform callback';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'INIZIATIVACONSMARK';
            field.value = 'sito standard';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'COMPANYCONSENSOMARKETING';
            field.value = 'MMS';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'FONTE';
            field.value = 'Webform callback';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'DETTAGLIOFONTE';
            field.value = 'sito standard';
            fieldList.add(field);
            
            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'AGENZIA';
            field.value = 'codeTest';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'D_O_RICONTATTO';
            field.value = '2021-10-01 T20:Z03:58';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'FILE';
            field.value = String.valueOf([SELECT Id FROM ContentVersion WHERE Title = 'titleTest'].Id);
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'EMAIL';
            field.value = 'sales@force.com';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'COMUNE';
            field.value = 'Gotham';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'NOME';
            field.value = 'firstName';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'COGNOME';
            field.value = 'lastName';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'CAP';
            field.value = '83542';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'TELEFONO';
            field.value = '023456789';
            fieldList.add(field);
            
            HDT_WRP_MrrRequest.HDT_WRP_Object objects = new HDT_WRP_MrrRequest.HDT_WRP_Object();
            objects.fields = fieldList;

            List<HDT_WRP_MrrRequest.HDT_WRP_Object> objectsList = new List<HDT_WRP_MrrRequest.HDT_WRP_Object>();
            objectsList.add(objects);

            HDT_WRP_MrrRequest.HDT_WRP_Request request = new HDT_WRP_MrrRequest.HDT_WRP_Request();
            request.objects = objectsList;
            
            HDT_WRP_MrrResponse.HDT_WRP_Response mrrResponseItem = new HDT_WRP_MrrResponse.HDT_WRP_Response();
            mrrResponseItem.objects = new List<HDT_WRP_MrrResponse.HDT_WRP_Object>();

            HDT_WRP_MrrResponse.HDT_WRP_Object responseObjects = new HDT_WRP_MrrResponse.HDT_WRP_Object();
            responseObjects.fields = new List<HDT_WRP_MrrResponse.HDT_WRP_Field>(); 

            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            req.requestURI = 'https://na11.salesforce.com';
            req.httpMethod = 'POST';
            RestContext.request = req;
            RestContext.response = res;

            HDT_WRP_MrrResponse.HDT_WRP_Response mrrResponseLeadProcess = HDT_UTL_LeadProcess.formSol(request, mrrResponseItem, responseObjects);
            
            Test.stopTest();

            System.assertEquals(false, mrrResponseLeadProcess.objects.isEmpty(), 'Response filled');
            System.assertNotEquals(true, mrrResponseLeadProcess.objects.isEmpty(), 'Response empty');
        }
    }
	
    @isTest
    public static void testFormSolEmptyCampaign() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){

            HDT_WS_HTTPServiceCallMock mock = new HDT_WS_HTTPServiceCallMock();
            Test.setMock(HttpCalloutMock.class, mock); 
            Test.startTest();

            List<Campaign> cmpList = [SELECT Id FROM Campaign WHERE Name = 'LEAD CALLBACK'];
            delete cmpList;

            HDT_WRP_MrrRequest.HDT_WRP_Field field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            List<HDT_WRP_MrrRequest.HDT_WRP_Field> fieldList = new List<HDT_WRP_MrrRequest.HDT_WRP_Field>();
            
            field.name = 'COMPANYOWNER';
            field.value = 'MMS';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'CELLULARE';
            field.value = '39381516381';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'CONSENSOMARKETING';
            field.value = 'SI';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'VERSINFOMARKET';
            field.value = 'privacyVersionTest';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'FONTECONSENSOMRK';
            field.value = 'Webform callback';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'INIZIATIVACONSMARK';
            field.value = 'sito standard';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'COMPANYCONSENSOMARKETING';
            field.value = 'MMS';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'FONTE';
            field.value = 'Webform callback';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'DETTAGLIOFONTE';
            field.value = 'sito standard';
            fieldList.add(field);
            
            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'AGENZIA';
            field.value = 'codeTest';
            fieldList.add(field);

            field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            field.name = 'D_O_RICONTATTO';
            field.value = '2021-10-01 T20:Z03:58';
            fieldList.add(field);
            
            HDT_WRP_MrrRequest.HDT_WRP_Object objects = new HDT_WRP_MrrRequest.HDT_WRP_Object();
            objects.fields = fieldList;

            List<HDT_WRP_MrrRequest.HDT_WRP_Object> objectsList = new List<HDT_WRP_MrrRequest.HDT_WRP_Object>();
            objectsList.add(objects);

            HDT_WRP_MrrRequest.HDT_WRP_Request request = new HDT_WRP_MrrRequest.HDT_WRP_Request();
            request.objects = objectsList;
            
            HDT_WRP_MrrResponse.HDT_WRP_Response mrrResponseItem = new HDT_WRP_MrrResponse.HDT_WRP_Response();
            mrrResponseItem.objects = new List<HDT_WRP_MrrResponse.HDT_WRP_Object>();

            HDT_WRP_MrrResponse.HDT_WRP_Object responseObjects = new HDT_WRP_MrrResponse.HDT_WRP_Object();
            responseObjects.fields = new List<HDT_WRP_MrrResponse.HDT_WRP_Field>(); 

            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            req.requestURI = 'https://na11.salesforce.com';
            req.httpMethod = 'POST';
            RestContext.request = req;
            RestContext.response = res;

            HDT_WRP_MrrResponse.HDT_WRP_Response mrrResponseLeadProcess = HDT_UTL_LeadProcess.formSol(request, mrrResponseItem, responseObjects);
            
            Test.stopTest();

            System.assertEquals(false, mrrResponseLeadProcess.objects.isEmpty(), 'Response filled');
            System.assertNotEquals(true, mrrResponseLeadProcess.objects.isEmpty(), 'Response empty');
        }
    }

    @isTest
    public static void testFormSolIsValidatedFalse() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){

            HDT_WS_HTTPServiceCallMock mock = new HDT_WS_HTTPServiceCallMock();
            Test.setMock(HttpCalloutMock.class, mock); 
            Test.startTest();

            HDT_WRP_MrrRequest.HDT_WRP_Field field = new HDT_WRP_MrrRequest.HDT_WRP_Field();
            List<HDT_WRP_MrrRequest.HDT_WRP_Field> fieldList = new List<HDT_WRP_MrrRequest.HDT_WRP_Field>();
            
            field.name = 'COMPANYOWNER';
            field.value = 'MMS';
            fieldList.add(field);
            
            HDT_WRP_MrrRequest.HDT_WRP_Object objects = new HDT_WRP_MrrRequest.HDT_WRP_Object();
            objects.fields = fieldList;

            List<HDT_WRP_MrrRequest.HDT_WRP_Object> objectsList = new List<HDT_WRP_MrrRequest.HDT_WRP_Object>();
            objectsList.add(objects);

            HDT_WRP_MrrRequest.HDT_WRP_Request request = new HDT_WRP_MrrRequest.HDT_WRP_Request();
            request.objects = objectsList;
            
            HDT_WRP_MrrResponse.HDT_WRP_Response mrrResponseItem = new HDT_WRP_MrrResponse.HDT_WRP_Response();
            mrrResponseItem.objects = new List<HDT_WRP_MrrResponse.HDT_WRP_Object>();

            HDT_WRP_MrrResponse.HDT_WRP_Object responseObjects = new HDT_WRP_MrrResponse.HDT_WRP_Object();
            responseObjects.fields = new List<HDT_WRP_MrrResponse.HDT_WRP_Field>(); 

            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            req.requestURI = 'https://na11.salesforce.com';
            req.httpMethod = 'POST';
            RestContext.request = req;
            RestContext.response = res;

            HDT_WRP_MrrResponse.HDT_WRP_Response mrrResponseLeadProcess = HDT_UTL_LeadProcess.formSol(request, mrrResponseItem, responseObjects);
            
            Test.stopTest();

            System.assertEquals(false, mrrResponseLeadProcess.objects.isEmpty(), 'Response filled');
            System.assertNotEquals(true, mrrResponseLeadProcess.objects.isEmpty(), 'Response empty');
        }
    }

    @isTest
    public static void testFormSolRequestObjectsEmpty() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){

            HDT_WS_HTTPServiceCallMock mock = new HDT_WS_HTTPServiceCallMock();
            Test.setMock(HttpCalloutMock.class, mock); 
            Test.startTest();

            HDT_WRP_MrrRequest.HDT_WRP_Request request = new HDT_WRP_MrrRequest.HDT_WRP_Request();
            request.objects = null;
            
            HDT_WRP_MrrResponse.HDT_WRP_Response mrrResponseItem = new HDT_WRP_MrrResponse.HDT_WRP_Response();
            mrrResponseItem.objects = new List<HDT_WRP_MrrResponse.HDT_WRP_Object>();

            HDT_WRP_MrrResponse.HDT_WRP_Object responseObjects = new HDT_WRP_MrrResponse.HDT_WRP_Object();
            responseObjects.fields = new List<HDT_WRP_MrrResponse.HDT_WRP_Field>(); 

            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            req.requestURI = 'https://na11.salesforce.com';
            req.httpMethod = 'POST';
            RestContext.request = req;
            RestContext.response = res;

            HDT_WRP_MrrResponse.HDT_WRP_Response mrrResponseLeadProcess = HDT_UTL_LeadProcess.formHvac(request, mrrResponseItem, responseObjects);
            
            Test.stopTest();

            System.assertEquals(false, mrrResponseLeadProcess.objects.isEmpty(), 'Response filled');
            System.assertNotEquals(true, mrrResponseLeadProcess.objects.isEmpty(), 'Response empty');
        }
    }
}