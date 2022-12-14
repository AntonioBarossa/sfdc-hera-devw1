@isTest
public with sharing class HDT_UTL_ProcessChiusuraMassivaActTst {
    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();

    @testSetup
    static void setup() {

        HDT_UTL_DataFactoryTst.pClickCasePhase();
        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
        User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
        internalUser.UserPermissionsMarketingUser=true;
        internalUser.FirstName='user';
        internalUser.LastName='test';
        insert internalUser;
        String rtName = 'HDT_RT_AlertDisassociazioneUtenteWeb';
        String rtId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(rtName).getRecordTypeId();

        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].id, 'Bozza');
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].Id);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].id);
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);    
 
        caseList[0].recordTypeId = rtId;
        caseList[0].Phase__c = 'Bozza';
        caseList[0].Status = 'New';
        caseList[0].Type = 'Variazione indirizzo di fornitura';


        List<wrts_prcgvr__Activity__c> myActivityList = HDT_UTL_DataFactoryTst.createActivityCustom(1, true, accList[0].Id);
        myActivityList[0].wrts_prcgvr__Status__c  = 'Aperta';
        myActivityList[0].Case__c = caseList[0].Id;
        update myActivityList;



       

        MassiveLoaderRequest__c request = new MassiveLoaderRequest__c();
        request.TotalRequest__c = 1;
        request.Priority__c = 1;
        request.ProcessType__c = 'ChiusuraMassivaActivity';
        request.Status__c = 'In attesa di lavorazione';
        insert request;

        List<MassiveLoaderRequestItem__c> itemsList = new List<MassiveLoaderRequestItem__c>();
        MassiveLoaderRequestItem__c item;
    

        item = new MassiveLoaderRequestItem__c();
        item.MassiveLoaderRequest__c = request.Id;
        item.Status__c = 'In attesa di lavorazione';
        item.Data__c = myActivityList[0].Id+'|Positivo|Da Inviare|user.test|chiusura attività test';      
        itemsList.add(item);
        
        insert itemsList;
    }


    @isTest
    public static void testChiusuraMassiva(){
        Test.startTest();
        HDT_SRV_ProcessRequestItem r = new HDT_SRV_ProcessRequestItem();
        r.execute();
        Test.stopTest();
    }


}
