/**
* @author Lucas da Silva Fernandes (lucas.dasilva@engdb.com.br)
* @date 26/07/2021
* @description HDT_QR_PriceBook Test Class
* @history Lucas da Silva Fernandes – 26/07/2021 – Class Created 
*/

@isTest
public with sharing class HDT_QR_PriceBookTst {

    @TestSetup
    static void setup(){

        HDT_UTL_DataFactoryTst.createPricebook(1, true);
        
    }
    
    @isTest
    public static void testGetRecordByName () {

        List<Pricebook2> pricebookSetup = [SELECT Id FROM Pricebook2 WHERE Name Like 'Test Price Book%' LIMIT 1];

        List<Pricebook2> pricebooks = HDT_QR_PriceBook.getRecordByName('Test Price Book0');

        System.assertEquals(pricebookSetup[0].Id, pricebooks[0].Id, 'Value of parameter is matching');

        System.assertNotEquals(pricebookSetup[0].Id, '', 'Value of parameter is not matching');
    }
}   