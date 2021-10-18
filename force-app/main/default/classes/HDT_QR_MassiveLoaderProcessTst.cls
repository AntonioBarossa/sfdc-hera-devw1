/**
* @author Pooyan (Pooyan.GhadiriAbkenar@webresults.it)
* @date 15/09/2021
* @description HDT_QR_MassiveLoaderProcess
* @history Pooyan – 15/09 – created class
*/

@isTest
public with sharing class HDT_QR_MassiveLoaderProcessTst {

   /* @TestSetup
	static void setup(){

   List<HDT_MassiveLoaderProcess__mdt> mLPLists = new List<HDT_MassiveLoaderProcess__mdt>();
       mLPLists[0].DeveloperName= 'Subentro';
       mLPLists[0].MasterLabel='Subentro';
       mLPLists[0].Priority__c= 2;
       mLPLists[0].IsActive__c=true;
       
       
       insert mLPLists;
       
    }
*/
    
    @isTest
    public static void testGetAllRecords(){
        
        Test.startTest();

        HDT_QR_MassiveLoaderProcess testMassiveProcess = new HDT_QR_MassiveLoaderProcess();
        List<HDT_MassiveLoaderProcess__mdt> testGetAllRecords = testMassiveProcess.getAllRecords();

        Test.stopTest();
        
       

        System.assertEquals(false, testGetAllRecords.isEmpty(), 'Massive Loader Process All Records not found');
        System.assertNotEquals(true, testGetAllRecords.isEmpty(), 'Expecte to retrieve at least one record');

        
        
    }

    @isTest
    public static void testGetRecordByName(){

        Test.startTest();
        


        String devName = [SELECT DeveloperName FROM HDT_MassiveLoaderProcess__mdt WHERE IsActive__c = true LIMIT 1].DeveloperName;
        // System.debug('devName ' + devName);
       // String devName = String.valueOf(queryDev[0].DeveloperName);

       HDT_QR_MassiveLoaderProcess testMassiveProcess = new HDT_QR_MassiveLoaderProcess();
       HDT_MassiveLoaderProcess__mdt testRecord = testMassiveProcess.getRecordByName(devName);

        //List<HDT_MassiveLoaderProcess__mdt> testListMDT = new List<HDT_MassiveLoaderProcess__mdt>();
       // testListMDT.add(testRecord );
       
       Test.stopTest();

        System.assertEquals(devName, testRecord.DeveloperName , 'Massive Loader Process Record by Name has been found');
        System.assertNotEquals('',testRecord.DeveloperName,'DeveloperName is not empty' );
        
        
        
    }
}
