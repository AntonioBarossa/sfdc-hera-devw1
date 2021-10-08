@isTest
public with sharing class HDT_LC_HighlightsPanelTst {
    
    //DEBUG
    public static final String TEST_NAME = 'HDT_LC_HighlightsPanelTst';
    
    
    //TEST SETUP
    
    
    //TESTS
    
    @isTest
    private static void updateKpisTest(){
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'updateKpisTest';
        System.debug(debugString);
        
        //SETUP
        Account acc = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME')[0];
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, acc.id, 'Bozza');
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, acc.id);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, acc.id);
        
        //CASE WITH VALID ORIGIN
        Case originCase = HDT_UTL_DataFactoryTst.createCase(1, false, acc.id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id)[0];
        originCase.Origin='Web';
        insert originCase;
        
        //CASE RECLAMI
        Case reclamoCase = HDT_UTL_DataFactoryTst.createCase(1, false, acc.id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id)[0];
        reclamoCase.Cluster__c='Reclami';
        insert reclamoCase;
        
        //TESTING
        String result = HDT_LC_HighlightsPanel.updateKpis(acc.Id);
        
        //ASSERTS
        System.assertEquals(null, result, 'updateKpis did not work correctly');
        
        
    }
    
    //exception coverage tests
    
    @isTest
    private static void exceptionCoverage(){
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'exceptionCoverage';
        System.debug(debugString);
        
        //TESTING - updateKpis
        String result = HDT_LC_HighlightsPanel.updateKpis('');
        System.assert(String.isNotBlank(result), 'updateKpis did not work correctly');
        
    }
    
}
