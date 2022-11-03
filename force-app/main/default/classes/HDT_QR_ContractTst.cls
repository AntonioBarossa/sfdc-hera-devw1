/**
 * @author Lucas da Silva Fernandes (lucas.dasilva@engdb.com.br)
 * @date 16/09/2021
 * @description HDT_QR_Contract Test Class
 * @history Lucas da Silva Fernandes – 16/09/2021 – Created Class
 */
@isTest
public with sharing class HDT_QR_ContractTst {
    private static HDT_QR_Contract contractQr = new HDT_QR_Contract();
    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();
    
    @TestSetup
    static void setup(){
        
        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
        User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
        internalUser.UserPermissionsMarketingUser=true;
        insert internalUser;
 
        System.runAs(internalUser) {
 
            List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, false, 'HERA COMM', 'Azienda', 'Aziende SME');
            accList[0].ActiveServicesEle__c = 30;
            accList[0].ActiveServicesGas__c = 30;
            accList[0].ActiveServicesTLR__c = 30;
            accList[0].ActiveServicesWater__c = 30;
            accList[0].ActiveServicesWaste__c = 30;
            insert accList;
            
            HDT_UTL_DataFactoryTst.createBillingProfile(1, true, accList[0].Id);

            List<ServicePoint__c> spList = HDT_UTL_DataFactoryTst.createServicePoint(1, false);
            spList[0].SAPContractCode__c = 'SAPCode';
            insert spList;
            
            List<Order> orderList = HDT_UTL_DataFactoryTst.createOrder(1, false, accList[0].Id, 'Bozza');
            orderList[0].RecordTypeId = constants.ORDER_RECORDTYPEID_RIATTIVAZIONENONMOROSE;
            orderList[0].ProcessType__c = 'Temporanea - Nuova Attivazione';
            orderList[0].ServicePoint__c = spList[0].Id;
            insert orderList;

            List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, false, accList[0].Id);
            contractList[0].ServicePoint__c = spList[0].Id;
            contractList[0].Status = 'Attivo';
            contractList[0].SBQQ__Order__c = orderList[0].Id;
            contractList[0].StartDate = System.today();
            contractList[0].EndDate = system.today().addDays(1);
            insert contractList;
        }
    }
    
    @isTest
    public static void testGetRecordsWithContractsByServicePointAndAccountId() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();
            List<Contract> cttList = [SELECT Id, ServicePoint__c, AccountId FROM Contract WHERE Status = 'Attivo'];
            List<Contract> assertEquals = contractQr.getRecordsWithContractsByServicePointAndAccountId(cttList[0].ServicePoint__c, cttList[0].AccountId);
 
            Test.stopTest();
            System.assertEquals(false, assertEquals.isEmpty(), 'Contract successfully queried.');
            System.assertNotEquals(true, assertEquals.isEmpty(), 'Contract query failed.');
        }
    }
    @isTest
    public static void testGetInd() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();
            Account acc = [SELECT Id FROM Account WHERE Category__c = 'Aziende SME'];
            List<BillingProfile__c> bpList = contractQr.getInd(acc.Id);
 
            Test.stopTest();
            System.assertEquals(false, bpList.isEmpty(), 'BillingProfile__c successfully queried.');
            System.assertNotEquals(true, bpList.isEmpty(), 'BillingProfile__c query failed.');
        }
    }
    @isTest
    public static void testGetSapContractCode() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();
            ServicePoint__c sp = [SELECT ServicePointCode__c FROM ServicePoint__c WHERE ServicePointCode__c='testServicePointCode'];
            
            Contract ct = [SELECT Id, Status FROM Contract WHERE Status = 'Attivo'];
            ct.Status = 'Activated';
            ct.ServicePoint__c = sp.Id;
            update ct;

            Contract ctFalse = contractQr.getSapContractCode(sp.ServicePointCode__c, false);
            Contract ctTrue = contractQr.getSapContractCode(sp.ServicePointCode__c, true);

            Test.stopTest();

            System.assertEquals(sp.ServicePointCode__c, ctFalse.ServicePoint__r.ServicePointCode__c, 'Contract successfully queried.');
            System.assertEquals(sp.ServicePointCode__c, ctTrue.ServicePoint__r.ServicePointCode__c, 'Contract successfully queried.');
            System.assertNotEquals(null, ctFalse.ServicePoint__r.ServicePointCode__c, 'Contract query failed.');
            System.assertNotEquals(null, ctTrue.ServicePoint__r.ServicePointCode__c, 'Contract query failed.');
        }
    }
    @isTest
    public static void testGetSapContractCodes() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();
            
            Contract ct = [SELECT Id, Status FROM Contract WHERE Status = 'Attivo'];
            ct.Status = 'Activated';
            update ct;

            String st = [SELECT ServicePointCode__c FROM ServicePoint__c WHERE Name='testServicePoint0'].ServicePointCode__c;
            List<String> stringList = new List<String>{st};
            
            List<Contract> ctList = contractQr.getSapContractCode(stringList);
 
            Test.stopTest();
            
            System.assertEquals(false, ctList.isEmpty(), 'Contracts successfully queried.');
            System.assertNotEquals(true, ctList.isEmpty(), 'Contracts query failed.');
        }
    }
    @isTest
    public static void testGetRecordById() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();
            Contract ct = [SELECT Id, Status FROM Contract WHERE Status = 'Attivo'];
            List<Contract> ctList = contractQr.getRecordById(ct.Id);
 
            Test.stopTest();
            System.assertEquals(false, ctList.isEmpty(), 'Contracts successfully queried.');
            System.assertNotEquals(true, ctList.isEmpty(), 'Contracts query failed.');
        }
    }
    @isTest
    public static void testGetActiveRecordsByAccountId() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();
            Account acc = [SELECT Id FROM Account WHERE Category__c = 'Aziende SME'];
            List<Contract> ctList = contractQr.getActiveRecordsByAccountId(acc.Id);
 
            Test.stopTest();
            System.assertEquals(false, ctList.isEmpty(), 'Contracts successfully queried.');
            System.assertNotEquals(true, ctList.isEmpty(), 'Contracts query failed.');
        }
    }
    @isTest
    public static void testGetTempNewActivationContractsByAccountId() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();
            Account acc = [SELECT Id FROM Account WHERE Category__c = 'Aziende SME'];
 
            List<Contract> ctList = contractQr.getTempNewActivationContractsByAccountId(acc.Id);
 
            Test.stopTest();
            System.assertEquals(false, ctList.isEmpty(), 'Contracts successfully queried.');
            System.assertNotEquals(true, ctList.isEmpty(), 'Contracts query failed.');
        }
    }
    @isTest
    public static void testGetActiveRecordsByAccountIdAndServicePointId() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();
            Contract ctt = [SELECT AccountId, ServicePoint__c FROM Contract WHERE Status = 'Attivo'];
            List<Contract> cttList = contractQr.getActiveRecordsByAccountIdAndServicePointId(ctt.AccountId, ctt.ServicePoint__c);
 
            Test.stopTest();
            System.assertEquals(false, cttList.isEmpty(), 'Contracts successfully queried.');
            System.assertNotEquals(true, cttList.isEmpty(), 'Contracts query failed.');
        }
    }
    @isTest
    public static void testGetContractFromRow() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();
            Contract ctt = [SELECT AccountId, ContractNumber FROM Contract WHERE Status = 'Attivo'];
            Contract cttQuery = HDT_QR_Contract.getContractFromRow(ctt.ContractNumber, ctt.AccountId);
 
            Test.stopTest();
            System.assertEquals(ctt.AccountId, cttQuery.AccountId, 'Contracts successfully queried.');
            System.assertNotEquals(null, cttQuery.AccountId, 'Contracts query failed.');
        }
    }
    @isTest
    public static void testGetAccountContractsWithFilter() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();
            Account acc = [SELECT Id FROM Account WHERE Category__c = 'Aziende SME'];
 
            List<Contract> ctList = contractQr.getAccountContractsWithFilter(acc.Id, '');
 
            Test.stopTest();
            System.assertEquals(false, ctList.isEmpty(), 'Contracts successfully queried.');
            System.assertNotEquals(true, ctList.isEmpty(), 'Contracts query failed.');
        }
    }
    @isTest
    public static void testGetAccountContracts() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();
            Account acc = [SELECT Id FROM Account WHERE Category__c = 'Aziende SME'];
 
            List<Contract> ctList = contractQr.getAccountContracts(acc.Id);
 
            Test.stopTest();
            System.assertEquals(false, ctList.isEmpty(), 'Contracts successfully queried.');
            System.assertNotEquals(true, ctList.isEmpty(), 'Contracts query failed.');
        }
    }
    @isTest
    public static void testGetAccountContractsWithFilter2() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();
            Account acc = [SELECT Id FROM Account WHERE Category__c = 'Aziende SME'];
            List<Contract> ctList = contractQr.getAccountContractsWithFilter('Id', acc.Id, '');
 
            Test.stopTest();
            System.assertEquals(false, ctList.isEmpty(), 'Contracts successfully queried.');
            System.assertNotEquals(true, ctList.isEmpty(), 'Contracts query failed.');
        }
    }
    @isTest
    public static void testGetAccountContracts2() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();
            Account acc = [SELECT Id FROM Account WHERE Category__c = 'Aziende SME'];
            List<Contract> ctList = contractQr.getAccountContracts('Id', acc.Id);
 
            Test.stopTest();
            System.assertEquals(false, ctList.isEmpty(), 'Contracts successfully queried.');
            System.assertNotEquals(true, ctList.isEmpty(), 'Contracts query failed.');
        }
    }
    @isTest
    public static void testGetRecordsWithOrders() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();
            Contract ct = [SELECT Id FROM Contract WHERE Status = 'Attivo'];
            List<String> st = new List<String>();
            st.add(ct.Id);
            List<Contract> ctList = contractQr.getRecordsWithOrders(st);
 
            Test.stopTest();
            System.assertEquals(false, ctList.isEmpty(), 'Contracts successfully queried.');
            System.assertNotEquals(true, ctList.isEmpty(), 'Contracts query failed.');
        }
    }
    @isTest
    public static void testGetContractFromServicePoint() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();
            ServicePoint__c sp = [SELECT Id FROM ServicePoint__c WHERE ServicePointCode__c='testServicePointCode'];
            List<Contract> ctList = contractQr.getContractFromServicePoint(sp.Id);
 
            Test.stopTest();
            System.assertEquals(false, ctList.isEmpty(), 'Contracts successfully queried.');
            System.assertNotEquals(true, ctList.isEmpty(), 'Contracts query failed.');
        }
    }
    @isTest
    public static void testGetContractAccountCompanyOwner() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();
            Contract ct = [SELECT Id, Account.CompanyOwner__c FROM Contract WHERE Status = 'Attivo'];
            Contract ctQuery = contractQr.getContractAccountCompanyOwner(ct.Id);
 
            Test.stopTest();
            System.assertEquals(ct.Account.CompanyOwner__c, ctQuery.Account.CompanyOwner__c, 'Contracts successfully queried.');
            System.assertNotEquals(null, ctQuery.Account.CompanyOwner__c, 'Contracts query failed.');
        }
    }
}