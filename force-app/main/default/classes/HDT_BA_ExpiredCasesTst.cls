@isTest
public with sharing class HDT_BA_ExpiredCasesTst {
    
    //DEBUG
    public static final String TEST_NAME = 'HDT_BA_ExpiredCasesTst';
    
    
    //DATA
	private static HDT_UTL_Constants utlConstants = new HDT_UTL_Constants();
    //TODO: VERIFICARE CHE NON VENGANO PRESI BLANK DocusignExpirationDate__c
    
    //TEST SETUP
    private static void mySetup(){
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
        for(Case c : caseList){
            c.DocusignExpirationDate__c = Date.today().addDays(5);
            c.RecordTypeId = recTypeId;
            //c.Contact__c = conList[0].Id;
        }
        
        Case mySingleCase = HDT_UTL_DataFactoryTst.createOrder(2, false, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id)[0];
        mySingleCase.RecordTypeId = recTypeId;
        
        caseList.add(mySingleCase);
        insert caseList;
        
    }
    
    
    //TESTS
    
    @isTest
    private static void myBatchTest() {
        
        //SETUP
        mySetup();
        Case myCase = [SELECT Id FROM Case LIMIT 1];
        
        //UPDATING ORDER FOR BATCH
        myCase.DocusignExpirationDate__c = Date.today().addDays(-10);
        update myCase;
        
        //TESTING
        Test.startTest();
        HDT_BA_ExpiredCases myBatchToTest = new HDT_BA_ExpiredCases();
        Database.executeBatch(myBatchToTest);
        Test.stopTest();
        
        //RETRIEVING DATA
        Case myUpdatedCase = [SELECT Id, Phase__c, CancellationReason__c FROM Case WHERE Id = :myCase.Id];
        Case myRegularCase = [SELECT Id, Phase__c, CancellationReason__c FROM Case WHERE Id != :myCase.Id];
        
        //ASSERTS
        System.assert('Annullato'.equalsIgnoreCase(myUpdatedCase.Phase__c), 'Ordine NON è in Fase Annullato');
        System.assert('Annullato per no conferma cliente'.equalsIgnoreCase(myUpdatedCase.CancellationReason__c), 'Ordine risulta NON annullato.');
        
        System.assert(!'Annullato'.equalsIgnoreCase(myRegularCase.Phase__c), 'Ordine è in Fase Annullato, non previsto.');
        System.assert(!'Annullato per no conferma cliente'.equalsIgnoreCase(myRegularCase.CancellationReason__c), 'Ordine risulta annullato.');
        
    }
    
}
