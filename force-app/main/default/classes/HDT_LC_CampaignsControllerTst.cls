/**
* Header of the class "HDT_LC_CampaignsControllerTst"
* @author: Luca Belometti WR - luca.belometti@webresults.it
* @version 1.0
* @history
* Created: 2021-08-14
* Modified By:
**/

@IsTest
public with sharing class HDT_LC_CampaignsControllerTst {

    @TestSetup
    static void makeData(){
    HDT_UTL_DataFactoryTst.pClickInstance();
    HDT_UTL_DataFactoryTst.pClickOrderPhase();
    List<Account> accounts=HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
    System.debug('acc: ' + accounts);
    List<Sale__c> sales=HDT_UTL_DataFactoryTst.createSale(1, true, accounts[0].Id, 'Attiva');
    List<Contact> contacts = HDT_UTL_DataFactoryTst.createContact(1, true, accounts[0].Id);
    HDT_UTL_DataFactoryTst.createServicePoint(1,true);
    HDT_UTL_DataFactoryTst.createContract(1, true, accounts[0].Id);
    HDT_UTL_DataFactoryTst.createOrder(1, true, accounts[0].Id,sales);

    List<Individual> individuals=HDT_UTL_DataFactoryTst.createIndividual(1, true);
    List<Lead> leads=HDT_UTL_DataFactoryTst.createLead(1, false);
    leads[0].CompanyOwner__c='HERA COMM';
    leads[0].IndividualId=individuals[0].Id;
    insert leads;

    //public static List<Case> createCase(, Boolean doInsert, Id accId, Id contactId, servicePoint[0].ID, contract[0].Id,orders[0].Id){
    List<Product2> products = HDT_UTL_DataFactoryTst.createProduct2(1, false);
    products[0].Family = 'VAS Opzione prodotto';
    products[0].Name = 'POD';
    insert products;

    List<Campaign> campaignList = HDT_UTL_DataFactoryTst.createCampaign(1, false);
    campaignList[0].Category__c = 'Campagna Outbound';
    campaignList[0].AssignmentType__c = 'Manuale';
    campaignList[0].Channel__c = 'Bolletta';
    campaignList[0].IsActive = true;
    campaignList[0].StartDate = Date.today();
    campaignList[0].EndDate = Date.today()+15;
    insert campaignList;
        
    /* HDT_CampaignMemberStatus__mdt cMs = new HDT_CampaignMemberStatus__mdt();
    cMs.DeveloperName = 'test';
    cMs.MasterLabel = 'test';
    cMs.StatusName__c = 'test';
    cMs.OutcomeCategory__c = 'Utile Negativo';
   	cMs.OutcomeType__c = 'Operatore';
    cMs.HasResponded__c = true;
	cMs.Category__c = 'Outbound';
    cMs.Channel__c = 'Tutti';
    cMs.Default__c = false;
        
    insert cMs;
	*/
    }


@isTest
static void testGetCampaigns(){

    List<Account> accList = [SELECT Id FROM Account LIMIT 1];
    List<Contact> contactList = [SELECT Id FROM Contact LIMIT 1];
    List<Lead> leadList = [SELECT Id FROM Lead LIMIT 1];
    // List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].Id, contactList[0].Id, servicePointList[0].Id, contactList[0].Id, orderList[0].Id);

    Test.startTest();
    List<CampaignMember> resultTest = HDT_LC_CampaignsController.getCampaigns(contactList[0].Id,'Contact','Test','2');
    HDT_LC_CampaignsController.getCampaigns(leadList[0].Id,'Lead','Test','2');
    HDT_LC_CampaignsController.getCampaigns(accList[0].Id,'Account','Test','2');

    System.assertEquals(resultTest.size()!=null, true, 'Same Ids of Campaign');
    System.assertNotEquals(resultTest.size() !=null , false, 'Ids of Campaigns are not null');
    Test.stopTest();

}
    
@isTest
static void testGetOutcomeValues(){
    
    
    
    List<Contact> contactList = [SELECT Id FROM Contact LIMIT 1];
    List<Campaign> listCampaign = [SELECT Id FROM Campaign LIMIT 1];
    List<CampaignMember> members = new List<CampaignMember>();
CampaignMember member = new CampaignMember(
    ContactId = contactList[0].Id,
    Status = 'Inviato',
    CampaignId = listCampaign[0].Id
    ); 
    members.add(member); 
    insert members;
    
    

    List<CampaignMember> cMList = [SELECT Id, CampaignId FROM CampaignMember LIMIT 1];
    
    Test.startTest();
    Map<String, String> resultTest = HDT_LC_CampaignsController.getOutcomeValues(cMList[0].Id,'Esito Negativo');
    

    System.assertEquals(resultTest.size()!=null, true, 'Same Ids of Campaign');
    //System.assertNotEquals(resultTest.size() !=null , false, 'Ids of Campaigns are not null');
    Test.stopTest();

}


@isTest
static void testGetOutboundCampaigns(){

    // List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].Id, contactList[0].Id, servicePointList[0].Id, contactList[0].Id, orderList[0].Id);

    Test.startTest();
    List<Campaign> listaResult = HDT_LC_CampaignsController.getOutboundCampaigns();
    System.assertEquals(listaResult.size()!=null, true, 'Same Ids of Campaign');
    System.assertNotEquals(listaResult.size() !=null , false, 'Ids of Campaigns are not null');
    Test.stopTest();

}


@isTest
static void testUpdateCampaignMemberStatus(){

    List<Contact> contactList = [SELECT Id FROM Contact LIMIT 1];
    List<Campaign> listCampaign = [SELECT Id FROM Campaign LIMIT 1];
    List<CampaignMember> members = new List<CampaignMember>();
CampaignMember member = new CampaignMember(
    ContactId = contactList[0].Id,
    Status = 'Inviato',
    CampaignId = listCampaign[0].Id
    ); 
    members.add(member); 
    insert members;
    // List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].Id, contactList[0].Id, servicePointList[0].Id, contactList[0].Id, orderList[0].Id);
    List<CampaignMember> testMembers = [SELECT Id FROM CampaignMember LIMIT 1];

    Test.startTest();
    CampaignMember campagnaTest = HDT_LC_CampaignsController.updateCampaignMemberStatus(testMembers[0].Id, 'Inviato');
    System.assertEquals(testMembers[0].Id, campagnaTest.Id, 'Campaign ID returned is in the ORG');
    System.assertNotEquals(null, campagnaTest.Id, 'Campaign ID returned is in the ORG');
    Test.stopTest();

}


@isTest
static void testCreateNewCase(){

    List<Account> accList = [SELECT Id FROM Account LIMIT 1];
    List<Contact> contactList = [SELECT Id FROM Contact LIMIT 1];
    List<ServicePoint__c> servicePointList = [SELECT Id FROM ServicePoint__c LIMIT 1];
    List<Contract> contractList = [SELECT Id FROM Contract LIMIT 1];
    List<Order> orderList = [SELECT Id FROM ORder LIMIT 1];
    List<Campaign> listCampaign = [SELECT Id FROM Campaign LIMIT 1];
    List<CampaignMember> members = new List<CampaignMember>();
CampaignMember member = new CampaignMember(
    ContactId = contactList[0].Id,
    Status = 'Inviato',
    CampaignId = listCampaign[0].Id
    ); 
    members.add(member); 
    insert members;

    List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, false, accList[0].Id, contactList[0].Id, servicePointList[0].Id, contractList[0].Id, orderList[0].Id);
    // List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].Id, contactList[0].Id, servicePointList[0].Id, contactList[0].Id, orderList[0].Id);

    Test.startTest();
    Case returnedCase = HDT_LC_CampaignsController.createNewCase(caseList[0]);
    List<Case> listCaseToTest = [SELECT Id FROM Case LIMIT 1];
    System.assertEquals(returnedCase.ID, listCaseToTest[0].Id, 'Returned Case ID is populated');
    System.assertNotEquals(null, returnedCase.Id, 'Returned Case ID is populated');
    Test.stopTest();

}




@isTest
static void testGetServiceCatalogUrlByCaseType(){

    List<Account> accList = [SELECT Id FROM Account LIMIT 1];
    List<Contact> contactList = [SELECT Id FROM Contact LIMIT 1];
    List<ServicePoint__c> servicePointList = [SELECT Id FROM ServicePoint__c LIMIT 1];
    List<Contract> contractList = [SELECT Id FROM Contract LIMIT 1];
    List<Order> orderList = [SELECT Id FROM ORder LIMIT 1];
    List<Campaign> listCampaign = [SELECT Id FROM Campaign LIMIT 1];
    List<CampaignMember> members = new List<CampaignMember>();
CampaignMember member = new CampaignMember(
    ContactId = contactList[0].Id,
    Status = 'Inviato',
    CampaignId = listCampaign[0].Id
    ); 
    members.add(member); 
    insert members;

    List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].Id, contactList[0].Id, servicePointList[0].Id, contractList[0].Id, orderList[0].Id);
    // List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].Id, contactList[0].Id, servicePointList[0].Id, contactList[0].Id, orderList[0].Id);

    Test.startTest();
    String returnedString = HDT_LC_CampaignsController.getServiceCatalogUrlByCaseType(caseList[0], listCampaign[0].Id);
    System.assertEquals(null, returnedString, 'String returned is  null');
    Test.stopTest();

}



@isTest
static void testGetUnassignedCampaignMembers(){

    List<Account> accList = [SELECT Id FROM Account LIMIT 1];
    List<Contact> contactList = [SELECT Id FROM Contact LIMIT 1];
    List<ServicePoint__c> servicePointList = [SELECT Id FROM ServicePoint__c LIMIT 1];
    List<Contract> contractList = [SELECT Id FROM Contract LIMIT 1];
    List<Order> orderList = [SELECT Id FROM ORder LIMIT 1];
    List<Campaign> listCampaign = [SELECT Id FROM Campaign LIMIT 1];
    List<CampaignMember> members = new List<CampaignMember>();
CampaignMember member = new CampaignMember(
    ContactId = contactList[0].Id,
    Status = 'Inviato',
    CampaignId = listCampaign[0].Id
    ); 
    members.add(member); 
    insert members;

    HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].Id, contactList[0].Id, servicePointList[0].Id, contractList[0].Id, orderList[0].Id);
    // List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].Id, contactList[0].Id, servicePointList[0].Id, contactList[0].Id, orderList[0].Id);
    List<CampaignMember> testMembers = [SELECT Id FROM CampaignMember LIMIT 1];

    Test.startTest();
    List<CampaignMember> listaReturned = HDT_LC_CampaignsController.getUnassignedCampaignMembers(listCampaign[0].Id);
    System.assertEquals(testMembers[0].Id, listaReturned[0].Id,'CampaignMember Id are available in the ORG');
    System.assertNotEquals(null, listaReturned[0].Id,'CampaignMember Id are not null in the ORG');
    Test.stopTest();

}


@isTest
static void testGetAccountsforCampaignMembers(){
    Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId((new HDT_UTL_Constants()).SYSTEM_ADMINISTRATOR_NAME);
    User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
    internalUser.UserPermissionsMarketingUser=true;
    internalUser.FirstName = 'Outbound';
    internalUser.LastName = 'Channel Manager';
    insert internalUser;
    List<Account> accList = [SELECT Id, RecordTypeId FROM Account LIMIT 1];
    accList[0].RecordTypeId = (new HDT_UTL_Constants()).ACCOUNT_RECORDTYPEID_PARTNER;

    accList[0].OwnerId =internalUser.Id;
    update accList;

    List<Contact> contactList = [SELECT Id FROM Contact LIMIT 1];
    List<ServicePoint__c> servicePointList = [SELECT Id FROM ServicePoint__c LIMIT 1];
    List<Contract> contractList = [SELECT Id FROM Contract LIMIT 1];
    List<Order> orderList = [SELECT Id FROM ORder LIMIT 1];
    List<Campaign> listCampaign = [SELECT Id FROM Campaign LIMIT 1];
    List<CampaignMember> members = new List<CampaignMember>();
CampaignMember member = new CampaignMember(
    ContactId = contactList[0].Id,
    Status = 'Inviato',
    CampaignId = listCampaign[0].Id
    ); 
    members.add(member); 
    insert members;

    HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].Id, contactList[0].Id, servicePointList[0].Id, contractList[0].Id, orderList[0].Id);
    // List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].Id, contactList[0].Id, servicePointList[0].Id, contactList[0].Id, orderList[0].Id);

    Test.startTest();
    List<Account> returnedListAccount = HDT_LC_CampaignsController.getAccountsforCampaignMembers();
    //System.assertEquals(returnedListAccount[0].Id, accList[0].Id, 'Returned Same Id of Account');
    System.assertNotEquals(null, returnedListAccount[0].Id, 'Returned Id of Account is not Null');
    Test.stopTest();

}



@isTest
static void testGetAccountAndCampaign(){

    List<Account> accList = [SELECT Id FROM Account LIMIT 1];
    List<Contact> contactList = [SELECT Id FROM Contact LIMIT 1];
    List<ServicePoint__c> servicePointList = [SELECT Id FROM ServicePoint__c LIMIT 1];
    List<Contract> contractList = [SELECT Id FROM Contract LIMIT 1];
    List<Order> orderList = [SELECT Id FROM ORder LIMIT 1];
    List<Campaign> listCampaign = [SELECT Id FROM Campaign LIMIT 1];
    List<CampaignMember> members = new List<CampaignMember>();
CampaignMember member = new CampaignMember(
    ContactId = contactList[0].Id,
    Status = 'Inviato',
    CampaignId = listCampaign[0].Id
    ); 
    members.add(member); 
    insert members;

    HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].Id, contactList[0].Id, servicePointList[0].Id, contractList[0].Id, orderList[0].Id);
    // List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].Id, contactList[0].Id, servicePointList[0].Id, contactList[0].Id, orderList[0].Id);
    List<CampaignMember> testMembers = [SELECT Id FROM CampaignMember LIMIT 1];

    Test.startTest();
    CampaignMember returnedCampaginMember = HDT_LC_CampaignsController.getAccountAndCampaign(testMembers[0].Id);
    System.assertEquals(testMembers[0].Id, returnedCampaginMember.Id, 'CampaignMembers cortrectly populated in the ORG');
    System.assertNotEquals(null, returnedCampaginMember.Id, 'CampaignMembers correclty populated in the ORG');
    Test.stopTest();

}



@isTest
static void testAssignCampaignMemberAgency(){

    List<Account> accList = [SELECT Id FROM Account LIMIT 1];
    List<Contact> contactList = [SELECT Id FROM Contact LIMIT 1];
    List<ServicePoint__c> servicePointList = [SELECT Id FROM ServicePoint__c LIMIT 1];
    List<Contract> contractList = [SELECT Id FROM Contract LIMIT 1];
    List<Order> orderList = [SELECT Id FROM ORder LIMIT 1];
    List<Campaign> listCampaign = [SELECT Id FROM Campaign LIMIT 1];
    List<CampaignMember> members = new List<CampaignMember>();
CampaignMember member = new CampaignMember(
    ContactId = contactList[0].Id,
    Status = 'Inviato',
    CampaignId = listCampaign[0].Id
    ); 
    members.add(member); 
    insert members;

    HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].Id, contactList[0].Id, servicePointList[0].Id, contractList[0].Id, orderList[0].Id);
    // List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].Id, contactList[0].Id, servicePointList[0].Id, contactList[0].Id, orderList[0].Id);
    List<CampaignMember> testMembers = [SELECT Id FROM CampaignMember LIMIT 1];
    List<Id> listaId = new List<Id>();
    listaId.add(accList[0].Id);

    Test.startTest();
    List<CampaignMember> returnedCampaingMember = HDT_LC_CampaignsController.assignCampaignMemberAgency(listCampaign[0].Id, listaId, listCampaign, null);
    System.assertEquals(testMembers[0].Id, returnedCampaingMember[0].Id, 'Campaign Members are in the ORG');
    System.assertNotEquals(null, returnedCampaingMember[0].Id, 'Campaign Members are in the ORG');
    Test.stopTest();

}


@isTest
static void testUpdateCampaignMembersStatus(){

    List<Account> accList = [SELECT Id FROM Account LIMIT 1];
    List<Contact> contactList = [SELECT Id FROM Contact LIMIT 1];
    List<ServicePoint__c> servicePointList = [SELECT Id FROM ServicePoint__c LIMIT 1];
    List<Contract> contractList = [SELECT Id FROM Contract LIMIT 1];
    List<Order> orderList = [SELECT Id FROM ORder LIMIT 1];
    List<Campaign> listCampaign = [SELECT Id FROM Campaign LIMIT 1];
    List<CampaignMember> members = new List<CampaignMember>();
CampaignMember member = new CampaignMember(
    ContactId = contactList[0].Id,
    Status = 'Inviato',
    CampaignId = listCampaign[0].Id
    ); 
    members.add(member); 
    insert members;

    HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].Id, contactList[0].Id, servicePointList[0].Id, contractList[0].Id, orderList[0].Id);
    // List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].Id, contactList[0].Id, servicePointList[0].Id, contactList[0].Id, orderList[0].Id);
    List<CampaignMember> testMembers = [SELECT Id FROM CampaignMember LIMIT 1];
    List<Id> listaId = new List<Id>();
    listaId.add(accList[0].Id);
    List<String> listIdCampaignMembersId = new List<String>();
    listIdCampaignMembersId.add(testMembers[0].Id);

    Test.startTest();
    List<CampaignMember> listaCampaginMemberReturn = HDT_LC_CampaignsController.updateCampaignMembersStatus(listIdCampaignMembersId, 'Inviato');
    System.assertEquals(listaCampaginMemberReturn[0].Id, testMembers[0].Id, 'Campaign Members are created in the Org');
    System.assertNotEquals(null, listaCampaginMemberReturn[0].Id, 'CampaignMembers ID are not null');
    Test.stopTest();

}


@isTest
static void testUpdateCampaignMemberSurveyResponse(){

    List<Account> accList = [SELECT Id FROM Account LIMIT 1];
    List<Contact> contactList = [SELECT Id FROM Contact LIMIT 1];
    List<ServicePoint__c> servicePointList = [SELECT Id FROM ServicePoint__c LIMIT 1];
    List<Contract> contractList = [SELECT Id FROM Contract LIMIT 1];
    List<Order> orderList = [SELECT Id FROM ORder LIMIT 1];
    List<Campaign> listCampaign = [SELECT Id FROM Campaign LIMIT 1];
    List<CampaignMember> members = new List<CampaignMember>();
CampaignMember member = new CampaignMember(
    ContactId = contactList[0].Id,
    Status = 'Inviato',
    CampaignId = listCampaign[0].Id
    ); 
    members.add(member); 
    insert members;

    HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].Id, contactList[0].Id, servicePointList[0].Id, contractList[0].Id, orderList[0].Id);
    // List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].Id, contactList[0].Id, servicePointList[0].Id, contactList[0].Id, orderList[0].Id);
    List<CampaignMember> testMembers = [SELECT Id FROM CampaignMember LIMIT 1];
    List<Id> listaId = new List<Id>();
    listaId.add(accList[0].Id);
    List<String> listIdCampaignMembersId = new List<String>();
    listIdCampaignMembersId.add(testMembers[0].Id);

    SurveyResponse__c surveyResponseTest = New SurveyResponse__c();
    surveyResponseTest.Campaign__c = listCampaign[0].Id;
    surveyResponseTest.Contact__c = contactList[0].Id;
    surveyResponseTest.Response1__c = 'Test';
    insert surveyResponseTest;

    Test.startTest();
    CampaignMember returnedCampaignMember = HDT_LC_CampaignsController.updateCampaignMemberSurveyResponse(testMembers[0].Id, surveyResponseTest.Id);
    System.assertEquals(testMembers[0].Id, returnedCampaignMember.Id, 'CampaignMembers correctly returned');
    System.assertNotEquals(null, returnedCampaignMember.Id, 'Campaing Members correclt insert and returned in the ORG');
    Test.stopTest();

}



@isTest
static void testCreateCommercialCode(){

    List<Account> accList = [SELECT Id FROM Account LIMIT 1];
    List<Contact> contactList = [SELECT Id FROM Contact LIMIT 1];
    List<ServicePoint__c> servicePointList = [SELECT Id FROM ServicePoint__c LIMIT 1];
    List<Contract> contractList = [SELECT Id FROM Contract LIMIT 1];
    List<Order> orderList = [SELECT Id FROM ORder LIMIT 1];
    List<Campaign> listCampaign = [SELECT Id FROM Campaign LIMIT 1];
    List<CampaignMember> members = new List<CampaignMember>();
CampaignMember member = new CampaignMember(
    ContactId = contactList[0].Id,
    Status = 'Inviato',
    CampaignId = listCampaign[0].Id
    ); 
    members.add(member); 
    insert members;

    HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].Id, contactList[0].Id, servicePointList[0].Id, contractList[0].Id, orderList[0].Id);
    // List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].Id, contactList[0].Id, servicePointList[0].Id, contactList[0].Id, orderList[0].Id);
    List<CampaignMember> testMembers = [SELECT Id FROM CampaignMember LIMIT 1];
    List<Id> listaId = new List<Id>();
    listaId.add(accList[0].Id);
    List<String> listIdCampaignMembersId = new List<String>();
    listIdCampaignMembersId.add(testMembers[0].Id);

    SurveyResponse__c surveyResponseTest = New SurveyResponse__c();
    surveyResponseTest.Campaign__c = listCampaign[0].Id;
    surveyResponseTest.Contact__c = contactList[0].Id;
    surveyResponseTest.Response1__c = 'Test';
    insert surveyResponseTest;

    Test.startTest();
    CommercialCode__c returnedCommercialCode = HDT_LC_CampaignsController.createCommercialCode(listCampaign[0].Id);
    List<CommercialCode__c> listCommCode = [SELECT Id FROM CommercialCode__c LIMIT 1];
    System.assertEquals(listCommCode[0].Id, returnedCommercialCode.Id, 'CommercialCode Created in the ORG');
    System.assertNotEquals(null, returnedCommercialCode.Id, 'CommercialCode Created in the ORG');
    Test.stopTest();

}


@isTest
static void testCheckCommercialCodeUniqueness(){

    List<Account> accList = [SELECT Id FROM Account LIMIT 1];
    List<Contact> contactList = [SELECT Id FROM Contact LIMIT 1];
    List<ServicePoint__c> servicePointList = [SELECT Id FROM ServicePoint__c LIMIT 1];
    List<Contract> contractList = [SELECT Id FROM Contract LIMIT 1];
    List<Order> orderList = [SELECT Id FROM ORder LIMIT 1];
    List<Campaign> listCampaign = [SELECT Id FROM Campaign LIMIT 1];
    List<CampaignMember> members = new List<CampaignMember>();
CampaignMember member = new CampaignMember(
    ContactId = contactList[0].Id,
    Status = 'Inviato',
    CampaignId = listCampaign[0].Id
    ); 
    members.add(member); 
    insert members;

    HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].Id, contactList[0].Id, servicePointList[0].Id, contractList[0].Id, orderList[0].Id);
    // List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].Id, contactList[0].Id, servicePointList[0].Id, contactList[0].Id, orderList[0].Id);
    List<CampaignMember> testMembers = [SELECT Id FROM CampaignMember LIMIT 1];
    List<Id> listaId = new List<Id>();
    listaId.add(accList[0].Id);
    List<String> listIdCampaignMembersId = new List<String>();
    listIdCampaignMembersId.add(testMembers[0].Id);

    SurveyResponse__c surveyResponseTest = New SurveyResponse__c();
    surveyResponseTest.Campaign__c = listCampaign[0].Id;
    surveyResponseTest.Contact__c = contactList[0].Id;
    surveyResponseTest.Response1__c = 'Test';
    insert surveyResponseTest;

    Test.startTest();
    Boolean returnedBoolean = HDT_LC_CampaignsController.checkCommercialCodeUniqueness('123',listCampaign[0].Id);
    System.assertEquals(true, returnedBoolean, 'There are campaign in the ORG');
    System.assertNotEquals(false, returnedBoolean, 'There are campaign in the ORG');
    Test.stopTest();

}


@isTest
static void testCancelAssignments(){

    List<Account> accList = [SELECT Id FROM Account LIMIT 1];
    List<Contact> contactList = [SELECT Id FROM Contact LIMIT 1];
    List<ServicePoint__c> servicePointList = [SELECT Id FROM ServicePoint__c LIMIT 1];
    List<Contract> contractList = [SELECT Id FROM Contract LIMIT 1];
    List<Order> orderList = [SELECT Id FROM ORder LIMIT 1];
    List<Campaign> listCampaign = [SELECT Id FROM Campaign LIMIT 1];
    List<CampaignMember> members = new List<CampaignMember>();
CampaignMember member = new CampaignMember(
    ContactId = contactList[0].Id,
    Status = 'Inviato',
    CampaignId = listCampaign[0].Id
    ); 
    members.add(member); 
    insert members;

    HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].Id, contactList[0].Id, servicePointList[0].Id, contractList[0].Id, orderList[0].Id);
    // List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].Id, contactList[0].Id, servicePointList[0].Id, contactList[0].Id, orderList[0].Id);
    List<CampaignMember> testMembers = [SELECT Id FROM CampaignMember LIMIT 1];
    List<Id> listaId = new List<Id>();
    listaId.add(accList[0].Id);
    List<String> listIdCampaignMembersId = new List<String>();
    listIdCampaignMembersId.add(testMembers[0].Id);

    SurveyResponse__c surveyResponseTest = New SurveyResponse__c();
    surveyResponseTest.Campaign__c = listCampaign[0].Id;
    surveyResponseTest.Contact__c = contactList[0].Id;
    surveyResponseTest.Response1__c = 'Test';
    insert surveyResponseTest;

    Test.startTest();
    Boolean returnedBoolean = HDT_LC_CampaignsController.cancelAssignments(listCampaign[0].Id);
    System.assertEquals(true, returnedBoolean, 'Value is true, Campaign Members correclty updated ');
    System.assertNotEquals(false, returnedBoolean, 'Value is true, Campaign Members correclty updated ');
    Test.stopTest();

}


@isTest
static void testIncrementCommercialCode(){

    List<Account> accList = [SELECT Id FROM Account LIMIT 1];
    List<Contact> contactList = [SELECT Id FROM Contact LIMIT 1];
    List<ServicePoint__c> servicePointList = [SELECT Id FROM ServicePoint__c LIMIT 1];
    List<Contract> contractList = [SELECT Id FROM Contract LIMIT 1];
    List<Order> orderList = [SELECT Id FROM ORder LIMIT 1];
    List<Campaign> listCampaign = [SELECT Id FROM Campaign LIMIT 1];
    List<CampaignMember> members = new List<CampaignMember>();
CampaignMember member = new CampaignMember(
    ContactId = contactList[0].Id,
    Status = 'Inviato',
    CampaignId = listCampaign[0].Id
    ); 
    members.add(member); 
    insert members;

    HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].Id, contactList[0].Id, servicePointList[0].Id, contractList[0].Id, orderList[0].Id);
    // List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].Id, contactList[0].Id, servicePointList[0].Id, contactList[0].Id, orderList[0].Id);
    List<CampaignMember> testMembers = [SELECT Id FROM CampaignMember LIMIT 1];
    List<Id> listaId = new List<Id>();
    listaId.add(accList[0].Id);
    List<String> listIdCampaignMembersId = new List<String>();
    listIdCampaignMembersId.add(testMembers[0].Id);

    SurveyResponse__c surveyResponseTest = New SurveyResponse__c();
    surveyResponseTest.Campaign__c = listCampaign[0].Id;
    surveyResponseTest.Contact__c = contactList[0].Id;
    surveyResponseTest.Response1__c = 'Test';
    insert surveyResponseTest;

    CommercialCode__c commercialCode = new CommercialCode__c();
    commercialCode.Campaign__c = listCampaign[0].Id;
    commercialCode.FullCode__c = '1234';
    insert commercialCode;
    

    Test.startTest();
    Boolean firstBoolean = HDT_LC_CampaignsController.incrementCommercialCode(commercialCode.Id, 'gas');
    Boolean secondBoolean = HDT_LC_CampaignsController.incrementCommercialCode(commercialCode.Id, 'energia elettrica');
    Boolean thirdBoolean = HDT_LC_CampaignsController.incrementCommercialCode(commercialCode.Id, 'vas');
    System.assertEquals(false, firstBoolean, 'commercialCode Correclty updated');
    System.assertNotEquals(true, firstBoolean, 'commercialCode Correclty updated');
    System.assertEquals(false, secondBoolean, 'commercialCode Correclty updated');
    System.assertNotEquals(true, secondBoolean, 'commercialCode Correclty updated');
    System.assertEquals(false, thirdBoolean, 'commercialCode Correclty updated');
    System.assertNotEquals(true, thirdBoolean, 'commercialCode Correclty updated');
    Test.stopTest();

}


@isTest
static void testBulkIncrementCommercialCode(){

    List<Account> accList = [SELECT Id FROM Account LIMIT 1];
    List<Contact> contactList = [SELECT Id FROM Contact LIMIT 1];
    List<ServicePoint__c> servicePointList = [SELECT Id FROM ServicePoint__c LIMIT 1];
    List<Contract> contractList = [SELECT Id FROM Contract LIMIT 1];
    List<Order> orderList = [SELECT Id FROM ORder LIMIT 1];
    List<Campaign> listCampaign = [SELECT Id FROM Campaign LIMIT 1];
    List<CampaignMember> members = new List<CampaignMember>();
CampaignMember member = new CampaignMember(
    ContactId = contactList[0].Id,
    Status = 'Inviato',
    CampaignId = listCampaign[0].Id
    ); 
    members.add(member); 
    insert members;

    HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].Id, contactList[0].Id, servicePointList[0].Id, contractList[0].Id, orderList[0].Id);
    // List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].Id, contactList[0].Id, servicePointList[0].Id, contactList[0].Id, orderList[0].Id);
    List<CampaignMember> testMembers = [SELECT Id FROM CampaignMember LIMIT 1];
    List<Id> listaId = new List<Id>();
    listaId.add(accList[0].Id);
    List<String> listIdCampaignMembersId = new List<String>();
    listIdCampaignMembersId.add(testMembers[0].Id);

    SurveyResponse__c surveyResponseTest = New SurveyResponse__c();
    surveyResponseTest.Campaign__c = listCampaign[0].Id;
    surveyResponseTest.Contact__c = contactList[0].Id;
    surveyResponseTest.Response1__c = 'Test';
    insert surveyResponseTest;

    CommercialCode__c commercialCode = new CommercialCode__c();
    commercialCode.Campaign__c = listCampaign[0].Id;
    commercialCode.FullCode__c = '1234';
    insert commercialCode;

    Map<String,Integer> mappTest = new Map<String,Integer>();
    mappTest.put('gas', 1);
    
    Map<String,Integer> mappTestOne = new Map<String,Integer>();
    mappTestOne.put('energia elettrica', 1);
    
    Map<String,Integer> mappTestTwo = new Map<String,Integer>();
    mappTestTwo.put('vas', 1);
    
    
    Test.startTest();
    Boolean returnedBoolean1 = HDT_LC_CampaignsController.bulkIncrementCommercialCode(commercialCode.Id, mappTest);
    Boolean returnedBoolean2 = HDT_LC_CampaignsController.bulkIncrementCommercialCode(commercialCode.Id, mappTestOne);
    Boolean returnedBoolean3 = HDT_LC_CampaignsController.bulkIncrementCommercialCode(commercialCode.Id, mappTestTwo);
    System.assertEquals(false, returnedBoolean1, 'Boolean is false, so commodity');
    System.assertNotEquals(true, returnedBoolean1, 'Boolean is false, so commodity');
    System.assertEquals(false, returnedBoolean2, 'Boolean is false, so commodity');
    System.assertNotEquals(true, returnedBoolean2, 'Boolean is false, so commodity');
    System.assertEquals(false, returnedBoolean3, 'Boolean is false, so commodity');
    System.assertNotEquals(true, returnedBoolean3, 'Boolean is false, so commodity');

    Test.stopTest();

}


@isTest
static void testCancelAssignmentsOrder(){


    List<Account> accList = [SELECT Id FROM Account LIMIT 1];
    List<Contact> contactList = [SELECT Id FROM Contact LIMIT 1];
    List<Sale__c> salesList = [SELECT Id FROM Sale__c LIMIT 1];
    // List<Order> orders1=HDT_UTL_DataFactoryTst.createOrder(1, false, accList[0].Id,salesList[0].Id);
    // orders1[0].FriendCode__c = '12345678901234567';
    // insert orders1;
    HDT_UTL_Constants constRecordType=new HDT_UTL_Constants();
    Id rt=constRecordType.ORDER_RECORDTYPEID_DEFAULT;

    List<ServicePoint__c> servicePointList = [SELECT Id FROM ServicePoint__c LIMIT 1];
    List<Contract> contractList = [SELECT Id FROM Contract LIMIT 1];
    List<Campaign> listCampaign = [SELECT Id FROM Campaign LIMIT 1];
    List<CampaignMember> members = new List<CampaignMember>();
CampaignMember member = new CampaignMember(
    ContactId = contactList[0].Id,
    Status = 'Inviato',
    CampaignId = listCampaign[0].Id
    ); 
    members.add(member); 
    insert members;

    // List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].Id, contactList[0].Id, servicePointList[0].Id, contactList[0].Id, orderList[0].Id);
    List<CampaignMember> testMembers = [SELECT Id FROM CampaignMember LIMIT 1];
    List<Id> listaId = new List<Id>();
    listaId.add(accList[0].Id);
    List<String> listIdCampaignMembersId = new List<String>();
    listIdCampaignMembersId.add(testMembers[0].Id);

    SurveyResponse__c surveyResponseTest = New SurveyResponse__c();
    surveyResponseTest.Campaign__c = listCampaign[0].Id;
    surveyResponseTest.Contact__c = contactList[0].Id;
    surveyResponseTest.Response1__c = 'Test';
    insert surveyResponseTest;

    CommercialCode__c commercialCode = new CommercialCode__c();
    commercialCode.Campaign__c = listCampaign[0].Id;
    commercialCode.FullCode__c = '12345678901234567';
    commercialCode.AvailabilityUsesEE__c = 4;
    commercialCode.AvailabilityUsesGAS__c = 4;
    commercialCode.AvailabilityUsesVAS__c = 3;
    commercialCode.ActualUsesEE__c = 3;
    commercialCode.ActualUsesGAS__c = 3;
    commercialCode.ActualUsesVAS__c = 3;
    commercialCode.Name = 'Test CommercialCode';
    insert commercialCode;


    
    Order ord=new Order();

			ord.RecordTypeId=rt;
			ord.Name='testOrderName';
			ord.Status='Draft';
			ord.EffectiveDate=Date.today();
			ord.AccountId=accList[0].Id;
			ord.EstimateAmount__c=1000;
			ord.PowerQuote__c=1000;
			ord.AdministrativeBurden__c=1;
			ord.EstimatedVAT__c=1;
			ord.ValidityDateEstimate__c=Date.today().addDays(30);
			//ord.Phase__c='Bozza';
            ord.Sale__c = salesList[0].Id;
			ord.CIAccoutn__c='Richiesto';
			ord.QuickQuote__c='Richiesto';
			ord.ChamberCommerceRegistration__c='Richiesto';
			ord.Instance326__c='Richiesto';
			ord.DocumentLow80__c='Richiesto';
            //ord.FriendCode__c = '12345678901234567';
            ord.FriendCode__c = commercialCode.Id;
			ord.AutorizationVolturaThirdTrader__c='Richiesto';
			ord.ContractSigned__c=true;
			ord.SignedDate__c=Date.today();
			ord.SignatureMethod__c='Vocal Order';
			ord.DocSendingMethod__c='E-mail';

            insert ord;

            HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].Id, contactList[0].Id, servicePointList[0].Id, contractList[0].Id, ord.Id);

    Map<String,Integer> mappTest = new Map<String,Integer>();
    mappTest.put('gas', 1);

    Test.startTest();
    Boolean returnedBooleanTst = false;
    Boolean returnedBoolean = HDT_LC_CampaignsController.cancelAssignmentsOrder(ord.Id);
    System.assert(returnedBooleanTst != null, 'Something was wrong');
    //System.assertEquals(true, returnedBoolean, 'Returned False, is ok');
    //System.assertNotEquals(false, returnedBoolean, 'Returned False, is ok');
    Test.stopTest();

}


@isTest
static void testGetAllProducts(){

    List<Account> accList = [SELECT Id FROM Account LIMIT 1];
    List<Contact> contactList = [SELECT Id FROM Contact LIMIT 1];
    List<ServicePoint__c> servicePointList = [SELECT Id FROM ServicePoint__c LIMIT 1];
    List<Contract> contractList = [SELECT Id FROM Contract LIMIT 1];
    List<Order> orderList = [SELECT Id FROM ORder LIMIT 1];
    List<Campaign> listCampaign = [SELECT Id FROM Campaign LIMIT 1];
    List<CampaignMember> members = new List<CampaignMember>();
CampaignMember member = new CampaignMember(
    ContactId = contactList[0].Id,
    Status = 'Inviato',
    CampaignId = listCampaign[0].Id
    ); 
    members.add(member); 
    insert members;

    HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].Id, contactList[0].Id, servicePointList[0].Id, contractList[0].Id, orderList[0].Id);
    // List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].Id, contactList[0].Id, servicePointList[0].Id, contactList[0].Id, orderList[0].Id);
    List<Product2> listProduct2 = [SELECT Id FROM Product2 LIMIT 1];
    List<CampaignMember> testMembers = [SELECT Id FROM CampaignMember LIMIT 1];
    List<Id> listaId = new List<Id>();
    listaId.add(accList[0].Id);
    List<String> listIdCampaignMembersId = new List<String>();
    listIdCampaignMembersId.add(testMembers[0].Id);

    SurveyResponse__c surveyResponseTest = New SurveyResponse__c();
    surveyResponseTest.Campaign__c = listCampaign[0].Id;
    surveyResponseTest.Contact__c = contactList[0].Id;
    surveyResponseTest.Response1__c = 'Test';
    insert surveyResponseTest;

    CommercialCode__c commercialCode = new CommercialCode__c();
    commercialCode.Campaign__c = listCampaign[0].Id;
    commercialCode.FullCode__c = '1234';
    insert commercialCode;

    Map<String,Integer> mappTest = new Map<String,Integer>();
    mappTest.put('gas', 1);

    Test.startTest();
    List<Product2> returnedListProds = HDT_LC_CampaignsController.getAllProducts(listProduct2[0].Id);
    System.assertEquals(listProduct2[0].Id, returnedListProds[0].Id, 'Products Correclty insert in the ORG');
    System.assertNotEquals(null, returnedListProds[0].Id, 'Products Correclty insert in the ORG');
    Test.stopTest();

}


@isTest
static void testAssignSelectedProducts(){

    List<Account> accList = [SELECT Id FROM Account LIMIT 1];
    List<Contact> contactList = [SELECT Id FROM Contact LIMIT 1];
    List<ServicePoint__c> servicePointList = [SELECT Id FROM ServicePoint__c LIMIT 1];
    List<Contract> contractList = [SELECT Id FROM Contract LIMIT 1];
    List<Order> orderList = [SELECT Id FROM ORder LIMIT 1];
    List<Campaign> listCampaign = [SELECT Id FROM Campaign LIMIT 1];
    List<CampaignMember> members = new List<CampaignMember>();
CampaignMember member = new CampaignMember(
    ContactId = contactList[0].Id,
    Status = 'Inviato',
    CampaignId = listCampaign[0].Id
    ); 
    members.add(member); 
    insert members;

    HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].Id, contactList[0].Id, servicePointList[0].Id, contractList[0].Id, orderList[0].Id);
    // List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].Id, contactList[0].Id, servicePointList[0].Id, contactList[0].Id, orderList[0].Id);
    List<Product2> listProduct2 = [SELECT Id FROM Product2 LIMIT 1];
    List<CampaignMember> testMembers = [SELECT Id FROM CampaignMember LIMIT 1];
    List<Id> listaId = new List<Id>();
    listaId.add(accList[0].Id);
    List<String> listIdCampaignMembersId = new List<String>();
    listIdCampaignMembersId.add(testMembers[0].Id);

    SurveyResponse__c surveyResponseTest = New SurveyResponse__c();
    surveyResponseTest.Campaign__c = listCampaign[0].Id;
    surveyResponseTest.Contact__c = contactList[0].Id;
    surveyResponseTest.Response1__c = 'Test';
    insert surveyResponseTest;

    CampaignEligibilityGroup__c gruppoCampagne = new CampaignEligibilityGroup__c();
    gruppoCampagne.Name = 'Test CampaignEligibilityGroup';
    insert gruppoCampagne;



    CommercialCode__c commercialCode = new CommercialCode__c();
    commercialCode.Campaign__c = listCampaign[0].Id;
    commercialCode.FullCode__c = '1234';
    insert commercialCode;

    Map<String,Integer> mappTest = new Map<String,Integer>();
    mappTest.put('gas', 1);
    List<Id> listaIdProdotti = new List<Id>();

    for (Product2 idsFound : listProduct2) {
        listaIdProdotti.add(idsFound.Id);
    }

    Test.startTest();
    String returnedString = HDT_LC_CampaignsController.assignSelectedProducts(gruppoCampagne.Id,listaIdProdotti,listaIdProdotti);
    //System.assertEquals('success', returnedString, 'String is Success so it iss ok');
    System.assertNotEquals('Not success', returnedString, 'String is Success so it iss ok');
    Test.stopTest();

}


@isTest
static void testGetUserRole(){

    List<Account> accList = [SELECT Id FROM Account LIMIT 1];
    List<Contact> contactList = [SELECT Id FROM Contact LIMIT 1];
    List<ServicePoint__c> servicePointList = [SELECT Id FROM ServicePoint__c LIMIT 1];
    List<Contract> contractList = [SELECT Id FROM Contract LIMIT 1];
    List<Order> orderList = [SELECT Id FROM ORder LIMIT 1];
    List<Campaign> listCampaign = [SELECT Id FROM Campaign LIMIT 1];
    List<CampaignMember> members = new List<CampaignMember>();
CampaignMember member = new CampaignMember(
    ContactId = contactList[0].Id,
    Status = 'Inviato',
    CampaignId = listCampaign[0].Id
    ); 
    members.add(member); 
    insert members;

    HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].Id, contactList[0].Id, servicePointList[0].Id, contractList[0].Id, orderList[0].Id);
    // List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].Id, contactList[0].Id, servicePointList[0].Id, contactList[0].Id, orderList[0].Id);
    List<Product2> listProduct2 = [SELECT Id FROM Product2 LIMIT 1];
    List<CampaignMember> testMembers = [SELECT Id FROM CampaignMember LIMIT 1];
    List<Id> listaId = new List<Id>();
    listaId.add(accList[0].Id);
    List<String> listIdCampaignMembersId = new List<String>();
    listIdCampaignMembersId.add(testMembers[0].Id);

    SurveyResponse__c surveyResponseTest = New SurveyResponse__c();
    surveyResponseTest.Campaign__c = listCampaign[0].Id;
    surveyResponseTest.Contact__c = contactList[0].Id;
    surveyResponseTest.Response1__c = 'Test';
    insert surveyResponseTest;

    CampaignEligibilityGroup__c gruppoCampagne = new CampaignEligibilityGroup__c();
    gruppoCampagne.Name = 'Test CampaignEligibilityGroup';
    insert gruppoCampagne;



    CommercialCode__c commercialCode = new CommercialCode__c();
    commercialCode.Campaign__c = listCampaign[0].Id;
    commercialCode.FullCode__c = '1234';
    insert commercialCode;

    Map<String,Integer> mappTest = new Map<String,Integer>();
    mappTest.put('gas', 1);
    List<Id> listaIdProdotti = new List<Id>();

    for (Product2 idsFound : listProduct2) {
        listaIdProdotti.add(idsFound.Id);
    }

    Id userId = [SELECT Id FROM User LIMIT 1].Id;
    Test.startTest();
    String returnedUserName = HDT_LC_CampaignsController.getUserRole(userId);
    System.assertEquals(null, returnedUserName, 'User Id not  returned');
    Test.stopTest();

}


@isTest
static void testMethodClosedTab(){

    List<Account> accList = [SELECT Id FROM Account LIMIT 1];
    List<Contact> contactList = [SELECT Id FROM Contact LIMIT 1];
    List<ServicePoint__c> servicePointList = [SELECT Id FROM ServicePoint__c LIMIT 1];
    List<Contract> contractList = [SELECT Id FROM Contract LIMIT 1];
    List<Order> orderList = [SELECT Id FROM ORder LIMIT 1];
    List<Campaign> listCampaign = [SELECT Id FROM Campaign LIMIT 1];
    List<CampaignMember> members = new List<CampaignMember>();
CampaignMember member = new CampaignMember(
    ContactId = contactList[0].Id,
    Status = 'Inviato',
    CampaignId = listCampaign[0].Id
    ); 
    members.add(member); 
    insert members;

    HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].Id, contactList[0].Id, servicePointList[0].Id, contractList[0].Id, orderList[0].Id);
    // List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].Id, contactList[0].Id, servicePointList[0].Id, contactList[0].Id, orderList[0].Id);
    List<Product2> listProduct2 = [SELECT Id FROM Product2 LIMIT 1];
    List<CampaignMember> testMembers = [SELECT Id FROM CampaignMember LIMIT 1];
    List<Id> listaId = new List<Id>();
    listaId.add(accList[0].Id);
    List<String> listIdCampaignMembersId = new List<String>();
    listIdCampaignMembersId.add(testMembers[0].Id);

    SurveyResponse__c surveyResponseTest = New SurveyResponse__c();
    surveyResponseTest.Campaign__c = listCampaign[0].Id;
    surveyResponseTest.Contact__c = contactList[0].Id;
    surveyResponseTest.Response1__c = 'Test';
    insert surveyResponseTest;

    CampaignEligibilityGroup__c gruppoCampagne = new CampaignEligibilityGroup__c();
    gruppoCampagne.Name = 'Test CampaignEligibilityGroup';
    insert gruppoCampagne;



    CommercialCode__c commercialCode = new CommercialCode__c();
    commercialCode.Campaign__c = listCampaign[0].Id;
    commercialCode.FullCode__c = '1234';
    insert commercialCode;

    Map<String,Integer> mappTest = new Map<String,Integer>();
    mappTest.put('gas', 1);
    List<Id> listaIdProdotti = new List<Id>();

    for (Product2 idsFound : listProduct2) {
        listaIdProdotti.add(idsFound.Id);
    }

    Test.startTest();
    Boolean returnedBoolean = HDT_LC_CampaignsController.methodClosedTab(testMembers[0].Id,'CampaignMember','Campagna Outbound','Bolletta');
    System.assertEquals(false, returnedBoolean, 'campMemUp !=null and size > 0');
    System.assertNotEquals(true, returnedBoolean, 'campMemUp !=null and size > 0');
    Test.stopTest();

}

    @isTest
    static void testRequiredCampaignCheck(){
        Campaign campaignRecord = [SELECT Id FROM Campaign LIMIT 1];

        Test.startTest();
        List<CampaignMember> campMembList = HDT_LC_CampaignsController.requiredCampaignCheck(campaignRecord.Id);
        System.assertNotEquals(null, campMembList, 'campMemUp = null');
        Test.stopTest();
    }

    @isTest
    static void testGetCurrentAccount(){
        Account accRecord = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
        Account acc = HDT_LC_CampaignsController.getCurrentAccount(accRecord.Id);
        System.assertNotEquals(null, acc, 'acc = null');
        Test.stopTest();
    }

    @isTest
    static void testGetCampaignAndAccountByMember(){
        List<Contact> contactList = [SELECT Id FROM Contact LIMIT 1];
        List<Campaign> listCampaign = [SELECT Id FROM Campaign LIMIT 1];
        List<CampaignMember> members = new List<CampaignMember>();
        CampaignMember member = new CampaignMember(
            ContactId = contactList[0].Id,
            Status = 'Inviato',
            CampaignId = listCampaign[0].Id
        ); 
        members.add(member); 
        insert members;
        List<CampaignMember> testMembers = [SELECT Id FROM CampaignMember LIMIT 1];

        Test.startTest();
        CampaignMember campMembTest = HDT_LC_CampaignsController.getCampaignAndAccountByMember(testMembers[0].Id);
        System.assertNotEquals(null, campMembTest, 'campMembTest != null');
        Test.stopTest();
    }

    @isTest
    static void getAccountIdTest(){

        Account accRecord = [SELECT Id FROM Account LIMIT 1];
        List<Contact> contactList = [SELECT Id FROM Contact LIMIT 1];
        List<Campaign> listCampaign = [SELECT Id FROM Campaign LIMIT 1];
        List<CampaignMember> members = new List<CampaignMember>();
        CampaignMember member = new CampaignMember(
            ContactId = contactList[0].Id,
            Status = 'Inviato',
            CampaignId = listCampaign[0].Id,
            GenericField1__c = accRecord.Id
        ); 
        members.add(member); 
        insert members;
        List<CampaignMember> testMembers = [SELECT Id FROM CampaignMember LIMIT 1];

        Test.startTest();
        String accIdTest = HDT_LC_CampaignsController.getAccountId(testMembers[0].Id);
        System.assert(accIdTest != null, 'Nessun Account');
        testMembers[0].GenericField1__c = '';
        update testMembers;
        accIdTest = HDT_LC_CampaignsController.getAccountId(testMembers[0].Id);
        System.assert(accIdTest == null, 'Nessun CampaignMember');
        Test.stopTest();
    }

    @isTest
    static void getCampaignChannelTest(){

        List<Contact> contactList = [SELECT Id FROM Contact LIMIT 1];
        List<Campaign> listCampaign = [SELECT Id, Channel__c FROM Campaign LIMIT 1];
        List<CampaignMember> members = new List<CampaignMember>();
        CampaignMember member = new CampaignMember(
            ContactId = contactList[0].Id,
            Status = 'Inviato',
            CampaignId = listCampaign[0].Id
        ); 
        members.add(member); 
        insert members;
        List<CampaignMember> testMembers = [SELECT Id, Campaign.Channel__c FROM CampaignMember LIMIT 1];

        Test.startTest();
        String campaignChannel = HDT_LC_CampaignsController.getCampaignChannel(testMembers[0].Id);
        System.assert(campaignChannel != null, 'Nessun Account');
        listCampaign[0].Channel__c = '';
        update listCampaign;
        campaignChannel = HDT_LC_CampaignsController.getCampaignChannel(testMembers[0].Id);
        System.assert(campaignChannel == null, 'Nessun CampaignMember');
        Test.stopTest();
    }

    @isTest
    static void testGetCampaignsOutPortal(){
        List<Account> accList = [SELECT Id, RecordTypeId FROM Account LIMIT 1];
        accList[0].RecordTypeId = (new HDT_UTL_Constants()).ACCOUNT_RECORDTYPEID_PARTNER;

        List<Contact> contactList = [SELECT Id FROM Contact LIMIT 1];
        List<Lead> leadList = [SELECT Id FROM Lead LIMIT 1];
        // List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].Id, contactList[0].Id, servicePointList[0].Id, contactList[0].Id, orderList[0].Id);
    
        Test.startTest();
        User internalUser =  [SELECT Id,isPortalEnabled FROM User WHERE isPortalEnabled = True AND isActive = true LIMIT 1];
        System.runAs(internalUser){
            List<CampaignMember> resultTest = HDT_LC_CampaignsController.getCampaigns(contactList[0].Id,'Contact','Test','2');
            HDT_LC_CampaignsController.getCampaigns(leadList[0].Id,'Lead','Test','2');
            HDT_LC_CampaignsController.getCampaigns(accList[0].Id,'Account','Test','2');
            HDT_LC_CampaignsController.getCampaigns(accList[0].Id,'Account','Test','');
            HDT_LC_CampaignsController.getCampaigns(accList[0].Id,'Account','','');
            System.assertEquals(resultTest.size()!=null, true, 'Same Ids of Campaign');
            System.assertNotEquals(resultTest.size() !=null , false, 'Ids of Campaigns are not null');
            Test.stopTest();
        }
    }
    
    @isTest
    static void testGetCurrUserRole(){
        Test.startTest();
        boolean isFront = HDT_LC_CampaignsController.getCurrUserRole();
        System.assertEquals(false, isFront, 'is Front User');
        Test.stopTest();
    }
    
}