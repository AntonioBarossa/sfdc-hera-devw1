@isTest
public with sharing class HDT_UTL_EmailProtocolReceiverTst {
    
  private static HDT_UTL_Constants constants = new HDT_UTL_Constants();

    @TestSetup
    static void setup() {

      Id adminUserProfileId = HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);

        User internalUser = HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);


        internalUser.UserPermissionsMarketingUser=true;

        insert internalUser;

        HDT_UTL_DataFactoryTst.assignPermissionSet(internalUser, constants.PERMISSIONSET_HDT_PROTOCOLMANUALACTIVITIES, true);

        System.runAs(internalUser) {
          HDT_UTL_DataFactoryTst.pClickInstanceActivityIntegration();

        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env    = new Messaging.InboundEnvelope();

        String str = 'PlainTextBody of the email for the test.';
        email.fromName = 'testName';
        email.plainTextBody = str;
        email.subject = 'testSubject';
        String[] toAddresses = new String[] {'toAdresses1@gmail.com','toAdresses2@gmail.com'};
        email.toAddresses = toAddresses;
        env.fromAddress = 'user@gmail.com';
/*
        List<Interaction__c> testInt = new List<Interaction__c>();
        testInt[0].Status__c = 'Bozza';
        testInt[0].Type__c = 'Digital';
        testInt[0].ReceptionDate__c = System.Date.today();
        testInt[0].BodyEmail__c = str;
        testInt[0].SubjectEmail__c = email.subject;
        insert testInt;
        Map<String,HDT_ProtocolSpecificEmail__mdt> mapEmailObj = new Map<String,HDT_ProtocolSpecificEmail__mdt>();
        HDT_ProtocolSpecificEmail__mdt specEmail = new HDT_ProtocolSpecificEmail__mdt();
        specEmail = mapEmailObj.get(email.toAddresses[0].toUpperCase());
        HDT_UTL_Note.createNoteAndAssign(testInt[0].id, 'Testo Troncato per Superamento Limite Caratteri', '');
*/
      Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
      attachment.body = blob.valueOf('the BinaryAttachment text body');
      attachment.fileName = 'textfileone.txt';
      attachment.mimeTypeSubType = 'text/plain';
      email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };

 
      Messaging.InboundEmail.TextAttachment attachmenttext = new Messaging.InboundEmail.TextAttachment();
      attachmenttext.body = 'The TextAttachment text body';
      attachmenttext.fileName = 'textfiletwo3.txt';
      attachmenttext.mimeTypeSubType = 'texttwo/plain';
      email.textAttachments =   new Messaging.inboundEmail.TextAttachment[] { attachmenttext };

        
      HDT_UTL_EmailProtocolReceiver emailProtocolReceiver = new HDT_UTL_EmailProtocolReceiver();
        emailProtocolReceiver.handleInboundEmail(email,env);

        }
      }

      @isTest
      public static void testHandleInboundEmail(){

       Interaction__c testFields = [SELECT id,BodyEmail__c FROM Interaction__c  LIMIT 1];

       system.assertEquals('PlainTextBody of the email for the test.', testFields.BodyEmail__c,'the inbound PlainTextBody is not correctly assigned to BodyEmail__c field of Interaction__c');
       system.assertEquals(true, testFields.BodyEmail__c != null,'BodyEmail__c field of Interaction__c is not assigned' );        
      }
}

