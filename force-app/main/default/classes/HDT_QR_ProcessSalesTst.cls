
@isTest
public with sharing class HDT_QR_ProcessSalesTst {
    private static HDT_UTL_Constants utlconstants = new HDT_UTL_Constants();
    
    @TestSetup
    static void setup(){

        List<Account> accounts=HDT_UTL_DataFactoryTst.createAccountBusiness(1, false, 'HERA COMM', 'Azienda', 'Aziende SME');
        accounts[0].ActiveMonitoring__c=false;
        accounts[0].Name='INRETE DIST. ENER.-13R0000000';
        accounts[0].LastName__c='INRETE DIST. ENER.-13R0000000';
        accounts[0].FiscalCode__c='SXSRLA45H28H6';
        accounts[0].VATNumber__c='12345689';
        accounts[0].CustomerCode__c='1003616211';
        accounts[0].CustomerMarking__c='Azienda';
        
        List<Account> accDist = HDT_UTL_DataFactoryTst.createAccountDistributore(1, true, 'HERA COMM', 'Azienda', 'Aziende SME'); 
        insert accounts;

        BillingProfile__c bp = new BillingProfile__c(
            Account__c = accounts[0].Id,
            ContractAccountCode__c = '200001008453'
        );
        insert bp;

        List<Contact> contacts = HDT_UTL_DataFactoryTst.createContact(1, false, accounts[0].Id);
        insert contacts;        
        
        HDT_UTL_DataFactoryTst.createServicePoint(1, true);

    } 
    

    @isTest
    public static void getAccountListTst(){

        Set<String> fiscalCodeSet = new Set<String>();
        Set<String> vatNumberSet = new Set<String>();
        Set<String> marcaturaSet = new Set<String>();
        Set<String> csnSet = new Set<String>();
        fiscalCodeSet.add('PMOPPP21M18E507H');
        vatNumberSet.add('12345689');
        marcaturaSet.add('Persona fisica');
        csnSet.add('1003616211');

        List<Account> lAcnt = HDT_QR_ProcessSales.getAccountList(fiscalCodeSet,vatNumberSet,marcaturaSet,csnSet);
        System.assertNotEquals(lAcnt[0], null, 'Query fails');

    }

    @isTest
    public static void getBillingProfileListTst(){

        Set<String> contoContrattualeSet = new  Set<String>();
        contoContrattualeSet.add('200001008453');
        List<BillingProfile__c> lbp = HDT_QR_ProcessSales.getBillingProfileList(contoContrattualeSet);
        System.assertNotEquals(lbp[0], null, 'Query fails');

    }

    @isTest
    public static void getAccountContactRelationByAccountIdTst(){

        List<AccountContactRelation> acrList = [SELECT Id, AccountId FROM AccountContactRelation WITH SECURITY_ENFORCED LIMIT 1];
        List<Id> accountIdsList = new List<Id>();
        Id id1 = [SELECT Id FROM Account WHERE Id = :acrList[0].AccountId WITH SECURITY_ENFORCED LIMIT 1].Id;
        accountIdsList.add(id1);
        List<AccountContactRelation> lacr = HDT_QR_ProcessSales.getAccountContactRelationByAccountId(acrList,accountIdsList);
        System.assertNotEquals(lacr[0], null, 'Query fails');

    }

    @isTest
    public static void getAccountContactRelationListTst(){

        List<AccountContactRelation> acrList = [SELECT Id, AccountId FROM AccountContactRelation WITH SECURITY_ENFORCED LIMIT 1];
        List<Id> accountIdsList = new List<Id>();
        Id id1 = [SELECT Id FROM Account WHERE Id = :acrList[0].AccountId WITH SECURITY_ENFORCED LIMIT 1].Id;
        accountIdsList.add(id1);
        List<AccountContactRelation> lacr = HDT_QR_ProcessSales.getAccountContactRelationList(acrList,accountIdsList);
        System.assertNotEquals(lacr[0], null, 'Query fails');

    }

    @isTest
    public static void getServicePointListTst(){

        List<ServicePoint__c> spList = [SELECT Id FROM ServicePoint__c WITH SECURITY_ENFORCED LIMIT 1];
        List<Id> spIdsList = new List<Id>();
        Id id1 = [SELECT Id FROM ServicePoint__c WITH SECURITY_ENFORCED LIMIT 1].Id;
        spIdsList.add(id1);
        List<ServicePoint__c> sps = HDT_QR_ProcessSales.getServicePointList(spList,spIdsList);
        System.assertNotEquals(sps[0], null, 'Query fails');

    }

}
