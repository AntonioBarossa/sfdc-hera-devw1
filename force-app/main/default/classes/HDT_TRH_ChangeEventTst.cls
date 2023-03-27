@isTest
public with sharing class HDT_TRH_ChangeEventTst {
    //You can use Test.getEventBus().deliver(); to fire the event.
    //If you don't use deliver() you have to use start and stop. the trigger fire after stop
    private static HDT_UTL_Constants constants=new HDT_UTL_Constants();
    @TestSetup
    static void makeData(){
        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, true);

		System.runAs(internalUser){
            HDT_UTL_DataFactoryTst.pClickInstanceActivityIntegration();
            //Creo l'Account Residenziale
            List<Account> accList = HDT_UTL_DataFactoryTst.createAccountResidenziale(1, false, 'MMS', 'G1 - MMS Persona fisica','Famiglie');
            accList[0].FiscalCode__c = 'BTQTVM40E24A562P';
            insert accList;
            Id accountId = accList[0].Id;

            List<Case> caseTest = HDT_UTL_DataFactoryTst.createCase(1, false, accountId, null, null, null, null);
            insert caseTest;
            List<wrts_prcgvr__Activity__c> actList = HDT_UTL_DataFactoryTst.createActivityCustom(1,false,accountId);
            actList[0].wrts_prcgvr__Status__c = 'Aperta';
            actList[0].Case__c = caseTest[0].Id;
            insert actList;
            List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, accountId, 'Bozza');
        }
    }

    @isTest 
    static void activityChangeEvent(){
        Test.enableChangeDataCapture();
        Test.startTest();
        List<wrts_prcgvr__Activity__c> actList = [SELECT Id, wrts_prcgvr__Status__c FROM wrts_prcgvr__Activity__c];
        actList[0].wrts_prcgvr__Status__c = 'Chiusa';
        List<Case> caseList = [SELECT Id,Status FROM Case];
        caseList[0].Status = 'Closed';
        List<Order> orderList = [SELECT Id,Status FROM Order];
        orderList[0].Status = 'In lavorazione';
        Test.stopTest();
    }
}