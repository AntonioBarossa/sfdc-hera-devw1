/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 23/09/2021
 * @description HDT_BA_PraxidiaReclami Test Class
 * @history Fabricio Petkevicius Nunes – 23/09/2021 – Created Class
 */
@isTest
public with sharing class HDT_BA_PraxidiaReclamiTst {
    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();
    private static HDT_WS_HTTPServiceCallMock mock = new HDT_WS_HTTPServiceCallMock();

	@TestSetup
    static void setup(){

        HDT_UTL_DataFactoryTst.pClickInstance();
        HDT_UTL_DataFactoryTst.pClickCasePhase();

        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
        User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, true); 

        System.runAs(internalUser) {

            List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
            List<Order> orderList = HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].Id, 'Bozza');
            List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].Id);
            List<ServicePoint__c> spList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
            List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].Id);
            List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, false, accList[0].Id, contactList[0].Id, spList[0].Id, contractList[0].Id, orderList[0].Id);
            caseList[0].Cluster__c = 'Reclami';
            insert caseList;
            
            List<wrts_prcgvr__Activity__c> actCust = HDT_UTL_DataFactoryTst.createActivityCustom(1, false, accList[0].Id);
            actCust[0].Case__c = caseList[0].Id;
            insert actCust;

            HDT_UTL_DataFactoryTst.createWebServiceConfiguration('PraxidiaIntegration', 'end', 'method', 'testUser');
            HDT_UTL_DataFactoryTst.createWebServiceCredential('testUser', '12345', 'usernameTest');
        }
    }

	@isTest
    public static void testBatch() {

        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];

        System.runAs(u){
            
            Test.setMock(HttpCalloutMock.class, mock);

            List<Order> orders = [SELECT Id, CreatedDate FROM Order WHERE Phase__c = 'Bozza'];
            List<Case> cases = [SELECT Id, CreatedDate, Cluster__c FROM Case WHERE Phase__c = 'Bozza'];

            Test.setCreatedDate(orders[0].Id, Datetime.now().addDays(-7));
            Test.setCreatedDate(cases[0].Id, Datetime.now().addDays(-7));

            Test.startTest();

            orders = [SELECT Id, CreatedDate FROM Order WHERE Phase__c = 'Bozza'];
            cases = [SELECT Id, CreatedDate, AccountId, CompanyOwner__c, creatorGroup__c, CustomerRequestDate__c, ClosedDate, cluster__c, commodityFormula__c, SupplyType__c, Account.category__c, Account.customerCode__c, status, origin, IsReiteration__c, subprocess__c, CustomerRequestNumberDay__c, IndemnityConfirmed__c, Account.segment__c, ServicePoint__r.SupplyCity__c, CorrectionRight__c, parentId, MotivatedResponseSendMode__c, phase__c FROM Case WHERE Phase__c = 'Bozza'];

            HDT_BA_PraxidiaReclami pr = new HDT_BA_PraxidiaReclami();

            Database.BatchableContext btCont;
            pr.start(btCont);
            pr.execute(btCont, cases);
            pr.finish(btCont);

            Test.stopTest();

            List<ContentVersion> cv = [SELECT Id FROM ContentVersion];

            System.assertEquals(false, cv.isEmpty(), 'Content Version created');
            System.assertNotEquals(true, cv.isEmpty(), 'Content Version not created');
        }
    }	
}