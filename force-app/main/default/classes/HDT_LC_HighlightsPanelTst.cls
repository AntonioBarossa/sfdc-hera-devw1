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
        
        
        //TESTING
        String result = HDT_LC_HighlightsPanel.updateKpis(acc.Id);
        //Recaller__c
        //ComplaintRateNum__c
        
        //ASSERTS
        System.assertEquals(null, result);
        
        
    }
    
    //exception coverage tests
    
    @isTest
    private static void exceptionCoverage(){
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'exceptionCoverage';
        System.debug(debugString);
        
        //TESTING - updateKpis
        String result = HDT_LC_HighlightsPanel.updateKpis('');
        System.assert(String.isNotBlank(result));
        
    }
    
}
