/**
* @author Luis Bispo (luis.bispo@engdb.com.br)
* @date 20/09/2021
* @description HDT_LC_ConfigurePaymentMethods for Test Classes
* @history Luis Bispo – 20/09/2021 – Created class
*/
@isTest
public with sharing class HDT_LC_ConfigurePaymentMethodsTst {
    
    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();

    @TestSetup
    static void setup(){

        HDT_UTL_DataFactoryTst.pClickInstanceActivityIntegration();
        
        Id adminUserProfileId = HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
 
        User internalUser = HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
 
        internalUser.UserPermissionsMarketingUser=true;
 
        insert internalUser;
 
        System.runAs(internalUser) {
            HDT_UTL_DataFactoryTst.pClickInstanceActivityIntegration();
            //seu testSetup   
            List<Account> accountList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
            List<Sale__c> saleList = HDT_UTL_DataFactoryTst.createSale(1, true, accountList[0].id, 'Bozza');
			List<Opportunity> oppList = HDT_UTL_DataFactoryTst.createOpportunity(1, true);
            List<Order> orderList = HDT_UTL_DataFactoryTst.createOrder(1, false, accountList[0].Id,'Bozza');
            List<SBQQ__Quote__c> quoteList = HDT_UTL_DataFactoryTst.createQuote(1, true, orderList[0].Id, oppList[0].Id, saleList[0].Id, 'Amendment');
            List<wrts_prcgvr__Activity__c> activityCustomList = HDT_UTL_DataFactoryTst.createActivityCustom(1, false, accountList[0].id);
			activityCustomList[0].Type__c = 'Approvazione Offerte';
            activityCustomList[0].wrts_prcgvr__Status__c = 'Aperta';
            activityCustomList[0].Sale__c = saleList[0].id;
            activityCustomList[0].Approved__c = 'No';
			insert activityCustomList;
        }
    }   

    @isTest
    static void testDisableMyButtonsSuccess() {
        User tUser = [SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1]; 
        System.runAs(tUser){

            Test.startTest(); 

            Account tAccount = [SELECT Id FROM Account LIMIT 1];
            wrts_prcgvr__Activity__c tActivityCust = [SELECT Id, Type__c, wrts_prcgvr__Status__c, Sale__c, Approved__c FROM wrts_prcgvr__Activity__c LIMIT 1];
            Sale__c tSale = [SELECT Id FROM Sale__c LIMIT 1];
            
            Boolean result = HDT_LC_ConfigurePaymentMethods.disableMyButtons(tSale);
            
            System.assertEquals(false, result, 'testDisableMyButtonsSuccess not populated correctly');
            System.assertNotEquals(true, result, 'testDisableMyButtonsSuccess not populated correctly');
            Test.stopTest();
        }
    }

    @isTest
    static void testDisableBottonSuccess() {
        User tUser = [SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1]; 
        System.runAs(tUser){

            Test.startTest(); 

            Account tAccount = [SELECT Id FROM Account LIMIT 1];
            wrts_prcgvr__Activity__c tActivityCust = [SELECT Id, Type__c, wrts_prcgvr__Status__c, Sale__c, Approved__c FROM wrts_prcgvr__Activity__c LIMIT 1];
            Sale__c tSale = [SELECT Id FROM Sale__c LIMIT 1];
            
            HDT_LC_ConfigurePaymentMethods.disableBotton(tAccount.Id, tSale);
            
            System.assertEquals('No', tActivityCust.Approved__c, 'tActivityCust Approved__c not populated correctly');
            System.assertNotEquals('Si', tActivityCust.Approved__c, 'tActivityCust Approved__c not populated correctly');
            Test.stopTest();
        }
    }

    @isTest
    static void testDisableBottonFail() {
        User tUser = [SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1]; 
        System.runAs(tUser){

            Test.startTest(); 

            Account tAccount = [SELECT Id FROM Account LIMIT 1];
            wrts_prcgvr__Activity__c tActivityCust = [SELECT Id, Type__c, wrts_prcgvr__Status__c, Sale__c, Approved__c FROM wrts_prcgvr__Activity__c LIMIT 1];
            tActivityCust.Approved__c = 'Si';
            update tActivityCust;
            Sale__c tSale = [SELECT Id FROM Sale__c LIMIT 1];
            
            new HDT_LC_ConfigurePaymentMethods();
            HDT_LC_ConfigurePaymentMethods.disableBotton(tAccount.Id, tSale);
            
            System.assertEquals('Si', tActivityCust.Approved__c, 'tActivityCust Approved__c not populated correctly');
            System.assertNotEquals('No', tActivityCust.Approved__c, 'tActivityCust Approved__c not populated correctly');
            Test.stopTest();
        }
    }
}