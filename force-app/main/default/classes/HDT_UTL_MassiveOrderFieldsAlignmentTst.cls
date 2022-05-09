/**
 * Header of the class "HDT_UTL_MassiveOrderFieldsAlignmentTst"
 * @author Edoardo Zanatta
 * @description: Apex Test Class of the relative Apex Class "HDT_UTL_MassiveOrderFieldsAlignment"
 * @Created 05/05/2022
 **/

@isTest
public class HDT_UTL_MassiveOrderFieldsAlignmentTst {

    private static HDT_UTL_Constants constants=new HDT_UTL_Constants();

    @TestSetup
    static void makedata(){

        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
        User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
        internalUser.UserPermissionsMarketingUser=true;
        /*internalUser.LoginChannel__c = 'Back office';
        internalUser.Station__c = 'ALTOFE_SP_ Goro';
        internalUser.CreatorGroup__c = 	'HC_Back Office Condomini';*/

        insert internalUser;

        system.runAs(internalUser){

        //List<Account> accListBus = HDT_UTL_DataFactoryTst.createAccountBusiness(1,true,'HERA COMM','Azienda','Aziende SME');
        List<Account> accList=HDT_UTL_DataFactoryTst.createAccountResidenziale(2, false, 'HERA COMM', 'D1 - Persona fisica', 'Enti');
        accList[0].PrimaryEmail__c = 'test@test.com';
        accList[0].Phone = '123456789';
        accList[0].BPSAPModel__c = 'CLIENTI GENERICI MMS';
        accList[0].BillingStreetNumberExtension__c = 'nExt';
        accList[0].BillingIsAddressVerified__c = true;
        accList[0].BillingState = 'IT';
        accList[0].BillingCity = 'Torino';
        accList[0].BillingPostalCode = '10123';
        accList[0].BillingCountry = 'Italia';
        accList[0].BillingPlace__c = 'test place';
        accList[0].CustomerCode__c = '0001';
        accList[0].CustomerType__c = 'Organizzazione';
        insert accList;

        List<Campaign> campList = HDT_UTL_DataFactoryTst.createCampaign(1, true);

        List<Contact> contList = HDT_UTL_DataFactoryTst.createContact(1, false, accList[0].id);
        contList[0].Phone = '123456789';
        insert contList;

        List<Individual> indList = HDT_UTL_DataFactoryTst.createIndividual(1,true);
        indList[0].MarketingPrivacy__c = 'SI';
        indList[0].ProfilingPrivacy__c = 'SI';

        List<Sale__c> saleList = HDT_UTL_DataFactoryTst.createSale(1,true,accList[0].id,'Bozza');
        saleList[0].SaleBy__c = internalUser.id;
        saleList[0].CommissioningCampaign__c = campList[0].id;
        saleList[0].Campaign__c = campList[0].id;
        saleList[0].SalesContact__c = contList[0].id;
        saleList[0].UpperChannelAgency__c = 'testUp'; 
        saleList[0].LowerChannelAgency__c = 'testLow';
        saleList[0].Channel__c = 'Back office';
        saleList[0].VendorFirstName__c = 'test'; 
        saleList[0].VendorLastName__c = 'test';
        saleList[0].CommercialId__c = 'test vendor';
        saleList[0].Agency__c = 'test agency'; 
        saleList[0].AgencyCode__c = 'AgencyCode';
        saleList[0].AreaManager__c = 'Area Manager test';
        //saleList[0].CreatedBy = internalUser.id;


        List<BillingProfile__c> billingProList = HDT_UTL_DataFactoryTst.createBillingProfile(1,true,accList[0].id);

        List<ServicePoint__c> servList = HDT_UTL_DataFactoryTst.createServicePoint(1,false);
        servList[0].Vat__c = '';
        insert servList;

        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(2,false,accList[0].id,'Bozza');
        ordList[0].ServicePoint__c = servList[0].id;
        ordList[0].Vat__c = servList[0].Vat__c;
        insert ordList;

        }

    }

    @isTest 
    static void testGetAccByIds(){

        List<Account> accList = [SELECT Id, BillingStreetNumberExtension__c, CustomerCode__c, CustomerType__c, Category__c, BillingPlace__c, BillingCountry, BillingPostalCode, BillingState, BillingCity, BillingIsAddressVerified__c,
        BillingStreetNumber__c, BillingStreetName__c, CustomerMarking__c, BillingCityCode__c, BPSAPModel__c, FiscalCode__c, VATNumber__c, RecordType.DeveloperName, Name, FirstName__c, LastName__c,
        PrimaryEmail__c,  Phone FROM Account LIMIT 1];

        List<Id> idsList = new List<Id>();

        for (Account a : accList){
            idsList.add(accList[0].id);
        }

        Test.startTest();
        List<Account> accResult = HDT_UTL_MassiveOrderFieldsAlignment.getAccountByIds(idsList);
        System.assertEquals(false, accResult.isEmpty(),'testGetAccByIds did not work correctly');
        Test.stopTest();
        
    }

    @isTest 
    static void testGetSalesByIds(){

        List<Sale__c> saleList = [SELECT Agency__c, AgencyCode__c, CommercialId__c, VendorFirstName__c, VendorLastName__c, Channel__c, UpperChannelAgency__c, LowerChannelAgency__c, SaleBy__c, Campaign__c, Campaign__r.Name,
        CommissioningCampaign__c, CommissioningCampaign__r.Name, SalesContact__c, SalesContact__r.IndividualId, SalesContact__r.Individual.MarketingPrivacy__c, SalesContact__r.Individual.ProfilingPrivacy__c,
        SalesContact__r.Phone, SalesContact__r.MobilePhone, CreatedBy.LoginChannel__c, CreatedBy.Station__c, CreatedBy.CreatorGroup__c, AreaManager__c FROM Sale__c LIMIT 1];

        List<Id> idsList = new List<Id>();

        for (Sale__c s : saleList){
            idsList.add(saleList[0].id);
        }

        Test.startTest();
        List<Sale__c> saleListResult = HDT_UTL_MassiveOrderFieldsAlignment.getSaleByIds(idsList);
        System.debug('EDO: saleListResult' +saleListResult);
        System.assertEquals(false, saleListResult.isEmpty(),'testGetSalesByIds did not work correctly');
        Test.stopTest();
        
    }

    @isTest 
    static void testGetBillingProfileByIds(){

        List<BillingProfile__c> billingList = [SELECT id, ContractAccountCode__c FROM BillingProfile__c LIMIT 1];

        List<Id> idsList = new List<Id>();

        for (BillingProfile__c b : billingList){
            idsList.add(billingList[0].id);
        }

        Test.startTest();
        List<BillingProfile__c> billingListResult = HDT_UTL_MassiveOrderFieldsAlignment.getBillingProfileByIds(idsList);
        System.assertEquals(false, billingListResult.isEmpty(),'testGetBillingProfileByIds did not work correctly');
        Test.stopTest();
        
    }

    @isTest 
    static void testGetServicePointByIds(){

        List<ServicePoint__c> servList = [SELECT id FROM ServicePoint__c LIMIT 1];

        List<Id> idsList = new List<Id>();

        for (ServicePoint__c s : servList){
            idsList.add(servList[0].id);
        }

        Test.startTest();
        List<ServicePoint__c> servPointResult = HDT_UTL_MassiveOrderFieldsAlignment.getServicePointByIds(idsList);
        System.assertEquals(false, servPointResult.isEmpty(),'testGetBillingProfileByIds did not work correctly');
        Test.stopTest();
        
    }

    @isTest 
    static void testalignAccountFieldsResidenziale(){

        Account acc = [SELECT id, RecordType.DeveloperName, FirstName__c, LastName__c, VATNumber__c, PrimaryEmail__c, Phone, BPSAPModel__c, BillingStreetNumberExtension__c, BillingIsAddressVerified__c, 
                        BillingState, BillingCity, BillingPostalCode, BillingCountry, BillingPlace__c, CustomerCode__c, CustomerType__c, FiscalCode__c, BillingStreetName__c, BillingStreetNumber__c, BillingCityCode__c, 
                        Category__c FROM Account WHERE Name ='test account0'];

        Order ord = [SELECT id, ServicePoint__c, ServicePoint__r.Vat__c, Vat__c FROM Order WHERE Name = 'testOrderName0'];

        Test.startTest();
        Order orderResultRes = HDT_UTL_MassiveOrderFieldsAlignment.alignAccountFields(ord, acc);
        Test.stopTest();

        System.assertEquals(true, orderResultRes.BPSAPModel__c == acc.BPSAPModel__c, 'testalignAccountFieldsResidenziale did not work correctly');

    }

    /*@isTest 
    static void testalignSaleFields(){

        Sale__c sale = [SELECT id, SaleBy__c, CommissioningCampaign__c, Campaign__c, SalesContact__c, LowerChannelAgency__c, UpperChannelAgency__c, Channel__c, VendorFirstName__c,
                        VendorLastName__c, CommercialId__c, Agency__c, AgencyCode__c, AreaManager__c, Campaign__r.Name, CommissioningCampaign__r.Name, SalesContact__r.Individual.MarketingPrivacy__c,
                        SalesContact__r.Phone, SalesContact__r.Individual.ProfilingPrivacy__c, CreatedBy,  FROM Sale__c WHERE Name = 'testSaleName0'];

        Order ord = [SELECT Id FROM Order WHERE Name = 'testOrderName0'];

        Test.startTest();
        Order oderResult = HDT_UTL_MassiveOrderFieldsAlignment.alignSaleFields(ord, sale);
        System.debug('EDO: accResult' +oderResult);
        System.assertEquals(true, oderResult.SaleBy__c == sale.SaleBy__c, 'testalignSaleFields did not work correctly');
        Test.stopTest();

    }*/
}