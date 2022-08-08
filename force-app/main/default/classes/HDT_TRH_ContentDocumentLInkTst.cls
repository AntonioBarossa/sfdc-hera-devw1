@isTest
public with sharing class HDT_TRH_ContentDocumentLInkTst {

private static HDT_UTL_Constants constants=new HDT_UTL_Constants();
@TestSetup
static void makeData(){

    List<ContentVersion> contentVersion=HDT_UTL_DataFactoryTst.createContentVers(1, true);
    Id contentDocumentId=[SELECT ContentDocumentId
                          FROM ContentVersion
                          WHERE Id=:contentVersion[0].Id].ContentDocumentId;

    ContentDocumentLink contentDocLink=new ContentDocumentLink();
    List<Account> accounts=HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
    List<Individual> individuals=HDT_UTL_DataFactoryTst.createIndividual(1, true);
    List<Contact> contacts=HDT_UTL_DataFactoryTst.createContact(1, false, accounts[0].Id);
    contacts[0].IndividualId=individuals[0].Id;
    insert contacts;
    List<Lead> leads=HDT_UTL_DataFactoryTst.createLead(1, false);
    leads[0].IndividualId=individuals[0].Id;
    insert leads;
    contentDocLink.LinkedEntityId=leads[0].Id;
    contentDocLink.ContentDocumentId=contentDocumentId;
    

    
    insert contentDocLink;
}


@isTest
static void testData(){
    List<Lead> lead = [SELECT Id FROM Lead LIMIT 1];

    List<ContentDocumentLink> cdl=[SELECT Visibility
    FROM ContentDocumentLink WHERE LinkedEntityId =:lead[0].Id LIMIT 1];
    System.assertEquals(true, cdl[0].Visibility == 'AllUsers', 'ContentDocumentLink not updated correctly');
}
    
    
}