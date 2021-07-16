/**
* @author Lucas da Silva Fernandes (lucas.dasilva@engdb.com.br)
* @date 29/06/2021
* @description Data Factory for Test Classes
* @history Luis Bispo – 13/07/2021 – Created City Object
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

    public static List<Account> createAccountBusiness(Integer amount, Boolean doInsert, String companyOwner, String customerMarking, String category) {
        
        List<Account> accList = new List<Account>();

        HDT_UTL_Constants constRecordType = new HDT_UTL_Constants();

        Id rt = constRecordType.ACCOUNT_RECORDTYPEID_BUSINESS;

        for (Integer i=0; i<amount; i++) {

            Account acc = new Account();

            acc.RecordTypeId = rt;
            acc.Name = 'test account'+i;
            acc.CompanyOwner__c = companyOwner;
            acc.CustomerMarking__c = customerMarking;
            acc.Category__C = category;
            acc.VATNumber__c = '12345678901';
            acc.BillingCityCode__c = 'Roma';
            acc.BillingStreetName__c = 'via roma';
            acc.BillingStreetNumber__c = '55';
            acc.LastName__c = 'test account'+i;
            acc.FiscalCode__c = 'SXSRLA45H28H501K';

            accList.add(acc);

        }
        
        if (doInsert) {

            insert accList;
        }

        return accList;
    }
    public static List<Order> createOrder(Integer amount, Boolean doInsert, Id accId) {

        List<Order> orderList = new List<Order>();

        HDT_UTL_Constants constRecordType = new HDT_UTL_Constants();

        Id rt = constRecordType.ORDER_RECORDTYPEID_DEFAULT;

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
            ord.CIAccoutn__c = 'Richiesto';
            ord.QuickQuote__c = 'Richiesto';
            ord.ChamberCommerceRegistration__c = 'Richiesto';
            ord.Instance326__c = 'Richiesto';
            ord.DocumentLow80__c = 'Richiesto';
            ord.AutorizationVolturaThirdTrader__c = 'Richiesto';
            ord.ContractSigned__c = true;
            ord.SignedDate__c = Date.today();
            ord.SignatureMethod__c = 'Vocal Order';
            ord.DocSendingMethod__c = 'E-mail';

            orderList.add(ord);
        }

        if (doInsert) {

            insert orderList;
        }

        return orderList;
    }

    public static List<Order> createOrder(Integer amount, Boolean doInsert, Id accId, List<Sale__c> sales) {

        List<Order> orderList = new List<Order>();

        HDT_UTL_Constants constRecordType = new HDT_UTL_Constants();

        Id rt = constRecordType.ORDER_RECORDTYPEID_DEFAULT;

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
            ord.CIAccoutn__c = 'Richiesto';
            ord.QuickQuote__c = 'Richiesto';
            ord.ChamberCommerceRegistration__c = 'Richiesto';
            ord.Instance326__c = 'Richiesto';
            ord.DocumentLow80__c = 'Richiesto';
            ord.AutorizationVolturaThirdTrader__c = 'Richiesto';
            ord.ContractSigned__c = true;
            ord.SignedDate__c = Date.today();
            ord.SignatureMethod__c = 'Vocal Order';
            ord.DocSendingMethod__c = 'E-mail';
            ord.Sale__c = sales[i].Id;

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


    public static List<ServicePoint__c> createServicePoint (Integer amount, Boolean doInsert) {

        List<ServicePoint__c> servPointList = new List<ServicePoint__c>();

        for (Integer i=0; i<amount; i++) {

            ServicePoint__c servPoint = new ServicePoint__c();

            servPointList.add(servPoint);
        }

        if (doInsert) {

            insert servPointList;
        }

        return servPointList;
    }


    public static List<Contact> createContact (Integer amount, Boolean doInsert, Id accId) {

        List<Contact> contactList = new List<Contact>();

        for (Integer i=0; i<amount; i++) {

            Contact testContact = new Contact();
            testContact.FirstName = 'test';
            testContact.LastName = 'tester';
            testContact.AccountId = accId;

            contactList.add(testContact);
        }

        if (doInsert) {

            insert contactList;
        }

        return contactList;
    }



    public static List<Contract> createContract (Integer amount, Boolean doInsert, Id accId) {

        List<Contract> contractList = new List<Contract>();

        for (Integer i=0; i<amount; i++) {

            Contract testContract = new Contract();
            testContract.AccountId = accId;

            contractList.add(testContract);
        }

        if (doInsert) {

            insert contractList;
        }

        return contractList;
    }


    public static List<Case> createCase (Integer amount, Boolean doInsert, Id accId, Id contactId, Id servPointId, Id contractId, Id orderId) {

        List<Case> caseList = new List<Case>();

        for (Integer i=0; i<amount; i++) {

            Case testCase = new Case();
            testCase.AccountId = accId;
            testCase.Status = 'In Lavorazione';
            testCase.Subject = 'test';
            testCase.Type = 'BP/CA - errata categoria';
            testCase.Subprocess__c = 'Account';
            testCase.HerokuPracticeCode__c = '21313232132132';
            testCase.ContactId = contactId;
            testCase.ServicePoint__c = servPointId;
            testCase.Contract__c = contractId;
            testCase.VulturePracticeReference__c = orderId;
            testCase.Cluster__c = 'Pagamenti';


            caseList.add(testCase);
        }

        if (doInsert) {

            insert caseList;
        }

        return caseList;
    }

}