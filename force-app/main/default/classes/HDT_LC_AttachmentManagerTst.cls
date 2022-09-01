/**
 * Header of the class "HDT_LC_AttachmentManagerTst"
 * @author Marco Arci, marco.arci@webresults.it
 * @version 1.0
 * @description: Apex Test Class of the relative Apex Class "HDT_LC_AttachmentManager"
 * @history
 * @Created 23/08/2028
 **/


@isTest
public with sharing class HDT_LC_AttachmentManagerTst {

    private static HDT_UTL_Constants constants=new HDT_UTL_Constants();

    @TestSetup
    static void createData(){

        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
		internalUser.UserPermissionsMarketingUser=true;
		insert internalUser;

        System.runAs(internalUser){
            
            List<Account> accs = HDT_UTL_DataFactoryTst.createAccountBusiness(1,true,'MMS','MMS Azienda','Aziende SME');
            Id accId = accs[0].id;

            list<Case> listFakeCases = HDT_UTL_DataFactoryTst.createCase(1, false, accId, null, null, null, null);
            listFakeCases[0].AdditionalAttachments__c = 'test';
            listFakeCases[0].MandatoryAttachments__c = 'allegato';
            insert listFakeCases;

            List<Order> listFakeOrders =  HDT_UTL_DataFactoryTst.createOrder(1, false, accId, 'Bozza');
            listFakeOrders[0].AdditionalAttachments__c = 'test_1';
            listFakeOrders[0].BillingCity__c = 'città';
            insert listFakeOrders;

            List<ContentVersion> contentVersion = HDT_UTL_DataFactoryTst.createContentVers(1, false);
            insert contentVersion;

            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument WHERE LatestPublishedVersionId = :contentVersion[0].Id];

            list<ContentDocumentLink> listDocumentLink = HDT_UTL_DataFactoryTst.createContentDocumentLink(1, false, listFakeCases[0].Id, documents[0].Id);
            insert listDocumentLink;
        }
    }

    @isTest
    static void test_1(){
    String varString = '';
    Id caseId = [SELECT Id
                FROM Case
                WITH SECURITY_ENFORCED].Id;
    Test.startTest();  
        varString = HDT_LC_AttachmentManager.getAdditionalAttachment(caseId);
    Test.stopTest();
    system.assertEquals('test', varString);
    }

    @isTest
    static void test_2(){
    String varString = '';
    Id orderId = [SELECT Id
                    FROM Order
                    WITH SECURITY_ENFORCED].Id;
    Test.startTest();
        varString = HDT_LC_AttachmentManager.getAdditionalAttachment(orderId);
    Test.stopTest();
    system.assertEquals('test_1', varString);
    }

    @isTest
    static void test_3(){
    List<ContentDocument> listContent = new List<ContentDocument>();
    Id caseId = [SELECT Id
                FROM Case
                WITH SECURITY_ENFORCED].Id;
    Test.startTest();
        listContent = HDT_LC_AttachmentManager.getRecordsById(caseId);
    Test.stopTest();  
    system.assertEquals(listContent.size(), 1); //not work
    }

    @isTest
    static void test_4(){
    List<ContentDocument> listContent = new List<ContentDocument>();
    Id orderId = [SELECT Id
                    FROM Order
                    WITH SECURITY_ENFORCED].Id;
    Test.startTest();
        listContent = HDT_LC_AttachmentManager.getRecordsById(orderId);
    Test.stopTest();  
    system.assert(listContent.size() == 0);
    }

    @isTest
    static void test_5(){
    HDT_LC_AttachmentManager varWrap = null;
    Id orderId = [SELECT Id
                    FROM Order
                    WITH SECURITY_ENFORCED].Id;
    Test.startTest();
        varWrap = HDT_LC_AttachmentManager.getOrderForButton(orderId);
    Test.stopTest();  
    system.assertEquals('città', varWrap.city);
    }

    @isTest
    static void test_6(){
    HDT_LC_AttachmentManager params = new HDT_LC_AttachmentManager();
    String varString = '';
    Id caseId = [SELECT Id
                FROM Case
                WITH SECURITY_ENFORCED].Id;
    Test.startTest();
        varString = HDT_LC_AttachmentManager.getRequiredAttachment(caseId, params);
    Test.stopTest();  
    system.assert(varString.length()>0);
    }

    @isTest
    static void test_7(){
    SObject varSObject = null;
    Id caseId = [SELECT Id
                FROM Case
                WITH SECURITY_ENFORCED].Id;
    Test.startTest();
        varSObject = HDT_LC_AttachmentManager.getRecordsToCheck(caseId);
    Test.stopTest();  
    system.assertEquals(caseId, varSObject.Id);
    }

}
