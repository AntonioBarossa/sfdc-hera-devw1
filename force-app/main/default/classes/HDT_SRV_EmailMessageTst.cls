@isTest
public with sharing class HDT_SRV_EmailMessageTst {
    
    //DEBUG
    public static final String TEST_NAME = 'HDT_SRV_EmailMessageTst';
    
    //DATA
    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();
    
    
    //TEST SETUP
    
    
    
    //TESTS
    
    //insertEmailMessage
    @isTest
    private static void insertEmailMessageTest() {
        
		//DEBUG
		String debugString = TEST_NAME + ' - insertEmailMessageTest';
		System.debug(debugString);
        
        //SETUP
        EmailMessage m = new EmailMessage();
        
        //TESTING
        HDT_SRV_EmailMessage.insertEmailMessage(m);
        
        //RETRIEVE DATA
        List<EmailMessage> result = [SELECT Id FROM EmailMessage];
        
        //ASSERTS
        System.assertEquals(1, result.size());
        
    }
    
    //checkEmailSender
    
    
    //checkIncomingEmails
    
    
}
