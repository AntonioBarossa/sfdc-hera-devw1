/**
 * @author Sabina Levonja (sabina.levonja@dunegroup.it)
 * @date 12/10/2021
 * @description HDT_BA_PublicValidation Test Class
 * @history Sabina Levonja – 12/10/2021 – Created Class
 */

@isTest
public with sharing class HDT_BA_PublicValidationTst {

    @TestSetup
    static void setup(){
        
		HDT_UTL_DataFactoryTst.pClickOrderPhase();
        List<Account> accList=HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
		List<Contact> conList = HDT_UTL_DataFactoryTst.createContact(1,true,accList[0].Id);
		List<Sale__c> sales=HDT_UTL_DataFactoryTst.createSale(1, true, accList[0].Id, 'Attiva');
		List<Order> orders=HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].Id, 'Bozza');
		HDT_UTL_DataFactoryTst.createChildOrder(1, true, accList[0].Id, sales, orders[0].Id, conList[0].Id);
        HDT_UTL_DataFactoryTst.createVocalOrderPublicConfirm(1,true,'Nuova',orders[0].Id);
	}
    @isTest
    public static void testBatch() {
        Test.startTest();

        HDT_BA_PublicValidation publicVal = new HDT_BA_PublicValidation();
        Database.executeBatch(publicVal);
                
        Test.stopTest();
        
        Order ord = [SELECT Id, MethodSignedAccepted__c from Order limit 1];
        VocalOrderPublicConfirm__c vcOrd= [SELECT Id,Order__c,Status__c,Createddate FROM VocalOrderPublicConfirm__c limit 1];

        System.assertEquals('web assistito', ord.MethodSignedAccepted__c ,'The MethodSignedAccepted__c field has not been updated');
        System.assertNotEquals('Nuova', vcOrd.Status__c ,'The Status__c of VocalOrderPublicConfirm__c has not been updated');

    }
    
}