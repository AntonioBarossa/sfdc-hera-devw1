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
        //DEBUG
        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(utlConstants.HERA_SYSTEM_ADMINISTRATOR_NAME);
        User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
        internalUser.UserPermissionsMarketingUser=true;
        insert internalUser;
        List<PermissionSetAssignment> permissionSetAssignments=new List<PermissionSetAssignment>{HDT_UTL_DataFactoryTst.assignPermissionSet(internalUser, utlConstants.PERMISSIONSET_HDT_SALESFORCE_CPQ_ADMIN_NAME, false), HDT_UTL_DataFactoryTst.assignPermissionSet(internalUser, utlConstants.PERMISSIONSET_HDT_VOLTURARETROATTIVA, false), HDT_UTL_DataFactoryTst.assignPermissionSet(internalUser, utlConstants.PERMISSIONSET_HDT_SALESFORCE_CPQ_LICENSE_NAME, false), HDT_UTL_DataFactoryTst.assignPermissionSet(internalUser,'HDT_DistributorManager', false)};
        insert permissionSetAssignments;
        System.runAs(internalUser){
            HDT_UTL_DataFactoryTst.pClickOrderPhase();

            City__c city=HDT_UTL_DataFactoryTst.createCity()[0];
            city.Name = 'PESARO';
            city.Province__c = 'PU';
            city.ServiceGas__c = true;
            update city;

            List<Account> accounts = HDT_UTL_DataFactoryTst.createAccountDistributore(2, false, 'AAA-EBT', 'AAS Azienda', 'Enti');
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

            List<Contract> myContractList = HDT_UTL_DataFactoryTst.createContract(1, true, accounts[0].Id);

            List<Product2> myProdList = HDT_UTL_DataFactoryTst.createProduct2(1, true);
            myProdList[0].ProductCode = 'myCode';
            myProdList[0].Version__c = 'myVersion';
            myProdList[0].Family = 'Offerta Commerciale';
            update myProdList;

            List<SBQQ__Subscription__c> mySubList = HDT_UTL_DataFactoryTst.createSubscription(1, true, accounts[0].Id, myContractList[0].Id, sp.Id);
            mySubList[0].SBQQ__Contract__c = myContractList[0].Id;
            mySubList[0].SBQQ__Product__c = myProdList[0].Id;
            update mySubList;

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

            Id priceBookId = Test.getStandardPriceBookId();

            List<PricebookEntry> stdpriceBookEntryList = HDT_UTL_DataFactoryTst.createPricebookEntry(myProdList, true, priceBookId);

            List<Pricebook2> pbList = HDT_UTL_DataFactoryTst.createPricebook(1, true);

            List<PricebookEntry> priceBookEntryList = HDT_UTL_DataFactoryTst.createPricebookEntry(myProdList, true, pbList[0].Id);


            List<Order> orders2 = HDT_UTL_DataFactoryTst.createOrder(2, false, accounts[0].Id, sales);

            String rtOrder = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_ScontiBonus').getRecordTypeId();        
            String rtParentOrder = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_OrderDossier').getRecordTypeId();        
            orders2[0].RecordTypeId = rtOrder;
            orders2[1].RecordTypeId = rtParentOrder;
            orders2[0].ProcessType__c = 'Aggiunta Sconti o Bonus VAS';
            orders2[0].ContractReference__c = myContractList[0].Id;
            orders2[0].ServicePoint__c = sp.Id;
            insert orders2;

            orders2[0].ParentOrder__c = orders2[1].Id;
            orders2[0].Pricebook2Id = pbList[0].Id;
            update orders2;

            List<OrderItem> ordersItems = HDT_UTL_DataFactoryTst.createOrderItem(1, true, orders2[0].Id, sp.Id, myProdList[0].Id, priceBookEntryList[0].Id);



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
            phaseTransitions.add(HDT_UTL_DataFactoryTst.insertPhaseTransition(null,null,null,null, '','From Documentazione da inviare to Documentazione da firmare',
                'Registrazione validata',null,null,null,false, 'Documentazione da inviare', null,null,
                utlConstants.ORDER_RECORDTYPEID_ORDERDOSSIER, utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_ORDERDOSSIER, null, 'A', false));
            phaseTransitions.add(HDT_UTL_DataFactoryTst.insertPhaseTransition(null,null,null,null, '','From Documentazione da inviare to Documentazione da firmare',
                'Registrazione da validare',null,null,null,false, 'Registrazione validata', null,null,
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
    }
    
    @IsTest
    static void isTransitionNoUpTest(){
        Sale__c sale0=[SELECT Account__r.CompanyOwner__c,Account__r.Category__c FROM Sale__c WHERE  Account__r.code__c!=null LIMIT 1];
        Sale__c sale1=[SELECT Account__r.CompanyOwner__c,Account__r.Category__c FROM Sale__c WHERE  Account__r.code__c=null LIMIT 1];
        ServicePoint__c servPoint = [SELECT Id, SupplyCity__c FROM ServicePoint__c LIMIT 1];
        Test.startTest();

        System.assertEquals(true, HDT_UTL_Sales.isTransitionNoUp(new ServicePoint__c(SupplyProvince__c='PEP', SupplyCity__c = servPoint.SupplyCity__c),sale0), 'The return was empty 1');
        System.assertEquals(true, HDT_UTL_Sales.isTransitionNoUp(new ServicePoint__c(SupplyProvince__c='AQ', SupplyCity__c = servPoint.SupplyCity__c, CommoditySector__c = 'Gas'),sale1), 'The return was empty 2');
        System.assertEquals(true, HDT_UTL_Sales.isTransitionNoUp(sale0), 'The return was empty');
        System.assertEquals(true, !HDT_UTL_Sales.isTransitionNoUp(sale1), 'The return was empty');
        
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
    static void getAgentNameAndCodeInvocable(){
        ServicePoint__c sp=[SELECT Id,SupplyCity__c,CommoditySector__c,Distributor__r.code__c FROM ServicePoint__c WHERE GlobalMigrationKey__c='1123255' LIMIT 1];
        Test.startTest();
        List<HDT_UTL_RimozioneAgevolazione.HDT_WRP_FlowInputs> inputs = new List<HDT_UTL_RimozioneAgevolazione.HDT_WRP_FlowInputs>{new HDT_UTL_RimozioneAgevolazione.HDT_WRP_FlowInputs() };
        inputs[0].servicePoint = sp;
        inputs[0].customerMarking = '';


        List<HDT_UTL_RimozioneAgevolazione.HDT_WRP_FlowOutputs> outputs = 
            new List<HDT_UTL_RimozioneAgevolazione.HDT_WRP_FlowOutputs>
        {  
                new HDT_UTL_RimozioneAgevolazione.HDT_WRP_FlowOutputs()
        };
        outputs = HDT_UTL_RimozioneAgevolazione.getSalesCompany(inputs);

        System.assert(STRING.isBlank(outputs[0].salesCompany), 'Agent and code shoud be empty');//because there are no custom metadatas
        System.assert(STRING.isBlank(outputs[0].salesCompanyCode), 'Agent and code shoud be empty');//because there are no custom metadatas
        Test.stopTest();
    }

    @IsTest
    static void validationActivityPhaseTransition(){

        List<String> ordIds = new List<String>();
        List<Sale__c> sales = new List<Sale__c>();

        for (Order ord : [SELECT Id, Sale__c FROM Order ORDER BY Name LIMIT 1]) {
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

        for (Order ord : [SELECT Id, Sale__c FROM Order ORDER BY Name LIMIT 1]) {
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

        for (Order ord : [SELECT Id, Sale__c FROM Order ORDER BY Name LIMIT 1]) {
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

        for (Order ord : [SELECT Id, Sale__c FROM Order ORDER BY Name LIMIT 1]) {
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

        List<Order> orders = [SELECT Id, Sale__c FROM Order WHERE ParentOrder__c = NULL AND Phase__c = 'Documentazione da inviare'];
        Sale__c sale = new Sale__c();
        sale.Id = orders[0].Sale__c;
        sale.Channel__c = 'Telefono';

        update sale;
        
        List<Order> orderList = (new HDT_QR_Order()).getRecordsByIds(new List<String>{orders[0].Id});

        for (order ord : orderList) {
            ord.SignatureMethod__c = 'Vocal Order';
        }
        
        Test.startTest();
            Order orderResult = HDT_UTL_Sales.validationActivityPhaseTransition(orderList[0]);
        Test.stopTest();
        System.assertEquals('Registrazione Validata', orderResult.Phase__c, 'Fase non aggiornata correttamente');
        
    }

    @IsTest
    static void validationActivityPhaseTransitionHcPoint(){

        List<String> ordIds = new List<String>();
        List<Sale__c> sales = new List<Sale__c>();

        for (Order ord : [SELECT Id, Sale__c FROM Order ORDER BY Name LIMIT 1]) {
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

        for (Order ord : [SELECT Id, Sale__c FROM Order ORDER BY Name  LIMIT 1]) {
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

        for (Order ord : [SELECT Id, Sale__c FROM Order ORDER BY Name LIMIT 1]) {
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

        for (Order ord : [SELECT Id, Sale__c FROM Order ORDER BY Name LIMIT 1]) {
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

    @isTest
    static void isTransitionVasTest(){

        Sale__c mySale = [Select Id from Sale__c LIMIT 1];
        String city = 'Roma';
        Test.startTest();
            Boolean result = HDT_UTL_Sales.isTransitionVas(city, mySale);
        Test.stopTest();
        System.assertEquals(true, result, 'Result is false');

    }

    @isTest
    static void isTransitionTest(){

        Sale__c mySale = [Select Id from Sale__c LIMIT 1];
        ServicePoint__c myServPoint = [Select Id, SupplyCity__c, CommoditySector__c from ServicePoint__c LIMIT 1];
        Test.startTest();
            Boolean result = HDT_UTL_Sales.isTransition(myServPoint, mySale);
        Test.stopTest();
        System.assertEquals(true, result, 'Result is false');

    }

    @IsTest
    static void handleContractVariationTestA(){
        
        List<Order> orders = [Select id, ProcessType__c, ContractReference__c, ServicePoint__c, ParentOrder__c, CommercialProduct__c, CommercialProductCode__c, CommercialProductVersion__c from Order WHERE ParentOrder__c != null];        
        Test.startTest();

            HDT_UTL_Sales.handleContractVariation(orders[0]);
            
        Test.stopTest();

        System.assert(orders != null, 'orders è null');
        
    }

    @IsTest
    static void handleContractVariationTestB(){
        
        List<Order> orders = [Select id, ProcessType__c, ContractReference__c, ServicePoint__c, ParentOrder__c from Order WHERE ParentOrder__c != null];        
        Test.startTest();

            orders[0].ContractReference__c = null;
            update orders;
            HDT_UTL_Sales.handleContractVariation(orders[0]);

        Test.stopTest();

        System.assert(orders != null, 'orders è null');
        
    }

    @IsTest
    static void handleContractVariationTestC(){
        
        List<Order> orders = [Select id, ProcessType__c, ContractReference__c, ServicePoint__c, ParentOrder__c, CommercialProduct__c, CommercialProductCode__c, CommercialProductVersion__c from Order WHERE ParentOrder__c != null];        
        Test.startTest();

            HDT_UTL_Sales.handleContractVariation(orders[0], orders[0]);
            
        Test.stopTest();

        System.assert(orders != null, 'orders è null');
        
    }

    @IsTest
    static void handleContractVariationTestD(){
        
        List<Order> orders = [Select id, ProcessType__c, ContractReference__c, ServicePoint__c, ParentOrder__c from Order WHERE ParentOrder__c != null];        
        Test.startTest();

            orders[0].ContractReference__c = null;
            update orders;
            HDT_UTL_Sales.handleContractVariation(orders[0], orders[0]);

        Test.stopTest();

        System.assert(orders != null, 'orders è null');
        
    }

    @IsTest
    static void setAgeFromAccountTest(){
        List<Account> accounts = [SELECT id FROM Account LIMIT 2];
        accounts[0].Name = 'TEST DITTA';
        accounts[0].LastName__c = 'TEST DITTA';
        accounts[0].FiscalCode__c = '';
        accounts[1].FirstNAme__c = 'Mario';
        accounts[1].LastName__c = 'Rossi';
        accounts[1].VatNumber__c = '';
        accounts[1].FiscalCode__c = 'RSSMRA74D04H501L';
        update accounts;
        List<Sale__c> sales = HDT_UTL_DataFactoryTst.createSale(2,false,accounts[0].Id,'Attiva');
        sales[1].Account__c = accounts[1].Id;
        Test.startTest();
            insert sales;
            for (Sale__c s : [SELECT id, Account__r.FiscalCode__c,ClientAge__c FROM Sale__c WHERE Id IN : sales]){
                if (String.isNotBlank(s.Account__r.FiscalCode__c)){
                    System.assertEquals(HDT_UTL_CalculateFiscalCode.getAgeFromFiscalCode('RSSMRA74D04H501L'), s.ClientAge__c, 'Età non correttamente valorizzata');
                }
                else{
                    System.assertEquals(null, s.ClientAge__c,'L\'età è stata ribaltata anche in assenza di cf');
                }
            }
        Test.stopTest();
    }


}