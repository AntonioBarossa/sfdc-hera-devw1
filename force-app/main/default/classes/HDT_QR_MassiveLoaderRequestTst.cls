/**
* @author Pooyan (Pooyan.GhadiriAbkenar@webresults.it)
* @date 16/09/2021
* @description HDT_QR_MassiveLoaderRequestTst
* @history Pooyan – 16/09 – created class
*/

@isTest
public with sharing class HDT_QR_MassiveLoaderRequestTst {
    
    @isTest
    public static void testGetRecord(){

        Test.startTest();
        HDT_QR_MassiveLoaderRequest testRequest = new HDT_QR_MassiveLoaderRequest ();
        List<MassiveLoaderRequest__c> returnedValue = testRequest.getRecordForImport();

        System.assertEquals(false, returnedValue.isEmpty(), 'Get Record for Import not found');
        System.assertNotEquals(true, returnedValue.isEmpty());

        Test.stopTest();
    }
}
