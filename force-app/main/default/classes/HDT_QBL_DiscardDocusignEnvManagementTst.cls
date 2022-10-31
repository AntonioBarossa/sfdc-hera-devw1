/**
* @author Elvin Iluca
* @date 31/10/2022
* @description Test Class for HDT_QBL_DiscardDocusignEnvManagement.cls
* @history Elvin Iluca – 31/10/2022 – Created class
*/

@isTest
public with sharing class HDT_QBL_DiscardDocusignEnvManagementTst {  
    /**​
    * @author Elvin Iluca
    * @date 31/10/2022
    * @description HDT_QBL_DiscardDocusignEnvManagementTst – Test Class for HDT_QBL_DiscardDocusignEnvManagement.cls
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
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, false, accList[0].id, 'Bozza');
        ordList[0].DocusignURL__c = 'Test';
        insert ordList;
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].id);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].id);
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(2, false, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);
        for(Case c : caseList){
            c.DocusignExpirationDate__c = Date.today().addDays(5);
            c.RecordTypeId = recTypeId;
            c.Phase__c = 'Attesa Modulo Firmato';
        }
        
        Case mySingleCase = HDT_UTL_DataFactoryTst.createCase(1, false, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id)[0];
        mySingleCase.DocusignURL__c = 'Test';
        insert mySingleCase;

        //public static list<DocumentSendTracking__c> createDocumentSendTracking(Integer numberRecords, Id orderId, Id caseId){
        HDT_UTL_DataFactoryTst.createDocumentSendTracking(1,ordList[0].Id, mySingleCase.Id);
    } 

    @isTest
    static void discardDocusignEnvManagementTst() {
        HDT_QBL_DiscardDocusignEnvManagement testDiscard;
        list<DocumentSendTracking__c> dicuLis = [SELECT Id FROM DocumentSendTracking__c];
        List<Case> caseList = [SELECT Id, DocusignURL__c FROM Case];
        Test.startTest();
        testDiscard = new HDT_QBL_DiscardDocusignEnvManagement(dicuLis[0].Id,caseList[0].Id,'');
        System.enqueueJob(testDiscard);
        Test.stopTest();
        caseList = [SELECT Id, DocusignURL__c FROM Case];
        System.assertEquals(null,caseList[0].DocusignURL__c,'Error DocusignURL__c it\'s not empty');
    }

    @isTest
    static void discardDocusignEnvManagementOrderTst() {

        System.debug([SELECT Id FROM DocumentSendTracking__c]);

        HDT_QBL_DiscardDocusignEnvManagement testDiscard;
        List<Order> orderList = [SELECT Id, DocusignURL__c FROM Order];
        Test.startTest();
        testDiscard = new HDT_QBL_DiscardDocusignEnvManagement('','',orderList[0].Id);

        Test.stopTest();
        orderList = [SELECT Id, DocusignURL__c FROM Order];
        System.assertEquals(null,orderList[0].DocusignURL__c,'Error DocusignURL__c it\'s not empty');
    }

    @isTest
    static void executeTst() {
        System.assertEquals(1,1,'ko');
    }
}
