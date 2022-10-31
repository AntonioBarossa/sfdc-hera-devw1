@isTest
public with sharing class HDT_UTL_RespBodyLogUtilityTst {
    @isTest
    public static void testMustSetBody(){
        Test.startTest();
            System.assertEquals(true, HDT_UTL_RestCallRespBodyLogUtility.mustSetBody('Test1', ''), 'Metodo non correttamente funzionante');
            System.assertEquals(true, HDT_UTL_RestCallRespBodyLogUtility.mustSetBody('Test1', 'Test 1'), 'Metodo non correttamente funzionante');
            System.assertEquals(false, HDT_UTL_RestCallRespBodyLogUtility.mustSetBody('Test1', 'Test1'), 'Metodo non correttamente funzionante');
            System.assertEquals(false, HDT_UTL_RestCallRespBodyLogUtility.mustSetBody('Test1', 'TEst_2'), 'Metodo non correttamente funzionante');
            System.assertEquals(false, HDT_UTL_RestCallRespBodyLogUtility.mustSetBody('Test1', 'Test_3'), 'Metodo non correttamente funzionante');
            System.assertEquals(false, HDT_UTL_RestCallRespBodyLogUtility.mustSetBody('Test2', ''), 'Metodo non correttamente funzionante');
            System.assertEquals(false, HDT_UTL_RestCallRespBodyLogUtility.mustSetBody('Test2', 'Test 1'), 'Metodo non correttamente funzionante');
            System.assertEquals(false, HDT_UTL_RestCallRespBodyLogUtility.mustSetBody('Test2', 'Test2'), 'Metodo non correttamente funzionante');
            System.assertEquals(true, HDT_UTL_RestCallRespBodyLogUtility.mustSetBody('Test2', 'TEst_2'), 'Metodo non correttamente funzionante');
            System.assertEquals(true, HDT_UTL_RestCallRespBodyLogUtility.mustSetBody('Test2', 'Test_3'), 'Metodo non correttamente funzionante');
        Test.stopTest();
    }    
}
