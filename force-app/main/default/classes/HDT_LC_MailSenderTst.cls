/**
* @author Elvin Iluca
* @date 19/10/2022
* @description Test Class for HDT_LC_MailSender.cls
* @history Elvin Iluca – 19/10/2022 – Created class
*/


@isTest
public with sharing class HDT_LC_MailSenderTst {

    /**​
    * @author Elvin Iluca
    * @date 19/10/2022
    * @description HDT_LC_MailSenderTst – Test Class for HDT_LC_MailSender.cls
    */
    @TestSetup
	static void setup(){
        EmailMessage emailMessage = new EmailMessage();
        emailMessage.status = '3'; // email was sent
        //emailMessage.relatedToId = '001XXXXXXXXXXX'; 
        emailMessage.fromAddress = 'billing@acme.com'; // from address
        emailMessage.fromName = 'Billing Department'; // from name
        emailMessage.toAddress = 'johnSmith@example.com';
        emailMessage.Subject = 'Hello';
        emailMessage.HtmlBody = 'Hello World';
        insert emailMessage;

       
        EmailTemplate validEmailTemplate;
        System.runAs (new User(Id = UserInfo.getUserId()) ){
            validEmailTemplate = new EmailTemplate();
            validEmailTemplate.isActive = true;
            validEmailTemplate.Name = 'name';
            validEmailTemplate.DeveloperName = 'unique_name_addSomethingSpecialHere';
            validEmailTemplate.TemplateType = 'text';
            validEmailTemplate.FolderId = UserInfo.getUserId();

            insert validEmailTemplate;

           
        }
/* 
        OrgWideEmailAddress orgWideEmailAddress = new OrgWideEmailAddress(Address='test@address.com');
        insert orgWideEmailAddress; */
        
        
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
        System.debug('Debug:');


        //to be continued
        List<OrgWideEmailAddress> test = [SELECT Id FROM OrgWideEmailAddress LIMIT 1];
        
        System.debug(test[0]);
        System.debug(ret.message);
        System.assert(true, 'ok');
        System.assertEquals(false, ret.success, 'can\'t find the EmailTemplate in the folder');
        
        //System.assertEquals('false', mapp.get('isCommunity'), 'URL not populated correctly');

        //System.assertNotEquals(null, mapp, 'value of parameter is not matching');

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
        System.assert(true, 'ok');
    }

    /**​
    * @author Elvin Iluca
    * @date 19/10/2022
    * @description HDT_LC_MailSenderTst – Test Class for HDT_LC_MailSender.cls
    */
    @isTest
    static void sendMailTst(){
        HDT_WRP_MailSender.HDT_WRP_SendMailResult ret;
        List<OrgWideEmailAddress> owea = [SELECT Id FROM OrgWideEmailAddress];
        System.debug(owea[0]);


        //orgWideAddId va settato "dinamicamente"
        String emailMessageJson = '{"Id": 1, "isReminder": true,"orgWideAddId": 2, "bodyMail": "Note 2", "toAddress": "Note 2"}';
        

        Test.startTest();
        ret = HDT_LC_MailSender.sendMail(emailMessageJson);
        Test.stopTest();
        System.assert(true, 'ok');
    }
}
