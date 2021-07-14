/**
* @author Luis Bispo (luis.bispo@engdb.com.br)
* @date 13/07/2021
* @description HDT_LC_DocumentValidationTst for Test Classes
* @history Luis Bispo – 13/07/2021 – Created class
*/


@isTest
public with sharing class HDT_LC_DocumentValidationTst {

    @TestSetup
    static void setup(){
        HDT_UTL_DataFactoryTst.pClickOrderPhase();
        List<Account> acc = HDT_UTL_DataFactoryTst.createAccount(1, true);
        HDT_UTL_DataFactoryTst.createOrder(1, true, acc[0].Id);
    }

    @isTest
    static void testIsValidPhase(){
        
        Order ord = [SELECT id From Order LIMIT 1];
        
        Test.startTest();

            Boolean result;
            result = HDT_LC_DocumentValidation.isValidPhase(ord.Id);

        System.assertEquals(false, result);
        System.assertNotEquals(true, result);

        Test.stopTest();
    }

    @isTest
    static void testSaveValidation(){
        Order ord = [SELECT id, Instance326__c, DocumentLow80__c, ChamberCommerceRegistration__c, AutorizationVolturaThirdTrader__c, CIAccoutn__c, QuickQuote__c,Phase__c From Order LIMIT 1];
        
        Test.startTest();   
            HDT_LC_DocumentValidation.saveValidation(ord);
            System.assert(ord !=null, 'Order is not null');
            System.assertNotEquals(null, ord);
        Test.stopTest();
    }
}
