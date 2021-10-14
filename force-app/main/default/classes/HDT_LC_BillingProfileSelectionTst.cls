@isTest
public class HDT_LC_BillingProfileSelectionTst {
    
    @TestSetup
    static void setup(){
        
    }

    @IsTest
    static void testGetConfiguration(){
        
        Test.startTest();

        String searchKey = 'BillingProfile';

        String results = HDT_LC_BillingProfileSelection.getConfiguration(searchKey);

        List<HDT_Generic_Record_Selection__mdt> configList = (List<HDT_Generic_Record_Selection__mdt>) JSON.deserialize(results, List<HDT_Generic_Record_Selection__mdt>.class);

        System.assert(configList.size() > 0, 'configList.size() = 0 or configList = null');
        System.assertNotEquals(null, configList[0].Columns__c, 'Columns__c = null');

        Test.stopTest();
        
    }

}
