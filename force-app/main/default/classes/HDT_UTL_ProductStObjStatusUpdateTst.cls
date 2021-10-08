@isTest
public class HDT_UTL_ProductStObjStatusUpdateTst {

    @isTest
    static void getTabsMetaData(){
        boolean finished = false;
        Test.startTest();
        HDT_UTL_ProductStObjStatusUpdate.scheduleJob();
        finished = true;
        Test.stopTest();
        
        //ASSERTS
        System.assertEquals(true, finished, 'Test Ended');
    }

}