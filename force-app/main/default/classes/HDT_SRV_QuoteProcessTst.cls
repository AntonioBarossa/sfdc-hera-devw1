/**
* @author Luis Bispo (luis.bispo@engdb.com.br)
* @date 29/07/2021
* @description HDT_SRV_QuoteProcess for Test Classes
* @history Luis Bispo – 29/07/2021 – Created class
*/
@isTest
public with sharing class HDT_SRV_QuoteProcessTst {
    
    @isTest
    public static void testCheckAccessInit() {
        Test.startTest();
        HDT_SRV_QuoteProcess hdtQuoteProcess = new HDT_SRV_QuoteProcess();
        hdtQuoteProcess.checkAccessInit('test', 'test');

        System.assert(hdtQuoteProcess != null,'');
        System.assertNotEquals(null, hdtQuoteProcess, '');
        Test.stopTest();

    }

    @isTest
    public static void testCheckReadAccess(){
        Test.startTest();
        HDT_SRV_QuoteProcess hdtQuoteProcess = new HDT_SRV_QuoteProcess();
        hdtQuoteProcess.checkReadAccess('Test');
        System.assert(hdtQuoteProcess != null,'');
        System.assertNotEquals(null, hdtQuoteProcess,'');
        Test.stopTest();

    }
}
