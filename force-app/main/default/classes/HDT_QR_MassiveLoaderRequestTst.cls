/**
* @author Pooyan (Pooyan.GhadiriAbkenar@webresults.it)
* @date 16/09/2021
* @description HDT_QR_MassiveLoaderRequestTst
* @history Pooyan – 16/09 – created class
*/

@isTest
public with sharing class HDT_QR_MassiveLoaderRequestTst {

    @TestSetup
	static void setup(){

        List<Opportunity> listOpp = HDT_UTL_DataFactoryTst.createOpportunity(1,true);
        List<ContentVersion> listContent = HDT_UTL_DataFactoryTst.createContentVersion(1,true,'test','body','path');
        Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: listContent[0].id].ContentDocumentId;
        List<MassiveLoaderRequest__c> mLRList = HDT_UTL_DataFactoryTst.createMassiveLoaderRequest(1,true);
        List<ContentDocumentLink>  cDLList = HDT_UTL_DataFactoryTst.createContentDocumentLink(1,true,listOpp[0].id,contentDocumentId);

    }


    
    @isTest
    public static void testGetRecord(){

        Test.startTest();
        HDT_QR_MassiveLoaderRequest testRequest = new HDT_QR_MassiveLoaderRequest ();
        List<MassiveLoaderRequest__c> returnedValue = testRequest.getRecordForImport();

        
        System.assertEquals(true, returnedValue.isEmpty(), 'Get Record for Import is found');
        System.assertNotEquals(false, returnedValue.isEmpty());

        Test.stopTest();
    }
}