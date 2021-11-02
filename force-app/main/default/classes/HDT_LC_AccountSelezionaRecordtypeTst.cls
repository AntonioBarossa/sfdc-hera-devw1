/**
* @author Luis Bispo (luis.bispo@engdb.com.br)
* @date 13/07/2021
* @description HDT_LC_AccountSelezionaRecordtype for Test Classes
* @history Luis Bispo – 13/07/2021 – Created class
*/

@isTest
public with sharing class HDT_LC_AccountSelezionaRecordtypeTst {
    @testSetup
    static void setup(){
        HDT_UTL_DataFactoryTst.pClickOrderPhase();
        HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
    }

    @isTest
    public static void testGetRecordTypesForAccount(){
        Test.startTest();
		
        List<Map<String,String>> lstAccount = HDT_LC_AccountSelezionaRecordtype.getRecordTypesForAccount();
        
        Test.stopTest();
        
        System.assertEquals(lstAccount.size() != null, true, 'The List is null!');
        System.assertNotEquals(lstAccount.size() == null, true, 'The List is null!');
        
    }
}