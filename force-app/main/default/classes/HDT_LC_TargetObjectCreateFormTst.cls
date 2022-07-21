/**
 * @author Lucas da Silva Fernandes (lucas.dasilva@engdb.com.br)
 * @date 27/08/2021
 * @description HDT_LC_TargetObjectCreateForm Test Class
 * @history Lucas da Silva Fernandes – 27/08/2021 – Created Class
 */
@isTest
public with sharing class HDT_LC_TargetObjectCreateFormTst {

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
            HDT_UTL_DataFactoryTst.createWebServiceConfiguration('TransitorioWinback', 'end', 'method', 'testUser');
            HDT_UTL_DataFactoryTst.createWebServiceCredential('testUser', '12345', 'usernameTest');

            City__c city = new City__c();
            city.Name = 'CHIETI';
            city.Province__c = 'CH';
            insert city;

            List<Account> acc = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'Reseller', 'GENESI-Altro', 'Reseller - Gruppo');
            
            List<ServicePoint__c> spList = HDT_UTL_DataFactoryTst.createServicePoint(1, false);
            spList[0].Name = 'servicepointTest';
            spList[0].SwitchInWinback__c = false;
            spList[0].SupplyCity__c = city.Name;
            spList[0].CommoditySector__c = 'Gas';
            insert spList;

            List<Sale__c> sales = HDT_UTL_DataFactoryTst.createSale(1, true, acc[0].Id, 'Bozza');
            List<Order> orders = HDT_UTL_DataFactoryTst.createOrder(1, true, acc[0].Id, 'Bozza');
            List<DistributorPointCode__c> dpcList = HDT_UTL_DataFactoryTst.createDistributorPointCode(1, false, acc[0].Id);
            dpcList[0].Commodity__c = 'Gold';
            dpcList[0].PointCode__c = 'Point';
            insert dpcList;

            List<Opportunity> oppList = HDT_UTL_DataFactoryTst.createOpportunity(1, false);
            oppList[0].Sale__c = sales[0].Id;
            insert oppList;

            List<SBQQ__Quote__c> quotes = HDT_UTL_DataFactoryTst.createQuote(1, false, orders[0].Id, oppList[0].Id, sales[0].Id, 'Amendment');
            quotes[0].SBQQ__Status__c = 'Accepted';
            insert quotes;

            HDT_UTL_DataFactoryTst.createSaleServiceItem(1, true, oppList[0].Id, quotes[0].Id, spList[0].Id);
        }
    }

    @isTest
    public static void testGetServicePoint() {

        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];

        System.runAs(u){

            Test.startTest();

            ServicePoint__c sp = [SELECT Id, ServicePointCode__c FROM ServicePoint__c WHERE Name = 'servicepointTest'];

            List<ServicePoint__c> testSp = HDT_LC_TargetObjectCreateForm.getServicePoint(sp.ServicePointCode__c, 'Id');

            System.assertEquals(sp.Id, testSp[0].Id, 'ServicePoint matches');

            System.assertNotEquals(null, testSp[0].Id, 'ServicePoint does not match');

            Test.stopTest();
        }
    }

    @isTest
    public static void testCreateServicePoint() {

        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];

        System.runAs(u){

            Test.startTest();

            ServicePoint__c testSp = new ServicePoint__c(
                Name='ServicePointName',
			    ServicePointCode__c='ACE',
                MeterStatus__c = 'Bozza'
            );

            ServicePoint__c targetTest = HDT_LC_TargetObjectCreateForm.createServicePoint(testSp);

            System.assertEquals(testSp.Name, targetTest.Name, 'ServicePoint matches');

            System.assertNotEquals(null, targetTest.Name, 'ServicePoint does not match');

            Test.stopTest();
        }
    }

    @isTest
    public static void testCreateServicePointString() {

        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];

        System.runAs(u){

            Test.startTest();

            Sale__c sale = [SELECT Id FROM Sale__c WHERE Status__c = 'Bozza'];

            City__c city = [SELECT Name, Province__c FROM City__c WITH SECURITY_ENFORCED LIMIT 1];

            ServicePoint__c testSp = new ServicePoint__c(
                Name='ServicePointName',
			    ServicePointCode__c='KING',
                MeterStatus__c = 'Bozza',
                SupplyCity__c = city.Name,
                CommoditySector__c = 'Gas'
            );

            String serializedServicePoint = JSON.serialize(testSp, true);

            ServicePoint__c targetTest = HDT_LC_TargetObjectCreateForm.createServicePoinString(serializedServicePoint, sale);
            
            System.assertEquals(testSp.Name, targetTest.Name, 'ServicePoint matches');

            System.assertNotEquals(null, targetTest.Name, 'ServicePoint does not match');

            Test.stopTest();
        }
    }

    @isTest
    public static void testConfirmServicePointTrue() {

        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];

        System.runAs(u){

            Test.startTest();

            ServicePoint__c testSp = new ServicePoint__c(
                Name='ServicePointName',
			    ServicePointCode__c='SPADES',
                MeterStatus__c = 'Bozza'
            );

            ServicePoint__c targetTest1 = HDT_LC_TargetObjectCreateForm.confirmServicePoint(testSp, true);
            
            System.assertEquals(testSp.Name, targetTest1.Name, 'ServicePoint matches');

            System.assertNotEquals(null, targetTest1.Name, 'ServicePoint does not match');

            Test.stopTest();
        }
    }

    @isTest
    public static void testConfirmServicePointFalse() {

        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];

        System.runAs(u){

            City__c city = [SELECT Name, Province__c FROM City__c WITH SECURITY_ENFORCED LIMIT 1];
            //Second Test passing sap as false
            ServicePoint__c testSpoint = new ServicePoint__c(
                Name='ServicePointName',
			    ServicePointCode__c='JOKER',
                MeterStatus__c = 'Bozza',
                CommoditySector__c = 'Energia Elettrica',
                PlugPresence__c = 'Si',
                PowerRequested__c = 5.0,
                PowerContractual__c = 5.0,
                RecordTypeId = constants.SERVICEPOINT_RECORDTYPEID_PELETRICCO,
                SupplyCity__c = city.Name,
                MarketOrigin__c = 'Libero'
            );
            insert testSpoint;
            
            Opportunity opp = [SELECT Id, Sale__c, Name, CreatedDate FROM Opportunity WHERE Sale__r.Status__c = 'Bozza'];
            SBQQ__Quote__c quote = [SELECT Id, Name FROM SBQQ__Quote__c WHERE SBQQ__Type__c = 'Amendment'];

            SaleServiceItem__c ssi = new SaleServiceItem__c(
                Opportunity__c = opp.Id,
                Quote__c = quote.Id,
                ServicePoint__c = testSpoint.Id
            );
            insert ssi;

            HDT_WS_HTTPServiceCallMock mock = new HDT_WS_HTTPServiceCallMock();

            Test.setMock(HttpCalloutMock.class, mock);

            Test.startTest();

            ServicePoint__c targetTest2 = HDT_LC_TargetObjectCreateForm.confirmServicePoint(testSpoint, false);
            
            System.assertEquals(testSpoint.Name, targetTest2.Name, 'ServicePoint matches');

            System.assertNotEquals(null, targetTest2.Name, 'ServicePoint does not match');

            Test.stopTest();
        }
    }

    @isTest
    public static void testGetDistributorPointCode() {

        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];

        System.runAs(u){

            DistributorPointCode__c dpc = [SELECT Id, PointCode__c, Commodity__c, City__c FROM DistributorPointCode__c WHERE Commodity__c = 'Gold'];

            Test.startTest();

            List<DistributorPointCode__c> targetTest = HDT_LC_TargetObjectCreateForm.getDistributorPointCode(dpc.PointCode__c, dpc.Commodity__c, dpc.City__c, 'Si');

            System.assertEquals(dpc.PointCode__c, targetTest[0].PointCode__c, 'ServicePoint matches');
            System.assertNotEquals(null, targetTest[0].PointCode__c, 'ServicePoint does not match');

            Test.stopTest();
        }
    }

    @isTest
    public static void testConfirmServicePoint2True() {

        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];

        System.runAs(u){

            City__c city = [SELECT Name, Province__c FROM City__c WITH SECURITY_ENFORCED LIMIT 1];

            ServicePoint__c testSpoint = new ServicePoint__c(
                Name='ServicePointName',
			    ServicePointCode__c='NOVE',
                MeterStatus__c = 'Bozza',
                CommoditySector__c = 'Energia Elettrica',
                PlugPresence__c = 'Si',
                PowerRequested__c = 5.0,
                PowerContractual__c = 5.0,
                RecordTypeId = constants.SERVICEPOINT_RECORDTYPEID_PELETRICCO,
                SupplyCity__c = city.Name,
                MarketOrigin__c = 'Libero'
            );

            Sale__c sale = [SELECT Id FROM Sale__c WHERE Status__c = 'Bozza'];

            HDT_WS_HTTPServiceCallMock mock = new HDT_WS_HTTPServiceCallMock();
            Test.setMock(HttpCalloutMock.class, mock);
            Test.startTest();

            ServicePoint__c targetTest = HDT_LC_TargetObjectCreateForm.confirmServicePoint2(testSpoint, true, sale);

            System.assertEquals(testSpoint.Id, targetTest.Id, 'ServicePoint matches');
            System.assertNotEquals(null, targetTest.Id, 'ServicePoint matches');

            Test.stopTest();
        }
    }

    @isTest
    public static void testConfirmServicePoint2False() {

        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];

        System.runAs(u){
        
            ServicePoint__c sp = [SELECT Id, ServicePointCode__c,  MeterStatus__c, CommoditySector__c,
                                    PlugPresence__c, PowerRequested__c, PowerContractual__c, RecordTypeId,
                                    SupplyCity__c, MarketOrigin__c, ImplantType__c, SupplyType__c, isReseller__c
                                  FROM ServicePoint__c
                                  WHERE Name = 'servicepointTest'];

            Sale__c sale = [SELECT Id FROM Sale__c WHERE Status__c = 'Bozza'];

            HDT_WS_HTTPServiceCallMock mock = new HDT_WS_HTTPServiceCallMock();
            Test.setMock(HttpCalloutMock.class, mock);
            Test.startTest();

            ServicePoint__c targetTest = HDT_LC_TargetObjectCreateForm.confirmServicePoint2(sp, false, sale);

            System.assertEquals(sp.Id, targetTest.Id, 'ServicePoint matches');
            System.assertNotEquals(null, targetTest.Id, 'ServicePoint matches');

            Test.stopTest();
        }
    }
    @isTest
    static void checkCoerenceServicePoint()
    {
        Map<String, Object> servicePoint = new Map<String, Object>
        {
            'SupplyType__c' => 'Domestico',
            'MarketOrigin__c' => 'Salvaguardia',
            'CommoditySector__c' => 'Energia Elettrica',
            'PowerRequested__c' => '13',
            'RequestPhase__c' => 'Monofase',
            'ImplantType__c' => 'Tipo Impianto errato'
        };
        Map<String, Object> inputFieldMap = new Map<String, Object>
        {
            'CategoriaCliente' => 'Famiglie',
            'TipoFornitura' => 'A-Domestico',
            'TipoImpianto' => 'Tipo Impianto errato',
            'Servizio' => 'Gas',
            'ProfiloPrelievo' => '001 - 7 giorni',
            'CategoriaUso' => '001-Uso cottura cibi',
            'Imposta' => 'G_ICD'
        };
        Test.startTest();
            String result = HDT_LC_TargetObjectCreateForm.checkCoerenceServicePoint(servicePoint, inputFieldMap);
        Test.stopTest();
        System.assertEquals(true, String.isNotBlank(result), 'Check non eseguito correttamente');
    }
}