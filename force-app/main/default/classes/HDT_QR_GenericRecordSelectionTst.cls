/**
* @author Elvin Iluca
* @date 28/10/2022
* @description Test Class for HDT_QR_GenericRecordSelection.cls
* @history Elvin Iluca – 28/10/2022 – Created class
*/

@isTest

public with sharing class HDT_QR_GenericRecordSelectionTst {
  
    /**​
    * @author Elvin Iluca
    * @date 28/10/2022
    * @description HDT_QR_GenericRecordSelectionTst – Test Class for HDT_QR_GenericRecordSelection.cls
    */
   
    @isTest
    static void getConfigurationByNameTst () {
        List<HDT_Generic_Record_Selection__mdt> recordSelectionExpected = [SELECT Id, DeveloperName FROM HDT_Generic_Record_Selection__mdt LIMIT 1];

        List<HDT_Generic_Record_Selection__mdt> recordSelectionActual;
        HDT_QR_GenericRecordSelection testGenericRecord = new HDT_QR_GenericRecordSelection();
        Test.startTest();
        recordSelectionActual = testGenericRecord.getConfigurationByName(recordSelectionExpected[0].DeveloperName);
        Test.stopTest();
        
        System.assertEquals(recordSelectionExpected[0].Id,recordSelectionActual[0].Id,'Error to select generic recprd');
    }

    /**​
    * @author Elvin Iluca
    * @date 28/10/2022
    * @description HDT_QR_GenericRecordSelectionTst – Test Class for HDT_QR_GenericRecordSelection.cls
    */
    @isTest
    static void executeQueryTst() {
        // executeSoqlQuery(String fields, String filters, String limitStr, String objectName) 
        List<List<sObject>> soslReturn;
        String fields = 'Name';
        String objectName = 'Account';
        String soslSearchTerm = 'test';
        String accountName = 'Test Account';

        HDT_QR_GenericRecordSelection testGenericRecord = new HDT_QR_GenericRecordSelection();
       
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, false, 'HERA COMM', 'Azienda', 'Aziende SME');
        accList[0].Name = accountName;
        insert accList;
        
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = accList[0].Id;
        Test.setFixedSearchResults(fixedSearchResults); 

        Test.startTest();
        soslReturn = testGenericRecord.executeQuery(fields, '', '',soslSearchTerm, objectName);
        Test.stopTest();
        Account actualAccount = (Account) soslReturn[0][0];
        
        System.assertEquals(accountName,actualAccount.Name,'Error sosl');
        
    }

     /**​
    * @author Elvin Iluca
    * @date 28/10/2022
    * @description HDT_QR_GenericRecordSelectionTst – Test Class for HDT_QR_GenericRecordSelection.cls
    */
    @isTest
    static void executeSoqlQueryTst() {
          // executeSoqlQuery(String fields, String filters, String limitStr, String objectName) 

          String fields = 'DeveloperName';
          String objectName = 'HDT_Generic_Record_Selection__mdt';
  
          HDT_QR_GenericRecordSelection testGenericRecord = new HDT_QR_GenericRecordSelection();

          List<HDT_Generic_Record_Selection__mdt> listReturned;
  
          Test.startTest();
          listReturned = testGenericRecord.executeSoqlQuery(fields, '', '', objectName);
          Test.stopTest();
          
          System.assertEquals(true,!listReturned.isEmpty(),'Error to select generic recprd');

    }
}

