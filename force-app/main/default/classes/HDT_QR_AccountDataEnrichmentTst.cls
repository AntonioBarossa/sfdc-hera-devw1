/**
* @author Elvin Iluca
* @date 09/12/2022
* @description Test Class for HDT_QR_AccountDataEnrichment.cls
* @history Elvin Iluca – 09/12/2022 – Created class
*/
@isTest
public with sharing class HDT_QR_AccountDataEnrichmentTst {
     /**​
    * @author Elvin Iluca
    * @date 09/12/2022
    * @description HDT_QR_AccountDataEnrichmentTst – Test Class for HDT_QR_AccountDataEnrichment.cls
    */
    @TestSetup
	static void setup(){
        HDT_UTL_DataFactoryTst.createAccountPartner(1, true, 'testAccount');
    }

    @isTest
    static void getAccountDataEnrichmentTst () {
        List<HDT_AccountDataEnrichment__mdt> enrichmentbMetadataList = new List<HDT_AccountDataEnrichment__mdt>();


        Test.startTest();
        enrichmentbMetadataList = HDT_QR_AccountDataEnrichment.getAccountDataEnrichment(enrichmentbMetadataList, 'contract');
        Test.stopTest();
        System.assertNotEquals(enrichmentbMetadataList.isEmpty(),true,'Error querying HDT_AccountDataEnrichment__mdt');
    }
    @isTest
    static void getAccountRecordsTst () {
        List<Account> accList = [SELECT Id FROM Account WITH SECURITY_ENFORCED LIMIT 1];
        Test.startTest();
        accList = HDT_QR_AccountDataEnrichment.getAccountRecords(new List<Account>(), accList[0].Id);
        Test.stopTest();
        System.assertNotEquals(accList.isEmpty(),true,'Error querying Account');
    }
    @isTest
    static void getReadingsTranscodeMapTst () {
        List<HDT_MeterReadingTranscodeMap__mdt> meterReadingTranscodeList = new List<HDT_MeterReadingTranscodeMap__mdt>();
        Test.startTest();
        meterReadingTranscodeList = HDT_QR_AccountDataEnrichment.getReadingsTranscodeMap();
        Test.stopTest();
        System.assertNotEquals(meterReadingTranscodeList.isEmpty(),true,'Error querying HDT_MeterReadingTranscodeMap__mdt');
    }
    @isTest
    static void getRecordsListTst () {
        List<sObject> objList = new List<sObject>(); 
        Test.startTest();
        objList = HDT_QR_AccountDataEnrichment.getRecordsList(objList, 'SELECT Id FROM User WITH SECURITY_ENFORCED LIMIT 1', 'User');
        Test.stopTest();
        System.assertNotEquals(objList.isEmpty(),true,'Error querying sObject');
    }
}
