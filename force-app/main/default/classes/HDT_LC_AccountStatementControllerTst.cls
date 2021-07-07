@isTest
public class HDT_LC_AccountStatementControllerTst {

    @isTest
    static void getTabsMetaData(){
        HDT_WRP_AccountStatement.HDT_WRP_Tabs tabMetadata;

        Test.startTest();
        tabMetadata = HDT_LC_AccountStatementController.getTabsMetaData();
        Test.stopTest();

        System.assertEquals(true, tabMetadata.success, '');
        System.assertEquals(10, tabMetadata.tabDetail.size(), '');
    }

    @isTest
    static void getSecondLevelColumns(){
        HDT_WRP_AccountStatement.HDT_WRP_SecLevColumnsObj secLevColumnsObj;

        Test.startTest();
        secLevColumnsObj = HDT_LC_AccountStatementController.getSecondLevelColumns('EC');
        Test.stopTest();

        System.debug('>>> columnObj ' + secLevColumnsObj.columnObj.size());
        System.debug('>>> buttonList ' + secLevColumnsObj.buttonList.size());
    }

    @isTest
    static void getTabConfiguration(){

        Account a = new Account();
        a.CustomerCode__c = '0001';
        a.Name = 'accountTest';
        insert a;

        HDT_WRP_AccountStatement.HDT_WRP_ColumnsObj colObj;

        Test.startTest();
        colObj = HDT_LC_AccountStatementController.getTabConfiguration('EC', a.Id);
        Test.stopTest();

    }

    @isTest
    static void getPicklistValue(){
        Test.startTest();
        String picklistValue = HDT_LC_AccountStatementController.getPicklistValue('EC', 'StepValues');
        Test.stopTest();

    }

    @isTest
    static void getFieldValues(){
        HDT_WRP_AccountStatement.HDT_WRP_ReturnPicklist picklist;

        Test.startTest();
        picklist = HDT_LC_AccountStatementController.getFieldValues('EC');
        Test.stopTest();

    }

    @isTest
    static void callMulesoft(){
        Test.setMock(HttpCalloutMock.class, new HDT_LC_AccountStatementControllerTstMock());

        Test.startTest();
        Object obj = HDT_LC_AccountStatementController.callMulesoft('{"customerCode":"1006322046","recordId":"0011X00000jcKXUQA2","requestType":"home","statementType":"ORDINARIO","tabCode":"EC"}', null);
        Test.stopTest();

    }

}