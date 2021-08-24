/**
 * @author Lucas da Silva Fernandes (lucas.dasilva@engdb.com.br)
 * @date 24/08/2021
 * @description HDT_QR_ContactPoint Test Classes
 * @history Lucas da Silva Fernandes – 24/08/2021 – Created Class
 */

@isTest
public with sharing class HDT_QR_ContactPointTst {

    @TestSetup
    static void setup(){
        
        List<Individual> ind = HDT_UTL_DataFactoryTst.createIndividual(1, true);
        List<ContactPointPhone> cppList = HDT_UTL_DataFactoryTst.createContactPointPhone(1, false, ind[0].Id);
        cppList[0].PhoneType = 'Home';
        insert cppList;

        List<ContactPointEmail> cpeList = HDT_UTL_DataFactoryTst.createContactPointEmail(1, false, ind[0].Id);
        cpeList[0].Type__c = 'E-mail SOL';
        insert cpeList;

    }

    @isTest
    public static void testGetContactPhoneById() {

        Test.startTest();

        ContactPointPhone contact = [SELECT Id FROM ContactPointPhone WHERE TelephoneNumber = '982591380'];

        ContactPointPhone cpp = HDT_QR_ContactPoint.getContactPhoneById(contact.Id, 'Id');

        System.assertEquals(contact.Id, cpp.Id, 'ContactPointPhone successfully retrieved');
        System.assertNotEquals(null, cpp.Id, 'ContactPointPhone not found');

        Test.stopTest();
    }

    @isTest
    public static void testGetPrimaryContactEmailByIndividual() {

        Test.startTest();

        ContactPointPhone contact = [SELECT Id, ParentId FROM ContactPointPhone WHERE TelephoneNumber = '982591380'];

        ContactPointPhone cpp = HDT_QR_ContactPoint.getPrimaryContactEmailByIndividual(contact.ParentId, 'Id');
        System.debug('cpp: '+cpp);

        System.assertEquals(contact.Id, cpp.Id, 'ContactPointPhone successfully retrieved');
        System.assertNotEquals(null, cpp.Id, 'ContactPointPhone not found');

        Test.stopTest();
    }

    @isTest
    public static void testGetIndividualContactPhoneList() {

        Test.startTest();

        ContactPointPhone contact = [SELECT Id, ParentId FROM ContactPointPhone WHERE TelephoneNumber = '982591380'];

        List<ContactPointPhone> cpp = HDT_QR_ContactPoint.getIndividualContactPhoneList(contact.ParentId, 'Id');

        System.assertEquals(contact.Id, cpp[0].Id, 'ContactPointPhone successfully retrieved');
        System.assertNotEquals(null, cpp[0].Id, 'ContactPointPhone not found');

        Test.stopTest();
    }

    @isTest
    public static void testGetIndividualContactsPhoneList() {

        Test.startTest();

        ContactPointPhone contact = [SELECT Id, ParentId FROM ContactPointPhone WHERE TelephoneNumber = '982591380'];

        List<String> cppId = new List<String>();

        String st = String.valueOf(contact.ParentId);
        System.debug('st: '+st);
        cppId.add(st);

        List<ContactPointPhone> cpp = HDT_QR_ContactPoint.getIndividualContactsPhoneList(cppId, 'Id');

        System.assertEquals(contact.Id, cpp[0].Id, 'ContactPointPhone successfully retrieved');
        System.assertNotEquals(null, cpp[0].Id, 'ContactPointPhone not found');

        Test.stopTest();
    }

    @isTest
    public static void testGetIndividualContactsEmailListWithIdList() {

        Test.startTest();

        ContactPointEmail email = [SELECT Id, ParentId FROM ContactPointEmail WHERE EmailAddress = 'sales@force.com'];

        List<String> cpeId = new List<String>();

        String st = String.valueOf(email.ParentId);
        cpeId.add(st);

        List<ContactPointEmail> cpeList = HDT_QR_ContactPoint.getIndividualContactsEmailList(cpeId, 'Id');

        System.assertEquals(email.Id, cpeList[0].Id, 'ContactPointEmail successfully retrieved');
        System.assertNotEquals(null, cpeList[0].Id, 'ContactPointEmail not found');

        Test.stopTest();
    }

    @isTest
    public static void testGetIndividualContactEmailList() {

        Test.startTest();

        ContactPointEmail email = [SELECT Id, ParentId FROM ContactPointEmail WHERE EmailAddress = 'sales@force.com'];

        List<ContactPointEmail> cpeList = HDT_QR_ContactPoint.getIndividualContactEmailList(email.ParentId, 'Id');

        System.assertEquals(email.Id, cpeList[0].Id, 'ContactPointEmail successfully retrieved');
        System.assertNotEquals(null, cpeList[0].Id, 'ContactPointEmail not found');

        Test.stopTest();
    }

    /*
    @isTest
    public static void testGetContactEmailByPhone() {

        Test.startTest();

        ContactPointPhone contact = [SELECT Id, ParentId, TelephoneNumber FROM ContactPointPhone WHERE TelephoneNumber = '982591380'];

        ContactPointPhone cpp = HDT_QR_ContactPoint.getContactEmailByPhone(contact.TelephoneNumber, contact.ParentId, 'Id');

        System.assertEquals(contact.Id, cpp.Id, 'ContactPointPhone successfully retrieved');
        System.assertNotEquals(null, cpp.Id, 'ContactPointPhone not found');

        Test.stopTest();
    } */

    // @isTest
    // public static void testGetContactEmailById() {

    //     Test.startTest();



    //     Test.stopTest();
    // }

    @isTest
    public static void testSearchContactPointEmail() {

        Test.startTest();

        ContactPointEmail email = [SELECT Id, EmailAddress FROM ContactPointEmail WHERE EmailAddress = 'sales@force.com'];

        ContactPointEmail cpeList = HDT_QR_ContactPoint.searchContactPointEmail(email.EmailAddress);

        System.assertEquals(email.Id, cpeList.Id, 'ContactPointEmail successfully retrieved');
        System.assertNotEquals(null, cpeList.Id, 'ContactPointEmail not found');

        Test.stopTest();
    }

    @isTest
    public static void testSearchContactPointEmailSOL() {

        Test.startTest();

        ContactPointEmail email = [SELECT Id, EmailAddress, Type__c FROM ContactPointEmail WHERE EmailAddress = 'sales@force.com'];

        ContactPointEmail cpeList = HDT_QR_ContactPoint.searchContactPointEmailSOL(email.EmailAddress);

        System.assertEquals(email.Id, cpeList.Id, 'ContactPointEmail successfully retrieved');
        System.assertNotEquals(null, cpeList.Id, 'ContactPointEmail not found');

        Test.stopTest();
    }

    @isTest
    public static void testSearchPointPhone() {

        Test.startTest();

        ContactPointPhone contact = [SELECT Id, ParentId FROM ContactPointPhone WHERE TelephoneNumber = '982591380'];

        List<ContactPointPhone> cpp = HDT_QR_ContactPoint.searchPointPhone(contact.ParentId);

        System.assertEquals(contact.Id, cpp[0].Id, 'ContactPointPhone successfully retrieved');
        System.assertNotEquals(null, cpp[0].Id, 'ContactPointPhone not found');

        Test.stopTest();
    }

    @isTest
    public static void testSearchContactPointPhone() {

        Test.startTest();

        ContactPointPhone contact = [SELECT Id, PhoneType FROM ContactPointPhone WHERE TelephoneNumber = '982591380'];

        ContactPointPhone cpp = HDT_QR_ContactPoint.searchContactPointPhone(contact.PhoneType);

        System.assertEquals(contact.Id, cpp.Id, 'ContactPointPhone successfully retrieved');
        System.assertNotEquals(null, cpp.Id, 'ContactPointPhone not found');

        Test.stopTest();
    }

    @isTest
    public static void testSearchPointEmail() {

        Test.startTest();

        ContactPointEmail email = [SELECT Id, ParentId FROM ContactPointEmail WHERE EmailAddress = 'sales@force.com'];

        List<ContactPointEmail> cpeList = HDT_QR_ContactPoint.searchPointEmail(email.ParentId);

        System.assertEquals(email.Id, cpeList[0].Id, 'ContactPointEmail successfully retrieved');
        System.assertNotEquals(null, cpeList[0].Id, 'ContactPointEmail not found');

        Test.stopTest();
    }

    @isTest
    public static void testGetOldContactEmails() {

        Test.startTest();

        ContactPointEmail email = [SELECT Id, ParentId, EmailAddress FROM ContactPointEmail WHERE EmailAddress = 'sales@force.com'];

        List<String> cpeId = new List<String>();

        String st = String.valueOf(email.ParentId);
        cpeId.add(st);

        List<String> cpemail = new List<String>();
        cpemail.add(email.EmailAddress);

        List<ContactPointEmail> cpeList = HDT_QR_ContactPoint.getOldContactEmails(cpeId, cpemail);

        System.assertEquals(email.Id, cpeList[0].Id, 'ContactPointEmail successfully retrieved');
        System.assertNotEquals(null, cpeList[0].Id, 'ContactPointEmail not found');

        Test.stopTest();
    }

    @isTest
    public static void testGetOldContactsPhone() {

        Test.startTest();

        ContactPointPhone cpp = [SELECT Id, ParentId, TelephoneNumber FROM ContactPointPhone WHERE TelephoneNumber = '982591380'];

        List<String> cppId = new List<String>();

        String st = String.valueOf(cpp.ParentId);
        cppId.add(st);

        List<String> cpphone = new List<String>();
        cpphone.add(cpp.TelephoneNumber);

        List<ContactPointPhone> cppList = HDT_QR_ContactPoint.getOldContactsPhone(cppId, cpphone);

        System.assertEquals(cpp.Id, cppList[0].Id, 'ContactPointPhone successfully retrieved');
        System.assertNotEquals(null, cppList[0].Id, 'ContactPointPhone not found');

        Test.stopTest();
    }

    @isTest
    public static void testGetContactPointByIdAndObjectType() {

        Test.startTest();

        ContactPointPhone contact = [SELECT Id FROM ContactPointPhone WHERE TelephoneNumber = '982591380'];

        SObject cpp = HDT_QR_ContactPoint.getContactPointByIdAndObjectType('ContactPointPhone', contact.Id, 'Id'); 

        System.assertEquals(contact.Id, cpp.Id, 'ContactPointPhone successfully retrieved');
        System.assertNotEquals(null, cpp.Id, 'ContactPointPhone not found');

        Test.stopTest();
    }
}
