/**
 * Created by David Diop  on 03.12.2019.
 */
@IsTest
public with sharing class HDT_LC_AdvancedSearchTest {
    @TestSetup
    static void setup() {
        List<Account> listAccount = new list<Account>();

        Account personAccount = TestDataFactory.account().personAccount().build();
        personAccount.Key__c = 'supply';
        listAccount.add(personAccount);
        Account businessAccount = TestDataFactory.account().businessAccount().build();
        businessAccount.Name = 'BusinessAccount1';
        businessAccount.VATNumber__c= '1343324';
        businessAccount.Key__c = '1324433';
        listAccount.add(businessAccount);
        insert listAccount;

        CompanyDivision__c companyDivision = TestDataFactory.CompanyDivision().createBulkCompanyDivision(1).build();
        insert companyDivision;

        User user = new User();
        user.Id = UserInfo.getUserId() ;
        user.CompanyDivisionId__c = companyDivision.Id;
        user.CompanyDivisionEnforced__c = true;
        update user;

        Supply__c supply = TestDataFactory.supply().createSupplyBuilder().setCompany(companyDivision.Id).build();
        supply.Status__c = 'Active';
        supply.Key__c = 'supply';
        supply.Account__c = listAccount[0].Id;
        supply.CompanyDivision__c = companyDivision.Id;
        insert supply;

        ContractAccount__c contractAccount = TestDataFactory.contractAccount().createContractAccount().setAccount(listAccount[1].Id).build();
        insert contractAccount;

        Contact contact = TestDataFactory.contact().createContact().build();
        insert contact;

        ServiceSite__c serviceSite = TestDataFactory.serviceSite().createServiceSite().build();
        insert serviceSite;

        ServicePoint__c servicePoint = TestDataFactory.servicePoint().createServicePoint().build();
        servicePoint.CurrentSupply__c = supply.Id;
        servicePoint.Key__c = 'service';
        insert servicePoint;

        BillingProfile__c billingProfile = TestDataFactory.BillingProfileBuilder().createBillingProfile().build();
        billingProfile.Account__c=listAccount[0].Id;
        insert billingProfile;

        Contract contract = TestDataFactory.contract().createContract().build();
        contract.AccountId = listAccount[1].Id;
        insert contract;

    }
    @IsTest
    public static void querySupplyTest(){
        Account account = [
            SELECT Id,Name
            FROM Account
            LIMIT 1
        ];
        CompanyDivision__c companyDivision = [
            SELECT Id,Name
            FROM CompanyDivision__c
            WHERE Name = 'ENEL 1'
            LIMIT 1
        ];
        String searchText = 'supply';
        List<String> supplyStatus = new List<String>();
        supplyStatus.add('Active');
        List<String> fields = new List<String>();
        fields.add('Id');
        Test.startTest();
        List<Supply__c> supplies =  HDT_LC_AdvancedSearch.querySupply(searchText,account.Id,companyDivision.Id,supplyStatus,fields);
        System.assertEquals(true,supplies.size() == 1);
        Test.stopTest();
    }

    @IsTest
    public static void querySupplyIsBlankAccountIdTest(){
        CompanyDivision__c companyDivision = [
            SELECT Id,Name
            FROM CompanyDivision__c
            WHERE Name = 'ENEL 1'
            LIMIT 1
        ];
        String searchText = 'supply';
        List<String> supplyStatus = new List<String>();
        supplyStatus.add('Active');
        List<String> fields = new List<String>();
        fields.add('Id');
        Test.startTest();
        List<Supply__c> supplies =  HDT_LC_AdvancedSearch.querySupply(searchText,'',companyDivision.Id,supplyStatus,fields);
        System.assertEquals(true,supplies.size() == 1);
        Test.stopTest();
    }

    @IsTest
    public static void querySupplyExcepTest(){
        List<String> supplyStatus = new List<String>();
        List<String> fields = new List<String>();
        Test.startTest();
        try {
            HDT_LC_AdvancedSearch.querySupply('','','',supplyStatus,fields);
        } catch (Exception e) {
            System.assert(true, e.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    public static void searchSupplyTest(){
        Account account = [
            SELECT Id,Name
            FROM Account
            LIMIT 1
        ];
        Supply__c supply = [
            SELECT Id
            FROM Supply__c
            LIMIT 1
        ];
        Contract contract = [
            SELECT Id
            FROM Contract
            LIMIT 1
        ];
        ContractAccount__c contractAccount = [
            SELECT Id
            FROM ContractAccount__c
            LIMIT 1
        ];
        ServiceSite__c serviceSite = [
            SELECT Id
            FROM ServiceSite__c
            LIMIT 1
        ];
        ServicePoint__c servicePoint = [
            SELECT Id
            FROM ServicePoint__c
            LIMIT 1
        ];

        BillingProfile__c billingProfile = [
            SELECT Id
            FROM BillingProfile__c
            LIMIT 1
        ];
        CompanyDivision__c companyDivision = [
            SELECT Id,Name
            FROM CompanyDivision__c
            WHERE Name = 'ENEL 1'
            LIMIT 1
        ];
        String searchText = 'BusinessAccount1';
        List<String> supplyStatus = new List<String>();
        supplyStatus.add('Active');
        List<String> fields = new List<String>();
        fields.add('Id');
        Test.startTest();

        Id [] fixedSearchResults = new Id[]{account.Id};
        fixedSearchResults.add(contractAccount.Id);
        fixedSearchResults.add(supply.Id);
        fixedSearchResults.add(contract.Id);
        fixedSearchResults.add(serviceSite.Id);
        fixedSearchResults.add(servicePoint.Id);
        fixedSearchResults.add(billingProfile.Id);
        fixedSearchResults.add(contract.Id);
        fixedSearchResults.add(contract.Id);
        Test.setFixedSearchResults(fixedSearchResults);

        List<Supply__c> supplies =  HDT_LC_AdvancedSearch.searchSupply(searchText,account.Id,supplyStatus,companyDivision.Id,fields);
        System.assertEquals(true,supplies.size() != 0);
        Test.stopTest();
    }

    @IsTest
    public static void searchSupplyEmptyTest(){
        Account account = [
            SELECT Id,Name
            FROM Account
            LIMIT 1
        ];
        CompanyDivision__c companyDivision = [
            SELECT Id,Name
            FROM CompanyDivision__c
            WHERE Name = 'ENEL 1'
            LIMIT 1
        ];
        String searchText = 'BusinessAccount1';
        List<String> supplyStatus = new List<String>();
        supplyStatus.add('Active');
        List<String> fields = new List<String>();
        fields.add('Id');
        Test.startTest();
        List<Supply__c> supplies =  HDT_LC_AdvancedSearch.searchSupply(searchText,account.Id,supplyStatus,companyDivision.Id,fields);
        System.assertEquals(true,supplies.size() == 0);
        Test.stopTest();
    }

    @IsTest
    public static void searchSupplyExcepTest(){
        List<String> fields = new List<String>();
        Test.startTest();
        try {
            HDT_LC_AdvancedSearch.searchSupply('','',null,'',fields);
        } catch (Exception e) {
            System.assert(true, e.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    public static void queryServicePointTest(){
        Account account = [
            SELECT Id,Name
            FROM Account
            LIMIT 1
        ];
        CompanyDivision__c companyDivision = [
            SELECT Id,Name
            FROM CompanyDivision__c
            WHERE Name = 'ENEL 1'
            LIMIT 1
        ];
        String searchText = 'service';
        List<String> supplyStatus = new List<String>();
        supplyStatus.add('Active');
        List<String> fields = new List<String>();
        fields.add('Code__c');
        Test.startTest();
        List<ServicePoint__c> servicePoints = HDT_LC_AdvancedSearch.queryServicePoint(searchText,account.Id,supplyStatus,companyDivision.Id,fields);
        System.assertEquals(true,servicePoints.size() != 0);
        Test.stopTest();
    }

    @IsTest
    public static void queryServicePointExcepTest(){
        List<String> fields = new List<String>();
        Test.startTest();
        try {
            HDT_LC_AdvancedSearch.queryServicePoint('','',null,'',fields);
        } catch (Exception e) {
            System.assert(true, e.getMessage());
        }
        Test.stopTest();
    }
    @IsTest
    public static void queryServicePointIsBlankAccountIdTest(){
        CompanyDivision__c companyDivision = [
            SELECT Id,Name
            FROM CompanyDivision__c
            WHERE Name = 'ENEL 1'
            LIMIT 1
        ];
        String searchText = 'supply';
        List<String> supplyStatus = new List<String>();
        supplyStatus.add('Active');
        List<String> fields = new List<String>();
        fields.add('Id');
        Test.startTest();
        List<ServicePoint__c> servicePoints = HDT_LC_AdvancedSearch.queryServicePoint(searchText,'',supplyStatus,companyDivision.Id,fields);
        System.assertEquals(true,servicePoints.size() != 0);
        Test.stopTest();
    }
    @IsTest
    public static void searchServicePointExcepTest(){
        List<String> fields = new List<String>();
        Test.startTest();
        try {
            HDT_LC_AdvancedSearch.searchServicePoint('','',null,'',fields);
        } catch (Exception e) {
            System.assert(true, e.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    public static void searchServicePointEmptyTest(){
        Account account = [
            SELECT Id,Name
            FROM Account
            LIMIT 1
        ];
        CompanyDivision__c companyDivision = [
            SELECT Id,Name
            FROM CompanyDivision__c
            WHERE Name = 'ENEL 1'
            LIMIT 1
        ];
        String searchText = 'BusinessAccount1';
        List<String> supplyStatus = new List<String>();
        supplyStatus.add('Active');
        List<String> fields = new List<String>();
        fields.add('Id');
        Test.startTest();
        List<ServicePoint__c> servicePoints =  HDT_LC_AdvancedSearch.searchServicePoint(searchText,account.Id,supplyStatus,companyDivision.Id,fields);
        System.assertEquals(true,servicePoints.size() == 0);
        Test.stopTest();
    }
    @IsTest
    public static void searchServicePointTest(){
        Account account = [
            SELECT Id,Name
            FROM Account
            LIMIT 1
        ];
        Supply__c supply = [
            SELECT Id
            FROM Supply__c
            LIMIT 1
        ];
        Contract contract = [
            SELECT Id
            FROM Contract
            LIMIT 1
        ];
        ContractAccount__c contractAccount = [
            SELECT Id
            FROM ContractAccount__c
            LIMIT 1
        ];
        ServiceSite__c serviceSite = [
            SELECT Id
            FROM ServiceSite__c
            LIMIT 1
        ];
        ServicePoint__c servicePoint = [
            SELECT Id
            FROM ServicePoint__c
            LIMIT 1
        ];

        BillingProfile__c billingProfile = [
            SELECT Id
            FROM BillingProfile__c
            LIMIT 1
        ];
        CompanyDivision__c companyDivision = [
            SELECT Id,Name
            FROM CompanyDivision__c
            WHERE Name = 'ENEL 1'
            LIMIT 1
        ];
        String searchText = 'BusinessAccount1';
        List<String> supplyStatus = new List<String>();
        supplyStatus.add('Active');
        List<String> fields = new List<String>();
        fields.add('Id');

        Test.startTest();
        Id [] fixedSearchResults = new Id[]{account.Id};
        fixedSearchResults.add(contractAccount.Id);
        fixedSearchResults.add(supply.Id);
        fixedSearchResults.add(contract.Id);
        fixedSearchResults.add(serviceSite.Id);
        fixedSearchResults.add(servicePoint.Id);
        fixedSearchResults.add(billingProfile.Id);
        fixedSearchResults.add(contract.Id);
        fixedSearchResults.add(contract.Id);
        Test.setFixedSearchResults(fixedSearchResults);
        List<ServicePoint__c> servicePoints =  HDT_LC_AdvancedSearch.searchServicePoint(searchText,account.Id,supplyStatus,companyDivision.Id,fields);
        System.assertEquals(true,servicePoints.size() != 0);
        Test.stopTest();
    }
}