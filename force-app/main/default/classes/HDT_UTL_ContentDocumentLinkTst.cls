/**
* @author Elvin Iluca
* @date 31/10/2022
* @description Test Class for HDT_UTL_ContentDocumentLink.cls
* @history Elvin Iluca – 31/10/2022 – Created class
*/
@isTest
public with sharing class HDT_UTL_ContentDocumentLinkTst {
    /**​
    * @author Elvin Iluca
    * @date 19/10/2022
    * @description HDT_LC_MailSenderTst – Test Class for HDT_LC_MailSender.cls
    */

    //DATA
	private static HDT_UTL_Constants utlConstants = new HDT_UTL_Constants();

    @TestSetup
	static void setup(){
        HDT_UTL_DataFactoryTst.pClickInstance();
        HDT_UTL_DataFactoryTst.pClickCasePhase();
        HDT_UTL_DataFactoryTst.pClickOrderPhase();
        
        Id recTypeId = utlConstants.CASE_RECORDTYPEID_MOROSITA;
        String recTypeName = utlConstants.CASE_RECORDTYPE_DEVELOPERNAME_MOROSITA;
        HDT_UTL_DataFactoryTst.newPhaseTransition('Annullato','Bozza', recTypeId, recTypeName);
        
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Lead> leadList = HDT_UTL_DataFactoryTst.createLead(1,true);
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].id, 'Bozza');
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].id);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].id);
        List<ContentVersion> contentVersion = HDT_UTL_DataFactoryTst.createContentVers(1, true);

        Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: contentVersion[0].Id].ContentDocumentId;
        list<ContentDocumentLink> docuList = HDT_UTL_DataFactoryTst.createContentDocumentLink(1,false,leadList[0].Id, contentDocumentId);
        docuList[0].visibility = 'AllUsers';
        insert docuList;
    } 

    @isTest
    static void checkLeadTst () {

        List<ContentDocument> documentList = [SELECT Id FROM ContentDocument LIMIT 1];
        Set<Id> newSet = new Set<Id>();
        newSet.add(documentList[0].Id);
        List<ContentDocumentLink> conDocLinkList = [SELECT Id, LinkedEntityId, visibility FROM ContentDocumentLink  WHERE ContentDocumentID IN: newSet];

        Test.startTest();
        HDT_UTL_ContentDocumentLink.checkLead(conDocLinkList);
        Test.stopTest();
        conDocLinkList = [SELECT Id, visibility FROM ContentDocumentLink  WHERE ContentDocumentID IN: newSet];

        System.assertEquals('AllUsers',conDocLinkList[0].visibility,'Error set ContentDocumentLink visibility');
    }
}
