@isTest
public with sharing class HDT_WS_CertifiedEmailTst {
    
    @isTest
    private static void doGetTest() {
        
        //TESTING
        List<Task> result = HDT_WS_CertifiedEmail.doGet();
        
        //ASSERTS
        System.assert(result.size() == 0);
        
    }
    
}
