@isTest
public with sharing class HDT_LC_GenericTableTst {

    @TestSetup
    static void setup()
    {
        
    }


    @isTest
    static void getDataTst()
    {
        String output = '';
        Test.startTest();
        output = HDT_LC_GenericTable.getData('Prova', 'AccountId', '000000');
        Test.stopTest();
    } 

}
