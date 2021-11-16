/**
* Header of the class "HDT_SRV_SaleServiceItemTst"
* @author: Luca Belometti WR (luca.belometti@webresults.it)
* @version 1.0
* @description: Apex Test Class of the relative ApexClass "HDT_SRV_SaleServiceItem"
* @history
* Created: 2021-09-15
* Modified By:
* Luca Belometti WR (luca.belometti@webresults.it) - Updated the class with the new methods - 25/10/2021
**/

@IsTest
public with sharing class HDT_SRV_SaleServiceItemTst {
private static HDT_UTL_Constants constants = new HDT_UTL_Constants();
@TestSetup
static void makeData(){
    HDT_UTL_DataFactoryTst.pClickInstance();
    HDT_UTL_DataFactoryTst.pClickOrderPhase();
    Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
    User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
    internalUser.UserPermissionsMarketingUser=true;
    insert internalUser;

    List<Account> accList=HDT_UTL_DataFactoryTst.createAccountResidenziale(1, false, 'HERA COMM', 'D1 - Persona fisica', 'Enti');
    accList[0].FiscalCode__c = 'RSSMRA80A01F839W';
    accList[0].VATNumber__c = 'RSSMRA80A01F839W';
    accList[0].CustomerCode__c = 'uniqueTest';
    accList[0].CustomerType__c = 'Persona Fisica'; 
    insert accList;
    HDT_UTL_DataFactoryTst.createContact(1,true,accList[0].Id);
    HDT_UTL_DataFactoryTst.createBillingProfile(1, true, accList[0].Id);
    List<Sale__c> saleList = HDT_UTL_DataFactoryTst.createSale(1, true, accList[0].Id, 'Bozza');
    Test.setCreatedDate(saleList[0].Id,System.now().addDays(-30));
    List<Opportunity> oppList = HDT_UTL_DataFactoryTst.createOpportunity(1, false);
    oppList[0].Sale__c= saleList[0].Id;
    insert oppList;
    List<ServicePoint__c> spList = HDT_UTL_DataFactoryTst.createServicePoint(1, false);
    spList[0].MeterStatus__c = 'Bozza';
    spList[0].AnnualConsumptionStandardM3__c = 10;
    spList[0].CommoditySector__c = 'Energia Elettrica';
    insert spList;
    List<Order> orders =  HDT_UTL_DataFactoryTst.createOrder(1, false, accList[0].id, 'Bozza');
    orders[0].ServicePoint__c = spList[0].id;
    orders[0].VoltageLevel__c ='MT';
    orders[0].MarketOrigin__c ='Libero';
    orders[0].PowerRequested__c = 50;
    orders[0].PowerCommitted__c = 45;
    orders[0].IsWinback__c = false;
    orders[0].Channel__c = 'test';
    //orders[0].ContractReference__c = contracts[0].id;
    orders[0].SAPImplantCode__c = '';
    insert orders;
    HDT_UTL_DataFactoryTst.createLead(1, true);
    



    List<wrts_prcgvr__Activity__c> actCust = HDT_UTL_DataFactoryTst.createActivityCustom(1, false, accList[0].Id);
    actCust[0].Order__c = orders[0].id;
    actCust[0].wrts_prcgvr__Status__c = 'Creata';
    actCust[0].NewEmail__c = 'yes@no.it';
    actCust[0].NewMobile__c = '3334441122';
    actCust[0].DiscardCategory__c = 'Anonima';
    //actCust[0].Case__c = cases[0].id;
    insert actCust;        

    HDT_WebServiceConfiguration__c wsConf=new HDT_WebServiceConfiguration__c();
    wsConf.name='CampagenDmDmpData';
    wsConf.Endpoint__c='https://integration-ts.gruppohera.it/dev/salesforce-api-exp/api/data-management/files';
    wsConf.Method__c='POST';
    wsConf.User__c='MulesoftSalesforceUser';
    insert wsConf;

    HDT_UTL_DataFactoryTst.createWebServiceCredential('testUser', '12345', 'usernameTest');
    }


    @isTest
    public static void testCheckAccessInit() {

        boolean finito = false;

        Test.startTest();

        User tUser=[SELECT Id, FirstName
                    FROM USER
                    WHERE UserPermissionsMarketingUser=true AND IsActive=true AND CreatedDate = TODAY
                    LIMIT 1];

        System.runAs(tUser){
            HDT_SRV_SaleServiceItem testClass = new HDT_SRV_SaleServiceItem();


            testClass.checkAccessInit('Opportunity__c', 'create');

        }
        
        Test.stopTest();
        finito = true;
        System.assertEquals(true, finito, 'Test not finished');
        System.assertNotEquals(false, finito, 'Test not finished');
    }


    @isTest
    public static void testCheckReadAccess() {

        boolean finito = false;

        Test.startTest();

        User tUser=[SELECT Id, FirstName
                    FROM USER
                    WHERE UserPermissionsMarketingUser=true AND IsActive=true AND CreatedDate = TODAY
                    LIMIT 1];

        System.runAs(tUser){
            HDT_SRV_SaleServiceItem testClass = new HDT_SRV_SaleServiceItem();


            testClass.checkReadAccess('Opportunity__c');

        }
        
        Test.stopTest();
        finito = true;
        System.assertEquals(true, finito, 'Test not finished');
        System.assertNotEquals(false, finito, 'Test not finished');
    }


    @isTest
    public static void testCheckCreateAccess() {

        boolean finito = false;

        Test.startTest();

        User tUser=[SELECT Id, FirstName
                    FROM USER
                    WHERE UserPermissionsMarketingUser=true AND IsActive=true AND CreatedDate = TODAY
                    LIMIT 1];

        System.runAs(tUser){
            HDT_SRV_SaleServiceItem testClass = new HDT_SRV_SaleServiceItem();


            testClass.checkCreateAccess('Opportunity__c');

        }
        
        Test.stopTest();
        finito = true;
        System.assertEquals(true, finito, 'Test not finished');
        System.assertNotEquals(false, finito, 'Test not finished');
    }


    @IsTest
    static void testCreateRecord(){

        User tUser=[SELECT Id, FirstName
        FROM USER
        WHERE UserPermissionsMarketingUser=true AND IsActive=true AND CreatedDate = TODAY
        LIMIT 1];
        
        Test.startTest();
        System.runAs(tUser){
            List<ServicePoint__c> spRetrieved = [SELECT id FROM ServicePoint__c LIMIT 1];
            List<Sale__c> saleRetrieved = [SELECT id FROM Sale__c LIMIT 1];
            Map<String,String> mapStrings = New Map<String,String>();
            //mapStrings.put('Test', 'Test');
            HDT_SRV_SaleServiceItem testClass = new HDT_SRV_SaleServiceItem();
            testClass.createRecord(spRetrieved[0],saleRetrieved[0],mapStrings);
            
        }
        Test.stopTest();
        List<SaleServiceItem__c> testSize = [SELECT Id FROM SaleServiceItem__c];

        System.assertNotEquals(testSize.size() == 0, true, 'The method correctly created a record of SaleServiceItem__c');
        System.assertEquals(testSize.size() > 0, true, 'The method correctly created a record of SaleServiceItem__c');
    }

    @IsTest
    static void testDeleteRecords(){
        User tUser=[SELECT Id, FirstName
        FROM USER
        WHERE UserPermissionsMarketingUser=true AND IsActive=true AND CreatedDate = TODAY
        LIMIT 1];
        
        Test.startTest();
        System.runAs(tUser){
            List<SaleServiceItem__c> ssiRetrieved = [SELECT Id FROM SaleServiceItem__c LIMIT 1];
            HDT_SRV_SaleServiceItem testClass = new HDT_SRV_SaleServiceItem();
            testClass.deleteRecords(ssiRetrieved);

        }
        Test.stopTest();

        List<SaleServiceItem__c> testSize = [SELECT Id FROM SaleServiceItem__c];

        System.assertEquals(testSize.size() == 0, true, 'The method correctly deleted a record of SaleServiceItem__c');
        System.assertNotEquals(testSize.size() > 0, true, 'The method correctly deleted a record of SaleServiceItem__c');
        
    }


    
    @IsTest
    static void testGroupRecordsByOpportunityNull(){
        User tUser=[SELECT Id, FirstName
        FROM USER
        WHERE UserPermissionsMarketingUser=true AND IsActive=true AND CreatedDate = TODAY
        LIMIT 1];
        List<List<SaleServiceItem__c>> returnedList = new List<List<SaleServiceItem__c>>();

        
        Test.startTest();
        System.runAs(tUser){
            List<Opportunity> oppRetrieved = [SELECT Id FROM Opportunity LIMIT 1];
            List<ServicePoint__c> spRetrieved = [SELECT id FROM ServicePoint__c LIMIT 1];
            List<Sale__c> saleRetrieved = [SELECT id FROM Sale__c LIMIT 1];
            Map<String,String> mapStrings = New Map<String,String>();
            HDT_SRV_SaleServiceItem testClass = new HDT_SRV_SaleServiceItem();

            testClass.createRecord(spRetrieved[0],saleRetrieved[0],mapStrings);

            List<SaleServiceItem__c> ssiRetrieved = [SELECT Id,Opportunity__c FROM SaleServiceItem__c LIMIT 1];
             returnedList = testClass.groupRecordsByOpportunity(oppRetrieved, ssiRetrieved);

        }
        

        System.assertEquals(true,returnedList.size() == 0, 'The method correctly returned a list of SaleServiceItem__c null');
        System.assertNotEquals(true,returnedList.size() > 0, 'The method correctly a list of SaleServiceItem__c null');
        Test.stopTest();
        
    }
}
