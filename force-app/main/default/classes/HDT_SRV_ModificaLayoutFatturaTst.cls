@isTest
public with sharing class HDT_SRV_ModificaLayoutFatturaTst {
    
    //DEBUG
    public static final String TEST_NAME = 'HDT_SRV_ModificaLayoutFatturaTst';
    
    //DATA
    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();
    
    
    //TEST SETUP
    private static void mySetup(){
        
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].id, 'Bozza');
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].Id);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].id);
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);
        
    }
    
    //TESTS
    
    
    @isTest
    private static void executeTest() {
        
        //DEBUG
        String debugString = 'HDT_SRV_ModificaLayoutFatturaTst - executeTest';
        
        //SETUP
        
        //SUB-SETUP
        ///CLICK
        HDT_UTL_DataFactoryTst.pClickCasePhase();
        
        ///AUTORIZZARE CAMBI DI FASE SUL CASE
        Id rt=constants.CASE_RECORDTYPEID_MOROSITA;
        HDT_UTL_DataFactoryTst.newPhaseTransition('Completata', 'Bozza', rt, 'HDT_RT_Morosita');
        HDT_UTL_DataFactoryTst.newPhaseTransition('Errore Lavorazione SAP', 'Bozza', rt, 'HDT_RT_Morosita');
        
        
        //TESTING
        String method_OK = 'ModificaLayoutFattura';//NOTA: in verità è endpoint.
        String method_dataNull = 'ModificaLayoutFattura_null';//NOTA: in verità è endpoint.
        String method_notOK = 'ModificaLayoutFattura_notOK';//NOTA: in verità è endpoint.

        Case obj = [SELECT Id, CaseNumber, ContractCode__c, ElementDetail__c FROM Case];
        System.debug(debugString + ' - case obj: ' + obj);
        
        Map<String, Object> argsMap = new Map<String,Object>();
        argsMap.put('method', method_OK);
        argsMap.put('sender', obj);
        
        
        
        
    }
    
}
