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
        List<FUBProcessing__c> fubProcessingList = HDT_UTL_DataFactoryTst.createfubProcessing(1, true, 'Archivio FUB da importare');
        HDT_UTL_DataFactoryTst.createFubProcessingItem(1, true, cmpList[0].Id, fubProcessingList[0].Id);
        List<Individual> indList = HDT_UTL_DataFactoryTst.createIndividual(1, true);
        HDT_UTL_DataFactoryTst.createContactPointPhone(1, true, indList[0].Id);

        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, false, accList[0].Id);
        contactList[0].IndividualId = indList[0].Id;
        insert contactList;

        List<CampaignMember> cmpMemberList = HDT_UTL_DataFactoryTst.createCampaignMember(false, cmpList[0].Id, leadList, contactList);
        cmpMemberList[0].PhoneNumber__c = '562782429';
        cmpMemberList[0].ExcludeFub__c = 'NO';

        insert cmpMemberList;
    }

    @isTest
    public static void testFubArchiveImportBatch() {

        Test.startTest();

        Id fubProcessingId = [SELECT Id FROM FUBProcessing__c WHERE Status__c = 'Archivio FUB da importare'].Id;

        Boolean fubArcImpCtrl = HDT_LC_FubArchiveImportController.fubArchiveImportBatch(fubProcessingId, '123456789, 987654312');

        System.assertEquals(true, fubArcImpCtrl, 'Batch process succeded.');

        System.assertNotEquals(false, fubArcImpCtrl, 'Batch process failed.');

        Test.stopTest();
    }
}
