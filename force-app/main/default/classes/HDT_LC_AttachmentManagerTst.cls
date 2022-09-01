/**
 * @description       : 
 * @author            : Giacinto Florio
 * @group             : 
 * @last modified on  : 25-08-2022
 * @last modified by  : Giacinto Florio
**/
@isTest
public with sharing class HDT_LC_AttachmentManagerTst {
    @TestSetup
    static void setup(){
        
        HDT_UTL_DataFactoryTst.pClickCasePhase();
        HDT_UTL_DataFactoryTst.pClickOrderPhase();

        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].id, 'Bozza');
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].Id);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].id);
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);    
    }

    @isTest
    public static void getAdditionalAttachmentCaseTest() {

        Case caso = [SELECT Id, AdditionalAttachments__c FROM Case LIMIT 1];
        caso.AdditionalAttachments__c='Allegato';
        update caso;
        Test.startTest();
        HDT_LC_AttachmentManager.getAdditionalAttachment(caso.Id);
        System.assertEquals(caso.AdditionalAttachments__c, 'Allegato', 'Allegato!');
        Test.stopTest();
    }

    @isTest
    public static void getAdditionalAttachmentOrderTest() {

        Order order = [SELECT Id, AdditionalAttachments__c FROM Order LIMIT 1];
        order.AdditionalAttachments__c='Allegato';
        update order;
        Test.startTest();
        HDT_LC_AttachmentManager.getAdditionalAttachment(order.Id);
        System.assertEquals(order.AdditionalAttachments__c, 'Allegato','Allegato!');
        Test.stopTest();
    }

    @isTest
    public static void getOrderForButtonTest() {

        Order order = [SELECT Id, AdditionalAttachments__c FROM Order LIMIT 1];
        order.BillingCity__c = 'Roma';
        update order;
        Test.startTest();
        HDT_LC_AttachmentManager result = HDT_LC_AttachmentManager.getOrderForButton(order.Id);
        System.assertEquals(result.city, 'Roma','Test!');
        Test.stopTest();
    }

    @isTest
    public static void getRecordsToCheckTest() {

        Case caso = [SELECT Id FROM Case LIMIT 1];
        caso.Surface__c = 100;
        update caso;
        Test.startTest();
        Case obj = (Case) HDT_LC_AttachmentManager.getRecordsToCheck(caso.Id);
        System.assertEquals(obj.Surface__c, 100,'Test!');
        Test.stopTest();

    }
}
