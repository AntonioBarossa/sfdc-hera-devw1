/**
* @author Luis Bispo (luis.bispo@engdb.com.br)
* @date 21/07/2021
* @description HDT_LC_TargetObjectRecordTypeSelection for Test Classes
* @history Luis Bispo – 21/07/2021 – Created class
*/

@isTest
public class HDT_LC_TargetObjectRecordTypeSelectionTS {

    @testSetup
    static void setup(){
        HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        
    }

    @isTest
    public static void testGetRecordTypesForServicePoint(){
    
    Test.startTest();
    List<Map<String,String>> recordtypesList = HDT_LC_TargetObjectRecordTypeSelection.getRecordTypesForServicePoint();
    
    System.assert(recordtypesList != null, 'getRecordTypesForServicePoint did not work correctly');

    System.assertNotEquals(new List<Map<String,String>>{new Map<String,String>()},recordtypesList, 'getRecordTypesForServicePoint did not work correctly');
    
    Test.stopTest(); 
    
    }
    
}
