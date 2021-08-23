/**
 * @author Lucas da Silva Fernandes (lucas.dasilva@engdb.com.br)
 * @date 16/08/2021
 * @description HDT_LC_FubArchiveImportController Test Classes
 * @history Lucas Fernandes 16/08/2021 – Created class
 */

 @isTest
public with sharing class HDT_LC_FubArchiveImportControllerTst {
    
    @TestSetup
    static void setup(){

        HDT_UTL_DataFactoryTst.pClickInstance();
        
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Lead> leadList = HDT_UTL_DataFactoryTst.createLead(1, true);
        List<Campaign> cmpList = HDT_UTL_DataFactoryTst.createCampaign(1, true);

        FUBProcessing__c fubProcessing = new FUBProcessing__c(
            Status__c = 'Archivio FUB da importare'
        );
        insert fubProcessing;

        FUBProcessingItem__c fubPItem = new FUBProcessingItem__c(
            Campaign__c = cmpList[0].Id,
            FUBProcessing__c = fubProcessing.Id
        );
        insert fubPItem;

        Individual ind = new Individual(
            FirstName = 'Mama',
            LastName = 'Guzzo'
        );
        insert ind;

        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, false, accList[0].Id);
        contactList[0].IndividualId = ind.Id;
        insert contactList;

        List<CampaignMember> cmpMemberList = HDT_UTL_DataFactoryTst.createCampaignMember(1, false, cmpList[0].Id, leadList[0].Id, contactList[0].Id);
        cmpMemberList[0].PhoneNumber__c = '562782429';
        cmpMemberList[0].ExcludeFub__c = 'NO';

        insert cmpMemberList;

        ContactPointPhone cpp = new ContactPointPhone(
            ParentId = ind.Id,
            TelephoneNumber = '992022286'
        );
        insert cpp;
    }

    @isTest
    public static void testFubArchiveImportBatch() {

        Test.startTest();

        Id fubProcessingId = [SELECT Id FROM FUBProcessing__c WHERE Status__c = 'Archivio FUB da importare'].Id;

        Id accId = [SELECT Id FROM Account WHERE Category__c = 'Aziende SME'].Id;

        Boolean fubArcImpCtrl = HDT_LC_FubArchiveImportController.fubArchiveImportBatch(fubProcessingId, '123456789, 987654312');

        System.assertEquals(true, fubArcImpCtrl, 'Batch process succeded.');

        System.assertNotEquals(false, fubArcImpCtrl, 'Batch process failed.');

        Test.stopTest();
    }
}
