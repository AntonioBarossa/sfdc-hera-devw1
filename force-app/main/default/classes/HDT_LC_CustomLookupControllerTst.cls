@isTest
public class HDT_LC_CustomLookupControllerTst {

    @testSetup
    static void setup() {

        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, false, 'HERA COMM', 'Azienda', 'Aziende SME');
        accList[0].Name = 'accountTest';
        accList[0].CustomerCode__c = '0001';
        insert accList;

    }

    @isTest
    static void getTabsMetaData(){

        List<HDT_LC_CustomLookupController.HDT_UTL_ObjDetail> objDetailList;
        Test.startTest();
        objDetailList = HDT_LC_CustomLookupController.lookUp('0001', 'Account', 'Name=\'accountTest\'', 'CustomerCode__c', 'Id', new List<String>{'CreatedById'});

        System.assert(objDetailList.size() > 0, 'objDetailList.size() == 0 or objDetailList == null');

        Test.stopTest();
    }

}