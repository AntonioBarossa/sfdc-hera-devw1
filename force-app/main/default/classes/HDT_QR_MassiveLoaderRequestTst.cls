/**
* @author Pooyan (Pooyan.GhadiriAbkenar@webresults.it)
* @date 16/09/2021
* @description HDT_QR_MassiveLoaderRequestTst
* @history Pooyan – 16/09 – created class
*/

@isTest
public with sharing class HDT_QR_MassiveLoaderRequestTst {

    private static HDT_UTL_Constants constantsUtl = new HDT_UTL_Constants();

    @TestSetup
	static void setup(){

        User u = HDT_UTL_DataFactoryTst.createInternalUser(HDT_UTL_DataFactoryTst.getProfileId(constantsUtl.SYSTEM_ADMINISTRATOR_NAME), true);

        System.runAs(u) {

            List<Opportunity> listOpp = HDT_UTL_DataFactoryTst.createOpportunity(1,true);
            List<ContentVersion> listContent = HDT_UTL_DataFactoryTst.createContentVersion(1,true,'test','body','path');
            Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: listContent[0].id].ContentDocumentId;

            //List<MassiveLoaderRequest__c> mLRList = HDT_UTL_DataFactoryTst.createMassiveLoaderRequest(1,false);
          //  mLRList.get(0).Status__c = constantsUtl.MASSIVLOADER_STATUS_INATTESAlAVORAZIONE;
          //  mLRList.get(0).Phase__c = constantsUtl.MASSIVLOADER_PHASE_FILENONPROCESSATO;
            
           // insert mLRList;

           // HDT_UTL_DataFactoryTst.createContentDocumentLink(1,true,listOpp[0].id,contentDocumentId);

        }

         

    }
    
    @isTest
    public static void testGetRecord(){

        User u = [SELECT Id FROM User WHERE Alias = 'crmuser' LIMIT 1];

        System.runAs(u) {

            Test.startTest();
            HDT_QR_MassiveLoaderRequest testRequest = new HDT_QR_MassiveLoaderRequest ();
            List<MassiveLoaderRequest__c> returnedValue = testRequest.getRecordForImport();
          
            System.assertEquals(false, returnedValue.isEmpty(), 'Get Record for Import is found');
            System.assertNotEquals(true, returnedValue.isEmpty(), 'No records of MassiveLoaderRequest__c were retrieved');

            Test.stopTest();

        }
        
    }
}