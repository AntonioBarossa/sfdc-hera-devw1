/**
 * @author Valere (valere@noeli-it.net)
 * @date 13/09/2021
 * @description HDT_UTL_Sales Test Class
 * @history valere - 13/09/2021– Created Class
 */
@IsTest
public class HDT_UTL_SalesTst {

    private static HDT_UTL_Constants utlConstants = new HDT_UTL_Constants();
    private static final String PROCESS_TYPE = 'Cambio offerta - EE';
    private static final String DEPENDENCY_MATCH_AC = 'Account';

    @TestSetup
    static void makeData(){

        City__c city=HDT_UTL_DataFactoryTst.createCity()[0];

        List<Account> accounts = HDT_UTL_DataFactoryTst.createAccountBusiness(2, false, 'AAA-EBT', 'AAS Azienda', 'Enti');
        accounts[0].Code__c = '00';
        accounts[1].Code__c = null;
        accounts[1].Category__C = 'Aziende Soho';
        insert accounts;

        List<Sale__c> sales = HDT_UTL_DataFactoryTst.createSale(1,false,accounts[0].Id,'Attiva');
        sales.addAll(HDT_UTL_DataFactoryTst.createSale(1,false,accounts[1].Id,'Attiva'));
        insert sales;
        
        ServicePoint__c sp = HDT_UTL_DataFactoryTst.createServicePoint(1, false).get(0);
        sp.SupplyCity__c = city.Name;
        sp.Distributor__c = accounts[0].Id;
        sp.GlobalMigrationKey__c = '1123255';
        insert sp;

        List<Order> orders = HDT_UTL_DataFactoryTst.createOrder(2, false, accounts[0].Id, sales);
        orders[0].AccountId = sales[0].Account__c;
        orders[1].AccountId = sales[1].Account__c;
        orders[0].Phase__c = 'Documentazione da inviare';
        orders[1].Phase__c = 'Documentazione da firmare';
        orders[0].Channel__c = 'Teleselling Outbound';
        orders[1].Channel__c = 'Agenzie';
        orders[0].RecordTypeId = utlConstants.ORDER_RECORDTYPEID_ORDERDOSSIER;
        orders[1].RecordTypeId = utlConstants.ORDER_RECORDTYPEID_ORDERDOSSIER;

        orders[0].SignatureMethod__c = 'Vocal Order';
        orders[1].DocumentalPhase__c = 'Plico firmato';

        insert orders;

        // Pclick setup

        wrts_prcgvr.PostInstall postinstall = new wrts_prcgvr.PostInstall();
        Test.testInstall(postinstall, null);

        HDT_UTL_DataFactoryTst.installPhaseManagerSObjectSetting('Order');
        HDT_UTL_DataFactoryTst.installCSDependecyPhaseCheckSetting('Documentazione Gestita');
        HDT_UTL_DataFactoryTst.pClickInstanceActivityIntegration();

        List<wrts_prcgvr__PhaseTransition__c> phaseTransitions = new List<wrts_prcgvr__PhaseTransition__c>();

        phaseTransitions.add(HDT_UTL_DataFactoryTst.insertPhaseTransition(null,null,null,null, '','From Documentazione da firmare to Documentazione Gestita',
            'Documentazione Gestita',null,null,null,false, 'Documentazione da firmare', null,null,
            utlConstants.ORDER_RECORDTYPEID_ORDERDOSSIER, utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_ORDERDOSSIER, null, 'A', false));
        phaseTransitions.add(HDT_UTL_DataFactoryTst.insertPhaseTransition(null,null,null,null, '','From Documentazione da firmare to Documentazione Gestita',
            'Documentazione da validare',null,null,null,false, 'Documentazione da firmare', null,null,
            utlConstants.ORDER_RECORDTYPEID_ORDERDOSSIER, utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_ORDERDOSSIER, null, 'A', false));
        phaseTransitions.add(HDT_UTL_DataFactoryTst.insertPhaseTransition(null,null,null,null, '','From Documentazione da inviare to Documentazione Gestita',
            'Documentazione Gestita',null,null,null,false, 'Documentazione da inviare', null,null,
            utlConstants.ORDER_RECORDTYPEID_ORDERDOSSIER, utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_ORDERDOSSIER, null, 'A', false));
        phaseTransitions.add(HDT_UTL_DataFactoryTst.insertPhaseTransition(null,null,null,null, '','From Documentazione da inviare to Registrazione  da validare',
            'Registrazione  da validare',null,null,null,false, 'Documentazione da inviare', null,null,
            utlConstants.ORDER_RECORDTYPEID_ORDERDOSSIER, utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_ORDERDOSSIER, null, 'A', false));
        phaseTransitions.add(HDT_UTL_DataFactoryTst.insertPhaseTransition(null,null,null,null, '','From Documentazione da inviare to Documentazione da validare',
            'Documentazione da validare',null,null,null,false, 'Documentazione da inviare', null,null,
            utlConstants.ORDER_RECORDTYPEID_ORDERDOSSIER, utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_ORDERDOSSIER, null, 'A', false));
        phaseTransitions.add(HDT_UTL_DataFactoryTst.insertPhaseTransition(null,null,null,null, '','From Documentazione da inviare to Documentazione da firmare',
            'Documentazione da firmare',null,null,null,false, 'Documentazione da inviare', null,null,
            utlConstants.ORDER_RECORDTYPEID_ORDERDOSSIER, utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_ORDERDOSSIER, null, 'A', false));

        insert phaseTransitions;

        List<ServiceRequest__c> serviceRequests = HDT_UTL_DataFactoryTst.createServiceRequest(2, false);

        serviceRequests[0].ServicePoint__c = sp.Id;
        serviceRequests[0].ServicePointCode__c = sp.ServicePointCode__c;
        serviceRequests[1].Order__c = orders[0].Id;
        serviceRequests[0].Type__c = HDT_UTL_Dependencies.TIPOLOGY_SALES;
        serviceRequests[0].Status__c = HDT_UTL_Dependencies.STATUS_BOZZA;
        serviceRequests[0].ProcessType__c = PROCESS_TYPE;

        serviceRequests[1].ServicePoint__c = sp.Id;
        serviceRequests[1].ServicePointCode__c = sp.ServicePointCode__c;
        serviceRequests[1].Order__c = orders[1].Id;
        serviceRequests[1].Type__c = HDT_UTL_Dependencies.TIPOLOGY_SALES;
        serviceRequests[1].Status__c = HDT_UTL_Dependencies.STATUS_BOZZA;
        serviceRequests[1].ProcessType__c = PROCESS_TYPE;

        insert serviceRequests;

    }
    
    @IsTest
    static void isTransitionNoUpTest(){
        Sale__c sale0=[SELECT Account__r.CompanyOwner__c,Account__r.Category__c FROM Sale__c WHERE  Account__r.code__c!=null LIMIT 1];
        Sale__c sale1=[SELECT Account__r.CompanyOwner__c,Account__r.Category__c FROM Sale__c WHERE  Account__r.code__c=null LIMIT 1];
        Test.startTest();

        System.assertEquals(true, HDT_UTL_Sales.isTransitionNoUp(new ServicePoint__c(SupplyProvince__c='PEP'),sale0), 'The return was empty');
        System.assertEquals(true, !HDT_UTL_Sales.isTransitionNoUp(new ServicePoint__c(SupplyProvince__c='AQ'),sale1), 'The return was empty');
        System.assertEquals(true, HDT_UTL_Sales.isTransitionNoUp(sale0), 'The return was empty');
        System.assertEquals(true, !HDT_UTL_Sales.isTransitionNoUp(sale1), 'The return was empty');
        System.assertEquals(true, HDT_UTL_Sales.isTransition(new ServicePoint__c(SupplyProvince__c='PEP'),sale0), 'The return was empty');
        System.assertEquals(true, !HDT_UTL_Sales.isTransition(new ServicePoint__c(SupplyProvince__c='AQ'),sale1), 'The return was empty');
        
        Test.stopTest();
    }

    @IsTest
    static void isWinbackTest(){
        ServicePoint__c sp=[SELECT Id FROM ServicePoint__c WHERE GlobalMigrationKey__c='1123255' LIMIT 1];
        Test.startTest();
        System.assertEquals(!HDT_UTL_Sales.isWinback(sp.Id), true, 'The Sale is not winback');
        Test.stopTest();
    }

    @IsTest
    static void getAgentNameAndCodeListTest(){
        List<ServicePoint__c> serviceList=[SELECT Id,SupplyCity__c,CommoditySector__c,Distributor__r.code__c FROM ServicePoint__c WHERE GlobalMigrationKey__c='1123255'];
        Test.startTest();
        System.assertEquals(true, HDT_UTL_Sales.getAgentNameAndCodeList(serviceList,'').get(serviceList[0].Id)=='', 'Agent shoud be empty');//because there are no custom metadatas
        Test.stopTest();
    }

    @IsTest
    static void getAgentNameAndCodeTest(){
        ServicePoint__c sp=[SELECT Id,SupplyCity__c,CommoditySector__c,Distributor__r.code__c FROM ServicePoint__c WHERE GlobalMigrationKey__c='1123255' LIMIT 1];
        Test.startTest();
        System.assertEquals(true, HDT_UTL_Sales.getAgentNameAndCode(sp,'').get('nomeAgente')=='', 'Agent and code shoud be empty');//because there are no custom metadatas
        System.assertEquals(true, HDT_UTL_Sales.getAgentNameAndCode(sp,'').get('codiceAgente')=='', 'Agent and code shoud be empty');//because there are no custom metadatas
        Test.stopTest();
    }

    @IsTest
    static void validationActivityPhaseTransition(){

        List<String> ordIds = new List<String>();
        List<Sale__c> sales = new List<Sale__c>();

        for (Order ord : [SELECT Id, Sale__c FROM Order ORDER BY Name]) {
            ordIds.add(ord.Id);
            sales.add(new Sale__c(Id = ord.Sale__c, Channel__c = 'Teleselling Outbound'));
        }

        update sales;
        
        List<Order> orders = (new HDT_QR_Order()).getRecordsByIds(ordIds);
        
        Test.startTest();

            System.assertEquals(false, HDT_UTL_Sales.validationActivityPhaseTransition(orders).isEmpty(), 'List of Orders is empty');
            
            orders.get(0).Phase__c = 'Documentazione da inviare';
            System.assertEquals(true, HDT_UTL_Sales.validationActivityPhaseTransition(orders.get(0)) != null, 'The Order was not updated');

        Test.stopTest();
        
    }

    @IsTest
    static void validationActivityPhaseTransitionOtp(){

        List<String> ordIds = new List<String>();
        List<Sale__c> sales = new List<Sale__c>();

        for (Order ord : [SELECT Id, Sale__c FROM Order ORDER BY Name]) {
            ordIds.add(ord.Id);
            sales.add(new Sale__c(Id = ord.Sale__c, Channel__c = 'Teleselling Outbound'));
        }

        update sales;
        
        List<Order> orders = (new HDT_QR_Order()).getRecordsByIds(ordIds);

        for (order ord : orders) {
            ord.SignatureMethod__c = 'OTP Remoto';
        }
        
        Test.startTest();

            System.assertEquals(false, HDT_UTL_Sales.validationActivityPhaseTransition(orders).isEmpty(), 'List of Orders is empty');

            orders.get(0).Phase__c = 'Documentazione da inviare';
            System.assertEquals(true, HDT_UTL_Sales.validationActivityPhaseTransition(orders.get(0)) != null, 'The Order was not updated');

        Test.stopTest();
        
    }

    @IsTest
    static void validationActivityPhaseTransitionAgenzie(){

        List<String> ordIds = new List<String>();
        List<Sale__c> sales = new List<Sale__c>();

        for (Order ord : [SELECT Id, Sale__c FROM Order ORDER BY Name]) {
            ordIds.add(ord.Id);
            sales.add(new Sale__c(Id = ord.Sale__c, Channel__c = 'Agenzie'));
        }

        update sales;
        
        List<Order> orders = (new HDT_QR_Order()).getRecordsByIds(ordIds);

        for (order ord : orders) {
            ord.SignatureMethod__c = 'OTP Remoto';
        }
        
        Test.startTest();

            System.assertEquals(false, HDT_UTL_Sales.validationActivityPhaseTransition(orders).isEmpty(), 'List of Orders is empty');
            
            orders.get(0).Phase__c = 'Documentazione da inviare';
            System.assertEquals(true, HDT_UTL_Sales.validationActivityPhaseTransition(orders.get(0)) != null, 'The Order was not updated');

        Test.stopTest();
        
    }

    @IsTest
    static void validationActivityPhaseTransitionBusinessAgent(){

        List<String> ordIds = new List<String>();
        List<Sale__c> sales = new List<Sale__c>();

        for (Order ord : [SELECT Id, Sale__c FROM Order ORDER BY Name]) {
            ordIds.add(ord.Id);
            sales.add(new Sale__c(Id = ord.Sale__c, Channel__c = 'Agenzie'));
        }

        update sales;
        
        List<Order> orders = (new HDT_QR_Order()).getRecordsByIds(ordIds);

        for (order ord : orders) {
            ord.SignatureMethod__c = 'Cartacea';
        }
        
        Test.startTest();

            System.assertEquals(false, HDT_UTL_Sales.validationActivityPhaseTransition(orders).isEmpty(), 'List of Orders is empty');
            
            orders.get(0).Phase__c = 'Documentazione da inviare';
            System.assertEquals(true, HDT_UTL_Sales.validationActivityPhaseTransition(orders.get(0)) != null, 'The Order was not updated');

        Test.stopTest();
        
    }

    @IsTest
    static void validationActivityPhaseTransitionTelefono(){

        List<String> ordIds = new List<String>();
        List<Sale__c> sales = new List<Sale__c>();

        for (Order ord : [SELECT Id, Sale__c FROM Order ORDER BY Name]) {
            ordIds.add(ord.Id);
            sales.add(new Sale__c(Id = ord.Sale__c, Channel__c = 'Telefono'));
        }

        update sales;
        
        List<Order> orders = (new HDT_QR_Order()).getRecordsByIds(ordIds);

        for (order ord : orders) {
            ord.SignatureMethod__c = 'Vocal Order';
        }
        
        Test.startTest();

            System.assertEquals(false, HDT_UTL_Sales.validationActivityPhaseTransition(orders).isEmpty(), 'List of Orders is empty');
            
            orders.get(0).Phase__c = 'Documentazione da inviare';
            System.assertEquals(true, HDT_UTL_Sales.validationActivityPhaseTransition(orders.get(0)) != null, 'The Order was not updated');

        Test.stopTest();
        
    }

    @IsTest
    static void validationActivityPhaseTransitionHcPoint(){

        List<String> ordIds = new List<String>();
        List<Sale__c> sales = new List<Sale__c>();

        for (Order ord : [SELECT Id, Sale__c FROM Order ORDER BY Name]) {
            ordIds.add(ord.Id);
            sales.add(new Sale__c(Id = ord.Sale__c, Channel__c = 'HC Point'));
        }

        update sales;
        
        List<Order> orders = (new HDT_QR_Order()).getRecordsByIds(ordIds);

        for (order ord : orders) {
            ord.SignatureMethod__c = 'OTP Remoto';
        }
        
        Test.startTest();

            System.assertEquals(false, HDT_UTL_Sales.validationActivityPhaseTransition(orders).isEmpty(), 'List of Orders is empty');
            
            orders.get(0).Phase__c = 'Documentazione da inviare';
            System.assertEquals(true, HDT_UTL_Sales.validationActivityPhaseTransition(orders.get(0)) != null, 'The Order was not updated');

        Test.stopTest();
        
    }

    @IsTest
    static void validationActivityPhaseTransitionHcPointCartacea(){

        List<String> ordIds = new List<String>();
        List<Sale__c> sales = new List<Sale__c>();

        for (Order ord : [SELECT Id, Sale__c FROM Order ORDER BY Name]) {
            ordIds.add(ord.Id);
            sales.add(new Sale__c(Id = ord.Sale__c, Channel__c = 'HC Point'));
        }

        update sales;
        
        List<Order> orders = (new HDT_QR_Order()).getRecordsByIds(ordIds);

        for (order ord : orders) {
            ord.SignatureMethod__c = 'Cartacea';
        }
        
        Test.startTest();

            System.assertEquals(false, HDT_UTL_Sales.validationActivityPhaseTransition(orders).isEmpty(), 'List of Orders is empty');
            
            orders.get(0).Phase__c = 'Documentazione da inviare';
            System.assertEquals(true, HDT_UTL_Sales.validationActivityPhaseTransition(orders.get(0)) != null, 'The Order was not updated');

        Test.stopTest();
        
    }

    @IsTest
    static void validationActivityPhaseTransitionVenditaCondomini(){

        List<String> ordIds = new List<String>();
        List<Sale__c> sales = new List<Sale__c>();

        for (Order ord : [SELECT Id, Sale__c FROM Order ORDER BY Name]) {
            ordIds.add(ord.Id);
            sales.add(new Sale__c(Id = ord.Sale__c, Channel__c = 'Vendita Condomini'));
        }

        update sales;
        
        List<Order> orders = (new HDT_QR_Order()).getRecordsByIds(ordIds);

        for (order ord : orders) {
            ord.SignatureMethod__c = 'OTP Remoto';
        }
        
        Test.startTest();

            System.assertEquals(false, HDT_UTL_Sales.validationActivityPhaseTransition(orders).isEmpty(), 'List of Orders is empty');
            
            orders.get(0).Phase__c = 'Documentazione da inviare';
            System.assertEquals(true, HDT_UTL_Sales.validationActivityPhaseTransition(orders.get(0)) != null, 'The Order was not updated');

        Test.stopTest();
        
    }

    @IsTest
    static void validationActivityPhaseTransitionBackOffice(){

        List<String> ordIds = new List<String>();
        List<Sale__c> sales = new List<Sale__c>();

        for (Order ord : [SELECT Id, Sale__c FROM Order ORDER BY Name]) {
            ordIds.add(ord.Id);
            sales.add(new Sale__c(Id = ord.Sale__c, Channel__c = 'Back office'));
        }

        update sales;
        
        List<Order> orders = (new HDT_QR_Order()).getRecordsByIds(ordIds);

        for (order ord : orders) {
            ord.SignatureMethod__c = 'OTP Remoto';
        }
        
        Test.startTest();

            System.assertEquals(false, HDT_UTL_Sales.validationActivityPhaseTransition(orders).isEmpty(), 'List of Orders is empty');
            
            orders.get(0).Phase__c = 'Documentazione da inviare';
            System.assertEquals(true, HDT_UTL_Sales.validationActivityPhaseTransition(orders.get(0)) != null, 'The Order was not updated');

        Test.stopTest();
        
    }

    @IsTest
    static void validationActivityPhaseTransitionSingle(){

        List<String> ordIds = new List<String>{[SELECT Id FROM Order WHERE Phase__c = 'Documentazione da firmare' LIMIT 1].Id};

        List<Order> orders = (new HDT_QR_Order()).getRecordsByIds(ordIds);
        
        Test.startTest();

            System.assertEquals(true, HDT_UTL_Sales.validationActivityPhaseTransition(orders.get(0)) != null, 'The Order was not updated');

        Test.stopTest();
        
    }

    @IsTest
    static void validationActivityPhaseTransitionDocumentoDaFirmare(){

        List<String> ordIds = new List<String>();
        List<Sale__c> sales = new List<Sale__c>();

        for (Order ord : [SELECT Id, Sale__c FROM Order WHERE Phase__c = 'Documentazione da firmare' ORDER BY Name]) {
            ordIds.add(ord.Id);
            sales.add(new Sale__c(Id = ord.Sale__c, Channel__c = 'Agenzie'));
        }

        update sales;
        
        List<Order> orders = (new HDT_QR_Order()).getRecordsByIds(ordIds);

        for (order ord : orders) {
            ord.SignatureMethod__c = 'OTP Remoto';
            ord.DocumentalPhase__c = 'Plico firmato';
        }
        
        Test.startTest();

            System.assertEquals(true, HDT_UTL_Sales.validationActivityPhaseTransition(orders.get(0)) != null, 'The Order was not updated');

        Test.stopTest();
        
    }

}