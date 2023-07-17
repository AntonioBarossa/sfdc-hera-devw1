@isTest
public with sharing class HDT_UTL_ErrorHandlerTst 
{
    @isTest
    static void constructorTst()
    {
        Test.startTest();
            HDT_UTL_ErrorHandler tst = new HDT_UTL_ErrorHandler('TST-00001','TEST');
        Test.stopTest();
        System.assertEquals(false, String.isBlank(tst.errorDescription),'Incorrect Description');
        System.assertEquals(false, tst.isSuccess,'Incorrect outcome');
    }

}
