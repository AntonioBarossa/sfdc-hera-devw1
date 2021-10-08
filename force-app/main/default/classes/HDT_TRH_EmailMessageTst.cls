@isTest
public with sharing class HDT_TRH_EmailMessageTst {

    
    //DEBUG
    public static final String TEST_NAME = 'HDT_TRH_EmailMessageTst';
    
    
    //TEST SETUP

    
    //TESTS
    

    @isTest
    private static void checkEmailSenderTest(){
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'checkEmailSenderTest';
        System.debug(debugString);
        
        //SETUP

        List<EmailMessage> emailList = new List<EmailMessage>();
        EmailMessage email = new EmailMessage();
        email.FromAddress = UserInfo.getUserEmail();
        emailList.add(email);
        
        //TESTING
        Test.startTest();
        try{

            insert emailList;
        
        }catch(DmlException e) {
                System.debug('The following exception has occurred: ' + e.getMessage());
        }
        Test.stopTest();
        
        //ASSERTS
        System.assert(emailList != null, 'Attenzione, emailList non può essere null!');
        
    }


    @isTest
    private static void checkIncomingEmails(){
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'checkEmailSenderTest';
        System.debug(debugString);
        
        //SETUP
        HDT_UTL_DataFactoryTst.pClickCasePhase();

        List<Account> acc = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<BillingProfile__c> bpf = HDT_UTL_DataFactoryTst.createBillingProfile(1, true, acc[0].Id);
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, acc[0].Id, 'Bozza');
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, acc[0].Id);
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, acc[0].id);
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCaseDocumentale(1, false, acc[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);
        
        Case myCase = caseList[0];
        myCase.Type = 'Comunicazione di Fallimento';
        insert myCase;

        List<EmailMessage> emailList = new List<EmailMessage>();
        EmailMessage email = new EmailMessage();
        email.parentId = myCase.Id;
        emailList.add(email);

        
        //TESTING
        Test.startTest();
        try{

            insert emailList;
            
        }catch(DmlException e) {
                System.debug('The following exception has occurred: ' + e.getMessage());
        }
        Test.stopTest();
        
        //ASSERTS
        System.assert(emailList != null, 'Attenzione, emailList non può essere null!');
        
    }

}
