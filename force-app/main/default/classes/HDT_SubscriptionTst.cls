/**
 * @author Valere (valere@noeli-it.net)
 * @date 24/09/2021
 * @description HDT_Subscription Test Class
 * @history valere - 24/09/2021– Created Class
 */
@isTest
private class HDT_SubscriptionTst {

    @testSetup 
    static void setup() {
        List<Account> accountList= HDT_UTL_DataFactoryTst.createAccountResidenziale(1,true,'HERA COMM','Persona fisica','Famiglie');
        HDT_UTL_DataFactoryTst.createContract(1, true, accountList[0].Id);
        HDT_UTL_DataFactoryTst.createServicePoint(1, true);
    } 



    @isTest 
    static void testDeleteAccountWithOnesubscriptionortunity() {
        List<Account> accountList=[SELECT Id FROM Account ];
        List<Contract> contracts=[SELECT Id FROM Contract ];
        List<ServicePoint__c> sps=[SELECT Id FROM ServicePoint__c ];
        Test.startTest();
        List<SBQQ__Subscription__c> subscriptions = HDT_UTL_DataFactoryTst.createSubscription(1, true, accountList[0].Id, contracts[0].Id, sps[0].Id);
        Test.stopTest();
        List<SBQQ__Subscription__c> tSubs=[SELECT Id, SBQQ__Account__c,SBQQ__Product__c
			                          FROM SBQQ__Subscription__c
			                          WHERE Id=:subscriptions[0].Id];

        System.assertEquals(false, tSubs[0].SBQQ__Product__c!=null, 'SBQQ__Product__c has not been provided creating the subscription');
        System.assertNotEquals(false, tSubs[0].SBQQ__Account__c==accountList[0].Id,'SBQQ__Account__c has  been provided creating the subscription');
    }
    
}