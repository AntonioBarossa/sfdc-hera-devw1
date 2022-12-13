/**
* @author Luis Bispo (luis.bispo@engdb.com.br)
* @date 23/07/2021
* @description HDT_LC_OrderDossierWizardSignature for Test Classes
* @history Luis Bispo – 23/07/2021 – Created class
*/


@isTest
public with sharing class HDT_LC_OrderDossierWizardSignatureTst {

    @TestSetup
    static void setup(){
       
        HDT_UTL_DataFactoryTst.pClickOrderPhase();
        List<Account> acc = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Sale__c> sale = HDT_UTL_DataFactoryTst.createSale(1, true, acc[0].Id, 'Bozza');
        List<Contact> cont = HDT_UTL_DataFactoryTst.createContact(1, true, acc[0].Id);
        List<Order> ord = HDT_UTL_DataFactoryTst.createOrder(1, true, acc[0].Id, 'Bozza');
        HDT_UTL_DataFactoryTst.createChildOrder(1, true, acc[0].Id, sale, ord[0].Id, cont[0].Id);
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
        Order ordParent = [SELECT Id,ParentOrder__c,ContractSigned__c FROM Order WHERE Name='testOrderName0' LIMIT 1];
        Order ordChild = [SELECT Id,ParentOrder__c,ContractSigned__c FROM Order WHERE Name='testChildOrderName' LIMIT 1];
        Test.startTest();
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
        Order ordParent = [SELECT Id,ParentOrder__c,ContractSigned__c FROM Order WHERE Name='testOrderName0' LIMIT 1];
        Order ordChild = [SELECT Id,ParentOrder__c,ContractSigned__c FROM Order WHERE Name='testChildOrderName' LIMIT 1];
        Test.startTest();
        HDT_LC_OrderDossierWizardSignature.edit(ordParent.Id);
		System.assertEquals(ordParent.Id,ordChild.ParentOrder__c, 'edit did not work correctly');
		System.assertNotEquals(null,ordChild.ParentOrder__c, 'edit did not work correctly');
        Test.stopTest();
    }

}
