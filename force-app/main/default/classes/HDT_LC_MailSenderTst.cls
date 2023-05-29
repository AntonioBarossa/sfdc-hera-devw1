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
        string recTypeInformativeDevName=utlConstants.CASE_RECORDTYPE_DEVELOPERNAME_INFORMATIVE;
        Id informativeRtypeId=utlConstants.CASE_RECORDTYPEID_INFORMATIVE;
        HDT_UTL_DataFactoryTst.newPhaseTransition('Annullato','Bozza', recTypeId, recTypeName);
        HDT_UTL_DataFactoryTst.newPhaseTransition('In attesa risposta Mail','Bozza', recTypeId, recTypeName);
        HDT_UTL_DataFactoryTst.newPhaseTransition('In attesa risposta Mail','Bozza', informativeRtypeId, recTypeInformativeDevName);
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

        HDT_QR_RecordType qrRecordType = new HDT_QR_RecordType();
        Case caseGestore = HDT_UTL_DataFactoryTst.createCase(1, false, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id)[0];
        caseGestore.RecordTypeId = qrRecordType.getRecordTypeIdByName('HDT_RT_Informative');
        caseGestore.Type = 'Comunicazione con il Gestore';
        caseGestore.Phase__c = 'In attesa risposta Mail';
        caseList.add(caseGestore);
        
        insert caseList;

        List<ContentVersion> contentVersion = HDT_UTL_DataFactoryTst.createContentVers(1, false);
        insert contentVersion;

        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument WHERE LatestPublishedVersionId = :contentVersion[0].Id];

        list<ContentDocumentLink> listDocumentLink = HDT_UTL_DataFactoryTst.createContentDocumentLink(1, false, caseList[0].Id, documents[0].Id);
        insert listDocumentLink;

        List<EmailMessage> listEmailMessage = new List<EmailMessage>();
        Case csGestore = [SELECT Id FROM Case WHERE Type = 'Comunicazione con il Gestore' LIMIT 1];
        List<EmailMessage> msgList = HDT_UTL_DataFactoryTst.createEmailMessage(1, false);
        msgList[0].Subject = 'Comunicazione dal gestore';
        msgList[0].RelatedToId = csGestore.Id;
        listEmailMessage.add(msgList[0]);
        insert listEmailMessage;

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
        System.assertEquals(true, ret.success, 'can\'t find the EmailTemplate in the folder');
        
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
        EmailTemplate emailTemplate =  [SELECT Id, Name FROM EmailTemplate LIMIT 1];

        Test.startTest();
        ret = HDT_LC_MailSender.getBodyMailMerged(emailTemplate.Name, emailTemplate.Id, emailMessage.Id);
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
        String emailMessageJson = '{"recordId": "'+ caseId +'", "isReminder": false,"orgWideAddId": "'+ orgWideAddId +'", "bodyMail": "Note 2", "toAddress": "'+ toAddress +'"}';

        Test.startTest();
        ret = HDT_LC_MailSender.sendMail(emailMessageJson);
        Test.stopTest();
        System.assertEquals(true, ret.success, ret.message);
    }

    @IsTest
    static void getContentDocsTst(){

        List<Case> cases =  [SELECT Id FROM Case LIMIT 1];
        Test.startTest();
        List<ContentDocument> cdList = HDT_LC_MailSender.getContentDocs(cases[0].Id);
        Test.stopTest();
        System.assert(cdList.size() > 0, 'Errore in fase di retrieve dei documenti caricati.');
        
    }

    @IsTest
    static void deletePendingFilesTst(){
        List<Case> cases =  [SELECT Id FROM Case LIMIT 1];
        List<Id> cdIdList = new List<Id>();
        Test.startTest();
            List<ContentDocument> cdList = HDT_LC_MailSender.getContentDocs(cases[0].Id);
            cdIdList.add(cdList[0].Id); 
            HDT_UTL_MailSenderHelper.deletePendingFiles(cdIdList);
        Test.stopTest();
        
        List<ContentDocument> cdListAfter = [SELECT Id FROM ContentDocument LIMIT 1];
        System.assert(cdListAfter.size() == 0, 'Errore in fase di eliminazione dei documenti.');
    }

    @IsTest
    static void getContentSizeAttachmentsTst(){
        List<Case> cases =  [SELECT Id FROM Case LIMIT 1];
        Test.startTest();
            List<ContentDocument> cdList = HDT_LC_MailSender.getContentDocs(cases[0].Id);
            List<Id> cdIdList = new List<Id>();
            cdIdList.add(cdList[0].Id);
            Decimal attachmentsSize = HDT_UTL_MailSenderHelper.getContentSizeAttachments(cdIdList);
        Test.stopTest();
        
        System.assert(attachmentsSize != null, 'Errore in fase di retrieve della dimensione dei documenti.');
    }

    @IsTest
    static void getMetadataForReminderTst(){
        HDT_WRP_MailSender.HDT_WRP_Result ret ;
        List<Case> cases =  [SELECT Id FROM Case WHERE Type = 'Comunicazione con il Gestore' LIMIT 1];
        Test.startTest();
            ret = HDT_LC_MailSender.getMetadata(cases[0].Id);
        Test.stopTest();
        
        System.assert(ret != null, 'Errore in fase di retrieve della dimensione dei documenti.');
    }
}