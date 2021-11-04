/**

Header of the class "HDT_UTL_EmailProtocolReceiverTst"
@author Pooyan Ghadiri Abkenar, pooyan.ghadiriabkenar@webresults.it
@Version 1.0
@description: Apex Test Class of the relative Apex Class "HDT_UTL_EmailProtocolReceiver"
@history
@created 30/09/2021
Modified By:
**/

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
      
        for(integer i = 0; i<10 ; i++){

          str = str + str ;

        }
        
      email.fromName = 'testName';
      email.plainTextBody = str;
      email.subject = 'testSubject';
      String[] toAddresses = new String[] {'toAdresses1@gmail.com','toAdresses2@gmail.com'};
      email.toAddresses = toAddresses;
      env.fromAddress = 'user@gmail.com';
      
      
      HDT_QR_Contact con = new HDT_QR_Contact();
      con.getContactByEmailAddress(email.fromAddress);


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

      Interaction__c newInt = new Interaction__c();
      newInt.Status__c = 'Bozza';
      newInt.Type__c = 'Digital';
      insert newInt;

      system.assertEquals(true, testFields.BodyEmail__c != null ,'The inbound PlainTextBody is not correctly assigned to BodyEmail__c field of Interaction__c');
      system.assertNotEquals('', testFields.BodyEmail__c ,'BodyEmail__c field of Interaction__c is not assigned' );        
      }
}