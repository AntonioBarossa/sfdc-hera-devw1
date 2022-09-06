@isTest
public with sharing class HDT_SRV_EmailMessageTst {
    
    //DEBUG
    public static final String TEST_NAME = 'HDT_SRV_EmailMessageTst';
    
    //DATA
    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();
    private static String myType = 'Comunicazione di Fallimento';
    
    
    //TEST SETUP
    private static void mySetup(){
        List<Account> acc = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<BillingProfile__c> bpf = HDT_UTL_DataFactoryTst.createBillingProfile(1, true, acc[0].Id);
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, acc[0].Id, 'Bozza');
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, acc[0].Id);
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, acc[0].id);
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCaseDocumentale(1, false, acc[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);
        
        //MANAGING CASE
        Case myCase = caseList[0];
        myCase.Type = myType;
        insert myCase;
        
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
        System.assertEquals(1, result.size(), 'value of parameter is matching');
        
    }
    
    
    
    //checkEmailSender
    ///TESTING ADDERROR
    @isTest
    private static void checkEmailSenderTest_addErrorTest() {
        
		//DEBUG
		String debugString = TEST_NAME + ' - checkEmailSenderTest_addErrorTest';
		System.debug(debugString);
        
        //SETUP
        
        //TESTING
        EmailMessage m1 = new EmailMessage();
        m1.fromAddress = UserInfo.getUserEmail();
        
        List<EmailMessage> emailList = new List<EmailMessage>{m1};
        
        //TESTING
		System.debug(debugString + ' - Inizio testing');
        HDT_SRV_EmailMessage.checkEmailSender(emailList);
        
        Boolean caught = false;
        try{
            insert emailList;
            
        } catch (Exception e) {
            System.debug(debugString + ' - Exception: ' + e.getMessage());
            caught = true;
            
        }
        
        //ASSERTS
        // System.assert(caught, 'value of parameter is matching');
        
    }
    
    
    ///TESTING - Comunicazione di Fallimento
    @isTest
    private static void checkEmailSenderTest_ComFall() {
        
		//DEBUG
		String debugString = TEST_NAME + ' - checkEmailSenderTest_ComFall';
		System.debug(debugString);
        
        //SETUP
        mySetup();
        Case myCase = [SELECT Id FROM Case];
        
        
        //TESTING
        EmailMessage m1 = new EmailMessage();
        m1.fromAddress = 'Pugnialio@Controfiletti.it';
        m1.parentId = myCase.Id;
        
        List<EmailMessage> emailList = new List<EmailMessage>{m1};
        
        Id rt = constants.CASE_RECORDTYPEID_DOCUMENTALECOPIACONTRATTO;
		HDT_UTL_DataFactoryTst.newPhaseTransition('In attesa risposta Mail', 'Bozza', rt, 'HDT_RT_DocCopiaContratto');
        
        
        //TESTING
		System.debug(debugString + ' - Inizio testing');
        HDT_SRV_EmailMessage.checkEmailSender(emailList);
        
        List<Case> cases = [Select id From Case where Phase__c = 'In attesa risposta Mail'];
        System.assertEquals(1, cases.size(), 'value of parameter is matching');
        System.assertNotEquals(null, cases, 'value of parameter is not matching');
        
    }
    
    
    ///TESTING - Richiesta Parere
    @isTest
    private static void checkEmailSenderTest_Richiesta() {
        
		//DEBUG
		String debugString = TEST_NAME + ' - checkEmailSenderTest_Richiesta';
		System.debug(debugString);
        
        //SETUP
        myType = 'Richiesta Parere';
        
        mySetup();
        Case myCase = [SELECT Id FROM Case];
        
        
        //TESTING - Richiesta Parere
        
        EmailMessage m1 = new EmailMessage();
        m1.fromAddress = 'Pugnialio@Controfiletti.it';
        m1.parentId = myCase.Id;
        
        List<EmailMessage> emailList = new List<EmailMessage>{m1};
        
        Id rt = constants.CASE_RECORDTYPEID_DOCUMENTALECOPIACONTRATTO;
		HDT_UTL_DataFactoryTst.newPhaseTransition('In attesa risposta parere', 'Bozza', rt, 'HDT_RT_DocCopiaContratto');
        
        //TESTING
		System.debug(debugString + ' - Inizio testing');
        HDT_SRV_EmailMessage.checkEmailSender(emailList);
        
        List<Case> cases = [Select id From Case where Phase__c = 'In attesa risposta parere'];
        System.assertEquals(1, cases.size(), 'value of parameter is matching');
        System.assertNotEquals(null, cases, 'value of parameter is not matching');        
        
    }
    
    
    
    //checkIncomingEmails
    
    ///Comunicazione fallimento
    @isTest
    private static void checkEmailSenderTest_Comunicazione() {
        
		//DEBUG
		String debugString = TEST_NAME + ' - checkEmailSenderTest_Comunicazione';
		System.debug(debugString);
        
        //SETUP
        mySetup();
        Case myCase = [SELECT Id FROM Case];
        
        
        //TESTING - Comunicazione fallimento
        
        EmailMessage m1 = new EmailMessage();
        m1.fromAddress = 'Pugnialio@Controfiletti.it';
        m1.parentId = myCase.Id;
        m1.Incoming = true;
        
        List<EmailMessage> emailList = new List<EmailMessage>{m1};
        
        Id rt = constants.CASE_RECORDTYPEID_DOCUMENTALECOPIACONTRATTO;
		HDT_UTL_DataFactoryTst.newPhaseTransition('Risposta Ricevuta', 'Bozza', rt, 'HDT_RT_DocCopiaContratto');
        
        //TESTING
		System.debug(debugString + ' - Inizio testing');
        HDT_SRV_EmailMessage.checkIncomingEmails(emailList);
        
		List<Case> cases = [Select id From Case where Phase__c = 'Risposta Ricevuta'];
        System.assertEquals(1, cases.size(), 'value of parameter is matching');
        System.assertNotEquals(null, cases, 'value of parameter is not matching');
    }
    
    ///Richiesta Parere
    @isTest
    private static void checkIncomingEmails_Richiesta() {
        
		//DEBUG
		String debugString = TEST_NAME + ' - checkIncomingEmails_Richiesta';
		System.debug(debugString);
        
        //SETUP
        myType = 'Richiesta Parere';
        mySetup();
        Case myCase = [SELECT Id FROM Case];
        
        
        //TESTING - Richiesta Parere
        
        EmailMessage m1 = new EmailMessage();
        m1.fromAddress = 'Pugnialio@Controfiletti.it';
        m1.parentId = myCase.Id;
        m1.Incoming = true;
        
        List<EmailMessage> emailList = new List<EmailMessage>{m1};
        
        Id rt = constants.CASE_RECORDTYPEID_DOCUMENTALECOPIACONTRATTO;
		HDT_UTL_DataFactoryTst.newPhaseTransition('Completata', 'Bozza', rt, 'HDT_RT_DocCopiaContratto');
        
        
        //TESTING
		System.debug(debugString + ' - Inizio testing');
        HDT_SRV_EmailMessage.checkIncomingEmails(emailList);
        
        List<Case> cases = [Select id From Case where Phase__c = 'Completata'];        
        System.assertEquals(1, cases.size(), 'value of parameter is matching');
        System.assertNotEquals(null, cases, 'value of parameter is not matching');
        
    }
    
    //EMPTY CONSTRUCTOR TEST
    @isTest
    private static void constructorTest(){
        
		//DEBUG
		String debugString = TEST_NAME + ' - constructorTest';
		System.debug(debugString);
        
        //TESTING
        Object test = new HDT_SRV_EmailMessage();
        
        System.assertEquals(true, (test instanceof HDT_SRV_EmailMessage), 'value of parameter is matching');
        System.assertNotEquals(null, test, 'value of parameter is not matching');     
        
    }
    
}