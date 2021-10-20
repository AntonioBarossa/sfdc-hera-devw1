@isTest
public with sharing class HDT_BA_ImportFubFileTst {
    
    @testSetup 
    static void setup(){
        
        List<Account> testAcc =  HDT_UTL_DataFactoryTst.createAccountPartner(1, false , 'testact');
        testAcc[0].CompanyOwner__c  = 'HERA COMM';
        insert testAcc;

        id acctId = [SELECT id FROM Account WHERE id =: testAcc[0].id ].Id;

        List<Individual>  testInd = HDT_UTL_DataFactoryTst.createIndividual(1,true);
        id indId = [SELECT id FROM Individual WHERE id =: testInd[0].id ].Id;

        List<Contact> testCont =  HDT_UTL_DataFactoryTst.createContact(1, true, acctId);
        testCont[0].IndividualId = indId;
        update testCont;
        id contId = [SELECT id FROM Contact WHERE id =: testCont[0].Id ].id;

        List<Lead> testLead =  HDT_UTL_DataFactoryTst.createLead(1,true);
        id leadId = [SELECT id FROM Lead WHERE id =: testLead[0].Id ].id;

        List<Campaign> camp = HDT_UTL_DataFactoryTst.createCampaign(1,true);
        id campId = [SELECT id FROM Campaign WHERE id =: camp[0].id].id;

        List<FUBProcessing__c> testFubPro = HDT_UTL_DataFactoryTst.createfubProcessing (1, true, 'Archivio FUB da importare');
        id fpId = [SELECT id FROM FUBProcessing__c WHERE id =:testFubPro[0].id].id;


        List<FUBProcessingItem__c> testFubProItem = HDT_UTL_DataFactoryTst.createFubProcessingItem(1,true,campId,fpId);

        List<CampaignMember> listCamps = HDT_UTL_DataFactoryTst.createCampaignMember(1,true,campId,leadId,contId);
        listCamps[0].ExcludeFub__c = 'No';
        listCamps[0].Agency__c = acctId;
        listCamps[0].PhoneNumber__c = '123456';
        listCamps[0].OutcomeFub__c = 'OK';
        listCamps[0].OutcomeDateFub__c = system.Date.today();
        update listCamps;

        List<ContactPointPhone> testContPointPhone = HDT_UTL_DataFactoryTst.createContactPointPhone(1,true,indId);
        testContPointPhone[0].TelephoneNumber = '123456';
        testContPointPhone[0].ParentId = testInd[0].id;
        testContPointPhone[0].LastOutcomeFUB__c = 'OK';
        testContPointPhone[0].LastResultDateFUB__c = system.Date.today();
        update testContPointPhone;

    }

    @isTest
    public static void testImportFubFiles() {
        
        String csv = '123';
        id fubId = [SELECT id FROM FUBProcessing__c WHERE  Status__c = 'Archivio FUB da importare'].id;

        Test.startTest();
        HDT_BA_ImportFubFile imp = new HDT_BA_ImportFubFile(fubId,csv);
        Id batchId = Database.executeBatch(imp);
        Test.stopTest();

        FUBProcessing__c fubP = [SELECT id,Status__c FROM FUBProcessing__c WHERE id = :fubId];

        system.assertEquals(true, fubP.Status__c == 'Archivio FUB importato' , 'the status of FUBProcessing__c is not assigned');
        system.assertNotEquals('', fubP.Status__c, 'the status of FUBProcessing__c is null');
    
    } 
}
