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
            HDT_UTL_DataFactoryTst.newPhaseTransition('In attesa tempi di ripensamento', 'Documentazione Validata', constants.ORDER_RECORDTYPEID_ORDERDOSSIER, 'HDT_RT_OrderDossier');
            HDT_UTL_DataFactoryTst.newPhaseTransition('Esportazione VS Siebel', 'Documentazione Validata', constants.ORDER_RECORDTYPEID_VOLTURA, 'HDT_RT_Voltura');
            HDT_UTL_DataFactoryTst.newPhaseTransition('Documentazione Gestita', 'Bozza', constants.ORDER_RECORDTYPEID_ORDERDOSSIER, 'HDT_RT_OrderDossier');
            HDT_UTL_DataFactoryTst.newPhaseTransition('Bozza', 'Documentazione Gestita', constants.ORDER_RECORDTYPEID_ORDERDOSSIER, 'HDT_RT_OrderDossier');
            HDT_UTL_DataFactoryTst.newPhaseTransition('Bozza', 'Documentazione Gestita', constants.ORDER_RECORDTYPEID_ATTIVAZIONE, 'HDT_RT_Attivazione');
            HDT_UTL_DataFactoryTst.newPhaseTransition('Amm. Precheck KO SII', 'Documentazione Gestita', constants.ORDER_RECORDTYPEID_CAMBIO_OFFERTA, 'HDT_RT_CambioOfferta');
            HDT_UTL_DataFactoryTst.newPhaseTransition('Amm. Precheck KO SII', 'Documentazione Gestita', constants.ORDER_RECORDTYPEID_ATTIVAZIONE, 'HDT_RT_Attivazione');
            HDT_UTL_DataFactoryTst.newPhaseTransition('Amm. Precheck KO SII', 'Documentazione Gestita', constants.ORDER_RECORDTYPEID_ORDERDOSSIER, 'HDT_RT_OrderDossier');
            HDT_UTL_DataFactoryTst.newPhaseTransition('Comunicazione verso Heroku', 'Bozza', constants.ORDER_RECORDTYPEID_ORDERDOSSIER, 'HDT_RT_OrderDossier');
            HDT_UTL_DataFactoryTst.newPhaseTransition('Comunicazione verso Heroku', 'Bozza', constants.ORDER_RECORDTYPEID_ATTIVAZIONE, 'HDT_RT_Attivazione');
            HDT_UTL_DataFactoryTst.newPhaseTransition('Comunicazione verso Heroku', 'Bozza', constants.ORDER_RECORDTYPEID_CAMBIO_OFFERTA, 'HDT_RT_CambioOfferta');
            HDT_UTL_DataFactoryTst.newPhaseTransition('In attesa tempi di ripensamento', 'Documentazione Gestita', constants.ORDER_RECORDTYPEID_ORDERDOSSIER, 'HDT_RT_OrderDossier');
            HDT_UTL_DataFactoryTst.newPhaseTransition('Completata', 'Documentazione Gestita', constants.ORDER_RECORDTYPEID_ORDERDOSSIER, 'HDT_RT_OrderDossier');
            HDT_UTL_DataFactoryTst.newPhaseTransition('In attesa di quality call', 'Documentazione Gestita', constants.ORDER_RECORDTYPEID_ORDERDOSSIER, 'HDT_RT_OrderDossier');
            HDT_UTL_DataFactoryTst.newPhaseTransition('Quality Call OK', 'Documentazione Gestita', constants.ORDER_RECORDTYPEID_ORDERDOSSIER, 'HDT_RT_OrderDossier');
            HDT_UTL_DataFactoryTst.newPhaseTransition('Quality Call OK', 'In attesa di quality call', constants.ORDER_RECORDTYPEID_ORDERDOSSIER, 'HDT_RT_OrderDossier');
            HDT_UTL_DataFactoryTst.newPhaseTransition('Documentazione Validata', 'In attesa validazione', constants.ORDER_RECORDTYPEID_VOLTURA, 'HDT_RT_Voltura');
            HDT_UTL_DataFactoryTst.newPhaseTransition('In attesa validazione', 'Da Inviare', constants.ORDER_RECORDTYPEID_VOLTURA, 'HDT_RT_Voltura');
            HDT_UTL_DataFactoryTst.newPhaseTransition('Completata', 'Bozza', constants.ORDER_RECORDTYPEID_CAMBIO_OFFERTA, 'HDT_RT_OrderDossier');
            HDT_UTL_DataFactoryTst.newPhaseTransition('Completata', 'Bozza', constants.ORDER_RECORDTYPEID_VAS, 'HDT_RT_VAS');
            HDT_UTL_DataFactoryTst.newPhaseTransition('In attesa tempi di ripensamento', 'Documentazione Validata', constants.ORDER_RECORDTYPEID_VAS, 'HDT_RT_VAS');
            HDT_UTL_DataFactoryTst.newPhaseTransition('In attesa tempi di ripensamento', 'Documentazione Validata', constants.ORDER_RECORDTYPEID_VOLTURA, 'HDT_RT_Voltura');
            HDT_UTL_DataFactoryTst.newPhaseTransition('Documentazione Gestita', 'Bozza', constants.ORDER_RECORDTYPEID_CAMBIO_OFFERTA, 'HDT_RT_CambioOfferta');
            HDT_UTL_DataFactoryTst.newPhaseTransition('Comunicazione Motore VAS', 'Documentazione Validata', constants.ORDER_RECORDTYPEID_VAS, 'HDT_RT_Voltura');
            HDT_UTL_DataFactoryTst.newPhaseTransition('In attesa tempi di ripensamento', 'Comunicazione Motore VAS', constants.ORDER_RECORDTYPEID_VAS, 'HDT_RT_Voltura');
            HDT_UTL_DataFactoryTst.newPhaseTransition('Comunicazione verso Heroku', 'Esportazione VS Siebel', constants.ORDER_RECORDTYPEID_VOLTURA, 'HDT_RT_Voltura');
            HDT_UTL_DataFactoryTst.newPhaseTransition('Comunicazione verso Heroku', 'Esportazione VS Siebel', constants.ORDER_RECORDTYPEID_SUBENTRO, 'HDT_RT_Default');
            HDT_UTL_DataFactoryTst.newPhaseTransition('Documentazione Validata', 'In attesa validazione', constants.ORDER_RECORDTYPEID_SUBENTRO, 'HDT_RT_Default');
            HDT_UTL_DataFactoryTst.newPhaseTransition('Esportazione VS Siebel', 'Documentazione Validata', constants.ORDER_RECORDTYPEID_SUBENTRO, 'HDT_RT_Default');
            HDT_UTL_DataFactoryTst.newPhaseTransition('In attesa validazione', 'Sequenzializzato', constants.ORDER_RECORDTYPEID_VAS, 'HDT_RT_VAS');
            HDT_UTL_DataFactoryTst.newPhaseTransition('Comunicazione verso Heroku KO', 'Documentazione Gestita', constants.ORDER_RECORDTYPEID_SWITCHIN, 'HDT_RT_SwitchIn');
            HDT_UTL_DataFactoryTst.newPhaseTransition('Documentazione Gestita','Comunicazione verso Heroku KO', constants.ORDER_RECORDTYPEID_SWITCHIN, 'HDT_RT_SwitchIn');
             
            List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(2, false, 'HERA COMM', 'Azienda', 'Aziende SME');
            accList[0].SatisfactionIndexCtrl__c = 1.0;
            accList[0].PraxidiaUpdateDate__c = Date.newInstance(2021, 09, 14);
            insert accList;

            List<BillingProfile__c> bpList = HDT_UTL_DataFactoryTst.createBillingProfile(1, true, accList[0].Id);
            List<Contact> cttList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].Id);
            List<ServicePoint__c> spList = HDT_UTL_DataFactoryTst.createServicePoint(1, false);
            spList[0].CommoditySector__c = 'Energia Elettrica';
            spList[0].SupplyType__c = 'Domestico';
            spList[0].ImplantType__c = '13A0-Usi di Abitazione BT';
            spList[0].Account__c = accList[0].Id;
            insert spList;

            List<Order> orderList = HDT_UTL_DataFactoryTst.createOrder(3, false, accList[0].Id, 'Bozza');
            orderList[0].Name = 'testOrderName0';
            orderList[0].PraxidiaOverrallSatisfaction__c = 2.0;
            orderList[0].PraxidiaDateOutcome__c = Date.newInstance(2020, 08, 10);
            orderList[0].isTransition__c = true;
            orderList[0].RecordTypeId = constants.ORDER_RECORDTYPEID_ORDERDOSSIER;
            orderList[0].AgencyCode__c = 'AgencyCode';
            orderList[0].CommercialId__c = 'AgentCode';
            orderList[0].WizardCompletedDate__c = Date.today();
            orderList[0].Contact__c = cttList[0].Id;
            orderList[0].DocumentPackage__c = 'Validato';
            orderList[0].QualityCall__c = true;
            orderList[0].SignedDate__c = Date.today().addDays(-7);
            orderList[0].ServicePoint__c = spList[0].Id;
            orderList[0].BillingProfile__c = bpList[0].Id;
            orderList[0].SapContractCode__c = '123456';
            orderList[0].TecnicalPhase__c = 'Bozza';
            orderList[0].DateSentToSII__c = Date.today();
            orderList[0].Phase__c = 'Documentazione Gestita';
            orderList[1].Name = 'testOrderName1';
            orderList[1].MethodSignedAccepted__c = null;
            insert orderList;

            List<Sale__c> sales = HDT_UTL_DataFactoryTst.createSale(1, false, accList[0].Id, 'Bozza');
            sales[0].isTransition__c = true;
            insert sales;
            
            List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, false, accList[0].Id);
            insert contractList;

            List<Order> childOrders = HDT_UTL_DataFactoryTst.createChildOrder(8, false, accList[0].Id, sales, orderList[0].Id, cttList[0].Id);
            childOrders[0].Name = 'childOrder0';
            childOrders[0].CommercialId__c = 'test';
            childOrders[0].Phase__c = 'Documentazione Validata';
            childOrders[0].CreditCheckDescription__c = 'Saldo debito cattivo pagatore A';
            childOrders[0].IncomingCreditCheckResult__c = 'OK';
            childOrders[0].ParentOrder__c = orderList[0].Id;
            childOrders[1].Name = 'childOrder1';
            childOrders[1].CommercialId__c = 'AgentCode';
            childOrders[1].Phase__c = 'In attesa validazione';
            childOrders[1].CreditCheckDescription__c = '';
            childOrders[1].ParentOrder__c = orderList[0].Id;
            childOrders[2].Name = 'childOrder2';
            childOrders[2].CommercialId__c = 'test';
            childOrders[2].Phase__c = 'Da Inviare';
            childOrders[2].ParentOrder__c = orderList[0].Id;
            childOrders[3].Name = 'childOrder3';
            childOrders[3].RecordTypeId = constants.ORDER_RECORDTYPEID_VAS;
            childOrders[3].ProcessType__c = 'VAS';
            childOrders[3].VASType__c = 'VAS Servizio';
            childOrders[3].CreditCheckDescription__c = 'Cattivo pagatore C';
            childOrders[3].ParentOrder__c = orderList[0].Id;
            childOrders[4].Name = 'childOrder4';
            childOrders[4].RecordTypeId = constants.ORDER_RECORDTYPEID_VAS;
            childOrders[4].ProcessType__c = 'VAS';
            childOrders[4].VASType__c = 'VAS Servizio';
            childOrders[4].CreditCheckDescription__c = 'Cattivo pagatore C';
            childOrders[4].Phase__c = 'Sequenzializzato';
            childOrders[4].isTransition__c = true;
            childOrders[4].ParentOrder__c = orderList[0].Id;
            childOrders[5].Name = 'childOrder5';
            childOrders[5].RecordTypeId = constants.ORDER_RECORDTYPEID_VOLTURA;
            childOrders[5].ContractReference__c = contractList[0].Id;
            childOrders[5].CreditCheckDescription__c = 'Cattivo pagatore C';
            childOrders[5].Phase__c = 'Credit Check KO';
            childOrders[5].IncomingCreditCheckResult__c='OK';
            childOrders[5].ProcessType__c = 'Switch in Fittizio';
            childOrders[5].ServicePoint__c = spList[0].Id;
            childOrders[5].isTransition__c = true;
            childOrders[5].IsMassive__c = true;
            childOrders[5].ParentOrder__c = orderList[0].Id;
            childOrders[6].Name = 'childOrder5';
            childOrders[6].ParentOrder__c = orderList[1].Id;
            childOrders[6].SignedDate__c = Date.today().addDays(-7);
            childOrders[6].ProcessType__c = 'Subentro Ele';
            childOrders[7].Name = 'childOrder6';
            childOrders[7].ParentOrder__c = orderList[1].Id;
            childOrders[7].SignedDate__c = Date.today().addDays(-7);
            childOrders[7].ProcessType__c = 'Switch in Ele';
            insert childOrders;

            List<ServiceRequest__c> myServiceRequestList = HDT_UTL_DataFactoryTst.createServiceRequest(1, false);
            myServiceRequestList[0].Order__c = childOrders[4].Id;
            myServiceRequestList[0].NextPhase__c = 'Esportazione VS Siebel';
            insert myServiceRequestList;


            List<AgentMatrix__c> agMatrixList = HDT_UTL_DataFactoryTst.createAgentMatrix(1, false, 'Telefono');
            agMatrixList[0].AgencyCode__c = 'AgencyCode';
            agMatrixList[0].IsMonitoring__c = true;
            agMatrixList[0].AgentCode__c =  'AgentCode';
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
            actList[0].wrts_prcgvr__Status__c = 'Aperta';
            actList[1].wrts_prcgvr__Status__c = 'Aperta';
            actList[2].wrts_prcgvr__Status__c = 'Aperta';
            actList[3].wrts_prcgvr__Status__c = 'Aperta';
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
                                        Contact__c, ParentOrder__c, PhaseStory__c, TecnicalPhase__c, ComfortCallDaysDue__c, CommercialId__c
                                    FROM Order WHERE AgencyCode__c = 'AgencyCode'];

            ordersOld[0].Phase__c = 'Documentazione validata';
            update ordersOld;

            List<Order> ordersNew = [SELECT Id, Phase__c, AccountId, isTransition__c, ContractSigned__c, RecordTypeId, VasSubtype__c,
                                            QualityCall__c, AgencyCode__c, EffectiveDate__c, Status, WizardCompletedDate__c, ProcessType__c,
                                            Contact__c, ParentOrder__c, PhaseStory__c, TecnicalPhase__c, ComfortCallDaysDue__c, CommercialId__c
                                    FROM Order 
                                    WHERE AgencyCode__c = 'AgencyCode'];

            ordersNew[0].isTransition__c = false;
            ordersNew[0].Phase__c = 'Comunicazione Verso Heroku';
            ordersNew[0].PhaseStory__c = '';
            ordersNew[0].VasSubtype__c = 'HERA LED 1 KIT V2';
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
    public static void testSalesProcessManagementBefore5() {

        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];

        System.runAs(u){

            Test.startTest();

            List<Order> ordersOld = [SELECT Id, Phase__c, AccountId, isTransition__c, ContractSigned__c, RecordTypeId,
                                        QualityCall__c, AgencyCode__c, EffectiveDate__c, Status, WizardCompletedDate__c, ProcessType__c,
                                        Contact__c, ParentOrder__c, PhaseStory__c, TecnicalPhase__c, ComfortCallDaysDue__c, CommercialId__c
                                    FROM Order WHERE AgencyCode__c = 'AgencyCode'];

            ordersOld[0].Phase__c = 'In attesa validazione';
            //update ordersOld;

            List<Order> ordersNew = [SELECT Id, Phase__c, AccountId, isTransition__c, ContractSigned__c, RecordTypeId,
                                            QualityCall__c, AgencyCode__c, EffectiveDate__c, Status, WizardCompletedDate__c, ProcessType__c,
                                            Contact__c, ParentOrder__c, PhaseStory__c, TecnicalPhase__c, ComfortCallDaysDue__c, CommercialId__c
                                    FROM Order 
                                    WHERE AgencyCode__c = 'AgencyCode'];

            ordersNew[0].isTransition__c = false;
            ordersNew[0].Phase__c = 'Documentazione Validata';
            ordersNew[0].PhaseStory__c = '';
            ordersNew[0].ComfortCallDaysDue__c = null;
            ordersNew[0].ProcessType__c = 'Voltura';

            HDT_UTL_OrderProcess.salesProcessManagementBefore(ordersNew, ordersOld);

            System.assertEquals('In attesa di quality call', ordersNew[0].Phase__c, 'Phase updated');

            Test.stopTest();
        }
    }

    @isTest
    public static void testSalesProcessManagementBefore6() {

        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];

        System.runAs(u){

            Test.startTest();

            List<Order> ordersOld = [SELECT Id, Phase__c, AccountId, isTransition__c, ContractSigned__c, RecordTypeId,
                                        QualityCall__c, AgencyCode__c, EffectiveDate__c, Status, WizardCompletedDate__c, ProcessType__c,
                                        Contact__c, ParentOrder__c, PhaseStory__c, TecnicalPhase__c, ComfortCallDaysDue__c, CommercialId__c
                                    FROM Order WHERE AgencyCode__c = 'AgencyCode'];

            ordersOld[0].Phase__c = 'Documentazione validata';
            //update ordersOld;

            List<Order> ordersNew = [SELECT Id, Phase__c, AccountId, isTransition__c, ContractSigned__c, RecordTypeId,
                                            QualityCall__c, AgencyCode__c, EffectiveDate__c, Status, WizardCompletedDate__c, ProcessType__c,
                                            Contact__c, ParentOrder__c, PhaseStory__c, TecnicalPhase__c, ComfortCallDaysDue__c, CommercialId__c
                                    FROM Order 
                                    WHERE AgencyCode__c = 'AgencyCode'];

            ordersNew[0].isTransition__c = false;
            ordersNew[0].Phase__c = 'Comunicazione Verso Heroku';
            ordersNew[0].PhaseStory__c = '';
            ordersNew[0].ComfortCallDaysDue__c = 10;
            ordersNew[0].ProcessType__c = 'Voltura';
            //update ordersNew;

            HDT_UTL_OrderProcess.salesProcessManagementBefore(ordersNew, ordersOld);

            //List<Order> assertList = [SELECT Id FROM Order WHERE Phase__c = 'In attesa di quality call'];

            System.assertEquals('In attesa conferma cliente', ordersNew[0].Phase__c, 'Phase updated');
            //System.assertNotEquals(true, assertList.isEmpty(), 'Phase not updated.');

            Test.stopTest();
        }
    }

    @isTest
    public static void testSalesProcessManagementBefore7() {

        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];

        System.runAs(u){

            Test.startTest();

            List<Order> ordersOld = [SELECT Id, Phase__c, AccountId, isTransition__c, ContractSigned__c, RecordTypeId,
                                        QualityCall__c, AgencyCode__c, EffectiveDate__c, Status, WizardCompletedDate__c, ProcessType__c,
                                        Contact__c, ParentOrder__c, PhaseStory__c, TecnicalPhase__c, ComfortCallDaysDue__c, CommercialId__c
                                    FROM Order WHERE AgencyCode__c = 'AgencyCode'];

            ordersOld[0].Phase__c = 'In attesa validazione';
            //update ordersOld;

            List<Order> ordersNew = [SELECT Id, Phase__c, AccountId, isTransition__c, ContractSigned__c, RecordTypeId,
                                            QualityCall__c, AgencyCode__c, EffectiveDate__c, Status, WizardCompletedDate__c, ProcessType__c,
                                            Contact__c, ParentOrder__c, PhaseStory__c, TecnicalPhase__c, ComfortCallDaysDue__c, CommercialId__c
                                    FROM Order 
                                    WHERE AgencyCode__c = 'AgencyCode'];

            ordersNew[0].isTransition__c = false;
            ordersNew[0].Phase__c = 'Documentazione Validata';
            ordersNew[0].PhaseStory__c = '';
            ordersNew[0].ComfortCallDaysDue__c = 10;
            ordersNew[0].ProcessType__c = 'Voltura';
            //update ordersNew;

            HDT_UTL_OrderProcess.salesProcessManagementBefore(ordersNew, ordersOld);

            //List<Order> assertList = [SELECT Id FROM Order WHERE Phase__c = 'In attesa di quality call'];

            System.assertEquals('In attesa conferma cliente', ordersNew[0].Phase__c, 'Phase updated');
            //System.assertNotEquals(true, assertList.isEmpty(), 'Phase not updated.');

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
                                
            /*parentOrder.Phase__c = 'Documentazione Gestita';
            parentOrder.RecordTypeId = constants.ORDER_RECORDTYPEID_ORDERDOSSIER;
            update parentOrder;*/

            List<Order> ordersOld = [SELECT Id, Phase__c, AccountId, isTransition__c, ContractSigned__c, RecordTypeId, DocumentPackage__c,
                                            QualityCall__c, AgencyCode__c, EffectiveDate__c, Status, WizardCompletedDate__c, ProcessType__c,
                                            Contact__c, ParentOrder__c, MethodSignedAccepted__c, SignedDate__c
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
    public static void testOrderCalculateDateUpdate() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            List<Order> ordersOld = [SELECT Id, Phase__c, AccountId, isTransition__c, ContractSigned__c, RecordTypeId,
                                            QualityCall__c, AgencyCode__c, EffectiveDate__c, Status, WizardCompletedDate__c, ProcessType__c,
                                            Contact__c, ParentOrder__c, PhaseStory__c, SignedDate__c, IncomingCreditCheckResult__c,MaxAfterthoughtDate__c,
                                            IsSequanzialized__c
                                     FROM Order WHERE AgencyCode__c = 'AgencyCode'];

            ordersOld[0].SignedDate__c = Date.today().addDays(-2);
            ordersOld[0].IsSequanzialized__c = true;
            update ordersOld;

            Order newOrd = new Order();
            newOrd.Id = ordersOld[0].Id;
            newOrd.AccountId = ordersOld[0].AccountId;
            newOrd.MaxAfterthoughtDate__c = ordersOld[0].MaxAfterthoughtDate__c;
            newOrd.Status = 'In Lavorazione';
            newOrd.RecordTypeId = constants.ORDER_RECORDTYPEID_ATTIVAZIONE;
            newOrd.ProcessType__c = 'Switch in Ele';
            newOrd.Phase__c = 'Comunicazione verso Heroku';
            newOrd.SignedDate__c = Date.today().addDays(-2);
            newOrd.WizardCompletedDate__c = Date.today();
            newOrd.RecessNotice__c = 1.0;
            newOrd.IsSequanzialized__c = false;
            List<Order> ordersNew = new List<Order>();
            ordersNew.add(newOrd);
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

            List<Order> ordersOld = [SELECT Id, Phase__c, AccountId, isTransition__c, ContractSigned__c, RecordTypeId, ServicePoint__c,SapImplantCode__c,
                                            QualityCall__c, AgencyCode__c, EffectiveDate__c, Status, WizardCompletedDate__c, ProcessType__c,
                                            Contact__c, ParentOrder__c, PhaseStory__c, SignedDate__c, IncomingCreditCheckResult__c,
                                            IsSequanzialized__c, TecnicalPhase__c
                                     FROM Order WHERE Name = 'testOrderName0'];
            Order newOrd = new Order();
            newOrd.Id = ordersOld[0].Id;
            newOrd.Phase__c = 'Completata';
            newOrd.Status = 'Activated';
            newOrd.ServicePoint__c = ordersOld[0].ServicePoint__c;
            newOrd.SapImplantCode__c = ordersOld[0].SapImplantCode__c;
            newOrd.AccountId = ordersOld[0].AccountId;
            newOrd.SignedDate__c = ordersOld[0].SignedDate__c;
            List<Order> ordersNew = new List<Order>();
            ordersNew.add(newOrd);

            HDT_UTL_OrderProcess.overturningFields(ordersOld, ordersNew);

            List<ServicePoint__c> spList = [SELECT Id,SAPImplantCode__c,account__c FROM ServicePoint__c WHERE Id = :ordersOld[0].ServicePoint__c];

            Test.stopTest();

            System.assertEquals(ordersOld[0].SapImplantCode__c, spList[0].SAPImplantCode__c, 'Service Point not updated');
            System.assertEquals(ordersOld[0].AccountId, spList[0].account__c, 'Service Point not updated');
        }
    }

    @isTest
    public static void testTransitorySiebelManagement() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            List<Order> ordersOld = [SELECT Id, Phase__c, AccountId, isTransition__c, ContractSigned__c, RecordTypeId, ServicePoint__c,SapImplantCode__c,
                                            QualityCall__c, AgencyCode__c, EffectiveDate__c, Status, WizardCompletedDate__c, ProcessType__c,
                                            Contact__c, ParentOrder__c, PhaseStory__c, SignedDate__c, IncomingCreditCheckResult__c,
                                            IsSequanzialized__c, TecnicalPhase__c
                                     FROM Order WHERE Name = 'testOrderName0'];
            ordersOld[0].Phase__c = 'In Corso caricamento Siebel';
            Map<Id,SObject> ordersOldMap = new Map<Id,SObject>();
            ordersOldMap.put(ordersOld[0].Id, ordersOld[0]);

            Order newOrd = new Order();
            newOrd.Id = ordersOld[0].Id;
            newOrd.Phase__c = 'Caricamento Siebel KO';
            newOrd.SiebelStatus__c = 'Pratica Gestita';
            List<SObject> ordersNew = new List<SObject>();
            ordersNew.add(newOrd);

            Boolean response = HDT_UTL_OrderProcess.transitorySiebelManagement(ordersNew, ordersOldMap);

            Test.stopTest();

            System.assertEquals(true,response, 'Response not correct');
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

            List<Order> orderParent = [SELECT Id, ProcessType__c, recordType.Developername FROM Order WHERE AgencyCode__c = 'AgencyCode'];
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
            /*orderParent[0].Phase__c = 'Documentazione Gestita';
            orderParent[0].RecordTypeId = constants.ORDER_RECORDTYPEID_ORDERDOSSIER;
            update orderParent;*/

            List<Order> myChildOrder = [SELECT Id, IncomingCreditCheckResult__c, OutgoingCreditCheckResult__c, ProcessType__c, Phase__c, 
                                             CreditCheckDescription__c, RecordTypeId, ParentOrder__c, ParentOrder__r.Phase__c,
                                             OrderReferenceNumber, RecordType.Developername, QualityCall__c, AgencyCode__c, Name, CommercialId__c
                                      FROM Order 
                                      WHERE Name = 'childOrder0'];

            HDT_UTL_OrderProcess.creditCheckPhaseManager(myChildOrder);

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
                                            OrderReferenceNumber, RecordType.Developername, QualityCall__c, AgencyCode__c, Name, CommercialId__c
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
                                            OrderReferenceNumber, RecordType.Developername, QualityCall__c, AgencyCode__c, Name, CommercialId__c
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
            /*orderParent[0].Phase__c = 'Documentazione Gestita';
            orderParent[0].RecordTypeId = constants.ORDER_RECORDTYPEID_ORDERDOSSIER;
            update orderParent;*/

            List<Order> childOrder3 = [SELECT Id, IncomingCreditCheckResult__c, OutgoingCreditCheckResult__c, ProcessType__c, Phase__c, 
                                            CreditCheckDescription__c, RecordTypeId, ParentOrder__c, ParentOrder__r.Phase__c, VasSubtype__c,
                                            OrderReferenceNumber, RecordType.Developername, QualityCall__c, AgencyCode__c, Name, ContractReference__c
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

    @isTest
    public static void testTransitoryPhaseManagement() {

        delete [SELECT Id FROM ServiceRequest__c];

        List<Order> orders = [SELECT Id,AccountId,ParentOrder__c FROM Order WHERE ParentOrder__r.RecordTypeId = :constants.ORDER_RECORDTYPEID_ORDERDOSSIER];
        Sale__c sale  = HDT_UTL_DataFactoryTst.createSale(1, true, orders[0].AccountId,'Attiva')[0];
        Opportunity opp = HDT_UTL_DataFactoryTst.createOpportunity(1, true)[0];
        List<SBQQ__Quote__c> qList = HDT_UTL_DataFactoryTst.createQuote(2, true, orders[0].Id, opp.Id, sale.Id, 'Quote');
        Integer i = 0;
        Id orderId = null; 
        List<ServiceRequest__c> myServiceRequestList = new List<ServiceRequest__c>();
        for (Order o : orders){
            o.isTransition__c = true;
            if (i<2){
                o.SBQQ__Quote__c = qList[i].Id;
                o.RecordTypeId = constants.ORDER_RECORDTYPEID_VOLTURA;
            }else{
                o.SBQQ__Quote__c = qList[Math.mod(i, 2)].Id;
                o.RecordTypeId = constants.ORDER_RECORDTYPEID_VAS;
            }
            if(o.SBQQ__Quote__c == qList[1].Id && o.RecordTypeId == constants.ORDER_RECORDTYPEID_VAS){
                orderId = o.Id;
            }
            ServiceRequest__c sr = HDT_UTL_DataFactoryTst.createServiceRequest(1, false)[0];
            sr.Order__c = o.Id;
            sr.NextPhase__c = 'Esportazione VS Siebel';
            myServiceRequestList.add(sr);
            i++;
        }
        insert myServiceRequestList;
        update orders;
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){

            Test.startTest();

                orders[0].SiebelStatus__c ='KO definitivo';
                update orders[0];
                
                update new Order(Id = orderId, SiebelStatus__c ='Pratica rifiutata');

                orders[1].SiebelStatus__c ='Eliminato';
                update orders[1];
            Test.stopTest();
        }

        i = 1;
        for (Order o : [SELECT Id,OrderNumber,SBQQ__Quote__c,Phase__c,Status,AccountId,RecordTypeId FROM Order WHERE ParentOrder__r.RecordTypeId = :constants.ORDER_RECORDTYPEID_ORDERDOSSIER]){
            System.assertEquals(true, ('Annullato'.equalsIgnoreCase(o.Status) && 'Annullato'.equalsIgnoreCase(o.Phase__c)),i+') Order ' + o.OrderNumber+' Phase__c '+o.Phase__c +' status ' +o.status+ ' quote ' + o.SBQQ__Quote__c+ '(orderId = '+orderId+' quote= '+qList[0].Id+'/'+qList[1].Id+')');
            i++;
        }
    }

    @isTest
    public static void testCheckCreditProcessStatus() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){

            List<Order> newOrderList = [SELECT Id,CreditCheckDescription__c, Phase__c, SiebelStatus__c, 
                                        ParentOrder__c, Status, PhaseStory__c, SBQQ__Contracted__c, recordTypeId,
                                        IncomingCreditCheckResult__c,OutgoingCreditCheckResult__c, OrderReferenceNumber,
                                        IsMassive__c, ContractReference__c, VasSubtype__c, CommodityFormula__c, isTransition__c 
                                        FROM Order WHERE Name = 'childOrder5' LIMIT 1];
        
            Order tmpOrd = new Order();
            tmpOrd.Id  = newOrderList[0].Id;
            tmpOrd.IncomingCreditCheckResult__c ='KO';

            Map<Id,Order> oldOrderMap = new Map<Id,Order>();
            oldOrderMap.put(tmpOrd.Id, tmpOrd);

            Test.startTest();

            HDT_UTL_OrderProcess.checkCreditProcessStatus(newOrderList, oldOrderMap);
            
            Test.stopTest();

            System.assertEquals('Documentazione Validata', newOrderList[0].Phase__c, 'Activity Custom created');
        }
    }

    @isTest
    public static void testCreditCheckActivityManagement() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){

            List<Order> newOrderList = [SELECT Id 
                                        FROM Order WHERE IsTransition__c = false LIMIT 2];
        
            newOrderList[0].IncomingCreditCheckResult__c = 'KO';
            newOrderList[1].IncomingCreditCheckResult__c = 'KO';
            newOrderList[0].CreditCheckDescription__c = 'TEST';
            newOrderList[1].CreditCheckDescription__c = 'TEST';

            Set<Id> ordersId = new Set<Id>{newOrderList[0].Id,newOrderList[1].Id};

            update newOrderList;

            System.assertEquals(2, HDT_QR_ActivityCustom.getActivityListCrediCheck(ordersId).size(), 'Le Activity di credit check non sono state create');

            Test.startTest();

            newOrderList[0].Phase__c = 'Annullato';
            newOrderList[1].Phase__c = 'Annullato';
            update newOrderList;
            
            Test.stopTest();

            System.assertEquals(0, HDT_QR_ActivityCustom.getActivityListCrediCheck(ordersId).size(), 'Le Activity di credit check non si sono chiuse');
        }
    }

    @isTest
    public static void testUpdateChildOrderIvr() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){

            List<Order> newList = [SELECT Id, Phase__c, SiebelStatus__c, ParentOrder__c, Status, PhaseStory__c, SBQQ__Contracted__c, recordTypeId, SignedDate__c,
                                          IncomingCreditCheckResult__c,OutgoingCreditCheckResult__c, OrderReferenceNumber, IsMassive__c, MethodSignedAccepted__c, 
                                          ContractReference__c, VasSubtype__c, CommodityFormula__c FROM Order WHERE Name = 'testOrderName1' LIMIT 1];

            Map<String,Order> oldMap = new Map<String,Order>();
            oldMap.put(newList[0].Id, newList[0]);
            List<Order> oldList = [SELECT Id, Phase__c, SiebelStatus__c, ParentOrder__c, Status, PhaseStory__c, SBQQ__Contracted__c, recordTypeId, SignedDate__c,
                                        IncomingCreditCheckResult__c,OutgoingCreditCheckResult__c, OrderReferenceNumber, IsMassive__c, MethodSignedAccepted__c, 
                                        ContractReference__c, VasSubtype__c, CommodityFormula__c FROM Order WHERE Name = 'childOrder5' LIMIT 1];
            oldMap.put(oldList[0].Id, oldList[0]);
            oldList = [SELECT Id, Phase__c, SiebelStatus__c, ParentOrder__c, Status, PhaseStory__c, SBQQ__Contracted__c, recordTypeId, SignedDate__c,
                                        IncomingCreditCheckResult__c,OutgoingCreditCheckResult__c, OrderReferenceNumber, IsMassive__c, MethodSignedAccepted__c, 
                                        ContractReference__c, VasSubtype__c, CommodityFormula__c FROM Order WHERE Name = 'childOrder6' LIMIT 1];
            oldMap.put(oldList[0].Id, oldList[0]);
            
            Map<String,Order> newMap = new Map<String,Order>();
            Order tmp = new Order();
            tmp.Id = newList[0].Id;
            tmp.MethodSignedAccepted__c = 'IVR';
            tmp.SignedDate__c = Date.Today();
            newMap.put(tmp.Id, tmp);

            Test.startTest();

            List<Order> returnList = HDT_UTL_OrderProcess.updateChildOrderIvr(oldMap, newMap);
            
            Test.stopTest();

            System.assertEquals(returnList[0].phase__c, 'Comunicazione verso Heroku', 'Fase non correttamente aggiornata');
            System.assertEquals(returnList[1].phase__c, 'Comunicazione verso Heroku', 'Fase non correttamente aggiornata');
        }
    }


}