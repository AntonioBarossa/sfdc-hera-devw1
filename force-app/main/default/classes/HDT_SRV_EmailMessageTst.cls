@isTest
public with sharing class HDT_SRV_EmailMessageTst {
    
    //DEBUG
    public static final String TEST_NAME = 'HDT_SRV_EmailMessageTst';
    
    //DATA
    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();
    
    
    //TEST SETUP
    private static void mySetup(){
        List<Account> acc = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<BillingProfile__c> bpf = HDT_UTL_DataFactoryTst.createBillingProfile(1, true, acc[0].Id);
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, acc[0].Id, 'Bozza');
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, acc[0].Id);
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, acc[0].id);
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, true, acc[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);
        HDT_UTL_DataFactoryTst.pClickCasePhase();
    }
    
    
    
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
    @isTest
    private static void checkEmailSenderTest() {
        
		//DEBUG
		String debugString = TEST_NAME + ' - checkEmailSenderTest';
		System.debug(debugString);
        
        //SETUP
        mySetup();
        Case myCase = [SELECT Id FROM Case];
        
        
        //TESTING FAILURE
        
        EmailMessage m_fail = new EmailMessage();
        m_fail.fromAddress = UserInfo.getUserEmail();
        m_fail.parentId = myCase.Id;
        
        Boolean caught = false;
        
        HDT_SRV_EmailMessage.checkEmailSender(new List<EmailMessage>{m_fail});
        
        try{
            insert m_fail;
            
        } catch (Exception e) {
            System.debug(debugString + ' - exception message: ' + e.getMessage());
            System.debug(debugString + ' - exception Type: ' + e.getTypeName());
            System.debug(debugString + ' - exception stacktrace string: ' + e.getStackTraceString());
            caught = true;
            
        }
        
        //ASSERTS
        System.assert(caught);
        
        
        
        //REGULAR TESTING
        
        EmailMessage m1 = new EmailMessage();
        m1.fromAddress = 'Pugnialio@Controfiletti.it';
        m1.parentId = myCase.Id;
        
        List<EmailMessage> emailList = new List<EmailMessage>{m1};
        
        //TESTING
        HDT_SRV_EmailMessage.checkEmailSender(emailList);
        
        
    }
    
    //checkIncomingEmails
    
    
}
