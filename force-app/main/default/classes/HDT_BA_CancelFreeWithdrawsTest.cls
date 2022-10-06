@SuppressWarnings('PMD.AvoidDebugStatements')
@isTest
public with sharing class HDT_BA_CancelFreeWithdrawsTest {

    @TestSetup
    static void makeData(){
        List<ServicePoint__c> pointList = HDT_UTL_DataFactoryTst.createServicePoint(5, false);
        pointList[0].CommoditySector__c = 'Ambiente';
        insert pointList;

        List<FreeWithdraw__c> freeWithdrawList = new List<FreeWithdraw__c>();
        FreeWithdraw__c ritiro = new FreeWithdraw__c(
            Canceled__c = false,
            Name = 'Test_FreeWithdraw',
            ServicePointMaster__c = pointList[0].Id
        );
        insert ritiro;
    }

    @isTest
    private static void testBatch(){
        List<FreeWithdraw__c> oldFreeWithdrawList = [
            SELECT id, Name
            FROM FreeWithdraw__c 
            WHERE Canceled__c = false 
            AND CreatedDate <: Datetime.newInstance(DateTime.now().year(), 12, 31)
            AND  Name = 'Test_FreeWithdraw'
        ];

        Test.startTest();
        new HDT_BA_CancelFreeWithdraws().execute(((SchedulableContext) null));
        Test.stopTest();

        oldFreeWithdrawList = [
            SELECT id  
            FROM FreeWithdraw__c 
            WHERE Canceled__c = false 
            AND CreatedDate <: Datetime.newInstance(DateTime.now().year(), 12, 31)
            AND  Name = 'Test_FreeWithdraw'
        ];
        system.assertEquals(0, oldFreeWithdrawList.size(), 'Error, there are still FreeWithdraw not Canceled');
    }
}
