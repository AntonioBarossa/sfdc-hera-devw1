/**
 * @author Lucas da Silva Fernandes (lucas.dasilva@engdb.com.br)
 * @date 23/09/2021
 * @description HDT_LC_AdvancedSearch Test Class
 * @history Lucas da Silva Fernandes – 23/09/2021 – Created Class
 */
@isTest
public with sharing class HDT_LC_AdvancedSearchTst {

    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();
	
	@TestSetup
    static void setup(){
        
        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
        User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
        internalUser.UserPermissionsMarketingUser=true;
        insert internalUser;
 
        System.runAs(internalUser) {

            HDT_UTL_DataFactoryTst.pClickInstance();
            HDT_UTL_DataFactoryTst.pClickOrderPhase();
            HDT_UTL_DataFactoryTst.pClickCasePhase();
 
            List<BlackList__c> bList = HDT_UTL_DataFactoryTst.createBlacklist(1, false);
            bList[0].isActive__c = true;
            insert bList;

            List<CS_SelezioneFornitura__c> sfList = HDT_UTL_DataFactoryTst.createSelezioneFornitura(1, false);
            sfList[0].Output_Contract__c = 'Name';
            sfList[0].Max_Record__c = 1.0;
            sfList[0].OutputServicePoint__c = 'ServicePointCode__c';
            insert sfList;

            List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
            List<Contact> cttList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].Id);
            List<Order> orderList = HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].Id, 'Bozza');
            
            List<ServicePoint__c> spList = HDT_UTL_DataFactoryTst.createServicePoint(1, false);
            spList[0].Account__c = accList[0].Id;
            insert spList;

            List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, false, accList[0].Id);
            contractList[0].SAPContractCode__c = '0123456789';
            insert contractList;

            List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, false, accList[0].Id, cttList[0].Id, spList[0].Id, contractList[0].Id, orderList[0].Id);
            caseList[0].ServicePointCode__c = 'caseSPC';
            caseList[0].RecordTypeId = constants.CASE_RECORDTYPEID_GENERICHE_ATTIVAZIONI;
            caseList[0].Type = 'Modifica Contr Preattivazione0';

            insert caseList;

            HDT_UTL_DataFactoryTst.createSubscription(1, true, accList[0].Id, contractList[0].Id, spList[0].Id);
        }
    }
	
	@isTest
    public static void testIsInBlacklist() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            List<BlackList__c> blackList = [SELECT Id, Pod__c, isActive__c FROM BlackList__c WHERE Name='testBlacklist'];

            Boolean result = HDT_LC_AdvancedSearch.isInBlacklist(blacklist[0].Pod__c);
 
            Test.stopTest();

            System.assertEquals(true, result, 'Found in Blacklist.');
            System.assertNotEquals(false, result, 'Not found in Blacklist.');
        }
    }
    
    @isTest
    public static void testSearchModificaContratti() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){

            Test.startTest();

            List<Case> caseList = [SELECT Id, ServicePointCode__c, ServicePoint__c  FROM Case WHERE ServicePointCode__c = 'caseSPC' LIMIT 1];
            caseList[0].ServicePoint__c = null;
            update caseList;

            List<Case> caseTest = HDT_LC_AdvancedSearch.searchModificaContratti(caseList[0].ServicePointCode__c);
 
            Test.stopTest();

            System.assertEquals(false, caseTest.isEmpty(), 'Case found');
            System.assertNotEquals(true, caseTest.isEmpty(), 'Case not found');
        }
    }

    @isTest
    public static void testPermissionForFlagContract() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            Boolean assert = HDT_LC_AdvancedSearch.permissionForFlagContract();
 
            Test.stopTest();

            System.assertEquals(false, assert, 'Not allowed');
            System.assertNotEquals(true, assert, 'Allowed');
        }
    }

    @isTest
    public static void testGetIndirizzoFornitura() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            String accId = [SELECT Id FROM Account WHERE CompanyOwner__c = 'HERA COMM'].Id;

            List<HDT_WRP_AddressObject> assert = HDT_LC_AdvancedSearch.getIndirizzoFornitura(accId);

            ServicePoint__c sp = [SELECT Id, SupplyCity__c, SupplyStreet__c, SupplyStreetNumber__c, SupplyStreetNumberExtension__c, SupplyPostalCode__c,
                                         SupplyProvince__c, SupplyCountry__c, SupplySAPStreetCode__c, SupplySAPCityCode__c, CommoditySector__c
                                  FROM ServicePoint__c WHERE ServicePointCode__c='testServicePointCode' LIMIT 1];

            sp.SupplyType__c = 'Domestico';
            sp.CommoditySector__c = 'Energia Elettrica';
            sp.SupplyCity__c = 'Roma';
            sp.SupplyStreet__c = 'Street Fighter';
            sp.SupplyStreetNumber__c = '2';
            sp.SupplyStreetNumberExtension__c = 'A';
            sp.SupplyPostalCode__c = '74000';
            sp.SupplyProvince__c = 'RM';
            sp.SupplyCountry__c = 'ITA';
            sp.SupplySAPStreetCode__c = 'IDDQD';
            sp.SupplySAPCityCode__c = 'IDKFA';
            update sp;
            
            assert = HDT_LC_AdvancedSearch.getIndirizzoFornitura(accId);
 
            Test.stopTest();

            System.assertEquals(false, assert.isEmpty(), 'Address retrieved');
            System.assertNotEquals(true, assert.isEmpty(), 'Address not retrieved');
        }
    }

    @isTest
    public static void testGetIndirizzo() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            Account acc = [SELECT Id, BillingStreetNumber__c FROM Account WHERE CompanyOwner__c = 'HERA COMM'];

            HDT_WRP_AddressObject assert = HDT_LC_AdvancedSearch.getIndirizzo(acc.Id);
 
            Test.stopTest();

            System.assertEquals(acc.BillingStreetNumber__c, assert.Civico, 'Address retrieved');
            System.assertNotEquals(null, assert.Civico, 'Address not retrieved');
        }
    }

    @isTest
    public static void testGetAddressFromAccount() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            Account acc = [SELECT Id FROM Account WHERE CompanyOwner__c = 'HERA COMM'];

            Map<String,String> assertMap = HDT_LC_AdvancedSearch.getAddressFromAccount(acc.Id);
 
            Test.stopTest();

            System.assertEquals(false, assertMap.isEmpty(), 'Address retrieved');
            System.assertNotEquals(true, assertMap.isEmpty(), 'Address not retrieved');
        }
    }

    // System.QueryException: Only variable references are allowed in dynamic SOQL/SOSL.  
    // Class.HDT_QR_Contract.getSapContractCode: line 45, column 1                        
    // Class.HDT_LC_AdvancedSearch.getServicePoints: line 395, column 1                   
    // Class.HDT_LC_AdvancedSearchTst.testGetServicePoints: line 198, column 1 
    @isTest
    public static void testGetServicePoints() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            List<ServicePoint__c> spList = [SELECT Id, MeterSN__c, ServicePointCode__c, SAPContractCode__c FROM ServicePoint__c WHERE ServicePointCode__c='testServicePointCode'];
            spList[0].MeterSN__c = 'paraMeterSN';
            spList[0].ServicePointCode__c = '1234567890';
            spList[0].SAPContractCode__c = '0123456789';
            update spList;

            List<Contract> cttList = [SELECT Id, Status FROM Contract WHERE SAPContractCode__c = '0123456789'];
            cttList[0].Status = 'Activated';
            update cttList;

            List<Map<String, Object>> assertMap = HDT_LC_AdvancedSearch.getServicePoints(spList[0].MeterSN__c, 'serialnumber', '', true);
            List<Map<String, Object>> assertMap2 = HDT_LC_AdvancedSearch.getServicePoints(spList[0].MeterSN__c, 'serialnumber', 'AND CorrectorSignal__c = null', false);
            List<Map<String, Object>> assertMap3 = HDT_LC_AdvancedSearch.getServicePoints(spList[0].ServicePointCode__c, 'pod', '', true);
            List<Map<String, Object>> assertMap4 = HDT_LC_AdvancedSearch.getServicePoints(spList[0].ServicePointCode__c, 'pod', 'AND CorrectorSignal__c = null', true);
            List<Map<String, Object>> assertMap5 = HDT_LC_AdvancedSearch.getServicePoints(spList[0].SAPContractCode__c, 'contract', '', true);

            List<CS_SelezioneFornitura__c> csList= [SELECT Id, OutputServicePoint__c FROM CS_SelezioneFornitura__c WHERE OutputServicePoint__c = 'ServicePointCode__c'];
            csList[0].OutputServicePoint__c = 'Account__r.Name';
            update csList;

            List<Map<String, Object>> assertMap6 = HDT_LC_AdvancedSearch.getServicePoints(spList[0].SAPContractCode__c, 'contract', 'AND SBQQ__AmendmentOpportunityStage__c = null', true);
            
            Test.stopTest();

            System.assertEquals(false, assertMap.isEmpty(), 'ServicePoint retrieved');
            System.assertNotEquals(true, assertMap.isEmpty(), 'ServicePoint not retrieved');
        }
    }

    @isTest
    public static void testServicePointFields() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            Map<String,String> assertMap = HDT_LC_AdvancedSearch.servicePointFields();
 
            Test.stopTest();

            System.assertEquals(false, assertMap.isEmpty(), 'Map retrieved');
            System.assertNotEquals(true, assertMap.isEmpty(), 'Map not retrieved');
        }
    }

    @isTest
    public static void testGetContracts() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            Account acc = [SELECT Id FROM Account WHERE CompanyOwner__c = 'HERA COMM'];

            List<Map<String,String>> assertMap = HDT_LC_AdvancedSearch.getContracts(acc.Id, '');
            List<Map<String,String>> assertMap2 = HDT_LC_AdvancedSearch.getContracts(acc.Id, 'AND SBQQ__AmendmentOpportunityStage__c = null');
 
            Test.stopTest();

            System.assertEquals(false, assertMap.isEmpty(), 'Map retrieved');
            System.assertNotEquals(true, assertMap.isEmpty(), 'Map not retrieved');
        }
    }

    @isTest
    public static void testGetContractsBackup() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            Account acc = [SELECT Id FROM Account WHERE CompanyOwner__c = 'HERA COMM'];

            List<Map<String,String>> assertMap = HDT_LC_AdvancedSearch.getContractsBackup(acc.Id, '');
            List<Map<String,String>> assertMap2 = HDT_LC_AdvancedSearch.getContractsBackup(acc.Id, 'AND SBQQ__AmendmentOpportunityStage__c = null');
 
            Test.stopTest();

            System.assertEquals(false, assertMap.isEmpty(), 'Map retrieved');
            System.assertNotEquals(true, assertMap.isEmpty(), 'Map not retrieved');
        }
    }

    @isTest
    public static void tryCallWebService() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            String pod = 'pod';

            String assert = HDT_LC_AdvancedSearch.callWebService(pod);
 
            Test.stopTest();

            System.assertEquals(pod, assert, 'String retrieved');
            System.assertNotEquals(null, assert, 'String not retrieved');
        }
    }

    @isTest
    public static void testCheckTheNumberOfRecords() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            Integer three = 3;
            String exc;

            try {

                HDT_LC_AdvancedSearch.checkTheNumberOfRecords(three);

            } catch (Exception e) {

                exc = String.valueOf(e);
            }
 
            Test.stopTest();

            System.assertEquals('System.AuraHandledException: Script-thrown exception', exc, 'Exception thrown');
            System.assertnotEquals(null, exc, 'Exception not thrown');

        }
    }

    @isTest
    public static void testGetForniture() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            Account acc = [SELECT Id FROM Account WHERE CompanyOwner__c = 'HERA COMM'];
            Contract ctt = [SELECT Id, Status FROM Contract WHERE SAPContractCode__c = '0123456789'];
            ctt.Status = 'Activated';
            update ctt;

            List<Map<String,String>> assertMap = HDT_LC_AdvancedSearch.getForniture(acc.Id, '');
            List<Map<String,String>> assertMap2 = HDT_LC_AdvancedSearch.getForniture(acc.Id, 'AND Vendor__c = null');
 
            Test.stopTest();

            System.assertEquals(false, assertMap.isEmpty(), 'Map retrieved');
            System.assertNotEquals(true, assertMap.isEmpty(), 'Map not retrieved');
        }
    }

    @isTest
    public static void testGetFornitureBackup() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            Account acc = [SELECT Id FROM Account WHERE CompanyOwner__c = 'HERA COMM'];

            List<Map<String,String>> assertMap = HDT_LC_AdvancedSearch.getFornitureBackup(acc.Id, '');
            List<Map<String,String>> assertMap2 = HDT_LC_AdvancedSearch.getFornitureBackup(acc.Id, 'AND CommoditySector__c = null');
 
            Test.stopTest();

            System.assertEquals(false, assertMap.isEmpty(), 'Map retrieved');
            System.assertNotEquals(true, assertMap.isEmpty(), 'Map not retrieved');
        }
    }

    @isTest
    public static void testExtractDataFromArriccDataService() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            ServicePoint__c sp = [SELECT Id, Account__c, ServicePointCode__c, Name, CommoditySector__c, ImplantType__c, AnnualConsumption__c, MarketOrigin__c,
                                         IsRemoteManaged__c, PowerContractual__c, PowerAvailable__c, VoltageLevel__c, Resident__c, SupplyPostalCode__c,
                                         SupplyStreet__c, SupplyStreetNumber__c, SupplyPlace__c, SupplySAPStreetCode__c, SupplySAPCityCode__c 
                                  FROM ServicePoint__c 
                                  WHERE ServicePointCode__c='testServicePointCode' LIMIT 1];

            HDT_WS_ArrichmentDataEntityResponse response = new HDT_WS_ArrichmentDataEntityResponse();
            HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_DataResponseObject dataResponseObject = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_DataResponseObject();
            List<HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject> proList = new List<HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject>();
            HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject posizioniResponseObject = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();

            posizioniResponseObject.campo = 'DISTRIBUTORE';
            posizioniResponseObject.valore = sp.Account__c;
            proList.add(posizioniResponseObject);

            posizioniResponseObject = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            posizioniResponseObject.campo = 'POD';
            posizioniResponseObject.valore = 'batatinhaFrita123';
            proList.add(posizioniResponseObject);

            posizioniResponseObject = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            posizioniResponseObject.campo = 'DESCRCOMM';
            posizioniResponseObject.valore = 'Energia elettrica';
            proList.add(posizioniResponseObject);

            posizioniResponseObject = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            posizioniResponseObject.campo = 'DESCRCOMM';
            posizioniResponseObject.valore = 'Gas';
            proList.add(posizioniResponseObject);

            posizioniResponseObject = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            posizioniResponseObject.campo = 'IMPIANTO';
            posizioniResponseObject.valore = '13A0-Usi di Abitazione BT';
            proList.add(posizioniResponseObject);

            posizioniResponseObject = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            posizioniResponseObject.campo = 'TIPOIMPIANTO';
            posizioniResponseObject.valore = '13A0';
            proList.add(posizioniResponseObject);

            posizioniResponseObject = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            posizioniResponseObject.campo = 'DESCRTIPOIMP';
            posizioniResponseObject.valore = 'Usi di Abitazione BT';
            proList.add(posizioniResponseObject);
            
            posizioniResponseObject = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            posizioniResponseObject.campo = 'CONSUMOCAPDR';
            posizioniResponseObject.valore = '1.0';
            proList.add(posizioniResponseObject);
            
            posizioniResponseObject = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            posizioniResponseObject.campo = 'MERCATO';
            posizioniResponseObject.valore = 'Default';
            proList.add(posizioniResponseObject);
            
            posizioniResponseObject = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            posizioniResponseObject.campo = 'FLAGTELEGESTIBILE';
            posizioniResponseObject.valore = 'true';
            proList.add(posizioniResponseObject);
            
            posizioniResponseObject = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            posizioniResponseObject.campo = 'POTENZACONTRATTUALE';
            posizioniResponseObject.valore = '2.0';
            proList.add(posizioniResponseObject);
            
            posizioniResponseObject = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            posizioniResponseObject.campo = 'POTENZATECNICA';
            posizioniResponseObject.valore = '2.0';
            proList.add(posizioniResponseObject);
            
            posizioniResponseObject = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            posizioniResponseObject.campo = 'TENSIONE';
            posizioniResponseObject.valore = 'BT';
            proList.add(posizioniResponseObject);
            
            posizioniResponseObject = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            posizioniResponseObject.campo = 'RESIDENTINDFORNITURA';
            posizioniResponseObject.valore = 'true';
            proList.add(posizioniResponseObject);
            
            posizioniResponseObject = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            posizioniResponseObject.campo = 'CAP';
            posizioniResponseObject.valore = '74000';
            proList.add(posizioniResponseObject);
            
            posizioniResponseObject = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            posizioniResponseObject.campo = 'VIA';
            posizioniResponseObject.valore = 'Street Fighter';
            proList.add(posizioniResponseObject);
            
            posizioniResponseObject = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            posizioniResponseObject.campo = 'CIVICO';
            posizioniResponseObject.valore = '2';
            proList.add(posizioniResponseObject);
            
            posizioniResponseObject = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            posizioniResponseObject.campo = 'LOCALITÀ';
            posizioniResponseObject.valore = 'USSR';
            proList.add(posizioniResponseObject);

            posizioniResponseObject = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            posizioniResponseObject.campo = 'CODICEVIA';
            posizioniResponseObject.valore = '0557';
            proList.add(posizioniResponseObject);

            posizioniResponseObject = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            posizioniResponseObject.campo = 'CODICEPAESE';
            posizioniResponseObject.valore = 'MS';
            proList.add(posizioniResponseObject);
            
            posizioniResponseObject = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            posizioniResponseObject.campo = 'REGIONE';
            posizioniResponseObject.valore = '74000';
            proList.add(posizioniResponseObject);
            
            dataResponseObject.posizioni = proList;
            response.data = dataResponseObject;

            List<Map<String,string>> assertMap = HDT_LC_AdvancedSearch.extractDataFromArriccDataService(sp, response);
 
            Test.stopTest();

            System.assertEquals(false, assertMap.isEmpty(), 'Map retrieved');
            System.assertNotEquals(true, assertMap.isEmpty(), 'Map not retrieved');
        }
    }
}
