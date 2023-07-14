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
        internalUser.LoginChannel__c = 'Back office';
        internalUser.Station__c = 'CC_VK_team 17';
        internalUser.CreatorGroup__c = 'HC_CRM_CC_OUT_VK'; 

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

        List<Account> simpleAccDistributor = HDT_UTL_DataFactoryTst.createSimpleAccountDistributore(1, false,'MMS','G3 - MMS Azienda','Aziende SME');
        simpleAccDistributor[0].Name = 'testSimplAccDistr0';
        simpleAccDistributor[0].Code__c = '13D0000082';
        insert simpleAccDistributor;

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
        saleList[0].CreatedBy__c = 'test';


        List<BillingProfile__c> billingProList = HDT_UTL_DataFactoryTst.createBillingProfile(1,true,accList[0].id);

        List<ServicePoint__c> servList = HDT_UTL_DataFactoryTst.createServicePoint(2,false);
        servList[0].Vat__c = '';

        servList[1].CommoditySector__c = 'Energia Elettrica';
        servList[1].Vat__c = '02';
        servList[1].SupplyTypeTemp__c = 'Non Domestico';
        servList[1].Distributor__c = simpleAccDistributor[0].id;
        insert servList;

        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(2,false,accList[0].id,'Bozza');
        ordList[0].ServicePoint__c = servList[0].id;
        ordList[0].Vat__c = servList[0].Vat__c;

        ordList[1].ServicePoint__c = servList[1].id;
        ordList[1].ExciseEle__c = null;
        ordList[1].Vat__c = null;
        insert ordList;

        List<BillingProfile__c> billingList = HDT_UTL_DataFactoryTst.createBillingProfile(1,false,accList[0].id);
        billingList[0].SubjectCode__c = '1234567';
        billingList[0].InvoiceCertifiedEmailAddress__c = 'test@test.com';
        billingList[0].ElectronicInvoicingMethod__c = 'XML';
        billingList[0].XMLType__c = 'Dettaglio';
        billingList[0].CIG__c = '123456';
        billingList[0].CUP__c = '123456';
        billingList[0].IbanIsForeign__c = false;
        billingList[0].IbanCIN_IBAN__c = '12';
        billingList[0].IbanCIN__c = 'S';
        billingList[0].IbanABI__c = '15558';
        billingList[0].IbanCAB__c = '66589';
        billingList[0].IbanCodeNumber__c = '1234568975856';
        billingList[0].BankAccountSignatoryFiscalCode__c = 'RMOFMN80A41H501H';
        billingList[0].BankAccountSignatoryFirstName__c = 'Flaminia';
        billingList[0].BankAccountSignatoryLastName__c = 'Roma';
        billingList[0].BillSendingMethod__c = 'Bolletta per e-mail';
        billingList[0].PaymentMethod__c = 'RID';
        billingList[0].InvoiceEmailAddress__c = 'test@test.com';
        billingList[0].InvoicingCity__c = 'MORINO';
        billingList[0].InvoicingCountry__c = 'ITALIA';
        billingList[0].InvoicingProvince__c = 'AQ';
        billingList[0].InvoicingStreetName__c = 'VIA GRAN SASSO';
        billingList[0].InvoicingStreetNumber__c = '56';
        billingList[0].InvoicingStreetNumberExtension__c = '56';
        billingList[0].InvoicingPostalCode__c = '56';
        billingList[0].InvoicingCityCode__c = '041069';
        billingList[0].SendCertifiedEmailConsentDate__c = System.today();
        billingList[0].CreateContractAccount__c = false;
        billingList[0].IbanCountry__c = 'IT';
        billingList[0].ContractAccountCode__c = '';

        insert billingList;

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
        Test.stopTest();

        System.assertEquals(false, accResult.isEmpty(),'testGetAccByIds did not work correctly');
        
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
        Test.stopTest();

        System.assertEquals(false, saleListResult.isEmpty(),'testGetSalesByIds did not work correctly');
        
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
        Test.stopTest();

        System.assertEquals(false, billingListResult.isEmpty(),'testGetBillingProfileByIds did not work correctly');
        
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
        Test.stopTest();

        System.assertEquals(false, servPointResult.isEmpty(),'testGetBillingProfileByIds did not work correctly');
        
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

    @isTest 
    static void testalignSaleFields(){

        Sale__c sale = [SELECT id, SaleBy__c, CommissioningCampaign__c, Campaign__c, SalesContact__c, LowerChannelAgency__c, UpperChannelAgency__c, Channel__c, VendorFirstName__c,
                        VendorLastName__c, CommercialId__c, Agency__c, AgencyCode__c, AreaManager__c, Campaign__r.Name, CommissioningCampaign__r.Name,
                        SalesContact__r.Phone, SalesContact__r.IndividualId, CreatedById, CreatedBy__c, CreatedBy.LoginChannel__c, CreatedBy.Station__c, CreatedBy.CreatorGroup__c 
                        FROM Sale__c WHERE Name = 'testSaleName0'];

        Order ord = [SELECT Id FROM Order WHERE Name = 'testOrderName0'];

        Test.startTest();
        Order orderResult = HDT_UTL_MassiveOrderFieldsAlignment.alignSaleFields(ord, sale);
        Test.stopTest();

        System.assertEquals(true, orderResult.SaleBy__c == sale.SaleBy__c, 'testalignSaleFields did not work correctly');

    }

    @isTest 
    static void testalignBillingProfileFields(){

        BillingProfile__c billing = [SELECT id, SubjectCode__c,InvoiceCertifiedEmailAddress__c,ElectronicInvoicingMethod__c,XMLType__c,CIG__c,CUP__c,IbanIsForeign__c,IbanCIN_IBAN__c,IbanCIN__c,IbanABI__c,IbanCAB__c,
        IbanCodeNumber__c,BankAccountSignatoryFiscalCode__c,BankAccountSignatoryFirstName__c,BankAccountSignatoryLastName__c,BillSendingMethod__c,PaymentMethod__c,InvoiceEmailAddress__c,
        InvoicingCity__c,InvoicingCountry__c,InvoicingProvince__c,InvoicingStreetName__c,InvoicingStreetNumber__c,InvoicingStreetNumberExtension__c,InvoicingPostalCode__c,
        InvoicingCityCode__c,SignatoryType__c,SendCertifiedEmailConsentDate__c, CreateContractAccount__c, IbanCountry__c, ContractAccountCode__c 
        FROM BillingProfile__c LIMIT 1];

        Order ord = [SELECT Id FROM Order WHERE Name = 'testOrderName0'];

        Test.startTest();
        Order orderResult = HDT_UTL_MassiveOrderFieldsAlignment.alignBillingProfileFields(ord, billing);
        Test.stopTest();

        System.assertEquals(true, orderResult.IbanCodeNumber__c == billing.IbanCodeNumber__c, 'testalignBillingProfileFields did not work correctly');

    }

    @isTest 
    static void testAlignServicePointFields(){

        List<Order> ord = [SELECT Id, ExciseEle__c, Vat__c FROM Order WHERE Name = 'testOrderName1'];

        List<ServicePoint__c> serv = [SELECT Id, CommoditySector__c, Vat__c, ExciseEle__c, SupplyTypeTemp__c,SupplyType__c, AnnualConsumption__c, SwitchInWinback__c, SwitchOutDate__c, MarketOrigin__c,
                                      PowerAvailable__c, VoltageLevel__c, DisconnectibilityPhone__c, UseTypeEnergy__c, UseCategory__c, MeterSN__c, Resident__c, RemiCode__c, VATNumberUdb__c, 
                                      SupplyCity__c, SupplyStreet__c, SupplyStreetNumber__c, SupplyStreetNumberExtension__c, SupplyPlace__c, SupplyPostalCode__c, SupplyCountry__c, PowerContractual__c,
                                      ServicePointCode__c, SAPImplantCode__c, ImplantTypeTemp__c, SupplySAPCityCode__c, SupplyProvince__c, Disconnectable__c, DisconnectibilityType__c, MeterClass__c,
                                      WithdrawalClass__c, PressureLevel__c, RequestPhase__c, PowerRequested__c, MeterType__c, IsRemoteManaged__c, Pressure__c, RecordType.DeveloperName,
                                      MeterStatus__c, Distributor__r.Code__c, ImplantType__c FROM ServicePoint__c WHERE Name = 'testServicePoint1'];

        Test.startTest();
        Order orderResult =  HDT_UTL_MassiveOrderFieldsAlignment.alignServicePointFields(ord[0], serv[0]);
        Test.stopTest();

        System.assertEquals(true, orderResult!=null, 'testAlignServicePointFields did not work correctly');

    }


}