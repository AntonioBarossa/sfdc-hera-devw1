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
        List<Account> acc = HDT_UTL_DataFactoryTst.createAccount(1, true);
    }

    @isTest
    public static void testGetRecordTypesForAccount(){
        Test.startTest();




        Test.stopTest();
    }
}
