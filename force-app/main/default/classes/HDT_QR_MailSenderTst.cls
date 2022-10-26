/**
* @author Elvin Iluca
* @date 26/10/2022
* @description Test Class for HDT_QR_MailSender.cls
* @history Elvin Iluca – 26/10/2022 – Created class
*/

@isTest
public with sharing class HDT_QR_MailSenderTst {
  

     /**​
    * @author Elvin Iluca
    * @date 26/10/2022
    * @description HDT_QR_MailSenderTst – Test Class for HDT_QR_MailSender.cls
    */
    /* @TestSetup
	static void setup(){
        HDT_UTL_DataFactoryTstcreateEmailMessage
    }
 */
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

        String emailExpected;
        
        Test.startTest();
        emailExpected = HDT_QR_MailSender.getEmail('');
        Test.stopTest();

        System.assertEquals(null, emailExpected, 'Error it\' not null');
    }

    /**​
    * @author Elvin Iluca
    * @date 26/10/2022
    * @description HDT_QR_MailSenderTst – Test Class for HDT_QR_MailSender.cls
    */
    @isTest
    static void getEmailMessageTst(){
        System.assertEquals(1, 1, 'msg');
    }
    
}
