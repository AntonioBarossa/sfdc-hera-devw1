@isTest
public class HDT_LC_AccountStatementControllerTst {

    @isTest static void getTabsMetaData(){
        HDT_WRP_AccountStatement.HDT_WRP_Tabs tabMetadata;
        tabMetadata = HDT_LC_AccountStatementController.getTabsMetaData();
        System.assertEquals(true, tabMetadata.success, '');
        System.assertEquals(10, tabMetadata.tabDetail.size(), '');
    }

    @isTest static void getSecondLevelColumns(){
        HDT_WRP_AccountStatement.HDT_WRP_SecLevColumnsObj secLevColumnsObj;
        secLevColumnsObj = HDT_LC_AccountStatementController.getSecondLevelColumns('EC');
        System.debug('>>> columnObj ' + secLevColumnsObj.columnObj.size());
        System.debug('>>> buttonList ' + secLevColumnsObj.buttonList.size());
    }

}