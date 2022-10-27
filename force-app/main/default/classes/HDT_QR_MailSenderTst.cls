/**
* @author Elvin Iluca
* @date 26/10/2022
* @description Test Class for HDT_QR_MailSender.cls
* @history Elvin Iluca – 26/10/2022 – Created class
*/

@isTest
public with sharing class HDT_QR_MailSenderTst {
  
    //DATA
	private static HDT_UTL_Constants utlConstants = new HDT_UTL_Constants();

     /**​
    * @author Elvin Iluca
    * @date 26/10/2022
    * @description HDT_QR_MailSenderTst – Test Class for HDT_QR_MailSender.cls
    */
    @TestSetup
	static void setup(){
        //HDT_UTL_DataFactoryTstcreateEmailMessage

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
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, false, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);
        insert caseList;

        List<EmailMessage> emailMessageList = HDT_UTL_DataFactoryTst.createEmailMessage(1, false);
        emailMessageList[0].RelatedToId = caseList[0].Id;
        insert emailMessageList;
    }

    /**​
    * @author Elvin Iluca
    * @date 26/10/2022
    * @description HDT_QR_MailSenderTst – Test Class for HDT_QR_MailSender.cls
    */
    @isTest
    static void getFolderListTst(){
        List<Folder> folderList = [SELECT Id, Name FROM Folder Limit 1];
        Id testId = folderList[0].Id;
        Test.startTest();
        folderList = HDT_QR_MailSender.getFolderList(folderList[0].Name);
        Test.stopTest();

        System.assertEquals(testId, folderList[0].Id, 'Error folder Id returned');
    }

    /**​
    * @author Elvin Iluca
    * @date 26/10/2022
    * @description HDT_QR_MailSenderTst – Test Class for HDT_QR_MailSender.cls
    */
    @isTest
    static void getEmailTemplateListTst(){

        List<EmailTemplate> folderList = [SELECT Id, FolderId FROM EmailTemplate WHERE IsActive = true Limit 1];
        Id testFolderId = folderList[0].FolderId;
        List<EmailTemplate> emailTemplateListExpected = [SELECT Id, FolderId FROM EmailTemplate WHERE FolderId =: testFolderId];
        List<EmailTemplate> emailTemplateListActual;
        Test.startTest();
        emailTemplateListActual = HDT_QR_MailSender.getEmailTemplateList(testFolderId);
        Test.stopTest();
        
        System.assertEquals(emailTemplateListExpected.size(), emailTemplateListActual.size(), 'Error size of email template list');
        System.assertEquals(emailTemplateListExpected[0].FolderId, emailTemplateListActual[0].FolderId, 'Error folderId returned');

    }

    /**​
    * @author Elvin Iluca
    * @date 26/10/2022
    * @description HDT_QR_MailSenderTst – Test Class for HDT_QR_MailSender.cls
    */
    @isTest
    static void getEmailTemplateByNameListTst(){
        List<EmailTemplate> emailTemplateListExpected = [SELECT Id, Name FROM EmailTemplate LIMIT 1];
        List<EmailTemplate> emailTemplateListActual;
        Test.startTest();
        emailTemplateListActual = HDT_QR_MailSender.getEmailTemplateByNameList(emailTemplateListExpected[0].Name);
        Test.stopTest();

        System.assertEquals(true, !emailTemplateListActual.isEmpty(), 'Error: EmailTemplate is empty');
    }

    /**​
    * @author Elvin Iluca
    * @date 26/10/2022
    * @description HDT_QR_MailSenderTst – Test Class for HDT_QR_MailSender.cls
    */
    @isTest
    static void getOrgWideEmailAddressListTst(){

        List<OrgWideEmailAddress> orgWideEmailAddressList = [SELECT Id, DisplayName FROM OrgWideEmailAddress];
        List<OrgWideEmailAddress> emailTemplateListActual;
        Test.startTest();
        emailTemplateListActual = HDT_QR_MailSender.getOrgWideEmailAddressList(orgWideEmailAddressList[0].DisplayName);
        Test.stopTest();

        System.assertEquals(true, !emailTemplateListActual.isEmpty(), 'Error: OrgWideEmailAddress List is empty');
    }

    /**​
    * @author Elvin Iluca
    * @date 26/10/2022
    * @description HDT_QR_MailSenderTst – Test Class for HDT_QR_MailSender.cls
    */
    @isTest
    static void getEmailTemplateByIdTst(){
        
        List<EmailTemplate> emailTemplateListExpected = [SELECT Id FROM EmailTemplate LIMIT 1];
        List<EmailTemplate> emailTemplateListActual;
        Test.startTest();
        emailTemplateListActual = HDT_QR_MailSender.getEmailTemplateById(emailTemplateListExpected[0].Id);
        Test.stopTest();

        System.assertEquals(true, !emailTemplateListActual.isEmpty(), 'Error: EmailTemplate List is empty');

    }
    
    /**​
    * @author Elvin Iluca
    * @date 26/10/2022
    * @description HDT_QR_MailSenderTst – Test Class for HDT_QR_MailSender.cls
    */
    @isTest
    static void getEmailTst(){

        String emailActual;
        
        Test.startTest();
        emailActual = HDT_QR_MailSender.getEmail('');
        Test.stopTest();

        System.assertEquals(null, emailActual, 'Error it\' not null');
    }

    /**​
    * @author Elvin Iluca
    * @date 26/10/2022
    * @description HDT_QR_MailSenderTst – Test Class for HDT_QR_MailSender.cls
    */
    @isTest
    static void getEmailMessageTst(){

        List<EmailMessage> emailMessageExpected = [SELECT Id, RelatedToId, Subject FROM EmailMessage];
        List<EmailMessage> emailMessageActual;

        Test.startTest();
        emailMessageActual = HDT_QR_MailSender.getEmailMessage(emailMessageExpected[0].RelatedToId,emailMessageExpected[0].Subject);
        Test.stopTest();

        System.assertEquals(true, !emailMessageActual.isEmpty(), 'Error: EmailTemplate List is empty');
        
    }
    
}
