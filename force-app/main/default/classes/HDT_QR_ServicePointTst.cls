/**
 * @author Lucas da Silva Fernandes (lucas.dasilva@engdb.com.br)
 * @date 03/09/2021
 * @description HDT_QR_City Test Class
 * @history Lucas da Silva Fernandes – 03/09/2021 – Created Class
 */

@isTest
public with sharing class HDT_QR_ServicePointTst {
    
    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();
    private static HDT_QR_ServicePoint qrServPoint = new HDT_QR_ServicePoint();

    @TestSetup
    static void setup(){
        
        // System Administrator User
        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
        User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
        internalUser.UserPermissionsMarketingUser=true;
        insert internalUser;

        Id rtServPoint=constants.SERVICEPOINT_RECORDTYPEID_PELETRICCO;

        System.runAs(internalUser) {

            List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
            
            List<ServicePoint__c> spList = HDT_UTL_DataFactoryTst.createServicePoint(1, false);
            spList[0].Account__c = accList[0].Id;
            spList[0].MeterSN__c ='meterTest';
            spList[0].SupplyCity__c = 'Firenze';
            spList[0].Distributor__c = accList[0].Id;
            spList[0].RecordTypeId = rtServPoint;
            spList[0].MeterStatus__c = 'Bozza';
            spList[0].CommoditySector__c = 'Energia Elettrica';
            spList[0].ImplantType__c = '13A0-Usi di Abitazione BT';
            spList[0].SupplyStreet__c = 'via rua';
            spList[0].SupplyStreetNumber__c = '51';
            spList[0].SupplyStreetNumberExtension__c = 'D';
            spList[0].SupplyPlace__c = 'myPlace';
            spList[0].SupplyProvince__c = 'AQ';
            spList[0].SupplyPostalCode__c = '67050';
            spList[0].SupplyCountry__c = 'Italy';
            spList[0].SupplySAPCityCode__c = 'FR';
            spList[0].SupplySAPStreetCode__c = '066057000041';
            spList[0].Status__c = 'Impianto compl. in funzione';
            
            insert spList;

            List<Contract> cttList = HDT_UTL_DataFactoryTst.createContract(1, false, accList[0].Id);
            cttList[0].ServicePoint__c = spList[0].Id;
            cttList[0].Name = 'contractTest';
            cttList[0].Status = 'Attivo';
            insert cttList;

            HDT_UTL_DataFactoryTst.createSubscription(1, true, accList[0].Id, cttList[0].Id, spList[0].Id);
            
            List<CS_SelezioneFornitura__c> selezioneList = HDT_UTL_DataFactoryTst.createSelezioneFornitura(1, false);
            selezioneList[0].Output_Contract__c = 'OutputContractTest';
            selezioneList[0].Max_Record__c = 1.0;
            selezioneList[0].OutputServicePoint__c = 'testOutputServicePoint';
            selezioneList[0].FieldRequiredEle__c = 'testFieldRequiredEle';
            selezioneList[0].FieldRequiredGas__c = 'testFieldRequiredGas';
            
            insert selezioneList;
        }
    }

    @isTest
    public static void testGetAccountServicePoints() {

        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
    
        System.runAs(u){

            Test.startTest();

            ServicePoint__c sp = [SELECT Id FROM ServicePoint__c WHERE MeterStatus__c = 'Bozza'];
            Account acc = [SELECT Id FROM Account WHERE Category__c = 'Aziende SME'];

            List<ServicePoint__c> spList = qrServPoint.getAccountServicePoints(acc.Id);

            Test.stopTest();

            System.assertEquals(sp.Id, spList[0].Id, 'ServicePoint successfully queried');
            System.assertNotEquals(null, spList[0].Id, 'ServicePoint query failed');
        }
    }

    @isTest
    public static void testGetAddressFornitura() {

        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
    
        System.runAs(u){

            Test.startTest();

            Account acc = [SELECT Id FROM Account WHERE Category__c = 'Aziende SME'];

            List<ServicePoint__c> spList = qrServPoint.getAddressFornitura(acc.Id);

            Test.stopTest();
         
            System.assertEquals(acc.Id, spList[0].Account__c, 'ServicePoint successfully queried');
            System.assertNotEquals(null, spList[0].Account__c, 'ServicePoint query failed');
        }
    }

    @isTest
    public static void testGetAccountServicePointsWithFilter() {

        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
    
        System.runAs(u){

            Test.startTest();

            Account acc = [SELECT Id FROM Account WHERE Category__c = 'Aziende SME'];

            List<ServicePoint__c> spList = qrServPoint.getAccountServicePointsWithFilter(acc.Id, 'AND CommoditySector__c = \'Energia Elettrica\'');

            Test.stopTest();
         
            System.assertEquals(acc.Id, spList[0].Account__c, 'ServicePoint successfully queried');
            System.assertNotEquals(null, spList[0].Account__c, 'ServicePoint query failed');
        }
    }

    @isTest
    public static void testGetRecordById() {

        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
    
        System.runAs(u){

            Test.startTest();

            ServicePoint__c sp = [SELECT Id, SupplyCity__c FROM ServicePoint__c WHERE SupplyCity__c = 'Firenze'];

            List<ServicePoint__c> spList = qrServPoint.getRecordById(sp.Id, 'Id, SupplyCity__c');

            Test.stopTest();
         
            System.assertEquals(sp.Id, spList[0].Id, 'ServicePoint successfully queried');
            System.assertNotEquals(null, spList[0].Id, 'ServicePoint query failed');
        }
    }

    @isTest
    public static void testGetRecordByIdList() {

        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
    
        System.runAs(u){

            Test.startTest();

            List<ServicePoint__c> sp = [SELECT Id, SupplyCity__c FROM ServicePoint__c WHERE SupplyCity__c = 'Firenze'];

            List<String> spId = new List<String>();

            for (Integer i=0; i<sp.size(); i++){

                String id = String.valueOf(sp[i].Id);
                spId.add(id);
            }

            List<ServicePoint__c> spList = qrServPoint.getRecordByIdList(spId, 'Id, SupplyCity__c');

            Test.stopTest();
         
            System.assertEquals(sp[0].Id, spList[0].Id, 'ServicePoint successfully queried');
            System.assertNotEquals(null, spList[0].Id, 'ServicePoint query failed');
        }
    }

    @isTest
    public static void testGetRecordByCode() {

        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
    
        System.runAs(u){

            Test.startTest();

            ServicePoint__c sp = [SELECT Id, ServicePointCode__c FROM ServicePoint__c WHERE SupplyCity__c = 'Firenze'];

            List<ServicePoint__c> spList = qrServPoint.getRecordByCode(sp.ServicePointCode__c, 'Id, ServicePointCode__c');

            Test.stopTest();
         
            System.assertEquals(sp.Id, spList[0].Id, 'ServicePoint successfully queried');
            System.assertNotEquals(null, spList[0].Id, 'ServicePoint query failed');
        }
    }

    @isTest
    public static void testGetRecordFromCode() {

        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
    
        System.runAs(u){

            Test.startTest();

            ServicePoint__c sp = [SELECT Id, ServicePointCode__c FROM ServicePoint__c WHERE SupplyCity__c = 'Firenze'];
            Contract ctt = [SELECT Id, SAPContractCode__c FROM Contract WHERE Name = 'contractTest'];

            List<ServicePoint__c> spList = qrServPoint.getRecordFromCode(ctt.SAPContractCode__c, 'Id');

            Test.stopTest();
         
            System.assertEquals(sp.Id, spList[0].Id, 'ServicePoint successfully queried');
            System.assertNotEquals(null, spList[0].Id, 'ServicePoint query failed');
        }
    }

    @isTest
    public static void testGetRecordFromCodeWithFilter() {

        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
    
        System.runAs(u){

            Test.startTest();

            ServicePoint__c sp = [SELECT Id, ServicePointCode__c, Status__c FROM ServicePoint__c WHERE SupplyCity__c = 'Firenze'];
            Contract ctt = [SELECT Id, SAPContractCode__c FROM Contract WHERE Name = 'contractTest'];

            List<ServicePoint__c> spList = qrServPoint.getRecordFromCodeWithFilter(ctt.SAPContractCode__c, 'Id', 'AND Status = \'Attivo\'');
            List<ServicePoint__c> spList2 = qrServPoint.getRecordFromCodeWithFilter(ctt.SAPContractCode__c, 'Id', 'AND CommoditySector__c = \'Energia Elettrica\'');

            Test.stopTest(); 
            
            System.assertEquals(sp.Id, spList[0].Id, 'ServicePoint successfully queried');
            System.assertNotEquals(null, spList[0].Id, 'ServicePoint query failed');

            System.assertEquals(sp.Id, spList2[0].Id, 'ServicePoint successfully queried');
            System.assertNotEquals(null, spList2[0].Id, 'ServicePoint query failed');
        }
    }

    @isTest
    public static void testGetServicePointsByMeterSerialNumber() {

        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
    
        System.runAs(u){

            Test.startTest();

            ServicePoint__c sp = [SELECT Id, MeterSN__c FROM ServicePoint__c WHERE MeterStatus__c = 'Bozza'];

            List<ServicePoint__c> spList = qrServPoint.getServicePointsByMeterSerialNumber(sp.MeterSN__c, 'Id');

            Test.stopTest();
         
            System.assertEquals(sp.Id, spList[0].Id, 'ServicePoint successfully queried');
            System.assertNotEquals(null, spList[0].Id, 'ServicePoint query failed');
        }
    }

    @isTest
    public static void testGetServicePointsByMeterSerialNumberWithFilter() {

        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
    
        System.runAs(u){

            Test.startTest();

            ServicePoint__c sp = [SELECT Id, MeterSN__c FROM ServicePoint__c WHERE MeterStatus__c = 'Bozza'];

            List<ServicePoint__c> spList = qrServPoint.getServicePointsByMeterSerialNumberWithFilter(sp.MeterSN__c, 'Id', 'AND SupplyCity__c = \'Firenze\'');

            List<ServicePoint__c> spList2 = qrServPoint.getServicePointsByMeterSerialNumberWithFilter(sp.MeterSN__c, 'Id', 'AND Status__c = \'Impianto compl. in funzione\'');

            Test.stopTest();
         
            System.assertEquals(sp.Id, spList[0].Id, 'ServicePoint successfully queried');
            System.assertNotEquals(null, spList[0].Id, 'ServicePoint query failed');

            System.assertEquals(sp.Id, spList2[0].Id, 'ServicePoint successfully queried');
            System.assertNotEquals(null, spList2[0].Id, 'ServicePoint query failed');
        }
    }

    @isTest
    public static void testGetServicePointsByCode() {

        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
    
        System.runAs(u){

            Test.startTest();

            ServicePoint__c sp = [SELECT Id, ServicePointCode__c FROM ServicePoint__c WHERE MeterStatus__c = 'Bozza'];

            List<ServicePoint__c> spList = qrServPoint.getServicePointsByCode(sp.ServicePointCode__c, 'Id');

            Test.stopTest();
         
            System.assertEquals(sp.Id, spList[0].Id, 'ServicePoint successfully queried');
            System.assertNotEquals(null, spList[0].Id, 'ServicePoint query failed');
        }
    }

    @isTest
    public static void testGetServicePointsByCodeWithFilter() {

        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
    
        System.runAs(u){

            Test.startTest();

            ServicePoint__c sp = [SELECT Id, ServicePointCode__c FROM ServicePoint__c WHERE MeterStatus__c = 'Bozza'];

            List<ServicePoint__c> spList = qrServPoint.getServicePointsByCodeWithFilter(sp.ServicePointCode__c, 'Id', 'AND Status__c = \'Impianto compl. in funzione\'');

            List<ServicePoint__c> spList2 = qrServPoint.getServicePointsByCodeWithFilter(sp.ServicePointCode__c, 'Id', 'AND SupplyCity__c = \'Firenze\'');

            Test.stopTest();
         
            System.assertEquals(sp.Id, spList[0].Id, 'ServicePoint successfully queried');
            System.assertNotEquals(null, spList[0].Id, 'ServicePoint query failed');

            System.assertEquals(sp.Id, spList2[0].Id, 'ServicePoint successfully queried');
            System.assertNotEquals(null, spList2[0].Id, 'ServicePoint query failed');
        }
    }

    @isTest
    public static void testGetAccountContracts() {

        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
    
        System.runAs(u){

            Test.startTest();

            Account acc = [SELECT Id FROM Account WHERE Category__c = 'Aziende SME'];

            Contract ctt = [SELECT Id, ContractNumber FROM Contract WHERE Name = 'contractTest'];

            List<Contract> cttList = qrServPoint.getAccountContracts(acc.Id);

            Test.stopTest();
  
            System.assertEquals(ctt.ContractNumber, cttList[0].ContractNumber, 'Contract successfully queried');
            System.assertNotEquals(null, cttList[0].ContractNumber, 'Contract query failed');
        }
    }

    @isTest
    public static void testGetAccountSubscriptions() {

        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
    
        System.runAs(u){

            Test.startTest();

            Account acc = [SELECT Id FROM Account WHERE Category__c = 'Aziende SME'];

            SBQQ__Subscription__c subs = [SELECT Id FROM SBQQ__Subscription__c WHERE SBQQ__Account__c =: acc.Id];

            List<SBQQ__Subscription__c> subsList = qrServPoint.getAccountSubscriptions(acc.Id);

            Test.stopTest();
         
            System.assertEquals(subs.Id, subsList[0].Id, 'SBQQ__Subscription__c successfully queried');
            System.assertNotEquals(null, subsList[0].Id, 'SBQQ__Subscription__c query failed');
        }
    }

    @isTest
    public static void testGetCustomSetting() {

        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
    
        System.runAs(u){

            Test.startTest();

            List<CS_SelezioneFornitura__c> selezList = new List<CS_SelezioneFornitura__c>();

            CS_SelezioneFornitura__c selezione = qrServPoint.getCustomSetting();

            selezList.add(selezione);

            Test.stopTest();
         
            System.assertEquals(false, selezList.isEmpty(), 'CS_SelezioneFornitura__c successfully queried');
            System.assertNotEquals(true, selezList.isEmpty(), 'CS_SelezioneFornitura__c query failed');
        }
    }

    @isTest
    public static void testGetCustomSettingFieldsRequiredEle() {

        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
    
        System.runAs(u){

            Test.startTest();

            List<CS_SelezioneFornitura__c> selezList = new List<CS_SelezioneFornitura__c>();

            CS_SelezioneFornitura__c selezione = HDT_QR_ServicePoint.getCustomSettingFieldsRequiredEle();

            selezList.add(selezione);

            Test.stopTest();
         
            System.assertEquals(false, selezList.isEmpty(), 'CS_SelezioneFornitura__c successfully queried');
            System.assertNotEquals(true, selezList.isEmpty(), 'CS_SelezioneFornitura__c query failed');
        }
    }

    @isTest
    public static void testGetCustomSettingFieldsRequiredGas() {

        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
    
        System.runAs(u){

            Test.startTest();

            List<CS_SelezioneFornitura__c> selezList = new List<CS_SelezioneFornitura__c>();

            CS_SelezioneFornitura__c selezione = HDT_QR_ServicePoint.getCustomSettingFieldsRequiredGas();

            selezList.add(selezione);

            Test.stopTest();
         
            System.assertEquals(false, selezList.isEmpty(), 'CS_SelezioneFornitura__c successfully queried');
            System.assertNotEquals(true, selezList.isEmpty(), 'CS_SelezioneFornitura__c query failed');
        }
    }
}
