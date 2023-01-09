@isTest
public with sharing class HDT_UTL_ProcessDateManagerTst {

    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();
	
	@TestSetup
    static void setup(){
        
        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
        User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
        internalUser.UserPermissionsMarketingUser=true;
        insert internalUser;

        HDT_UTL_DataFactoryTst.assignPermissionSet(internalUser, constants.PERMISSIONSET_HDT_ENABLECREDITCHECK, true);
 
        System.runAs(internalUser) {
 
            List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(2, false, 'HERA COMM', 'Azienda', 'Aziende SME');
            accList[0].SatisfactionIndexCtrl__c = 1.0;
            accList[0].PraxidiaUpdateDate__c = Date.newInstance(2021, 09, 14);
            insert accList;

/*             List<Account> accListResidenziale = HDT_UTL_DataFactoryTst.createAccountResidenziale(2, false, 'HERA COMM', 'D1 - Persona fisica', 'Enti');
            insert accListResidenziale; */

            List<Account> myAccountResidenzialeList = new List<Account>();
            Account myAccountResidenziale = new Account();
            id accountResidenziale=constants.ACCOUNT_RECORDTYPEID_RESINDEZIALE;
            myAccountResidenziale.RecordTypeId = accountResidenziale;
            myAccountResidenziale.Name = 'Test Residenziale';
            myAccountResidenziale.CompanyOwner__c = 'MMS';
            myAccountResidenziale.CustomerMarking__c = 'G1 - MMS Persona fisica';
            myAccountResidenziale.Category__c = 'Famiglie';
            myAccountResidenziale.BillingCityCode__c='Roma';
			myAccountResidenziale.BillingStreetName__c='via roma';
			myAccountResidenziale.BillingStreetNumber__c='55';
            myAccountResidenziale.FiscalCode__c = 'PMOPPP21M18E507H';
            myAccountResidenziale.IsWrongFiscalData__c = false;
        	myAccountResidenziale.BillingIsAddressVerified__c = true;
            myAccountResidenzialeList.add(myAccountResidenziale);
            insert myAccountResidenzialeList;

            List<BillingProfile__c> bpList = HDT_UTL_DataFactoryTst.createBillingProfile(1, true, accList[0].Id);
            List<Contact> cttList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].Id);
            List<ServicePoint__c> spList = HDT_UTL_DataFactoryTst.createServicePoint(2, false);
            spList[0].CommoditySector__c = 'Energia Elettrica';
            spList[0].SupplyType__c = 'Domestico';
            spList[0].ImplantType__c = '13A0-Usi di Abitazione BT';
            spList[0].Account__c = accList[0].Id;
            spList[1].CommoditySector__c = 'Gas';
            insert spList;

            List<Order> orderList = HDT_UTL_DataFactoryTst.createOrder(1, false, accList[0].Id, 'Bozza');
            orderList[0].PraxidiaOverrallSatisfaction__c = 2.0;
            orderList[0].PraxidiaDateOutcome__c = Date.newInstance(2020, 08, 10);
            orderList[0].isTransition__c = true;
            orderList[0].RecordTypeId = constants.ORDER_RECORDTYPEID_ORDERDOSSIER;
            orderList[0].AgencyCode__c = 'AgencyCode';
            orderList[0].WizardCompletedDate__c = Date.today();
            orderList[0].Contact__c = cttList[0].Id;
            orderList[0].DocumentPackage__c = 'Validato';
            orderList[0].QualityCall__c = true;
            orderList[0].SignedDate__c = Date.today().addDays(-7);
            orderList[0].ServicePoint__c = spList[0].Id;
            orderList[0].BillingProfile__c = bpList[0].Id;
            orderList[0].SapContractCode__c = '123456';
            orderList[0].TecnicalPhase__c = 'Bozza';
            orderList[0].DateSentToSII__c = System.today();
            orderList[0].Name = 'testOrderName0';
            orderList[0].Phase__c = 'Documentazione Gestita';
            insert orderList;

            List<Sale__c> sales = HDT_UTL_DataFactoryTst.createSale(1, false, accList[0].Id, 'Bozza');
            sales[0].isTransition__c = true;
            insert sales;
            
            List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, false, accList[0].Id);
            insert contractList;

            List<Order> childOrders = HDT_UTL_DataFactoryTst.createChildOrder(4, false, accList[0].Id, sales, orderList[0].Id, cttList[0].Id);
            childOrders[0].Name = 'childOrder0';
            childOrders[0].RecordTypeId = constants.ORDER_RECORDTYPEID_VOLTURA;
            childOrders[0].ContractReference__c = contractList[0].Id;
            childOrders[0].CreditCheckDescription__c = 'Cattivo pagatore C';
            childOrders[0].Phase__c = 'Credit Check KO';
            childOrders[0].IncomingCreditCheckResult__c='OK';
            childOrders[0].ProcessType__c = 'Switch in Fittizio';
            childOrders[0].ServicePoint__c = spList[0].Id;
            childOrders[0].isTransition__c = true;
            childOrders[0].IsMassive__c = true;
            childOrders[0].ParentOrder__c = orderList[0].Id;
            childOrders[0].Channel__c='Back office';
            childOrders[0].Market__c='Libero';
            childOrders[0].MarketOrigin__c='Libero';
            childOrders[0].SupplyType__c = 'Domestico';
            childOrders[0].CustomerCategory__c='Famiglie';
            childOrders[0].SignatureMethod__c='Cartacea';
            childOrders[0].DocSendingMethod__c='Stampa Cartacea';
            childOrders[0].VoltageLevel__c='MT';
            childOrders[0].IsActivationDeferred__c =true;
            childOrders[0].EffectiveDate__c = System.Today();
            childOrders[0].DateSentToSII__c=System.Today();
            childOrders[1].Name = 'childOrder1';
            childOrders[1].SignedDate__c = Date.today().addDays(-7);
            childOrders[1].ProcessType__c = 'Switch In Fittizio';
            childOrders[1].WaiverRightAfterthought__c = 'No';
            childOrders[1].IsEarlyActivation__c = false;
            childOrders[1].MaxAfterthoughtDate__c = Date.today().addDays(+7);
            childOrders[1].AccountId = myAccountResidenzialeList[0].Id;
            childOrders[2].Name = 'childOrder2';
            childOrders[2].RecordTypeId = constants.ORDER_RECORDTYPEID_VOLTURA;
            childOrders[2].ContractReference__c = contractList[0].Id;
            childOrders[2].CreditCheckDescription__c = 'Cattivo pagatore C';
            childOrders[2].Phase__c = 'Credit Check KO';
            childOrders[2].IncomingCreditCheckResult__c='OK';
            childOrders[2].ProcessType__c = 'Switch in Fittizio';
            childOrders[2].ServicePoint__c = spList[1].Id;
            childOrders[2].isTransition__c = true;
            childOrders[2].IsMassive__c = true;
            childOrders[2].ParentOrder__c = orderList[0].Id;
            childOrders[2].Channel__c='Back office';
            childOrders[2].Market__c='Libero';
            childOrders[2].MarketOrigin__c='Libero';
            childOrders[2].SupplyType__c = 'Domestico';
            childOrders[2].CustomerCategory__c='Famiglie';
            childOrders[2].SignatureMethod__c='Cartacea';
            childOrders[2].DocSendingMethod__c='Stampa Cartacea';
            childOrders[2].VoltageLevel__c='MT';
            childOrders[2].IsActivationDeferred__c =false;
            childOrders[2].EffectiveDate__c = System.Today();
            childOrders[2].DateSentToSII__c=System.Today();
            insert childOrders;

            List<AgentMatrix__c> agMatrixList = HDT_UTL_DataFactoryTst.createAgentMatrix(1, false, 'Telefono');
            agMatrixList[0].AgencyCode__c = 'AgencyCode';
            agMatrixList[0].IsMonitoring__c = true;
            insert agMatrixList;

        }
    }

    @isTest
    public static void testIsAfterthoughtDaysZero() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){

            List<Order> orders = [SELECT Id, Phase__c, Channel__c, Market__c, CustomerCategory__c, SignatureMethod__c, DocSendingMethod__c FROM Order WHERE Name = 'childOrder0'];

            Test.startTest();
            
            Boolean result = HDT_UTL_ProcessDateManager.isAfterthoughtDaysZero(orders[0]);

            Test.stopTest();
            
            List<HDT_AfterthoughtDays__mdt> afterthoughtDays = [SELECT AfterthoughtDays__c FROM HDT_AfterthoughtDays__mdt WHERE Channel__c =: orders[0].Channel__c AND Market__c =: orders[0].Market__c AND AccountType__c =: orders[0].CustomerCategory__c AND SignatureMode__c =: orders[0].SignatureMethod__c AND DocumentSendingMode__c =: orders[0].DocSendingMethod__c];

            System.assertEquals(result, afterthoughtDays[0].AfterthoughtDays__c == 0, 'AfterthoughtDays__c not correct');

        }
    }

    @isTest
    public static void testHandleBusinessDate() {

        List<Order> orders = [SELECT Id,DateSentToSII__c, Phase__c, SignedDate__c, RecessNotice__c,EffectiveDate__c,CommodityFormula__c,MarketOrigin__c,SupplyType__c,VoltageLevel__c, ClientCategoryFormula__c, DocumentalProcessType__c, IsActivationDeferred__c, Channel__c, Market__c, CustomerCategory__c, SignatureMethod__c, DocSendingMethod__c,WizardCompletedDate__c FROM Order WHERE Name = 'childOrder0'];

        Test.startTest();
        
        HDT_UTL_ProcessDateManager.handleBusinessDate(orders);

        Test.stopTest();

        System.assertEquals(true, !orders.isEmpty(), 'RecessNotice__c not correct');

    }

    @isTest
    public static void testSetEffectiveDate() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){

            List<Order> orders = [SELECT Id, Phase__c,DateSentToSII__c, SignedDate__c, RecessNotice__c,EffectiveDate__c,CommodityFormula__c,MarketOrigin__c,SupplyType__c,VoltageLevel__c, ClientCategoryFormula__c, DocumentalProcessType__c, IsActivationDeferred__c, Channel__c, Market__c, CustomerCategory__c, SignatureMethod__c, DocSendingMethod__c FROM Order WHERE Name = 'childOrder0'];

            FulfillmentDateMatrix__c matrixDate = new FulfillmentDateMatrix__c();
			matrixDate.OriginMarket__c = orders[0].MarketOrigin__c;
			matrixDate.Commodity__c = orders[0].CommodityFormula__c;
			matrixDate.VoltageLevel__c = orders[0].VoltageLevel__c;
			matrixDate.ProcessType__c = orders[0].DocumentalProcessType__c;
			matrixDate.SupplyType__c = orders[0].SupplyType__c; 
            matrixDate.ActivationDate__c = System.Today();
            matrixDate.FulfillmentDateTo__c = System.Today()+1;
            matrixDate.FulfillmentDateFrom__c  = System.Today();
            insert matrixDate;
            
            Test.startTest();
            
            HDT_UTL_ProcessDateManager.setEffectiveDate(orders);

            Test.stopTest();

            System.assertEquals(orders[0].EffectiveDate__c, matrixDate.ActivationDate__c, 'EffectiveDate__c not correct');

        }
    }

    @isTest
    public static void testSetEffectiveDateGas() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){

            List<Order> orders = [SELECT Id, Phase__c,DateSentToSII__c, SignedDate__c, RecessNotice__c,EffectiveDate__c,CommodityFormula__c,MarketOrigin__c,
                                SupplyType__c,VoltageLevel__c, ClientCategoryFormula__c, DocumentalProcessType__c, IsActivationDeferred__c, Channel__c, 
                                Market__c, CustomerCategory__c, SignatureMethod__c, DocSendingMethod__c FROM Order WHERE Name = 'childOrder2'];

            FulfillmentDateMatrix__c matrixDate = new FulfillmentDateMatrix__c();
			matrixDate.OriginMarket__c = orders[0].MarketOrigin__c;
			matrixDate.Commodity__c = orders[0].CommodityFormula__c;
			matrixDate.VoltageLevel__c = orders[0].VoltageLevel__c;
			matrixDate.ProcessType__c = orders[0].DocumentalProcessType__c;
			matrixDate.SupplyType__c = orders[0].SupplyType__c; 
            matrixDate.ActivationDate__c = System.Today();
            matrixDate.FulfillmentDateTo__c = System.Today()+1;
            matrixDate.FulfillmentDateFrom__c  = System.Today();
            insert matrixDate;
            
            Test.startTest();
            
            HDT_UTL_ProcessDateManager.setEffectiveDate(orders);

            Test.stopTest();

            System.assertEquals(orders[0].EffectiveDate__c, matrixDate.ActivationDate__c, 'EffectiveDate__c not correct');

        }
    }

    @isTest
    public static void testSetDateSentToSiiBusiness() {
        List<Order> orders = [SELECT Id, Phase__c,DateSentToSII__c, SignedDate__c, RecessNotice__c,EffectiveDate__c,CommodityFormula__c,MarketOrigin__c,SupplyType__c,VoltageLevel__c, ClientCategoryFormula__c, DocumentalProcessType__c, IsActivationDeferred__c, Channel__c, Market__c, CustomerCategory__c, SignatureMethod__c, DocSendingMethod__c,WizardCompletedDate__c FROM Order WHERE Name = 'childOrder0'];

        FulfillmentDateMatrix__c matrixDate = new FulfillmentDateMatrix__c();
        matrixDate.OriginMarket__c = orders[0].MarketOrigin__c;
        matrixDate.Commodity__c = orders[0].CommodityFormula__c;
        matrixDate.VoltageLevel__c = orders[0].VoltageLevel__c;
        matrixDate.ProcessType__c = orders[0].DocumentalProcessType__c;
        matrixDate.SupplyType__c = orders[0].SupplyType__c;
        matrixDate.ActivationDate__c = System.Today();
        matrixDate.FulfillmentDateTo__c = System.Today()+1;
        matrixDate.FulfillmentDateFrom__c  = System.Today();
        insert matrixDate;
        
        Test.startTest();
        
        HDT_UTL_ProcessDateManager.setDateSentToSiiBusiness(orders);

        Test.stopTest();

        Date targetDate = matrixDate.FulfillmentDateFrom__c;
        Integer preavviso = orders[0].RecessNotice__c != null? (Integer)orders[0].RecessNotice__c : 0 ;
        Integer month = 1 - preavviso;
        Date siiDate = targetDate;

        System.assertEquals(true, !orders.isEmpty(), 'DateSentToSII__c not correct');

    }

    @isTest
    public static void testSetDateSentToSiiBusinessGas() {
 
        List<Order> orders = [SELECT Id, Phase__c,DateSentToSII__c, SignedDate__c, RecessNotice__c,EffectiveDate__c,CommodityFormula__c,
                            MarketOrigin__c,SupplyType__c,VoltageLevel__c, ClientCategoryFormula__c, DocumentalProcessType__c,
                            IsActivationDeferred__c, Channel__c, Market__c, CustomerCategory__c, SignatureMethod__c, DocSendingMethod__c,WizardCompletedDate__c
                            FROM Order WHERE Name = 'childOrder2'];

        FulfillmentDateMatrix__c matrixDate = new FulfillmentDateMatrix__c();
        matrixDate.OriginMarket__c = orders[0].MarketOrigin__c;
        matrixDate.Commodity__c = orders[0].CommodityFormula__c;
        matrixDate.VoltageLevel__c = orders[0].VoltageLevel__c;
        matrixDate.ProcessType__c = orders[0].DocumentalProcessType__c;
        matrixDate.SupplyType__c = orders[0].SupplyType__c;
        matrixDate.ActivationDate__c = System.Today();
        matrixDate.FulfillmentDateTo__c = System.Today()+1;
        matrixDate.FulfillmentDateFrom__c  = System.Today();
        insert matrixDate;
        
        Test.startTest();
        
        HDT_UTL_ProcessDateManager.setDateSentToSiiBusiness(orders);

        Test.stopTest();

        Date targetDate = matrixDate.FulfillmentDateFrom__c;
        Integer preavviso = orders[0].RecessNotice__c != null? (Integer)orders[0].RecessNotice__c : 0 ;
        Integer month = 1 - preavviso;
        Date siiDate = targetDate;

        System.assertEquals(orders[0].DateSentToSII__c, siiDate, 'DateSentToSII__c not correct');
    }

    @isTest
    public static void testSetDateSentToSiiResidenziale() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){

            List<Order> orders = [SELECT DateSentToSII__c,SignedDate__c,WaiverRightAfterthought__c,ProcessType__c,WizardCompletedDate__c,
                                MaxAfterthoughtDate__c, IsEarlyActivation__c, Account.RecordType.DeveloperName
                                FROM Order WHERE Name = 'childOrder1'];
            
            Test.startTest();

            HDT_UTL_ProcessDateManager.setDateSentToSii(orders);

            Test.stopTest();

            System.assertEquals(orders[0].DateSentToSII__c, orders[0].MaxAfterthoughtDate__c.addDays(1), 'DateSentToSII__c not correct');
        }
    }

    @isTest
    public static void testCalculateOrderProcessDate() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){

            List<Order> orders = [SELECT DateSentToSII__c,SignedDate__c,WaiverRightAfterthought__c,ProcessType__c,WizardCompletedDate__c,
                                MaxAfterthoughtDate__c, IsEarlyActivation__c, Account.RecordType.DeveloperName, Channel__c, Market__c,
                                CustomerCategory__c, SignatureMethod__c, DocSendingMethod__c, DocumentalProcessType__c, MarketOrigin__c,
                                CommodityFormula__c, VoltageLevel__c, SupplyType__c, IsActivationDeferred__c,IsTransition__c
                                FROM Order WHERE Name = 'childOrder1'];
            
            Test.startTest();

            HDT_UTL_ProcessDateManager.calculateOrderProcessDate(orders);

            Test.stopTest();

            System.assertEquals(true, orders[0].MaxAfterthoughtDate__c != null, ' not correct');
        }
    }


}