/**
 * @author Lucas da Silva Fernandes (lucas.dasilva@engdb.com.br)
 * @date 14/09/2021
 * @description HDT_UTL_OrderProcess Test Class
 * @history Lucas da Silva Fernandes – 14/09/2021 – Created Class
 */
@isTest
public with sharing class HDT_UTL_OrderProcessTst {

    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();
	
	@TestSetup
    static void setup(){
        
        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
        User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
        internalUser.UserPermissionsMarketingUser=true;
        insert internalUser;

        HDT_UTL_DataFactoryTst.assignPermissionSet(internalUser, constants.PERMISSIONSET_HDT_ENABLECREDITCHECK, true);
 
        System.runAs(internalUser) {

            HDT_UTL_DataFactoryTst.pClickInstance();
            HDT_UTL_DataFactoryTst.pClickOrderPhase();
            HDT_UTL_DataFactoryTst.createWebServiceConfiguration('CreditCheck', 'endpoint', 'POST', 'user');
            HDT_UTL_DataFactoryTst.createWebServiceCredential('user', 'password', 'user');
            HDT_UTL_DataFactoryTst.newPhaseTransition('Documentazione validata', 'Bozza', constants.ORDER_RECORDTYPEID_CAMBIO_OFFERTA, 'HDT_RT_CambioOfferta');
            HDT_UTL_DataFactoryTst.newPhaseTransition('Documentazione validata', 'Bozza', constants.ORDER_RECORDTYPEID_VAS, 'HDT_RT_VAS');
            HDT_UTL_DataFactoryTst.newPhaseTransition('Comunicazione Verso Heroku', 'Documentazione validata', constants.ORDER_RECORDTYPEID_CAMBIO_OFFERTA, 'HDT_RT_CambioOfferta');
            HDT_UTL_DataFactoryTst.newPhaseTransition('Documentazione validata', 'Esportazione VS Siebel', constants.ORDER_RECORDTYPEID_CAMBIO_OFFERTA, 'HDT_RT_CambioOfferta');
            HDT_UTL_DataFactoryTst.newPhaseTransition('Comunicazione verso Heroku', 'Esportazione VS Siebel', constants.ORDER_RECORDTYPEID_CAMBIO_OFFERTA, 'HDT_RT_CambioOfferta');
            HDT_UTL_DataFactoryTst.newPhaseTransition('Esportazione VS Siebel', 'Comunicazione verso Heroku', constants.ORDER_RECORDTYPEID_CAMBIO_OFFERTA, 'HDT_RT_CambioOfferta');
            HDT_UTL_DataFactoryTst.newPhaseTransition('Comunicazione verso Heroku', 'Bozza', constants.ORDER_RECORDTYPEID_CAMBIO_OFFERTA, 'HDT_RT_CambioOfferta');
            HDT_UTL_DataFactoryTst.newPhaseTransition('In attesa di quality call', 'Bozza', constants.ORDER_RECORDTYPEID_CAMBIO_OFFERTA, 'HDT_RT_CambioOfferta');
            HDT_UTL_DataFactoryTst.newPhaseTransition('Quality Call OK', 'In attesa di quality call', constants.ORDER_RECORDTYPEID_CAMBIO_OFFERTA, 'HDT_RT_CambioOfferta');
            HDT_UTL_DataFactoryTst.newPhaseTransition('Quality Call OK', 'Bozza', constants.ORDER_RECORDTYPEID_CAMBIO_OFFERTA, 'HDT_RT_CambioOfferta');
            HDT_UTL_DataFactoryTst.newPhaseTransition('Esportazione VS Siebel', 'Documentazione Validata', constants.ORDER_RECORDTYPEID_CAMBIO_OFFERTA, 'HDT_RT_CambioOfferta');
            HDT_UTL_DataFactoryTst.newPhaseTransition('Esportazione VS Siebel', 'Documentazione Validata', constants.ORDER_RECORDTYPEID_ORDERDOSSIER, 'HDT_RT_OrderDossier');
            HDT_UTL_DataFactoryTst.newPhaseTransition('Esportazione VS Siebel', 'Documentazione Validata', constants.ORDER_RECORDTYPEID_VOLTURA, 'HDT_RT_Voltura');
            HDT_UTL_DataFactoryTst.newPhaseTransition('Documentazione Gestita', 'Bozza', constants.ORDER_RECORDTYPEID_ORDERDOSSIER, 'HDT_RT_OrderDossier');
            HDT_UTL_DataFactoryTst.newPhaseTransition('Documentazione Validata', 'In attesa validazione', constants.ORDER_RECORDTYPEID_VOLTURA, 'HDT_RT_Voltura');
            HDT_UTL_DataFactoryTst.newPhaseTransition('In attesa validazione', 'Da Inviare', constants.ORDER_RECORDTYPEID_VOLTURA, 'HDT_RT_Voltura');
            HDT_UTL_DataFactoryTst.newPhaseTransition('Completata', 'Bozza', constants.ORDER_RECORDTYPEID_CAMBIO_OFFERTA, 'HDT_RT_OrderDossier');
            HDT_UTL_DataFactoryTst.newPhaseTransition('Completata', 'Bozza', constants.ORDER_RECORDTYPEID_VAS, 'HDT_RT_VAS');
            HDT_UTL_DataFactoryTst.newPhaseTransition('Documentazione Gestita', 'Bozza', constants.ORDER_RECORDTYPEID_CAMBIO_OFFERTA, 'HDT_RT_CambioOfferta');
            HDT_UTL_DataFactoryTst.newPhaseTransition('Comunicazione Motore VAS', 'Documentazione Validata', constants.ORDER_RECORDTYPEID_VAS, 'HDT_RT_Voltura');
            HDT_UTL_DataFactoryTst.newPhaseTransition('In attesa tempi di ripensamento', 'Comunicazione Motore VAS', constants.ORDER_RECORDTYPEID_VAS, 'HDT_RT_Voltura');
            HDT_UTL_DataFactoryTst.newPhaseTransition('Comunicazione verso Heroku', 'Esportazione VS Siebel', constants.ORDER_RECORDTYPEID_VOLTURA, 'HDT_RT_Voltura');
            HDT_UTL_DataFactoryTst.newPhaseTransition('Comunicazione verso Heroku', 'Esportazione VS Siebel', constants.ORDER_RECORDTYPEID_SUBENTRO, 'HDT_RT_Default');
            HDT_UTL_DataFactoryTst.newPhaseTransition('Documentazione Validata', 'In attesa validazione', constants.ORDER_RECORDTYPEID_SUBENTRO, 'HDT_RT_Default');
            HDT_UTL_DataFactoryTst.newPhaseTransition('Esportazione VS Siebel', 'Documentazione Validata', constants.ORDER_RECORDTYPEID_SUBENTRO, 'HDT_RT_Default');

            List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(2, false, 'HERA COMM', 'Azienda', 'Aziende SME');
            accList[0].SatisfactionIndexCtrl__c = 1.0;
            accList[0].PraxidiaUpdateDate__c = Date.newInstance(2021, 09, 14);
            insert accList;

            List<BillingProfile__c> bpList = HDT_UTL_DataFactoryTst.createBillingProfile(1, true, accList[0].Id);
            List<Contact> cttList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].Id);
            List<ServicePoint__c> spList = HDT_UTL_DataFactoryTst.createServicePoint(1, false);
            spList[0].CommoditySector__c = 'Energia Elettrica';
            spList[0].SupplyType__c = 'Domestico';
            spList[0].ImplantType__c = '13Z0-Grossisti';
            spList[0].Account__c = accList[0].Id;
            insert spList;

            List<Order> orderList = HDT_UTL_DataFactoryTst.createOrder(1, false, accList[0].Id, 'Bozza');
            orderList[0].PraxidiaOverrallSatisfaction__c = 2.0;
            orderList[0].PraxidiaDateOutcome__c = Date.newInstance(2020, 08, 10);
            orderList[0].isTransition__c = true;
            orderList[0].RecordTypeId = constants.ORDER_RECORDTYPEID_CAMBIO_OFFERTA;
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
            insert orderList;

            List<Sale__c> sales = HDT_UTL_DataFactoryTst.createSale(1, false, accList[0].Id, 'Bozza');
            sales[0].isTransition__c = true;
            insert sales;

            List<Order> childOrders = HDT_UTL_DataFactoryTst.createChildOrder(4, false, accList[0].Id, sales, orderList[0].Id, cttList[0].Id);
            childOrders[0].Name = 'childOrder0';
            childOrders[0].Phase__c = 'Documentazione Validata';
            childOrders[0].CreditCheckDescription__c = 'Saldo debito cattivo pagatore A';
            childOrders[0].IncomingCreditCheckResult__c = 'OK';
            childOrders[1].Name = 'childOrder1';
            childOrders[1].Phase__c = 'In attesa validazione';
            childOrders[1].CreditCheckDescription__c = '';
            childOrders[2].Name = 'childOrder2';
            childOrders[2].Phase__c = 'Da Inviare';
            childOrders[3].Name = 'childOrder3';
            childOrders[3].RecordTypeId = constants.ORDER_RECORDTYPEID_VAS;
            childOrders[3].ProcessType__c = 'VAS';
            childOrders[3].VASType__c = 'VAS Servizio';
            childOrders[3].CreditCheckDescription__c = 'Cattivo pagatore C';
            insert childOrders;

            List<AgentMatrix__c> agMatrixList = HDT_UTL_DataFactoryTst.createAgentMatrix(1, false, 'Telefono');
            agMatrixList[0].AgencyCode__c = 'AgencyCode';
            agMatrixList[0].IsMonitoring__c = true;
            insert agMatrixList;

            List<wrts_prcgvr__Activity__c> actList = HDT_UTL_DataFactoryTst.createActivityCustom(4, false, accList[0].Id);
            actList[0].Order__c = childOrders[0].Id;
            actList[1].Order__c = childOrders[1].Id;
            actList[2].Order__c = childOrders[2].Id;
            actList[3].Order__c = childOrders[3].Id;
            actList[0].RecordTypeId = constants.ACTIVITYCUSTOM_RECORDTYPEID_CREDITCHECKKO;
            actList[1].RecordTypeId = constants.ACTIVITYCUSTOM_RECORDTYPEID_CREDITCHECKKO;
            actList[2].RecordTypeId = constants.ACTIVITYCUSTOM_RECORDTYPEID_CREDITCHECKKO;
            actList[3].RecordTypeId = constants.ACTIVITYCUSTOM_RECORDTYPEID_CREDITCHECKKO;
            actList[0].Status__c = 'Creata';
            actList[1].Status__c = 'Creata';
            actList[2].Status__c = 'Creata';
            actList[3].Status__c = 'Creata';
            insert actList;
        }
    }

    @isTest
    public static void testUpdateServicePointToComplete() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            List<Order> ordersOld = [SELECT Id, Phase__c, AccountId, isTransition__c, ContractSigned__c, RecordTypeId,
                                            QualityCall__c, AgencyCode__c, EffectiveDate__c, Status, WizardCompletedDate__c, ProcessType__c,
                                            Contact__c, ParentOrder__c, PhaseStory__c, SignedDate__c, IncomingCreditCheckResult__c,
                                            IsSequanzialized__c, TecnicalPhase__c, ServicePoint__c
                                     FROM Order WHERE AgencyCode__c = 'AgencyCode'];

            List<Order> ordersNew = [SELECT Id, Phase__c, AccountId, isTransition__c, ContractSigned__c, RecordTypeId,
                                            QualityCall__c, AgencyCode__c, EffectiveDate__c, Status, WizardCompletedDate__c, ProcessType__c,
                                            Contact__c, ParentOrder__c, PhaseStory__c, SignedDate__c, IncomingCreditCheckResult__c,
                                            IsSequanzialized__c, TecnicalPhase__c, ServicePoint__c
                                     FROM Order WHERE AgencyCode__c = 'AgencyCode'];

            ordersNew[0].Phase__c = 'Completata';
            
            HDT_UTL_OrderProcess.updateServicePointToComplete(ordersOld, ordersNew);

            List<ServicePoint__c> assertList = [SELECT Id, SupplyType__c, ImplantType__c FROM ServicePoint__c WHERE SupplyType__c = 'Domestico'];
            
            Test.stopTest();

            System.assertEquals(false, assertList.isEmpty(), 'ServicePoint updated');
            System.assertNotEquals(true, assertList.isEmpty(), 'ServicePoint not updated.');
        }
    }
	
	@isTest
    public static void testCheckSatisfationIndex() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            List<Order> orders = [SELECT Id, PraxidiaOverrallSatisfaction__c, PraxidiaDateOutcome__c, AccountId 
                                  FROM Order WHERE Name='testOrderName0'];

            Map<Id,Order> mapOld = new Map<Id, Order>(orders);

            orders[0].PraxidiaOverrallSatisfaction__c = 3.0;
            orders[0].PraxidiaDateOutcome__c = Date.newInstance(2021, 09, 11);
            update orders;

            orders = [SELECT Id, PraxidiaOverrallSatisfaction__c, PraxidiaDateOutcome__c, AccountId 
                      FROM Order WHERE PraxidiaOverrallSatisfaction__c = 3.0];

            Map<Id,Order> mapNew = new Map<Id, Order>(orders);

            HDT_UTL_OrderProcess.checkSatisfationIndex(mapNew, mapOld);

            Account acc = [SELECT SatisfactionIndexCtrl__c, PraxidiaUpdateDate__c FROM Account WHERE Name='test account0'];
 
            Test.stopTest();

            System.assertEquals(orders[0].PraxidiaOverrallSatisfaction__c, acc.SatisfactionIndexCtrl__c, 'Account Updated.');
            System.assertNotEquals(null, acc.SatisfactionIndexCtrl__c, 'Account update failed.');
        }
    }

    @isTest
    public static void testSalesProcessManagementBefore() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            List<Order> ordersOld = [SELECT Id, Phase__c, AccountId, isTransition__c, ContractSigned__c, RecordTypeId,
                                            QualityCall__c, AgencyCode__c, EffectiveDate__c, Status, WizardCompletedDate__c, ProcessType__c,
                                            Contact__c, ParentOrder__c, PhaseStory__c 
                                     FROM Order WHERE AgencyCode__c = 'AgencyCode'];

            ordersOld[0].Phase__c = 'Comunicazione Verso Heroku';
            ordersOld[0].QualityCall__c = true;
            update ordersOld;

            ordersOld[0].Phase__c = 'Bozza';
            update ordersOld;

            ordersOld[0].Phase__c = 'Comunicazione Verso Heroku';
            update ordersOld;

            List<Order> assertList = [SELECT Id FROM Order WHERE Phase__c = 'Esportazione VS Siebel'];

            Test.stopTest();

            System.assertEquals(false, assertList.isEmpty(), 'Phase updated to \'Esportazione VS Siebel\'');
            System.assertNotEquals(true, assertList.isEmpty(), 'Phase not updated.');

        }
    }
            
        @isTest
        public static void testSalesProcessManagementBefore2() {
 
            User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
    
            System.runAs(u){
    
                Test.startTest();

                List<Order> ordersOld = [SELECT Id, Phase__c, AccountId, isTransition__c, ContractSigned__c, RecordTypeId,
                                            QualityCall__c, AgencyCode__c, EffectiveDate__c, Status, WizardCompletedDate__c, ProcessType__c,
                                            Contact__c, ParentOrder__c, PhaseStory__c, TecnicalPhase__c 
                                     FROM Order WHERE AgencyCode__c = 'AgencyCode'];

                ordersOld[0].Phase__c = 'Documentazione validata';
                update ordersOld;

                List<Order> ordersNew = [SELECT Id, Phase__c, AccountId, isTransition__c, ContractSigned__c, RecordTypeId,
                                                QualityCall__c, AgencyCode__c, EffectiveDate__c, Status, WizardCompletedDate__c, ProcessType__c,
                                                Contact__c, ParentOrder__c, PhaseStory__c, TecnicalPhase__c 
                                        FROM Order 
                                        WHERE AgencyCode__c = 'AgencyCode'];

                ordersNew[0].isTransition__c = false;
                ordersNew[0].Phase__c = 'Comunicazione Verso Heroku';
                ordersNew[0].PhaseStory__c = '';
                update ordersNew;

                HDT_UTL_OrderProcess.salesProcessManagementBefore(ordersNew, ordersOld);

                List<Order> assertList = [SELECT Id FROM Order WHERE Phase__c = 'Comunicazione Verso Heroku'];

                System.assertEquals(false, assertList.isEmpty(), 'Phase updated');
                System.assertNotEquals(true, assertList.isEmpty(), 'Phase not updated.');

                Test.stopTest();
            }
        }

        @isTest
        public static void testSalesProcessManagementBefore3() {
 
            User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
    
            System.runAs(u){
    
                Test.startTest();

                List<Order> ordersOld = [SELECT Id, Phase__c, AccountId, isTransition__c, ContractSigned__c, RecordTypeId,
                                            QualityCall__c, AgencyCode__c, EffectiveDate__c, Status, WizardCompletedDate__c, ProcessType__c,
                                            Contact__c, ParentOrder__c, PhaseStory__c 
                                     FROM Order WHERE AgencyCode__c = 'AgencyCode'];

                ordersOld[0].Phase__c = 'In attesa di quality call';
                update ordersOld;

                List<Order> ordersNew = [SELECT Id, Phase__c, AccountId, isTransition__c, ContractSigned__c, RecordTypeId,
                                                QualityCall__c, AgencyCode__c, EffectiveDate__c, Status, WizardCompletedDate__c, ProcessType__c,
                                                Contact__c, ParentOrder__c, PhaseStory__c 
                                        FROM Order 
                                        WHERE AgencyCode__c = 'AgencyCode'];

                ordersNew[0].isTransition__c = false;
                ordersNew[0].Phase__c = 'Quality Call OK';
                ordersNew[0].PhaseStory__c = '';
                update ordersNew;

                HDT_UTL_OrderProcess.salesProcessManagementBefore(ordersNew, ordersOld);

                List<Order> assertList = [SELECT Id FROM Order WHERE Phase__c = 'Comunicazione Verso Heroku'];

                System.assertEquals(false, assertList.isEmpty(), 'Phase updated to Comunicazione Verso Heroku');
                System.assertNotEquals(true, assertList.isEmpty(), 'Phase not updated.');

                Test.stopTest();
            }
        }

        @isTest
        public static void testSalesProcessManagementBefore4() {
 
            User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
    
            System.runAs(u){
    
                Test.startTest();

                List<Order> ordersOld = [SELECT Id, Phase__c, AccountId, isTransition__c, ContractSigned__c, RecordTypeId,
                                            QualityCall__c, AgencyCode__c, EffectiveDate__c, Status, WizardCompletedDate__c, ProcessType__c,
                                            Contact__c, ParentOrder__c, PhaseStory__c 
                                     FROM Order WHERE AgencyCode__c = 'AgencyCode'];

                List<Order> ordersNew = ordersOld;

                ordersNew[0].isTransition__c = false;
                ordersNew[0].Phase__c = 'Quality Call OK';
                ordersNew[0].PhaseStory__c = '';
                update ordersNew;

                HDT_UTL_OrderProcess.salesProcessManagementBefore(ordersNew, ordersOld);

                List<Order> assertList = [SELECT Id FROM Order WHERE Phase__c = 'In attesa validazione'];

                System.assertEquals(false, assertList.isEmpty(), 'Phase updated to Comunicazione Verso Heroku');
                System.assertNotEquals(true, assertList.isEmpty(), 'Phase not updated.');

                Test.stopTest();
            }
        }

    @isTest
    public static void testOrderPhaseManagementAfterUpdate() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            Order parentOrder = [SELECT Id, Phase__c, AccountId, isTransition__c, ContractSigned__c, RecordTypeId, DocumentPackage__c,
                                        QualityCall__c, AgencyCode__c, EffectiveDate__c, Status, WizardCompletedDate__c, ProcessType__c,
                                        Contact__c, ParentOrder__c
                                FROM Order WHERE Name='testOrderName0'];
                                
            parentOrder.Phase__c = 'Documentazione Gestita';
            parentOrder.RecordTypeId = constants.ORDER_RECORDTYPEID_ORDERDOSSIER;
            update parentOrder;

            List<Order> ordersOld = [SELECT Id, Phase__c, AccountId, isTransition__c, ContractSigned__c, RecordTypeId, DocumentPackage__c,
                                            QualityCall__c, AgencyCode__c, EffectiveDate__c, Status, WizardCompletedDate__c, ProcessType__c,
                                            Contact__c, ParentOrder__c
                                  FROM Order WHERE ParentOrder__r.Name='testOrderName0'];

            List<Order> ordersNew = ordersOld;

            HDT_UTL_OrderProcess.orderPhaseManagementAfterUpdate(ordersNew, ordersOld);

            List<Order> assertList = [SELECT Id, Phase__c FROM Order WHERE ParentOrder__r.Name='testOrderName0' AND Phase__c = 'Esportazione VS Siebel'];
 
            Test.stopTest();

            System.assertEquals(false, assertList.isEmpty(), 'Phase updated');
            System.assertNotEquals(true, assertList.isEmpty(), 'Phase not updated.');
        }
    }

    @isTest
    public static void testOrderCalulateDateUpdate() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            List<Order> ordersOld = [SELECT Id, Phase__c, AccountId, isTransition__c, ContractSigned__c, RecordTypeId,
                                            QualityCall__c, AgencyCode__c, EffectiveDate__c, Status, WizardCompletedDate__c, ProcessType__c,
                                            Contact__c, ParentOrder__c, PhaseStory__c, SignedDate__c, IncomingCreditCheckResult__c,
                                            IsSequanzialized__c
                                     FROM Order WHERE AgencyCode__c = 'AgencyCode'];

            List<Order> ordersNew = ordersOld;
            ordersNew[0].Status = 'In Lavorazione';
            ordersNew[0].RecordTypeId = constants.ORDER_RECORDTYPEID_ATTIVAZIONE;
            ordersNew[0].ProcessType__c = 'Switch in Ele';
            ordersNew[0].SignedDate__c = Date.today();
            ordersNew[0].WizardCompletedDate__c = Date.today();
            ordersNew[0].RecessNotice__c = 1.0;
            update ordersNew;

            HDT_UTL_OrderProcess.orderCalulateDateUpdate(ordersNew, ordersOld);

            List<Order> assertList = [SELECT Id FROM Order WHERE DateSentToSII__c =: Date.today()];

            Test.stopTest();

            System.assertEquals(false, assertList.isEmpty(), 'Order updated');
            System.assertNotEquals(true, assertList.isEmpty(), 'Order not updated.');
        }
    }

    @isTest
    public static void testOverturningFields() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            List<Order> ordersOld = [SELECT Id, Phase__c, AccountId, isTransition__c, ContractSigned__c, RecordTypeId,
                                            QualityCall__c, AgencyCode__c, EffectiveDate__c, Status, WizardCompletedDate__c, ProcessType__c,
                                            Contact__c, ParentOrder__c, PhaseStory__c, SignedDate__c, IncomingCreditCheckResult__c,
                                            IsSequanzialized__c, TecnicalPhase__c
                                     FROM Order WHERE AgencyCode__c = 'AgencyCode'];
            
            List<Order> ordersNew = ordersOld;
            ordersNew[0].Phase__c = 'Completata';
            update ordersNew;

            HDT_UTL_OrderProcess.overturningFields(ordersOld, ordersNew);

            List<Order> assertList = [SELECT Id FROM Order WHERE Phase__c = 'Completata'];

            Test.stopTest();

            System.assertEquals(false, assertList.isEmpty(), 'Order updated');
            System.assertNotEquals(true, assertList.isEmpty(), 'Order not updated.');
        }
    }

    @isTest
    public static void testGetParentOrders() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            List<Order> ordersOld = [SELECT Id, Phase__c, AccountId, isTransition__c, ContractSigned__c, RecordTypeId,
                                            QualityCall__c, AgencyCode__c, EffectiveDate__c, Status, WizardCompletedDate__c, ProcessType__c,
                                            Contact__c, ParentOrder__c, PhaseStory__c, SignedDate__c, IncomingCreditCheckResult__c,
                                            IsSequanzialized__c, TecnicalPhase__c
                                     FROM Order WHERE AgencyCode__c = 'AgencyCode'];

            ordersOld[0].RecordTypeId = constants.ORDER_RECORDTYPEID_ORDERDOSSIER;
            ordersOld[0].Phase__c = 'Documentazione Gestita';
            update ordersOld;

            List<Order> listToFulfillParameters = new List<Order>();
            Map<String,Order> mapToFulfillParameters = new Map<String,Order>();

            List<String> assertList = HDT_UTL_OrderProcess.getParentOrders(ordersOld, listToFulfillParameters, mapToFulfillParameters);
 
            Test.stopTest();

            System.assertEquals(false, assertList.isEmpty(), 'Something done');
            System.assertNotEquals(true, assertList.isEmpty(), 'Something not done.');
        }
    }

    @isTest
    public static void testGetParentOrders2() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            List<Order> ordersOld = [SELECT Id, Phase__c, AccountId, isTransition__c, ContractSigned__c, RecordTypeId,
                                            QualityCall__c, AgencyCode__c, EffectiveDate__c, Status, WizardCompletedDate__c, ProcessType__c,
                                            Contact__c, ParentOrder__c, PhaseStory__c, SignedDate__c, IncomingCreditCheckResult__c,
                                            IsSequanzialized__c, TecnicalPhase__c
                                     FROM Order WHERE AgencyCode__c = 'AgencyCode'];

            ordersOld[0].RecordTypeId = constants.ORDER_RECORDTYPEID_ORDERDOSSIER;
            ordersOld[0].Phase__c = 'Documentazione Gestita';
            update ordersOld;

            List<Order> listToFulfillParameters = new List<Order>();
            Map<String,Order> mapToFulfillParameters = new Map<String,Order>();

            List<Order> assertList = HDT_UTL_OrderProcess.getParentOrders2(ordersOld, listToFulfillParameters, mapToFulfillParameters);
 
            Test.stopTest();

            System.assertEquals(false, assertList.isEmpty(), 'Something done');
            System.assertNotEquals(true, assertList.isEmpty(), 'Something not done.');
        }
    }
    
    @isTest
    public static void testUpdateChildOrdersPhase() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            List<Order> orderParent = [SELECT Id, ProcessType__c FROM Order WHERE AgencyCode__c = 'AgencyCode'];
            List<String> orderIdList = new List<String>{orderParent[0].Id};

            HDT_UTL_OrderProcess.updateChildOrdersPhase(orderIdList, 'Documentazione Validata', 'Esportazione VS Siebel');

            List<Order> assertList = [SELECT Id FROM Order WHERE Phase__c = 'Esportazione VS Siebel' AND ParentOrder__c =: orderParent[0].Id];
 
            Test.stopTest();
            
            System.assertEquals(false, assertList.isEmpty(), 'Child Order updated');
            System.assertNotEquals(true, assertList.isEmpty(), 'Child Order not updated.');
        }
    }

    @isTest
    public static void testUpdateChildOrdersPhaseChild() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            List<Order> orderParent = [SELECT Id, ProcessType__c FROM Order WHERE AgencyCode__c = 'AgencyCode'];
            List<String> orderIdList = new List<String>{orderParent[0].Id};

            HDT_UTL_OrderProcess.updateChildOrdersPhaseChild(orderIdList, 'Documentazione Validata', 'Esportazione VS Siebel', 'Bozza', 'Completata');

            List<Order> assertList = [SELECT Id FROM Order WHERE Phase__c = 'Completata' AND ParentOrder__c =: orderParent[0].Id];
 
            Test.stopTest();

            System.assertEquals(false, assertList.isEmpty(), 'Child Order updated');
            System.assertNotEquals(true, assertList.isEmpty(), 'Child Order not updated.');
        }
    }

    @isTest
    public static void testCreditCheckPhaseManager() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            List<Order> orderParent = [SELECT Id, ProcessType__c, Phase__c, CreditCheckDescription__c, RecordTypeId FROM Order WHERE AgencyCode__c = 'AgencyCode'];
            orderParent[0].Phase__c = 'Documentazione Gestita';
            orderParent[0].RecordTypeId = constants.ORDER_RECORDTYPEID_ORDERDOSSIER;
            update orderParent;

            List<Order> childOrder0 = [SELECT Id, IncomingCreditCheckResult__c, OutgoingCreditCheckResult__c, ProcessType__c, Phase__c, 
                                             CreditCheckDescription__c, RecordTypeId, ParentOrder__c, ParentOrder__r.Phase__c,
                                             OrderReferenceNumber, RecordType.Developername, QualityCall__c, AgencyCode__c, Name
                                      FROM Order 
                                      WHERE Name LIKE 'childOrder0'];

            HDT_UTL_OrderProcess.creditCheckPhaseManager(childOrder0);

            List<wrts_prcgvr__Activity__c> assertList = [SELECT Id FROM wrts_prcgvr__Activity__c];
 
            Test.stopTest();

            System.assertEquals(false, assertList.isEmpty(), 'Activity Custom created');
            System.assertNotEquals(true, assertList.isEmpty(), 'Activity Custom not created.');
        }
    }
    
    @isTest
    public static void testCreditCheckPhaseManager2() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            List<Order> orderParent = [SELECT Id, ProcessType__c, Phase__c, CreditCheckDescription__c, RecordTypeId FROM Order WHERE AgencyCode__c = 'AgencyCode'];
            orderParent[0].Phase__c = 'Documentazione Gestita';
            orderParent[0].RecordTypeId = constants.ORDER_RECORDTYPEID_ORDERDOSSIER;
            update orderParent;

            List<Order> childOrder1 = [SELECT Id, IncomingCreditCheckResult__c, OutgoingCreditCheckResult__c, ProcessType__c, Phase__c, 
                                            CreditCheckDescription__c, RecordTypeId, ParentOrder__c, ParentOrder__r.Phase__c,
                                            OrderReferenceNumber, RecordType.Developername, QualityCall__c, AgencyCode__c, Name
                                    FROM Order 
                                    WHERE Name LIKE 'childOrder1'];

            HDT_UTL_OrderProcess.creditCheckPhaseManager(childOrder1);

            List<wrts_prcgvr__Activity__c> assertList = [SELECT Id FROM wrts_prcgvr__Activity__c];
 
            Test.stopTest();
            
            System.assertEquals(false, assertList.isEmpty(), 'Activity Custom created');
            System.assertNotEquals(true, assertList.isEmpty(), 'Activity Custom not created.');
        }
    }

    @isTest
    public static void testCreditCheckPhaseManager3() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            List<Order> orderParent = [SELECT Id, ProcessType__c, Phase__c, CreditCheckDescription__c, RecordTypeId FROM Order WHERE AgencyCode__c = 'AgencyCode'];
            orderParent[0].Phase__c = 'Documentazione Gestita';
            orderParent[0].RecordTypeId = constants.ORDER_RECORDTYPEID_ORDERDOSSIER;
            update orderParent;

            List<Order> childOrder2 = [SELECT Id, IncomingCreditCheckResult__c, OutgoingCreditCheckResult__c, ProcessType__c, Phase__c, 
                                            CreditCheckDescription__c, RecordTypeId, ParentOrder__c, ParentOrder__r.Phase__c,
                                            OrderReferenceNumber, RecordType.Developername, QualityCall__c, AgencyCode__c, Name
                                    FROM Order 
                                    WHERE Name LIKE 'childOrder2'];

            childOrder2[0].Phase__c = 'Documentazione Validata';
            childOrder2[0].RecordTypeId = constants.ORDER_RECORDTYPEID_SUBENTRO;
            update childOrder2;

            HDT_UTL_OrderProcess.creditCheckPhaseManager(childOrder2);

            List<wrts_prcgvr__Activity__c> assertList = [SELECT Id FROM wrts_prcgvr__Activity__c];
 
            Test.stopTest();
            
            System.assertEquals(false, assertList.isEmpty(), 'Activity Custom created');
            System.assertNotEquals(true, assertList.isEmpty(), 'Activity Custom not created.');
        }
    }

    @isTest
    public static void testCreditCheckPhaseManager4() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            List<Order> orderParent = [SELECT Id, ProcessType__c, Phase__c, CreditCheckDescription__c, RecordTypeId FROM Order WHERE AgencyCode__c = 'AgencyCode'];
            orderParent[0].Phase__c = 'Documentazione Gestita';
            orderParent[0].RecordTypeId = constants.ORDER_RECORDTYPEID_ORDERDOSSIER;
            update orderParent;

            List<Order> childOrder3 = [SELECT Id, IncomingCreditCheckResult__c, OutgoingCreditCheckResult__c, ProcessType__c, Phase__c, 
                                            CreditCheckDescription__c, RecordTypeId, ParentOrder__c, ParentOrder__r.Phase__c,
                                            OrderReferenceNumber, RecordType.Developername, QualityCall__c, AgencyCode__c, Name
                                    FROM Order 
                                    WHERE Name LIKE 'childOrder3'];

            childOrder3[0].Phase__c = 'Documentazione Validata';
            update childOrder3;

            HDT_UTL_OrderProcess.creditCheckPhaseManager(childOrder3);

            List<wrts_prcgvr__Activity__c> assertList = [SELECT Id FROM wrts_prcgvr__Activity__c];
 
            Test.stopTest();
            
            System.assertEquals(false, assertList.isEmpty(), 'Activity Custom created');
            System.assertNotEquals(true, assertList.isEmpty(), 'Activity Custom not created.');
        }
    }
}