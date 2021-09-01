@isTest
public with sharing class HDT_LC_CloneArticleTst {
    
    //DEBUG
    public static final String TEST_NAME = 'HDT_LC_CaseDocumentValidationTstTst';
    
    
    //TEST SETUP
    
    
    
    //TESTS
    
    //getRecordTypeOptions
    @isTest
    private static void getRecordTypeOptionsTest() {
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'getRecordTypeOptionsTest';
        System.debug(debugString);
        
        //TESTING
        List<RecordType> result = HDT_LC_CloneArticle.getRecordTypeOptions();
        
        //ASSERTS
        System.assertNotEquals(null, result);
        
    }
    
    
    //cloneArticle
    @isTest
    private static void cloneArticleTest() {
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'cloneArticleTest';
        System.debug(debugString);
        
        //SETUP
        Knowledge__kav kArt = new Knowledge__kav(Title = 'Test Original Title', urlName = 'original');
        insert kArt;
        
        HDT_UTL_Constants utConst = new HDT_UTL_Constants();
        String title = 'Test Clone Title';
        String urlName = 'clone';
        String recordtypeId = utConst.KNOWLEDGEARTICLE_RECORDTYPEID_FAQ;
        
        //HDT_RT_FAQ
        
        //TESTING
        Knowledge__kav result = HDT_LC_CloneArticle.cloneArticle(kArt.Id, title, urlName, recordtypeId);
        
        //ASSERTS
        System.assertNotEquals(kArt.Id, result.Id);
        
    }
    
    
    //redirectToArticle
    @isTest
    private static void redirectToArticleTest() {
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'redirectToArticleTest';
        System.debug(debugString);
        
        //SETUP
        Knowledge__kav kArt = new Knowledge__kav(Title = 'Test Original Title', urlName = 'original');
        insert kArt;
        
        //HDT_RT_FAQ
        
        //TESTING
        Id result = HDT_LC_CloneArticle.redirectToArticle(kArt.Title, kArt.urlName);
        
        //ASSERTS
        System.assertEquals(kArt.Id, result);
        
    }
    
    
}
