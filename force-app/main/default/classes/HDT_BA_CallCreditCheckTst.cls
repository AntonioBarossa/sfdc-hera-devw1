/*
    @Author:        Francesco Vitiello
    CreatedDate:    09/02/2022
    Reason: Classe che testa il Batch HDT_BA_CallCreditCheck
*/
@isTest
public class HDT_BA_CallCreditCheckTst {

    //DEBUG
    public static final String TEST_NAME = 'HDT_BA_CallCreditCheckTst';
    private static HDT_UTL_Constants utlConstants = new HDT_UTL_Constants();
    
    @TestSetup
    static void setup(){

        HDT_UTL_DataFactoryTst.createWebServiceConfiguration ('CreditCheck', 'endpoint', 'method', 'Other');

        HDT_UTL_DataFactoryTst.pClickOrderPhase();

        String uniqueUserName = 'systemAdmin' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name =: utlConstants.SYSTEM_ADMINISTRATOR_NAME ];
        User u = new User(Alias = 'sysAdmin', Email='systemadministrator@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles',
        UserName=uniqueUserName);
        insert u;
        
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        accList[0].Category__c = 'Famiglie';
        accList[0].CustomerType__c = 'Persona Fisica';
        accList[0].VATNumber__c = '40019570510';
        accList[0].CustomerCode__c = '1001433566';
        accList[0].FiscalCode__c = 'STTCFR80A01F205Q';
        accList[0].Name = 'CeLaFaremo StateACasa';
        accList[0].FirstName__c = 'CeLaFaremo';
        accList[0].LastName__c = 'StateACasa';
        accList[0].CustomerMarking__c = 'D1 - Persona fisica';
        update accList;

        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].id, 'Bozza');
        ordList[0].AnnualConsumption__c = 1000;
        ordList[0].SupplyPostalCode__c = '67050';
        ordList[0].ProcessType__c = 'Prima Attivazione Ele';
        ordList[0].Catalog__c = 'myCatalog';
        ordList[0].SupplyCity__c = 'MORINO';
        ordList[0].Market__c = 'Libero';
        ordList[0].SupplyState__c = 'AQ';
        ordList[0].Commodity__c = 'ENERGIA ELETTRICA';
        ordList[0].SalesCompany__c = 'Hera Comm S.p.A.';
        ordList[0].CustomerType__c = 'Persona Fisica';
        ordList[0].SupplyStreetName__c = 'VIA DELLA VITTORIA';
        update ordList;

        List<wrts_prcgvr__Activity__c> actList = HDT_UTL_DataFactoryTst.createActivityCustom(1, true, accList[0].Id);
        String rtId = Schema.SObjectType.wrts_prcgvr__Activity__c.getRecordTypeInfosByDeveloperName().get('HDT_RT_CreditCheckKO').getRecordTypeId();
        actList[0].RecordTypeId = rtId;
        actList[0].Order__c = ordList[0].Id;
        actList[0].wrts_prcgvr__Status__c = 'Aperta';
        actList[0].StartDate__c = Date.today().addDays(-65);
        System.runAs(u) {
            PermissionSet ps = [SELECT Id, Name FROM PermissionSet WHERE Name = 'HDT_EnableCreditCheck'];
            insert new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = ps.Id);      
        }
        System.runAs(u) {
            update actList;
        }
    }

    @IsTest
    static void testBatchExecution(){

        Test.setMock(HttpCalloutMock.class, new HDT_BA_CallCreditCheckTstMock());

        Test.startTest();           

        HDT_BA_CallCreditCheck psm = new HDT_BA_CallCreditCheck();        

        Database.executeBatch(psm);

        Test.stopTest();

        wrts_prcgvr__Activity__c updatedActivity = [SELECT Id FROM wrts_prcgvr__Activity__c LIMIT 1];
        System.assert(updatedActivity!=null, 'Nessuna Activity!');
    }

    public class HDT_BA_CallCreditCheckTstMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"status": "success","correlationId": "8a5e46d0-89ab-11ec-95b9-06fc2e5eeefa","timestamp": "2022-02-09T14:24:00","result": {"applicationGuid": "8ac0b238-89ab-11ec-a510-0050569f","applicationId": "14709","identificativoCrm": "8011j000006vfpS","responseStatus": "SUCCESS","errorDescription": {},"errorTimestamp": "0"}}');
            response.setStatusCode(200);
            response.setStatus('OK');
            return response; 
        }
    }


}

