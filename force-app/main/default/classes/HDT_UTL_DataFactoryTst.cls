/**
* @author Lucas da Silva Fernandes (lucas.dasilva@engdb.com.br)
* @date 29/06/2021
* @description Data Factory for Test Classes
* @history Lucas da Silva Fernandes – 29/06/2021 – Created class
*/

public with sharing class HDT_UTL_DataFactoryTst {

    //Method to avoid 'ObjectCompatibility' errors from ProcessClick
    public static void pClickInstance() {
        
        wrts_prcgvr.InstallIntegration.install();
        wrts_prcgvr.VersionManager.newClassInstance('ObjectCompatibility');
    }

    //Metho to avoid PClick for OrderPhase Errors
    public static void pClickOrderPhase(){
        wrts_prcgvr.InstallIntegration.install();
        wrts_prcgvr__PhaseManagerSObjectSetting__c setting = new wrts_prcgvr__PhaseManagerSObjectSetting__c(Name = 'Order', wrts_prcgvr__ObjectType__c = 'Order', wrts_prcgvr__PivotField__c = 'Phase__c');
        insert setting;
    }

    public static List<Lead> createLead(Integer amount, Boolean doInsert) {

        List<Lead> leadList = new List<Lead>();

        for (Integer i=0; i<amount; i++) {

            Lead ld = new Lead();
            
            ld.FirstName = 'FirstNameTest'+i;
            ld.LastName = 'LastNameTest';
            ld.CompanyOwner__c = 'MMS';
            ld.Company = 'CompanyTest';
            ld.Status = 'New';
            ld.Email = 'test@test.com';
            ld.Birthdate__c = date.today();
            ld.Gender__c = 'Maschio';
            ld.Birthcity__c = 'Roma';

            leadList.add(ld);

        }
        
        if (doInsert) {

            insert leadList;
        }

        return leadList;
    }


    public static List<City__c> createCity(Integer amount, Boolean doInsert) {
        List<City__c> cityList = new List<City__c>();

        for (Integer i=0; i<amount; i++) {

            City__c ct = new City__c();
            
            ct.Name = 'Roma';
            ct.BelfioreCode__c = 'Bt'+i;

            cityList.add(ct);

        }
        
        if (doInsert) {

            insert cityList;
        }

        return cityList;
    }
    
    public static List<Opportunity> createOpportunity (Integer amount, Boolean doInsert) {

        List<Opportunity> oppList = new List<Opportunity>();

        for (Integer i=0; i<amount; i++) {

            Opportunity opp = new Opportunity();

            opp.Name = 'testOpportunity'+ i;
            opp.CloseDate = Date.today().addDays(30);
            opp.StageName = 'Negotiation';

            oppList.add(opp);
        }        

        if (doInsert) {

            insert oppList;
        }

        return oppList;
    }

    public static List<Account> createAccount(Integer amount, Boolean doInsert) {
        
        List<Account> accList = new List<Account>();

        Id rt = [SELECT Id 
                FROM Recordtype 
                WHERE SobjectType = 'Account' and Developername = 'HDT_RT_Business' 
                LIMIT 1].Id;

        for (Integer i=0; i<amount; i++) {

            Account acc = new Account();

            acc.RecordTypeId = rt;
            acc.Name = 'test account'+i;
            acc.CompanyOwner__c = 'HERA COMM';
            acc.CustomerMarking__c = 'Azienda';
            acc.Category__C = 'Aziende SME';
            acc.VATNumber__c = '12345678901';
            acc.BillingCityCode__c = 'Roma';
            acc.BillingStreetName__c = 'via roma';
            acc.BillingStreetNumber__c = '55';
            acc.LastName__c = 'test account'+i;

            accList.add(acc);

        }
        
        if (doInsert) {

            insert accList;
        }

        return accList;
    }
    
    public static List<Order> createOrder(Integer amount, Boolean doInsert, Id accId) {

        List<Order> orderList = new List<Order>();

        Id rt = [SELECT Id 
                FROM Recordtype 
                WHERE SobjectType = 'Order' and Developername = 'HDT_RT_Default' 
                LIMIT 1].Id;

        for (Integer i=0; i<amount; i++) {

            Order ord = new Order();

            ord.RecordTypeId = rt;
            ord.Name = 'testOrderName'+i;
            ord.Status = 'Draft';
            ord.EffectiveDate = Date.today();
            ord.AccountId = accId;
            ord.EstimateAmount__c = 1000;
            ord.PowerQuote__c = 1000;
            ord.AdministrativeBurden__c = 1; 
            ord.EstimatedVAT__c = 1; 
            ord.ValidityDateEstimate__c = Date.today().addDays(30);
            ord.Phase__c = 'Bozza';

            orderList.add(ord);
        }

        if (doInsert) {

            insert orderList;
        }

        return orderList;
    }

    public static List<Sale__c> createSale (Integer amount, Boolean doInsert, Id accId, String status) {

        List<Sale__c> salesList = new List<Sale__c>();

        for (Integer i=0; i<amount; i++) {

            Sale__c sale = new Sale__c();

            sale.Name = 'testSaleName'+i;
            sale.Status__c = status;
            sale.Account__c = accId;

            salesList.add(sale);
        }

        if (doInsert) {

            insert salesList;
        }

        return salesList;
    }
}