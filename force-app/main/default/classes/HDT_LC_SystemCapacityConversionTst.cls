@isTest
public class HDT_LC_SystemCapacityConversionTst {
    
    @TestSetup
    static void setup(){
        
    }

    @IsTest
    static void testGetSystemCacacity(){
        
        Test.startTest();

        String field = 'CaliberClass';
        String value = '584,1';

        String results = HDT_LC_SystemCapacityConversion.getSystemCapacity(field, value);

        System.assertNotEquals(null, results, 'results = null');
        System.assertNotEquals('', results, 'results = \'\'');

        Test.stopTest();
        
    }

}
