/**
* @author Elvin Iluca
* @date 19/10/2022
* @description Test Class for HDT_LC_MailSender.cls
* @history Elvin Iluca – 19/10/2022 – Created class
*/


@isTest
public with sharing class HDT_LC_MailSenderTst {

    //DATA
	private static HDT_UTL_Constants utlConstants = new HDT_UTL_Constants();

    /**​
    * @author Elvin Iluca
    * @date 19/10/2022
    * @description HDT_LC_MailSenderTst – Test Class for HDT_LC_MailSender.cls
    */
    @TestSetup
	static void setup(){

        HDT_UTL_DataFactoryTst.createEmailMessage(1, true);
        HDT_UTL_DataFactoryTst.createEmailTemplate(1, true);
        HDT_UTL_DataFactoryTst.pClickInstance();
        HDT_UTL_DataFactoryTst.pClickCasePhase();
        
        Id recTypeId = utlConstants.CASE_RECORDTYPEID_MOROSITA;
        String recTypeName = utlConstants.CASE_RECORDTYPE_DEVELOPERNAME_MOROSITA;
        HDT_UTL_DataFactoryTst.newPhaseTransition('Annullato','Bozza', recTypeId, recTypeName);
        
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].id, 'Bozza');
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
        mySingleCase.RecordTypeId = recTypeId;
        mySingleCase.Phase__c = 'Attesa Modulo Firmato';
        
        caseList.add(mySingleCase);
        insert caseList;

    }

    /**​
    * @author Elvin Iluca
    * @date 19/10/2022
    * @description HDT_LC_MailSenderTst – Test Class for HDT_LC_MailSender.cls
    */
    @isTest
    static void getMetadataTst () {
        HDT_WRP_MailSender.HDT_WRP_Result ret ;
        EmailMessage emailMessage =  [SELECT Id FROM EmailMessage LIMIT 1];

        Test.startTest();
        ret = HDT_LC_MailSender.getMetadata(emailMessage.Id);
        Test.stopTest();
      
        System.assertEquals(false, ret.success, 'can\'t find the EmailTemplate in the folder');
        
    }

    /**​
    * @author Elvin Iluca
    * @date 19/10/2022
    * @description HDT_LC_MailSenderTst – Test Class for HDT_LC_MailSender.cls
    */
    @isTest
    static void getBodyMailMergedTst(){
        HDT_WRP_MailSender.HDT_WRP_BodyMail ret;
        EmailMessage emailMessage =  [SELECT Id FROM EmailMessage LIMIT 1];
        EmailTemplate emailTemplate =  [SELECT Id FROM EmailTemplate LIMIT 1];

        Test.startTest();
        ret = HDT_LC_MailSender.getBodyMailMerged(emailTemplate.Id, emailMessage.Id);
        Test.stopTest();
        System.assertEquals(true, ret.success, 'body mail was succsesfully merged');
    }

    /**​
    * @author Elvin Iluca
    * @date 19/10/2022
    * @description HDT_LC_MailSenderTst – Test Class for HDT_LC_MailSender.cls
    */
    @isTest
    static void sendMailTst(){
        HDT_WRP_MailSender.HDT_WRP_SendMailResult ret;
        //In the org there must be at least one record of OrgWideEmailAddress
        List<OrgWideEmailAddress> orgWideEmailAdress = [SELECT Id, Address FROM OrgWideEmailAddress];
        List<Case> cases =  [SELECT Id FROM Case LIMIT 1];
        String orgWideAddId = orgWideEmailAdress[0].Id;
        String toAddress = orgWideEmailAdress[0].Address;
        String caseId= cases[0].Id;
        System.debug(caseId);
        
        String emailMessageJson = '{"caseId": "'+ caseId +'", "isReminder": false,"orgWideAddId": "'+ orgWideAddId +'", "bodyMail": "Note 2", "toAddress": "'+ toAddress +'"}';

        Test.startTest();
        ret = HDT_LC_MailSender.sendMail(emailMessageJson);
        Test.stopTest();
        System.assertEquals(true, ret.success, ret.message);
    }
}