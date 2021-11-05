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
            String processName='Lead';
            String dataLead='HERA COMM,HCM,084588559,3485555555,test@mail.com,null,Rossi,Mario,Laurea,Studente,Benedetto Brin,1,80100,80100,Napoli,NA,null,null,null,,25,null,Maschio,null,SI,null,,null,,null,NO,null,,null,,null,sito standard,null,,null,,2020-10-11,null,,null,,null,,null,,null,test';
            HDT_UTL_DataFactoryTst.createMassiveLoaderRequest(processName,new List<String>{dataLead});
            //List<MassiveLoaderRequest__c> mLRList = HDT_UTL_DataFactoryTst.createMassiveLoaderRequest(1,false);
            //  mLRList.get(0).Status__c = constantsUtl.MASSIVLOADER_STATUS_INATTESAlAVORAZIONE;
            //  mLRList.get(0).Phase__c = constantsUtl.MASSIVLOADER_PHASE_FILENONPROCESSATO;
            

           HDT_UTL_DataFactoryTst.createContentDocumentLink(1,true,listOpp[0].id,contentDocumentId);

        }

         

    }
    
    @isTest
    public static void testGetRecord(){

        User u = [SELECT Id FROM User WHERE Alias = 'crmuser' LIMIT 1];

        System.runAs(u) {

            Test.startTest();
            HDT_QR_MassiveLoaderRequest testRequest = new HDT_QR_MassiveLoaderRequest ();
            List<MassiveLoaderRequest__c> returnedValue = testRequest.getRecordForImport();
          
            System.assertEquals(1, returnedValue.size(), 1);
          

            Test.stopTest();

        }
        
    }
}