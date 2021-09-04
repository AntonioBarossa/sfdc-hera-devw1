/**
 * @author Lucas da Silva Fernandes (lucas.dasilva@engdb.com.br)
 * @date 01/09/2021
 * @description HDT_QR_Variations Test Class
 * @history Lucas da Silva Fernandes – 01/09/2021 – Created Class
 */

@isTest
public with sharing class HDT_QR_VariationsTst {
   
    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();

    @TestSetup
    static void setup(){

        HDT_UTL_DataFactoryTst.pClickInstance();
        HDT_UTL_DataFactoryTst.pClickCasePhase();
        HDT_UTL_DataFactoryTst.pClickOrderPhase();
        
        // System Administrator User
        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
        User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
        internalUser.UserPermissionsMarketingUser=true;
        insert internalUser;

        // Minimum Access User
        Id minimumUserId = HDT_UTL_DataFactoryTst.getProfileId(constants.MINIMUM_ACCESS_SALESFORCE);
        User minimumUser=HDT_UTL_DataFactoryTst.createInternalUser(minimumUserId, false);
        minimumUser.Alias = 'minimum';
        minimumUser.FirstName = 'Name';
        minimumUser.LastName = 'Last';
        insert minimumUser;
 
        System.runAs(internalUser) {

            List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'Reseller', 'GENESI-Altro', 'Reseller - Gruppo');
            List<Order> orders = HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].Id, 'Bozza');
            
            List<Contact> cttList = HDT_UTL_DataFactoryTst.createContact(1, false, accList[0].Id);
            cttList[0].CompanyOwner__c = null;
            cttList[0].Company__c = null;
            insert cttList;

            List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].Id);
            
            List<ServicePoint__c> spList = HDT_UTL_DataFactoryTst.createServicePoint(1, false);
            spList[0].Account__c = accList[0].Id;
            spList[0].CommoditySector__c = 'Energia Elettrica';
            spList[0].Resident__c = true;
            insert spList;
            
            List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, false, accList[0].Id, cttList[0].Id, spList[0].Id, contractList[0].Id, orders[0].Id);
            caseList[0].Taxes__c = 'Imposta usi non domestici iva 10% (Cod. G_ICC10)';
            caseList[0].UseCategory__c = '002-Prod.acqua calda sanitaria';
            caseList[0].Resident__c = false;
            insert caseList;
        }
    }

    @isTest
    public static void testQueryConsistencyTable() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            Case cs = [SELECT Id, Taxes__c, UseCategory__c FROM Case WHERE Status='In Lavorazione'];
            
            String implantType = '1002-Cottura/Produz acq calda';
            String supplyType = 'C-Aziende di pubblica utilita';

            Boolean result = HDT_QR_Variations.queryConsistencyTable(cs.Id, cs.UseCategory__c, supplyType , implantType);

            System.assertEquals(true, result, 'Query successfully done.');
            System.assertNotEquals(false, result, 'Query failed.');

            implantType = null;

            result = HDT_QR_Variations.queryConsistencyTable(cs.Id, '', supplyType , implantType);

            System.assertEquals(false, result, 'Query successfully failed.');
            System.assertNotEquals(true, result, 'Query was unwanted successfull.');

            Test.stopTest();
        }
    }

    @isTest
    public static void testQueryServicePoint() {

        Test.startTest();

        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
        User x=[SELECT Id FROM User WHERE Alias='minimum' LIMIT 1];
 
        System.runAs(u){
 
            ServicePoint__c sp = [SELECT Id, CommoditySector__c, Account__c, Resident__c
                                  FROM ServicePoint__c
                                  WHERE ServicePointCode__c='testServicePointCode'];

            List<ServicePoint__c> spListTest = HDT_QR_Variations.queryServicePoint(sp.Account__c, sp.CommoditySector__c, '');

            System.assertEquals(false, spListTest.isEmpty(), 'Populated list retrieved');

            System.assertNotEquals(true, spListTest.isEmpty(), 'Empty list retrieved');
        }

        System.runAs(x){

            ServicePoint__c sp = [SELECT Id, CommoditySector__c, Account__c, Resident__c
                                  FROM ServicePoint__c
                                  WHERE ServicePointCode__c='testServicePointCode'];

            List<ServicePoint__c> spListTest = HDT_QR_Variations.queryServicePoint(sp.Account__c, sp.CommoditySector__c, '');

            System.assertEquals(true, spListTest.isEmpty(), 'Populated list retrieved');

            System.assertNotEquals(false, spListTest.isEmpty(), 'Empty list retrieved');
        }

        Test.stopTest();
    }

    @isTest
    public static void testQueryOtherCases() {
        
        Test.startTest();

        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
        User x=[SELECT Id FROM User WHERE Alias='minimum' LIMIT 1];

        System.runAs(u){
 
            List<Case> csList = [SELECT Id, ServicePoint__c FROM Case];

            List<Id> idList = new List<Id>();

            for (Integer i=0; i<csList.size(); i++) {
                Id id = csList[i].Id;
                idList.add(id);
            }

            List<Case> cs = HDT_QR_Variations.queryOtherCases(idList, '');

            System.assertEquals(false, cs.isEmpty(), 'Populated list retrieved');

            System.assertNotEquals(true, cs.isEmpty(), 'Empty list retrieved');
        }

        System.runAs(x){

            List<Case> csList = [SELECT Id, ServicePoint__c FROM Case];

            List<Id> idList = new List<Id>();

            for (Integer i=0; i<csList.size(); i++) {
                Id id = csList[i].Id;
                idList.add(id);
            }

            List<Case> cs = HDT_QR_Variations.queryOtherCases(idList, '');

            System.assertEquals(true, cs.isEmpty(), 'Populated list retrieved');

            System.assertNotEquals(false, cs.isEmpty(), 'Empty list retrieved');

        }

        Test.stopTest();
    }

    @isTest
    public static void testGetCaseInfo() {

        Test.startTest();

        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
        User x=[SELECT Id FROM User WHERE Alias='minimum' LIMIT 1];
 
        System.runAs(u){
            
            List<Case> csList = [SELECT Id, ServicePoint__c, CommodityFormula__c FROM Case WHERE Phase__c='Bozza'];

            Case testCase = HDT_QR_Variations.getCaseInfo(csList[0].Id);

            System.assertEquals(csList[0].Id, testCase.Id, 'Case successfully queried');
            System.assertNotEquals(null, testCase.Id, 'Case query failed');
        }

        System.runAs(x){
            
            List<Case> csList = [SELECT Id, ServicePoint__c, CommodityFormula__c FROM Case WHERE Phase__c='Bozza'];
            Case testCase = new Case();

            try {
                testCase = HDT_QR_Variations.getCaseInfo(csList[0].Id);
            } catch (Exception e) {
                
            }

            System.assertEquals(null, testCase.Id, 'Case successfully queried');
            System.assertNotEquals('something', testCase.Id, 'Case query failed');
        }

        Test.stopTest();
    }
}
