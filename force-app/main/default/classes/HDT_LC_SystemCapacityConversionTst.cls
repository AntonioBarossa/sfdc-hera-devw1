@isTest
public class HDT_LC_SystemCapacityConversionTst {
    
    @TestSetup
    static void setup(){
        
    }

    @IsTest
    static void testGetSystemCacacity(){
        
        Test.startTest();

        String field = 'CaliberClass';
        String value = 'G40';

        String results = HDT_LC_SystemCapacityConversion.getSystemCapacity(field, value);

        System.assertNotEquals(null, results, 'results = null');
        System.assertNotEquals('', results, 'results = \'\'');

        Test.stopTest();
        
    }

    @IsTest
    static void testGetSystemCacacityCase2(){
        
        Test.startTest();

        String field = 'NotCaliberClass';
        String value = '53,9';

        String results = HDT_LC_SystemCapacityConversion.getSystemCapacity(field, value);

        System.assertNotEquals(null, results, 'results = null');
        System.assertNotEquals('', results, 'results = \'\'');

        Test.stopTest();
        
    }

}
