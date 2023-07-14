/**
 * @author Lucas da Silva Fernandes (lucas.dasilva@engdb.com.br)
 * @date 24/09/2021
 * @description HDT_LC_SaleVas Test Classes
 * @history Lucas Fernandes 24/09/2021 – Created Class
 */
@isTest
public with sharing class HDT_LC_SaleVasTst {
    
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
            HDT_UTL_DataFactoryTst.newPhaseTransition('In Lavorazione', 'Bozza', constants.ORDER_RECORDTYPEID_DEFAULT, 'HDT_RT_Default');
            HDT_UTL_DataFactoryTst.newPhaseTransition('In Lavorazione', 'Bozza', constants.ORDER_RECORDTYPEID_VAS, 'HDT_RT_VAS');
 
            List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
            
            HDT_UTL_DataFactoryTst.createSale(1, true, accList[0].Id, 'Bozza');

            List<ServicePoint__c> spList = HDT_UTL_DataFactoryTst.createServicePoint(1, false);
            spList[0].RecordTypeId = constants.SERVICEPOINT_RECORDTYPEID_PELETRICCO;
            spList[0].CommoditySector__c = 'Energia Elettrica';
            insert spList;

            List<Order> orderList = HDT_UTL_DataFactoryTst.createOrder(1, false, accList[0].Id, 'Bozza');
            orderList[0].ServicePoint__c = spList[0].Id;
            orderList[0].SalesCompany__c = 'Hera Comm Marche';
            orderList[0].Market__c = 'Default';
            insert orderList;

            List<Contract> cttList = HDT_UTL_DataFactoryTst.createContract(1, false, accList[0].Id);
            cttList[0].ServicePoint__c = spList[0].Id;
            cttList[0].SBQQ__Order__c = orderList[0].Id;
            cttList[0].Status = 'Attivo';
            insert cttList;

            orderList[0].ContractReference__c = cttList[0].Id;
            update orderList;

            List<Campaign> cmpList = HDT_UTL_DataFactoryTst.createCampaign(1, true);

            List<Sale__c> saleList = HDT_UTL_DataFactoryTst.createSale(1, false, accList[0].Id, 'Bozza');
            saleList[0].Agency__c = 'agencyTest';
            saleList[0].Channel__c = 'Telefono';
            saleList[0].FriendCode__c = '4m1g0';
            saleList[0].CampaignCode__c = 'cmpCode';
            saleList[0].Campaign__c = cmpList[0].Id;
            insert saleList;

            List<Pricebook2> pbList = HDT_UTL_DataFactoryTst.createPricebook(1, false);
            pbList[0].Name = 'VAS ELE';
            insert pbList;

            List<City__c> cityList = HDT_UTL_DataFactoryTst.createCity();
            cityList[0].Province__c = 'AQ';
            update cityList;

            List<Opportunity> oppList = HDT_UTL_DataFactoryTst.createOpportunity(1, true);
            List<SBQQ__Quote__c> quoteList = HDT_UTL_DataFactoryTst.createQuote(1, true, orderList[0].Id, oppList[0].Id, saleList[0].Id, 'Quote');

            orderList[0].SBQQ__Quote__c = quoteList[0].Id;
            update orderList;

            List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].Id);

            List<Product2> prodList = HDT_UTL_DataFactoryTst.createProduct2(1, false);
            prodList[0].Name = 'Analisi Consumi';
            prodList[0].Family='VAS Fatturabili';
            insert prodList;

            List<Asset> assetList = HDT_UTL_DataFactoryTst.createAsset(2, false);
            assetList[0].DigitalAssetStatus = 'Attivo';
            assetList[0].AccountId = accList[0].Id;
            assetList[0].Contract__c = cttList[0].Id;
            assetList[0].Product2Id = prodList[0].Id;
            assetList[1].DigitalAssetStatus = 'Attivo';
            assetList[1].AccountId = accList[0].Id;
            insert assetList;

            List<SBQQ__Subscription__c> subscList = HDT_UTL_DataFactoryTst.createSubscription(2, false, accList[0].Id, cttList[0].Id, spList[0].Id);
            subscList[0].SBQQ__Account__c = accList[0].Id;
            subscList[0].SBQQ__Product__c = prodList[0].Id;
            subscList[1].SBQQ__Account__c = accList[0].Id;
            subscList[1].SBQQ__Product__c = prodList[0].Id;
            insert subscList;

            List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, false, accList[0].Id, contactList[0].Id, spList[0].Id, cttList[0].Id, orderList[0].Id);
            caseList[0].AssetId = assetList[0].Id;
            caseList[0].Type = 'Disattivazione VAS';
            caseList[0].Subscription__c = subscList[0].Id;
            insert caseList;
        }
    }
	
	@isTest
    public static void testConfirmActionOrder() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            Account acc = [SELECT Id FROM Account WHERE CompanyOwner__c = 'HERA COMM' LIMIT 1];
            Order order = [SELECT Id, ServicePoint__r.ServicePointCode__c, SalesCompany__c, AccountId, Market__c, ContractReference__c FROM Order WHERE Phase__c = 'Bozza' LIMIT 1];
            Contract contract = [SELECT Id FROM Contract WHERE SAPContractCode__c='3011913470' LIMIT 1];
            Sale__c sale = [SELECT Id, Name, Account__c, Agency__c, Channel__c, FriendCode__c, CampaignCode__c, CreatedBy__c, Campaign__c FROM Sale__c WHERE Status__c = 'Bozza' LIMIT 1];

            HDT_LC_SaleVas.confirmAction('Ordini in corso', order, contract, '', acc.Id, sale); 
 
            List<Opportunity> opp = [SELECT Id FROM Opportunity WHERE StageName = 'Proposal' LIMIT 1];

            Test.stopTest();

            System.assertEquals(false, opp.isEmpty(), 'Opportunity created');
            System.assertNotEquals(true, opp.isEmpty(), 'Opportunity created');
        }
    }
	
    @isTest
    public static void testConfirmActionContract() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            Account acc = [SELECT Id FROM Account WHERE CompanyOwner__c = 'HERA COMM' LIMIT 1];
            Order order = [SELECT Id FROM Order WHERE Phase__c = 'Bozza' LIMIT 1]; //, ServicePoint__r.ServicePointCode__c, SalesCompany__c, AccountId, Market__c
            Contract contract = [SELECT Id, ServicePoint__r.ServicePointCode__c, ServicePoint__r.Vendor__c, AccountId FROM Contract WHERE SAPContractCode__c='3011913470' LIMIT 1];
            Sale__c sale = [SELECT Id, Name, Account__c, Agency__c, Channel__c, FriendCode__c, CampaignCode__c, CreatedBy__c, Campaign__c FROM Sale__c WHERE Status__c = 'Bozza' LIMIT 1];

            HDT_LC_SaleVas.confirmAction('Contratti Attivi', order, contract, '', acc.Id, sale);
 
            List<Opportunity> opp = [SELECT Id FROM Opportunity WHERE StageName = 'Proposal' LIMIT 1];

            Test.stopTest();

            System.assertEquals(false, opp.isEmpty(), 'Opportunity created');
            System.assertNotEquals(true, opp.isEmpty(), 'Opportunity created');
        }
    }

    @isTest
    public static void testConfirmActionVas() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            Account acc = [SELECT Id FROM Account WHERE CompanyOwner__c = 'HERA COMM' LIMIT 1];
            Order order = [SELECT Id FROM Order WHERE Phase__c = 'Bozza' LIMIT 1]; //, ServicePoint__r.ServicePointCode__c, SalesCompany__c, AccountId, Market__c
            Contract contract = [SELECT Id FROM Contract WHERE SAPContractCode__c='3011913470' LIMIT 1];
            Sale__c sale = [SELECT Id, Name, Account__c, Agency__c, Channel__c, FriendCode__c, CampaignCode__c, CreatedBy__c, Campaign__c FROM Sale__c WHERE Status__c = 'Bozza' LIMIT 1];

            HDT_LC_SaleVas.confirmAction('VAS stand alone', order, contract, 'Roma', acc.Id, sale);
 
            List<Opportunity> opp = [SELECT Id FROM Opportunity WHERE StageName = 'Proposal' LIMIT 1];

            Test.stopTest();

            System.assertEquals(false, opp.isEmpty(), 'Opportunity created');
            System.assertNotEquals(true, opp.isEmpty(), 'Opportunity created');
        }
    }

    @isTest
    public static void testGetContractsAndOrdersMap() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            String accId = [SELECT Id FROM Account WHERE CompanyOwner__c = 'HERA COMM' LIMIT 1].Id;

            Map<String,List<SObject>> result = HDT_LC_SaleVas.getContractsAndOrdersMap(accId);
 
            Test.stopTest();

            System.assertEquals(false, result.isEmpty(), 'Objects found');
            System.assertNotEquals(true, result.isEmpty(), 'Objects not found');
        }
    }

    @isTest
    public static void testTransitionCheck() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            Sale__c sale = [SELECT Id, isTransition__c FROM Sale__c WHERE Status__c = 'Bozza' LIMIT 1];

            Boolean check = HDT_LC_SaleVas.transitionCheck(sale.Id);

            check = HDT_LC_SaleVas.transitionCheck(sale.Id);
            
            Test.stopTest();

            System.assertEquals(false, check, 'Transition OK');
            System.assertNotEquals(true, check, 'Transition failed');
        }
    }

    @isTest
    public static void testTransitionCheckNew() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            Sale__c sale = [SELECT Id, isTransition__c FROM Sale__c WHERE Status__c = 'Bozza' LIMIT 1];
            City__c city = [SELECT Id, Name FROM City__c WHERE Province__c = 'AQ' LIMIT 1];

            HDT_LC_SaleVas.wrapReturn wrap = HDT_LC_SaleVas.transitionCheckNew(sale.Id, city.Name, 'VAS stand alone');
 
            Test.stopTest();

            System.assertEquals(false, wrap.res, 'Transition OK');
            System.assertNotEquals(true, wrap.res, 'Transition failed');
        }
    }

    @isTest
    public static void testGetOrdersList() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            Account acc = [SELECT Id FROM Account WHERE CompanyOwner__c = 'HERA COMM' LIMIT 1];
            SBQQ__Quote__c quote = [SELECT Id, IsVAS__c, AmendmentAllowed__c FROM SBQQ__Quote__c LIMIT 1];
            quote.IsVAS__c = false;
            quote.AmendmentAllowed__c = false;
            update quote;

            Order order = [SELECT Id, Status FROM Order WHERE Market__c = 'Default' LIMIT 1];
            order.Status = 'In Lavorazione';
            update order;

            List<Order> result = HDT_LC_SaleVas.getOrdersList(acc.Id);
 
            Test.stopTest();

            System.assertEquals(false, result.isEmpty(), 'Order found');
            System.assertNotEquals(true, result.isEmpty(), 'Order not found');
        }
    }

    @isTest
    public static void testGetOrdersListNotActive() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            Account acc = [SELECT Id FROM Account WHERE CompanyOwner__c = 'HERA COMM' LIMIT 1];

            List<Order> result = HDT_LC_SaleVas.getOrdersListNotActive(acc.Id);
 
            Test.stopTest();

            System.assertEquals(false, result.isEmpty(), 'Order found');
            System.assertNotEquals(true, result.isEmpty(), 'Order not found');
        }
    }

    @isTest
    public static void testGetContractsList() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            Account acc = [SELECT Id FROM Account WHERE CompanyOwner__c = 'HERA COMM' LIMIT 1];

/*             List<Contract> cttList = [SELECT Id, Status FROM Contract WHERE SAPContractCode__c='3011913470' LIMIT 1];
            cttList[0].Status = 'Attivo';
            update cttList; */

            List<Contract> result = HDT_LC_SaleVas.getContractsList(acc.Id);
 
            Test.stopTest();

            System.assertEquals(false, result.isEmpty(), 'Contract found');
            System.assertNotEquals(true, result.isEmpty(), 'Contract not found');
        }
    }

    @isTest
    public static void testGetTempNuovaAttivazContracts() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            Account acc = [SELECT Id FROM Account WHERE CompanyOwner__c = 'HERA COMM' LIMIT 1];
            List<Order> orders = HDT_UTL_DataFactoryTst.createOrder(1, false, acc.Id, 'Bozza');
            orders[0].Name = 'newOrder';
            orders[0].RecordTypeId = constants.ORDER_RECORDTYPEID_TEMPORANEANUOVAATT;
            orders[0].ProcessType__c = 'Temporanea - Nuova Attivazione';
            insert orders;

            Contract ctt = [SELECT Id, SBQQ__Order__c, Status FROM Contract WHERE SAPContractCode__c='3011913470' LIMIT 1];
            ctt.Status = 'Attivo';
            ctt.SBQQ__Order__c = orders[0].Id;
            ctt.EndDate = Date.today().addDays(10);
            update ctt;

            List<Contract> result = HDT_LC_SaleVas.getTempNuovaAttivazContracts(acc.Id);
 
            Test.stopTest();

            System.assertEquals(false, result.isEmpty(), 'Contract found');
            System.assertNotEquals(true, result.isEmpty(), 'Contract not found');
        }
    }

    @isTest
    public static void testGetFornituraOrdersInProgressVas() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            SBQQ__Quote__c quote = [SELECT Id, IsVas__c, AmendmentAllowed__c FROM SBQQ__Quote__c WHERE SBQQ__Type__c = 'Quote' LIMIT 1];
            quote.IsVAS__c = true;
            quote.AmendmentAllowed__c = false;
            update quote;

            Order order = [SELECT Id, AccountId, RecordTypeId, Status FROM Order WHERE Market__c = 'Default'];
            order.RecordTypeId = constants.ORDER_RECORDTYPEID_VAS;
            order.Status = 'In Lavorazione';
            update order;
            
            List<SObject> result = HDT_LC_SaleVas.getFornitura(order.AccountId, 'ORDERS_IN_PROGRESS_VAS');
 
            Test.stopTest();

            System.assertEquals(false, result.isEmpty(), 'Query done');
            System.assertNotEquals(true, result.isEmpty(), 'Query failed');
        }
    }

    @isTest
    public static void testGetFornituraOrdersEle() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            ServicePoint__c sp = [SELECT Id, CommoditySector__c FROM ServicePoint__c WHERE ServicePointCode__c='testServicePointCode' LIMIT 1];
            sp.CommoditySector__c = 'Energia Elettrica';
            update sp;

            Order order = [SELECT Id, AccountId FROM Order WHERE Market__c = 'Default'];
            
            List<SObject> result = HDT_LC_SaleVas.getFornitura(order.AccountId, 'ORDERS_ELE');
 
            Test.stopTest();

            System.assertEquals(false, result.isEmpty(), 'Query done');
            System.assertNotEquals(true, result.isEmpty(), 'Query failed');
        }
    }

    @isTest
    public static void testGetFornituraAssetsActivated() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            Order order = [SELECT Id, AccountId FROM Order WHERE Market__c = 'Default'];
            
            List<SObject> result = HDT_LC_SaleVas.getFornitura(order.AccountId, 'ASSETS_ACTIVATED');
 
            Test.stopTest();

            System.assertEquals(false, result.isEmpty(), 'Query done');
            System.assertNotEquals(true, result.isEmpty(), 'Query failed');
        }
    }

    @isTest
    public static void testGetFornituraSubsAnalisiConsumi() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){

            SBQQ__Subscription__c subscr = [SELECT Id, SBQQ__Account__c,SBQQ__Product__c,SBQQ__Product__r.Family FROM SBQQ__Subscription__c LIMIT 1];
            system.debug('subscr>>>'+subscr);

            Test.startTest();

            List<SObject> result = HDT_LC_SaleVas.getFornitura(subscr.SBQQ__Account__c, 'SUBS_ANALISI_CONSUMI');

            Test.stopTest();

            System.assertEquals(false, result.isEmpty(), 'Query done');
            System.assertNotEquals(true, result.isEmpty(), 'Query failed');
        }
    }

    @isTest
    public static void testGetFornituraContractsVas() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            Order order = [SELECT Id, AccountId, RecordTypeId FROM Order WHERE Market__c = 'Default'];
            order.RecordTypeId = constants.ORDER_RECORDTYPEID_VAS;
            update order;

            SBQQ__Subscription__c sub = [Select Id FROM SBQQ__Subscription__c WHERE SBQQ__Account__c = :order.AccountId LIMIT 1];
            Asset a = [Select Id FROM Asset WHERE AccountId = :order.AccountId LIMIT 1];
            List<SObject> sobjToUpdate = new List<Sobject>();
            sub.VasPracticeCode__c = '091820482';
            a.VasPracticeCode__c = '091820482';
            sobjToUpdate.add(sub);
            sobjToUpdate.add(a);
            update sobjToUpdate;

            List<SObject> result = HDT_LC_SaleVas.getFornitura(order.AccountId, 'CONTRACTS_VAS');
 
            Test.stopTest();

            System.assertEquals(false, result.isEmpty(), 'Query done');
            System.assertNotEquals(true, result.isEmpty(), 'Query failed');
        }
    }

    @isTest
    public static void testGetFornituraSubsFromContract() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){

            //Contract ctt = [SELECT Id FROM Contract WHERE SAPContractCode__c='3011913470' LIMIT 1];

            SBQQ__Subscription__c sub = [SELECT Name, SBQQ__Contract__c FROM SBQQ__Subscription__c WHERE SBQQ__Product__r.Family like 'VAS%' LIMIT 1 ];
            system.debug('sub>>>'+sub);

            Test.startTest();

            List<SObject> result = HDT_LC_SaleVas.getFornitura(sub.SBQQ__Contract__c, 'SUBS_FROM_CONTRACT');
 
            Test.stopTest();

            System.assertEquals(false, result.isEmpty(), 'Query done');
            System.assertNotEquals(true, result.isEmpty(), 'Query failed');
        }
    }

    @isTest
    public static void testGetFornituraAssetsFromContract() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            //Contract ctt = [SELECT Id FROM Contract WHERE SAPContractCode__c='3011913470' LIMIT 1];

            Asset ast = [SELECT Name, Product2Id, Contract__c FROM Asset WHERE Product2.Family like 'VAS%' WITH SECURITY_ENFORCED];
            system.debug('asset>>>'+ast);
            List<SObject> result = HDT_LC_SaleVas.getFornitura(ast.Contract__c, 'ASSETS_FROM_CONTRACT');
 
            Test.stopTest();

            System.assertEquals(false, result.isEmpty(), 'Query done');
            System.assertNotEquals(true, result.isEmpty(), 'Query failed');
        }
    }

    @isTest
    public static void testGetFornituraContractEleActive() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            Contract ctt = [SELECT Id, AccountId, Status FROM Contract WHERE Status = 'Attivo' AND SAPContractCode__c='3011913470' LIMIT 1];

            List<SObject> result = HDT_LC_SaleVas.getFornitura(ctt.AccountId, 'CONTRACT_ELE_ACTIVE');
 
            Test.stopTest();

            System.assertEquals(false, result.isEmpty(), 'Query done');
            System.assertNotEquals(true, result.isEmpty(), 'Query failed');
        }
    }

    @isTest
    static void handleNotMigratedContratTst()
    {
        List<Sale__c> saleList = [SELECT Id FROM Sale__c];
        Test.setMock(HttpCalloutMock.class, new HDT_UTL_TestMockArricchimento());
        Test.startTest();
            String result = HDT_LC_SaleVas.handleNotMigratedContract('3029109239',saleList[0]);
        Test.stopTest();
        System.assertEquals('Success', result,'Vendita non effettuata correttamente');

    }
    public class HDT_UTL_TestMockArricchimento implements HTTPCalloutMock{

        public HTTPResponse respond(HTTPRequest request){

            HttpResponse response = new HttpResponse();
            String bodyResponse;
            Integer statusCode;

            bodyResponse = '{"status": "success","correlationId": "2a0c1340-f6b5-11eb-bb88-068530f44c42","timestamp": "2021-08-06T14:52:33",'
            +'"data": {"testata": {"esito": "OK"},"posizioni": ['
            +'{"campo": "DATACESSAZIONE","valore": "99991231"},'
            +'{"campo": "ALIQUOTAIVA","valore": "01"},'
            +'{"campo": "CA","valore": "200008867681"},'
            +'{"campo": "DESCRFATTURAZCOLL","valore": "Il contratto può essere fatturato con altri contratti"},'
            +'{"campo": "ANNOFABBRCONT","valore": "2000"},'
            +'{"campo": "CALIBRO1","valore": "GRT003"},'
            +'{"campo": "PRESENZACORRETTORE","valore": "NO"},'
            +'{"campo": "OPZIONE","valore": "E_UD_TDR"},'
            +'{"campo": "MOTIVOBLOCCOCALCOLO","valore": "T1"},'
            +'{"campo": "ACCISE","valore": "0.02270000"},'
            +'{"campo": "CODICE_ATECO","valore": "999999"}'
            +']}}';
            statusCode = 200;

            response.setHeader('Content-Type', 'application/json');
            response.setBody(bodyResponse);
            response.setStatusCode(statusCode);
            response.setStatus('OK');
            return response;
        }
    }
}
