/**
* @author Luis Bispo (luis.bispo@engdb.com.br)
* @date 23/07/2021
* @description HDT_LC_OrderDossierWizardSignature for Test Classes
* @history Luis Bispo – 23/07/2021 – Created class
*/


@isTest
public with sharing class HDT_LC_OrderDossierWizardSignatureTst {
    private static HDT_UTL_Constants utlConstants = new HDT_UTL_Constants();
    @TestSetup
    static void setup(){
       
        HDT_UTL_DataFactoryTst.pClickOrderPhase();
        List<Account> acc = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Sale__c> sale = HDT_UTL_DataFactoryTst.createSale(1, true, acc[0].Id, 'Bozza');
        List<Contact> cont = HDT_UTL_DataFactoryTst.createContact(1, true, acc[0].Id);
        List<Order> ord = HDT_UTL_DataFactoryTst.createOrder(1, false, acc[0].Id, 'Bozza');
        ord[0].RecordTypeId = utlConstants.ORDER_RECORDTYPEID_ORDERDOSSIER;
        insert ord;
        List<Order> childOrder = HDT_UTL_DataFactoryTst.createChildOrder(4, false, acc[0].Id, sale, ord[0].Id, cont[0].Id);
        childOrder[0].RecordTypeId = utlConstants.ORDER_RECORDTYPEID_SWITCHIN;
        childOrder[0].MarketOrigin__c = 'Libero';
        childOrder[0].CustomerCategory__c = 'Famiglie';
        childOrder[0].Channel__c = 'Agenzie';
        childOrder[0].ProcessType__c = 'Switch in Ele';
        childOrder[1].RecordTypeId = utlConstants.ORDER_RECORDTYPEID_VAS;
        childOrder[1].MarketOrigin__c = 'Libero';
        childOrder[1].CustomerCategory__c = 'Famiglie';
        childOrder[1].Channel__c = 'Agenzie';
        childOrder[1].ProcessType__c = 'VAS';
        childOrder[2].RecordTypeId = utlConstants.ORDER_RECORDTYPEID_DEFAULT;
        childOrder[2].ProcessType__c = '';
        insert childOrder;
        Map<Id,String> mapRecordType = new Map<Id,String>{
            utlConstants.ORDER_RECORDTYPEID_VAS => utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_VAS,
            utlConstants.ORDER_RECORDTYPEID_SWITCHIN => utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_SWITCHIN
        };
        List<ComfortQualityCall__c> config = new List<ComfortQualityCall__c>();
        Integer i = 0;
        for (ComfortQualityCall__c cqc : HDT_UTL_DataFactoryTst.createComfortQualityCall(2,false)){
            cqc.Process__c = mapRecordType.get(childOrder[i].RecordTypeId);
            cqc.CustomerType__c = childOrder[i].CustomerCategory__c;
            cqc.Channel__c = childOrder[i].Channel__c;
            cqc.MarketType__c = childOrder[i].MarketOrigin__c;
            if ('HDT_RT_VAS'.equalsIgnoreCase(mapRecordType.get(childOrder[i].RecordTypeId))){
                cqc.ComfortDocSendingChannel__c = 'E-Mail';
                cqc.ComfortEnabled__c = true;
            }else{
                cqc.QualityEnabled__c = true;
                cqc.QualitySignatureMethod__c = 'OTP Remoto';
            }
            cqc.DaysComfort__c = 5;
            config.add(cqc);
            i++;
        }
        insert config;
    }

    @isTest
    static void testControllerInit(){
        Test.startTest();
        Map<String,Object> result = HDT_LC_OrderDossierWizardSignature.controllerInit('test', 'test');
        System.debug('@@result' + result);
        System.assert(result != null, 'controllerInit did not work correctly');
		System.assertNotEquals(new Map<String,Object>{},result, 'controllerInit did not work correctly');
        Test.stopTest();
    }

    @isTest
    static void testNext(){
        Order ordParent = [SELECT Id,ParentOrder__c,ContractSigned__c FROM Order WHERE Name='testOrderName0' AND RecordTypeId = :utlConstants.ORDER_RECORDTYPEID_ORDERDOSSIER LIMIT 1];
        Order ordChild = [SELECT Id,ParentOrder__c,ContractSigned__c FROM Order WHERE Name='testChildOrderName' AND RecordTypeId = :utlConstants.ORDER_RECORDTYPEID_SWITCHIN LIMIT 1];
        Test.startTest();
        ordParent.SignatureMethod__c = 'OTP Remoto';
        HDT_LC_OrderDossierWizardSignature.next(ordParent);
		System.assertEquals(ordParent.Id,ordChild.ParentOrder__c, 'next did not work correctly');
		System.assertNotEquals(null,ordChild.ParentOrder__c, 'next did not work correctly');
        Test.stopTest();
    }

    @isTest
    static void testSignatureMethodSwitchIn(){
        Order ordParent = [SELECT Id,ParentOrder__c,ContractSigned__c, RecordTypeId, SignatureMethod__c, VolturaThirdTrader__c, AccountId FROM Order WHERE Name='testOrderName0' LIMIT 1];
        Order ordChild = [SELECT Id,ParentOrder__c,ContractSigned__c, RecordTypeId, VolturaThirdTrader__c FROM Order WHERE Name='testChildOrderName' LIMIT 1];  
        Test.startTest();
        ordChild.RecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_SwitchIn').getRecordTypeId();
        ordChild.VolturaThirdTrader__c = true;
        ordParent.SignatureMethod__c = 'Cartacea';
        HDT_UTL_DatabaseService.updateSObject(ordChild);
        HDT_LC_OrderDossierWizardSignature.next(ordParent);
		System.assertEquals(ordParent.Id,ordChild.ParentOrder__c, 'next did not work correctly');
		System.assertNotEquals(null,ordChild.ParentOrder__c, 'next did not work correctly');
        ordParent.SignatureMethod__c = 'Vocal Order';
        HDT_UTL_DatabaseService.updateSObject(ordChild);
        HDT_LC_OrderDossierWizardSignature.next(ordParent);
        Account acc = new Account(Id = ordParent.AccountId);
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('HDT_RT_Residenziale').getRecordTypeId();
        acc.CustomerMarking__c = 'D1 - Persona Fisica';
        acc.Category__C = 'Famiglie';
        acc.FiscalCode__c = 'SXSRLA45H28H5' + String.valueOf(101);
        acc.BillingCityCode__c='Roma';
        acc.BillingStreetName__c='via roma'; 
        acc.BillingStreetNumber__c='55';
        acc.CompanyOwner__c='HERA COMM';
        HDT_UTL_DatabaseService.updateSObject(acc);

        ordParent.SignatureMethod__c = 'Vocal Order';
        HDT_UTL_DatabaseService.updateSObject(ordChild);
        HDT_LC_OrderDossierWizardSignature.next(ordParent);

        ordParent.SignatureMethod__c = 'Cartacea';
        ordChild.SignatureMethod__c = 'Vocal Order';
        HDT_UTL_DatabaseService.updateSObject(ordChild);
        HDT_LC_OrderDossierWizardSignature.next(ordParent);

        Test.stopTest();
    }

    @isTest
    static void testSignatureMethodVolturaConSwitch(){
        Order ordParent = [SELECT Id,ParentOrder__c,ContractSigned__c, RecordTypeId, SignatureMethod__c, VolturaThirdTrader__c, AccountId FROM Order WHERE Name='testOrderName0' LIMIT 1];
        Order ordChild = [SELECT Id,ParentOrder__c,ContractSigned__c, RecordTypeId, VolturaThirdTrader__c FROM Order WHERE Name='testChildOrderName' LIMIT 1];  
        Test.startTest();
        ordChild.RecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_VolturaConSwitch').getRecordTypeId();
        ordChild.VolturaThirdTrader__c = true;
        ordParent.SignatureMethod__c = 'Cartacea';
        HDT_UTL_DatabaseService.updateSObject(ordChild);
        HDT_LC_OrderDossierWizardSignature.next(ordParent);
		System.assertEquals(ordParent.Id,ordChild.ParentOrder__c, 'next did not work correctly');
		System.assertNotEquals(null,ordChild.ParentOrder__c, 'next did not work correctly');
        ordParent.SignatureMethod__c = 'Vocal Order';
        HDT_UTL_DatabaseService.updateSObject(ordChild);
        HDT_LC_OrderDossierWizardSignature.next(ordParent);
        Account acc = new Account(Id = ordParent.AccountId);
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('HDT_RT_Residenziale').getRecordTypeId();
        acc.CustomerMarking__c = 'D1 - Persona Fisica';
        acc.Category__C = 'Famiglie';
        acc.FiscalCode__c = 'SXSRLA45H28H5' + String.valueOf(101);
        acc.BillingCityCode__c='Roma';
        acc.BillingStreetName__c='via roma'; 
        acc.BillingStreetNumber__c='55';
        acc.CompanyOwner__c='HERA COMM';
        HDT_UTL_DatabaseService.updateSObject(acc);

        ordParent.SignatureMethod__c = 'Vocal Order';
        HDT_UTL_DatabaseService.updateSObject(ordChild);
        HDT_LC_OrderDossierWizardSignature.next(ordParent);

        ordParent.SignatureMethod__c = 'Cartacea';
        ordChild.SignatureMethod__c = 'Vocal Order';
        HDT_UTL_DatabaseService.updateSObject(ordChild);
        HDT_LC_OrderDossierWizardSignature.next(ordParent);

        Test.stopTest();
    }

    @isTest
    static void testEdit(){
        Order ordParent = [SELECT Id,ParentOrder__c,ContractSigned__c FROM Order WHERE Name='testOrderName0' AND RecordTypeId = :utlConstants.ORDER_RECORDTYPEID_ORDERDOSSIER LIMIT 1];
        Order ordChild = [SELECT Id,ParentOrder__c,ContractSigned__c FROM Order WHERE Name='testChildOrderName' AND RecordTypeId = :utlConstants.ORDER_RECORDTYPEID_SWITCHIN LIMIT 1];
        Test.startTest();
        HDT_LC_OrderDossierWizardSignature.edit(ordParent.Id);
		System.assertEquals(ordParent.Id,ordChild.ParentOrder__c, 'edit did not work correctly');
		System.assertNotEquals(null,ordChild.ParentOrder__c, 'edit did not work correctly');
        Test.stopTest();
    }

}
