/**
* @author Cristiano Salvati (c.salvati@key2.it)
* @date 26/10/2022
* @description HDT_WRP_MailSenderTst – Test class for HDT_WRP_MailSender
* @history
*/

@isTest
public with sharing class HDT_WRP_MailSenderTst {
    

    @isTest
    static void instantiateResultTst(){
        Test.startTest();
        HDT_WRP_MailSender.HDT_WRP_Result resultWrp=new HDT_WRP_MailSender.HDT_WRP_Result();
        Test.stopTest();
        System.assertEquals(true, resultWrp!=null, 'Wrapper created');
    }

    @isTest
    static void instantiateMailDataTst(){
        Test.startTest();
        HDT_WRP_MailSender.HDT_WRP_MailData dataWrp=new HDT_WRP_MailSender.HDT_WRP_MailData();
        Test.stopTest();
        System.assertEquals(true, dataWrp!=null, 'Wrapper created');
    }

    @isTest
    static void instantiatePicklistObjTst(){
        Test.startTest();
        HDT_WRP_MailSender.HDT_WRP_PicklistObj picklistWrp=new HDT_WRP_MailSender.HDT_WRP_PicklistObj();
        Test.stopTest();
        System.assertEquals(true, picklistWrp!=null, 'Wrapper created');
    }

    @isTest
    static void instantiateBodyMailTst(){
        Test.startTest();
        HDT_WRP_MailSender.HDT_WRP_BodyMail bodyWrp=new HDT_WRP_MailSender.HDT_WRP_BodyMail();
        Test.stopTest();
        System.assertEquals(true, bodyWrp!=null, 'Wrapper created');
    }

    @isTest
    static void instantiateSendMailResultTst(){
        Test.startTest();
        HDT_WRP_MailSender.HDT_WRP_SendMailResult mailResultWrp=new HDT_WRP_MailSender.HDT_WRP_SendMailResult();
        Test.stopTest();
        System.assertEquals(true, mailResultWrp!=null, 'Wrapper created');
    }

    @isTest
    static void instantiateMailStructureTst(){
        Test.startTest();
        HDT_WRP_MailSender.HDT_WRP_MailStructure mailStructureWrp=new HDT_WRP_MailSender.HDT_WRP_MailStructure();
        Test.stopTest();
        System.assertEquals(true, mailStructureWrp!=null, 'Wrapper created');
    }

    @isTest
    static void instantiateGenerateCaseResultTst(){
        Test.startTest();
        HDT_WRP_MailSender.HDT_WRP_GenerateCaseResult caseResultWrp=new HDT_WRP_MailSender.HDT_WRP_GenerateCaseResult();
        Test.stopTest();
        System.assertEquals(true, caseResultWrp!=null, 'Wrapper created');
    }
}
