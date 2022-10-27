/**
* @author Elvin Iluca
* @date 27/10/2022
* @description Test Class for HDT_UTL_MailSenderHelper.cls
* @history Elvin Iluca – 27/10/2022 – Created class
*/  

@isTest
public with sharing class HDT_UTL_MailSenderHelperTst{
    
     //DATA
	private static HDT_UTL_Constants utlConstants = new HDT_UTL_Constants();


     /**​
    * @author Elvin Iluca
    * @date 27/10/2022
    * @description HDT_UTL_MailSenderHelperTst – Test Class for HDT_UTL_MailSenderHelper.cls
    */
    @TestSetup
	static void setup(){
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
        insert caseList;

        List<EmailMessage> emailMessageList = HDT_UTL_DataFactoryTst.createEmailMessage(2, false);
        emailMessageList[0].RelatedToId = caseList[0].Id;
        emailMessageList[0].Subject = 'Comunicazione dal gestore';
        emailMessageList[1].RelatedToId = caseList[1].Id;
        emailMessageList[1].Subject = 'Sollecito';
        insert emailMessageList;
    }

    /**​
    * @author Elvin Iluca
    * @date 27/10/2022
    * @description HDT_UTL_MailSenderHelperTst – Test Class for HDT_UTL_MailSenderHelper.cls
    */

    @isTest
    static void checkForReminderMailTst(){
        
        List<EmailMessage> emailMessageList = [SELECT Id, RelatedToId FROM EmailMessage WHERE Subject='Comunicazione dal gestore' LIMIT 1];
        Boolean actual;

        Test.startTest();
        actual = HDT_UTL_MailSenderHelper.checkForReminderMail(emailMessageList[0].RelatedToId);
        Test.stopTest();
        
        System.assertEquals(true,actual,'Error Failed check');
    }

    /**​
    * @author Elvin Iluca
    * @date 27/10/2022
    * @description HDT_UTL_MailSenderHelperTst – Test Class for HDT_UTL_MailSenderHelper.cls
    */

    @isTest   //no EmailTemplate
    static void getReminderMetadataHelperNoEmailTemplateTst(){

        List<EmailMessage> emailMessageList = [SELECT Id, RelatedToId FROM EmailMessage WHERE Subject='Sollecito' LIMIT 1];

        HDT_WRP_MailSender.HDT_WRP_Result mailSenderResultActual;

        Test.startTest();
        mailSenderResultActual = HDT_UTL_MailSenderHelper.getReminderMetadataHelper(emailMessageList[0].RelatedToId);
        Test.stopTest();
       
        System.assertEquals('Non ci sono template', mailSenderResultActual.message, 'Error message of mail sender result');
    }

     /**​
    * @author Elvin Iluca
    * @date 27/10/2022
    * @description HDT_UTL_MailSenderHelperTst – Test Class for HDT_UTL_MailSenderHelper.cls
    */

    @isTest   //no EmailTemplate
    static void getReminderMetadataHelperTst(){

        //Insert EmailTemplate
        List<EmailTemplate> emailTemplateList = HDT_UTL_DataFactoryTst.createEmailTemplate(1,false);
        emailTemplateList[0].Name='COM-Sollecito';
        insert emailTemplateList;

        List<EmailMessage> emailMessageList = [SELECT Id, RelatedToId FROM EmailMessage WHERE Subject='Sollecito' LIMIT 1];

        HDT_WRP_MailSender.HDT_WRP_Result mailSenderResultActual;

        Test.startTest();
        mailSenderResultActual = HDT_UTL_MailSenderHelper.getReminderMetadataHelper(emailMessageList[0].RelatedToId);
        Test.stopTest();
        
        System.assertEquals(true,mailSenderResultActual.success,'Error email was not send correctly');
    }

    /**​
    * @author Elvin Iluca
    * @date 27/10/2022
    * @description HDT_UTL_MailSenderHelperTst – Test Class for HDT_UTL_MailSenderHelper.cls
    */

    @isTest
    static void getMetadataHelperTst(){

        List<EmailMessage> emailMessageList = [SELECT Id, RelatedToId FROM EmailMessage WHERE Subject='Sollecito' LIMIT 1];

        HDT_WRP_MailSender.HDT_WRP_Result mailSenderResultActual;

        Test.startTest();
        mailSenderResultActual = HDT_UTL_MailSenderHelper.getMetadataHelper(emailMessageList[0].RelatedToId);
        Test.stopTest();

        System.assertEquals(true,mailSenderResultActual.success,'Error email was not send correctly');
    
    }

    /**​
    * @author Elvin Iluca
    * @date 27/10/2022
    * @description HDT_UTL_MailSenderHelperTst – Test Class for HDT_UTL_MailSenderHelper.cls
    */

    @isTest
    static void updateReminderCaseTst(){
        
        List<EmailMessage> emailMessageList = [SELECT Id, RelatedToId FROM EmailMessage WHERE Subject='Sollecito' LIMIT 1];

        HDT_WRP_MailSender.HDT_WRP_GenerateCaseResult generalCaseResultActual;

        Test.startTest();
        generalCaseResultActual = HDT_UTL_MailSenderHelper.updateReminderCase(emailMessageList[0].RelatedToId);
        Test.stopTest();

        System.assertEquals(true,generalCaseResultActual.success,'Error general case result was not update correctly');
        
    }

    /**​
    * @author Elvin Iluca
    * @date 27/10/2022
    * @description HDT_UTL_MailSenderHelperTst – Test Class for HDT_UTL_MailSenderHelper.cls
    */
 
    @isTest
    static void generateNewCaseTst(){
        List<Case> caseList = [SELECT Id FROM Case LIMIT 1];

        HDT_WRP_MailSender.HDT_WRP_GenerateCaseResult generalCaseResultActual;

        Test.startTest();
        generalCaseResultActual = HDT_UTL_MailSenderHelper.generateNewCase(caseList[0].Id);

        Test.stopTest();

        System.assertEquals(true,generalCaseResultActual.success,'Error general case result was not update correctly');
    }
    
    /**​
    * @author Elvin Iluca
    * @date 27/10/2022
    * @description HDT_UTL_MailSenderHelperTst – Test Class for HDT_UTL_MailSenderHelper.cls
    */

    @isTest
    static void generateNewCaseErrorTst(){

        List<EmailMessage> emailMessageList = [SELECT Id, RelatedToId FROM EmailMessage LIMIT 1];

        HDT_WRP_MailSender.HDT_WRP_GenerateCaseResult generalCaseResultActual;

        Test.startTest();
        generalCaseResultActual = HDT_UTL_MailSenderHelper.generateNewCase(emailMessageList[0].Id);
        Test.stopTest();

        System.assertEquals(false,generalCaseResultActual.success,'Error general case result was not update correctly');
    }

    /**​
    * @author Elvin Iluca
    * @date 27/10/2022
    * @description HDT_UTL_MailSenderHelperTst – Test Class for HDT_UTL_MailSenderHelper.cls
    */

    @isTest
    static void getBodyMailMergedTst(){
       
        List<Account> accountList = [SELECT Id FROM Account LIMIT 1];
        List<EmailTemplate> emailTemplateList = [SELECT Id FROM EmailTemplate LIMIT 1];

        HDT_WRP_MailSender.HDT_WRP_BodyMail bodyMailActual;

        Test.startTest();
        bodyMailActual = HDT_UTL_MailSenderHelper.getBodyMailMerged(emailTemplateList[0].Id, accountList[0].Id);
        Test.stopTest();

        System.assertEquals(true,bodyMailActual.success,'Error general case result was not update correctly');

    }
    
    /**​
    * @author Elvin Iluca
    * @date 27/10/2022
    * @description HDT_UTL_MailSenderHelperTst – Test Class for HDT_UTL_MailSenderHelper.cls
    */

    @isTest
    static void sendMailHelperTst(){

        List<OrgWideEmailAddress> orgWideEmailAdress = [SELECT Id, Address FROM OrgWideEmailAddress];
        List<Case> cases =  [SELECT Id FROM Case LIMIT 1];
        String orgWideAddId = orgWideEmailAdress[0].Id;
        String toAddress = orgWideEmailAdress[0].Address;
        String caseId= cases[0].Id;
        
        String emailMessageJson = '{"caseId": "'+ caseId +'", "isReminder": false,"orgWideAddId": "'+ orgWideAddId +'", "bodyMail": "Note 2", "toAddress": "'+ toAddress +'"}';
       
        HDT_WRP_MailSender.HDT_WRP_SendMailResult sendMailResultActual;

        Test.startTest();
        sendMailResultActual = HDT_UTL_MailSenderHelper.sendMailHelper(emailMessageJson);
        Test.stopTest();

        System.assertEquals(true,sendMailResultActual.success,'Error general case result was not update correctly');
    }

}
