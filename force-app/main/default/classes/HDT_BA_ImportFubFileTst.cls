@isTest
public with sharing class HDT_BA_ImportFubFileTst {
    
    @testSetup 
    static void setup(){
        
        List<Account> testAcc =  HDT_UTL_DataFactoryTst.createAccountPartner(1, false , 'testact');
        testAcc[0].CompanyOwner__c  = 'HERA COMM';
        insert testAcc;

        id acctId =testAcc[0].id;

        List<Individual>  testInd = HDT_UTL_DataFactoryTst.createIndividual(1,true);
        id indId = testInd[0].id;

        List<Contact> testCont =  HDT_UTL_DataFactoryTst.createContact(2, true, acctId);
        testCont[0].IndividualId = indId;
        update testCont;
        

        List<Lead> testLead =  HDT_UTL_DataFactoryTst.createLead(2,true);
        

        List<Campaign> camp = HDT_UTL_DataFactoryTst.createCampaign(1,true);
        id campId = camp[0].id;

        List<FUBProcessing__c> testFubPro = HDT_UTL_DataFactoryTst.createfubProcessing (1, true, 'Archivio FUB da importare');
        id fpId = testFubPro[0].id;


        HDT_UTL_DataFactoryTst.createFubProcessingItem(1,true,campId,fpId);

        List<CampaignMember> listCamps = HDT_UTL_DataFactoryTst.createCampaignMember(true,campId,testLead,testCont);
        listCamps[0].ExcludeFub__c = 'No';
        listCamps[0].Agency__c = acctId;
        listCamps[0].PhoneNumber__c = '1234';
        //listCamps[0].OutcomeFub__c = '';
        //listCamps[0].OutcomeDateFub__c = system.Date.today();
        listCamps[1].PhoneNumber__c = '';
        listCamps[1].ExcludeFub__c = 'No';
        listCamps[1].Agency__c = acctId;
        update listCamps;

        List<ContactPointPhone> testContPointPhone = HDT_UTL_DataFactoryTst.createContactPointPhone(1,true,indId);
        testContPointPhone[0].TelephoneNumber = '1234';
        testContPointPhone[0].ParentId = testInd[0].id;
        testContPointPhone[0].LastOutcomeFUB__c = 'OK';
        testContPointPhone[0].LastResultDateFUB__c = system.Date.today();
        update testContPointPhone;

    }

    @isTest
    public static void testImportFubFiles() {
        
        String csv = '1234';
        id fubId = [SELECT id FROM FUBProcessing__c WHERE  Status__c = 'Archivio FUB da importare'].id;

        Test.startTest();
        HDT_BA_ImportFubFile imp = new HDT_BA_ImportFubFile(fubId,csv);
        Database.executeBatch(imp);
        Test.stopTest();

        FUBProcessing__c fubp = [SELECT id,Status__c FROM FUBProcessing__c WHERE id = :fubId];

        system.assertEquals(true, fubp.Status__c == 'Archivio FUB importato' , 'the status of FUBProcessing__c is not assigned');
        system.assertNotEquals('', fubp.Status__c, 'the status of FUBProcessing__c is null');
    
    } 
}
