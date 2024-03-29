/**
* @author Luis Bispo (luis.bispo@engdb.com.br)
* @date 20/09/2021
* @description HDT_LC_CambioUso for Test Classes
* @history Luis Bispo – 20/09/2021 – Created class
*/
@isTest
public with sharing class HDT_LC_CambioUsoTst {
    
    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();

    @TestSetup
    static void setup(){
        
        Id adminUserProfileId = HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
 
        User internalUser = HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
 
        internalUser.UserPermissionsMarketingUser=true;
 
        insert internalUser;
 
        System.runAs(internalUser) {
            List<Account> accountList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
            List<BillingProfile__c> bpList = HDT_UTL_DataFactoryTst.createBillingProfile(1, true, accountList[0].Id);
            List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accountList[0].Id);
            List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, false);
            servPointList[0].Account__c = accountList[0].Id;
            insert servPointList;
            List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, false, accountList[0].Id);
            contractList[0].ServicePoint__c = servPointList[0].Id;
            contractList[0].billingProfile__c = bpList[0].Id;
            insert contractList;
            List<Order> orderList = HDT_UTL_DataFactoryTst.createOrder(1, true, accountList[0].Id, 'Bozza');
            HDT_UTL_DataFactoryTst.createCase(1, true, accountList[0].Id, contactList[0].Id, servPointList[0].Id, contractList[0].Id, orderList[0].Id);
    
        }
    }

    @isTest
    static void testUpdateCase() {
        User tUser = [SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1]; 
        System.runAs(tUser){

            Test.startTest();

            Case tCase = [SELECT Id,SupplyType__c, PhoneNumber__c, ServicePointType__c, Resident__c, Note__c, Phase__c, Status, Disconnectable__c, DisconnectibilityType__c FROM Case LIMIT 1];
            Boolean successCase = HDT_LC_CambioUso.updateCase((String) tCase.Id,'Si', tCase.SupplyType__c, tCase.PhoneNumber__c, tCase.ServicePointType__c, tCase.Resident__c, tCase.Note__c, tcase.Disconnectable__c, tcase.DisconnectibilityType__c); //Updated method signature
            
            System.assertEquals(true, successCase != null, 'sucessCase is not null');
			System.assertNotEquals(true, successCase == null, 'sucessCase is null');
            Test.stopTest();
        }
    }
}
