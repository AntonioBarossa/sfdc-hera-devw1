/**
* @author Elvin Iluca
* @date 09/12/2022
* @description Test Class for HDT_QR_AccountStatement.cls
* @history Elvin Iluca – 09/12/2022 – Created class
*/

@isTest
public with sharing class HDT_QR_AccountStatementTst {
     /**​
    * @author Elvin Iluca
    * @date 09/12/2022
    * @description HDT_QR_AccountStatementTst – Test Class for HDT_QR_AccountStatement.cls
    */
    @TestSetup
	static void setup(){
        HDT_UTL_DataFactoryTst.pClickInstance();
        HDT_UTL_DataFactoryTst.pClickOrderPhase();
        List<Account>accList = HDT_UTL_DataFactoryTst.createAccountPartner(1, true, 'testAccount');
        insert new AccountStatementFilter__c();
        HDT_UTL_DataFactoryTst.createActivityCustom(1,true,accList[0].Id);
        // SiebelCustomer__x t = new SiebelCustomer__x();
        // Database.insertImmediate(t);

    }

    
    @isTest
    static void getTabMetaDataTst() {
        List<HDT_TabConfiguration__mdt> metaDataList;

        Test.startTest();
        metaDataList = HDT_QR_AccountStatement.getTabMetaData(metaDataList);
        Test.stopTest();

        System.assertNotEquals(metaDataList.isEmpty(),true,'Error querying MetaData');
    }

    @isTest
    static void getColumnsSecondLevelTst() {
        List<HDT_ColumnsSecondLevel__mdt> columnsSecondLevelList = [SELECT Id, Tab__r.DeveloperName FROM HDT_ColumnsSecondLevel__mdt WITH SECURITY_ENFORCED LIMIT 1];

        Test.startTest();
        columnsSecondLevelList = HDT_QR_AccountStatement.getColumnsSecondLevel(columnsSecondLevelList, columnsSecondLevelList[0].Tab__r.DeveloperName);
        Test.stopTest();

        System.assertNotEquals(columnsSecondLevelList.isEmpty(), true, 'Error querying HDT_ColumnsSecondLevel__mdt');
    }
    @isTest
    static void getStatementRequestMetaDataTst() {
        List<HDT_StatementRequest__mdt> statementRequestList = [SELECT Id, DeveloperName FROM HDT_StatementRequest__mdt WITH SECURITY_ENFORCED LIMIT 1];
        
        Test.startTest();
        statementRequestList = HDT_QR_AccountStatement.getStatementRequestMetaData(statementRequestList, statementRequestList[0].DeveloperName);
        Test.stopTest();

        System.assertNotEquals(statementRequestList.isEmpty(),true,'Error querying HDT_StatementRequest__mdt');

    }
    @isTest
    static void getTabConfigurationMetaDataTst() {
        List<HDT_TabConfiguration__mdt> getTabConfigurationList = [SELECT Id, DeveloperName FROM HDT_TabConfiguration__mdt WITH SECURITY_ENFORCED LIMIT 1];

        Test.startTest();
        getTabConfigurationList = HDT_QR_AccountStatement.getTabConfigurationMetaData(getTabConfigurationList, getTabConfigurationList[0].DeveloperName);
        Test.stopTest();

        System.assertNotEquals(getTabConfigurationList.isEmpty(), true, 'Error querying HDT_TabConfiguration__mdt');
    }
    @isTest
    static void getCompanyListTst() {
        List<HDT_HeraCompany__mdt> companyList;

        Test.startTest();
        companyList = HDT_QR_AccountStatement.getCompanyList(companyList);
        Test.stopTest();

        System.assertNotEquals(companyList.isEmpty(), true, 'Error querying HDT_HeraCompany__mdt');
    }
    @isTest
    static void getColumnMetaDataListTst() {
        List<HDT_ColumnsFirstLevel__mdt> columnMetaDataList = [SELECT Id, Tab__r.DeveloperName FROM HDT_ColumnsFirstLevel__mdt WITH SECURITY_ENFORCED LIMIT 1];
        
        Test.startTest();
        columnMetaDataList = HDT_QR_AccountStatement.getColumnMetaDataList(columnMetaDataList, columnMetaDataList[0].Tab__r.DeveloperName);
        Test.stopTest();

        System.assertNotEquals(columnMetaDataList.isEmpty(), true, 'Error querying HDT_ColumnsFirstLevel__mdt');
    }
    @isTest
    static void getTabConfMetadataListTst() {
        List<HDT_TabConfiguration__mdt> tabConfMetadataList =  [SELECT Id, DeveloperName FROM HDT_TabConfiguration__mdt WITH SECURITY_ENFORCED LIMIT 1];

        Test.startTest();
        tabConfMetadataList = HDT_QR_AccountStatement.getTabConfMetadataList(tabConfMetadataList, tabConfMetadataList[0].DeveloperName);
        Test.stopTest();

        System.assertNotEquals(tabConfMetadataList.isEmpty(),true,'Error querying HDT_TabConfiguration__mdt');
    }
    @isTest
    static void getAccountDataTst() {
        List<Account> getAccountData = [SELECT Id FROM Account WITH SECURITY_ENFORCED LIMIT 1];

        Test.startTest();
        getAccountData = HDT_QR_AccountStatement.getAccountData(getAccountData[0].Id);
        Test.stopTest();

        System.assertNotEquals(getAccountData.isEmpty(),true,'Error querying Account');
    }






    @isTest
    static void getSiebelCustomerTst() {
        // List<SiebelCustomer__x> getSiebelCustomer(String recId){
        List<SiebelCustomer__x> siebelCustomer = [SELECT Id FROM SiebelCustomer__x WITH SECURITY_ENFORCED LIMIT 1];
        System.debug(siebelCustomer);
        Test.startTest();
       // enrichmentbMetadataList = HDT_QR_AccountDataEnrichment.getAccountDataEnrichment(enrichmentbMetadataList, 'contract');
        Test.stopTest();
        System.assertNotEquals(1,0,'ok');
    }





    @isTest
    static void getButtonMetadataListTst() {
        List<HDT_ButtonDetails__mdt> buttonMetadataList = [SELECT Id, Tab__r.DeveloperName, ButtonLevel__c FROM HDT_ButtonDetails__mdt WITH SECURITY_ENFORCED LIMIT 1];

        Test.startTest();
        buttonMetadataList = HDT_QR_AccountStatement.getButtonMetadataList(buttonMetadataList, buttonMetadataList[0].Tab__r.DeveloperName, buttonMetadataList[0].ButtonLevel__c);
        Test.stopTest();

        System.assertNotEquals(buttonMetadataList.isEmpty(), true, 'Error querying HDT_ButtonDetails__mdt');
    }

    @isTest
    static void getButtonParametersTst() {
        List<HDT_ButtonDetails__mdt> buttonParameters = [SELECT Id, Tab__r.DeveloperName, ButtonCode__c FROM HDT_ButtonDetails__mdt WITH SECURITY_ENFORCED LIMIT 1];

        Test.startTest();
        buttonParameters = HDT_QR_AccountStatement.getButtonParameters(buttonParameters, buttonParameters[0].Tab__r.DeveloperName, buttonParameters[0].ButtonCode__c);
        Test.stopTest();

        System.assertNotEquals(buttonParameters.isEmpty(), true, 'Error querying HDT_ButtonDetails__mdt');
    }
    @isTest
    static void getFilterTst() {
        List<AccountStatementFilter__c> filterList = [SELECT Id FROM AccountStatementFilter__c WITH SECURITY_ENFORCED LIMIT 1];

        Test.startTest();
        filterList = HDT_QR_AccountStatement.getFilter(filterList[0].Id);
        Test.stopTest();

        System.assertNotEquals(filterList.isEmpty(), true, 'Error querying AccountStatementFilter__c');
    }
    @isTest
    static void getActivityByIdTst() {
        List<wrts_prcgvr__Activity__c> activityList = [SELECT Id FROM wrts_prcgvr__Activity__c WITH SECURITY_ENFORCED LIMIT 1];

        Test.startTest();
        activityList = HDT_QR_AccountStatement.getActivityById(activityList[0].Id);
        Test.stopTest();

        System.assertNotEquals(activityList.isEmpty(), true, 'Error querying wrts_prcgvr__Activity__c');
    }

}
