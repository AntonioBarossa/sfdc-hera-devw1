@isTest
public class HDT_LC_CustomLookupControllerTst {

    @testSetup
    static void setup() {
        Account a = new Account();
        a.CustomerCode__c = '0001';
        a.Name = 'accountTest';
        insert a;
    }

    @isTest
    static void getTabsMetaData(){

        List<HDT_LC_CustomLookupController.HDT_UTL_ObjDetail> objDetailList;
        Test.startTest();
        objDetailList = HDT_LC_CustomLookupController.lookUp('0001', 'Account', 'Name=\'accountTest\'', 'CustomerCode__c', 'Id', new List<String>{'CreatedById'});
        Test.stopTest();
    }

}