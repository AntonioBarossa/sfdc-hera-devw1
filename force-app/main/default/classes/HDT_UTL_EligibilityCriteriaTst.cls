@isTest
public with sharing class HDT_UTL_EligibilityCriteriaTst 
{
    @TestSetup
    static void setup()
    {
        List<Account> accList=HDT_UTL_DataFactoryTst.createAccountResidenziale(1, false, 'HERA COMM', 'D1 - Persona fisica', 'Enti');
        accList[0].BirthDate__c = Date.valueof('1964-03-21');
        insert accList;
        List<Sale__c> saleList = HDT_UTL_DataFactoryTst.createSale(1, true, accList[0].Id, 'Bozza');

        List<Product2> productList = HDT_UTL_DataFactoryTst.createProduct2(1, false);
        productList[0].ProductCode = 'pCode01';
        productList[0].Version__c = '01V1';
        productList[0].Name = 'ExampleProduct';
        productList[0].Family = Label.HDT_ProductFamilyTrigger;
        productList[0].IsActive = true;
        productList[0].NoOrderable__c = false;
        productList[0].Status__c = 'Vendibile';
        insert productList;

        Id pricebookId=Test.getStandardPricebookId();
		HDT_UTL_DataFactoryTst.createPricebookEntry(productList, true, pricebookId);
        HDT_UTL_DataFactoryTst.createOrderWithPricebook(1, true, accList[0].Id, saleList, pricebookId);

        List<Pricebook2> pbList = HDT_UTL_DataFactoryTst.createPricebook(1, true);
    
        LoginGroup__c loginGroup = new LoginGroup__c(NameGroup__c = 'Sportello Imola');
        insert loginGroup;

        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.SBQQ__PricebookId__c = pbList[0].Id;
        quote.SupplyCity__c = 'Roma';
        quote.LoginGroup__c = loginGroup.Id;
        insert quote;

        List<EligibilityCriteria__c> criteriaList = new List<EligibilityCriteria__c>();
        EligibilityCriteria__c criteria = new EligibilityCriteria__c();
        criteria.Product__c = productList[0].Id;
        criteria.EligibleForAllCities__c = false;
        criteria.ClientAgeMin__c = null;
        criteria.ClientAgeMax__c = null;
        criteria.LoginGroup__c = loginGroup.Id;
        criteria.ConsumptionRangeEEmin__c = 10;
        criteria.ConsumptionRangeEEmax__c = 30;
        criteria.ConsumptionRangeGASmin__c = 10;
        criteria.ConsumptionRangeGASmax__c = 30;
        criteria.PowerRangeMin__c = 10;
        criteria.PowerRangeMax__c = 30;
        criteria.ResidentDeliveryAddress__c = 'Si';
        criteria.NewClient__c = 'No';
        criteria.OriginMarketOperator__c = 'includesAll';
        criteria.ChannelOperator__c = 'includesAll';
        criteria.ClientMarkerOperator__c = 'includesAll';
        criteria.CategoryTypeClientOperator__c = 'includesAll';
        criteria.CompanyOwnerOperator__c = 'includesAll';
        criteria.CampaignName__c = null;
        criteria.PromoCode__c = null;
        criteria.Agency__c = null;
        criteria.UseCategory__c = null;
        criteria.EquipmenType__c = null;
        criteriaList.add(criteria);
        insert criteriaList;

        EligibilityCriteria__c crit = [SELECT Id FROM EligibilityCriteria__c LIMIT 1];
        EligibleMunicipality__c eligibilityMun = new EligibleMunicipality__c();
        eligibilityMun.Name = 'Roma';
        eligibilityMun.AreaCode__c = 'RM';
        eligibilityMun.EligibilityCriteria__c = crit.Id;
        insert eligibilityMun;


        /* Creazione User */
        Profile p = [SELECT Id FROM profile WHERE Name = 'Hera Standard User'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='eligibilitytest@testorg.com');
        insert u;
       
    }
    @isTest
    static void adminSuperUserTst()
    {
        List<User> userAdminSuperUser = [SELECT Id FROM User WHERE Alias = 'standt'];
        PermissionSet cpqLicense = [SELECT Id FROM PermissionSet WHERE Name = 'HDT_SalesforceCPQLicense'];
        insert new PermissionSetAssignment(AssigneeId = userAdminSuperUser[0].id, PermissionSetId = cpqLicense.Id);

        
        PermissionSet psAdmin = [SELECT Id FROM PermissionSet WHERE Name = :Label.HDT_SuperUserCPQ];
        PermissionSet psSuperUser = [SELECT Id FROM PermissionSet WHERE Name = :Label.HDT_PermissionSetNameForCPQ];
        insert new PermissionSetAssignment(AssigneeId = userAdminSuperUser[0].id, PermissionSetId = psAdmin.Id);
        insert new PermissionSetAssignment(AssigneeId = userAdminSuperUser[0].id, PermissionSetId = psSuperUser.Id);

        List<SBQQ__Quote__c> quoteTest = [SELECT Id,CustomerMarking__c,CategoryTypeClient__c,CompanyOwner__c,CampaignEleggibilityGroup__c,CampaignName__c,FriendCode__c,Agency__c,UseCategory__c,MeterType__c,Channel__c,Market__c,ClientAge__c,ListPriceName__c,ConsumptionRangeGAS__c,PowerFlow__c,ResidentDeliveryAddress__c,NewClient__c,SuperUser__c,ConsumptionRangeEE__c,SBQQ__PricebookId__c, SupplyCity__c, LoginGroup__c FROM SBQQ__Quote__c];
        quoteTest[0].SuperUser__c = 'Y';
        quoteTest[0].ConsumptionRangeEE__c = 20.00;
        System.runAs(userAdminSuperUser[0])
        {
            Test.startTest();
                Set<Id> testSet = HDT_UTL_EligibilityCriteria.getEligibleProducts(quoteTest[0]);
            Test.stopTest();
            System.assertEquals(true, testSet.isEmpty(), 'Test adminSuperUser fallito');
        }
    }
    @isTest
    static void adminNotSuperUserTst()
    {
        List<User> userAdminSuperUser = [SELECT Id FROM User WHERE Alias = 'standt'];
        PermissionSet cpqLicense = [SELECT Id FROM PermissionSet WHERE Name = 'HDT_SalesforceCPQLicense'];
        insert new PermissionSetAssignment(AssigneeId = userAdminSuperUser[0].id, PermissionSetId = cpqLicense.Id);

        
        PermissionSet psAdmin = [SELECT Id FROM PermissionSet WHERE Name = :Label.HDT_PermissionSetNameForCPQ];
        insert new PermissionSetAssignment(AssigneeId = userAdminSuperUser[0].id, PermissionSetId = psAdmin.Id);

        List<SBQQ__Quote__c> quoteTest = [SELECT Id,CustomerMarking__c,CategoryTypeClient__c,CompanyOwner__c,CampaignEleggibilityGroup__c,CampaignName__c,FriendCode__c,Agency__c,UseCategory__c,MeterType__c,Channel__c,Market__c,ClientAge__c,ListPriceName__c,ConsumptionRangeGAS__c,PowerFlow__c,ResidentDeliveryAddress__c,NewClient__c,SuperUser__c,ConsumptionRangeEE__c,SBQQ__PricebookId__c, SupplyCity__c, LoginGroup__c FROM SBQQ__Quote__c];
        quoteTest[0].ConsumptionRangeEE__c = 25.00;
        quoteTest[0].ConsumptionRangeGAS__c = 25.00;
        quoteTest[0].PowerFlow__c = 25.00;
        quoteTest[0].ResidentDeliveryAddress__c = 'Si';
        quoteTest[0].NewClient__c = 'No';
        quoteTest[0].LoginGroup__c = 'Sportello Imola';
        System.runAs(userAdminSuperUser[0])
        {
            Test.startTest();
                Set<Id> testSet = HDT_UTL_EligibilityCriteria.getEligibleProducts(quoteTest[0]);
            Test.stopTest();
            System.assertEquals(true, testSet.isEmpty(), 'Test adminNotSuperUser fallito');
        }
    }
    @isTest
    static void notAdminSuperUserTst()
    {
        List<User> userAdminSuperUser = [SELECT Id FROM User WHERE Alias = 'standt'];
        PermissionSet cpqLicense = [SELECT Id FROM PermissionSet WHERE Name = 'HDT_SalesforceCPQLicense'];
        insert new PermissionSetAssignment(AssigneeId = userAdminSuperUser[0].id, PermissionSetId = cpqLicense.Id);


        PermissionSet psSuperUser = [SELECT Id FROM PermissionSet WHERE Name = :Label.HDT_SuperUserCPQ];
        insert new PermissionSetAssignment(AssigneeId = userAdminSuperUser[0].id, PermissionSetId = psSuperUser.Id);

        List<SBQQ__Quote__c> quoteTest = [SELECT Id,CustomerMarking__c,CategoryTypeClient__c,CompanyOwner__c,CampaignEleggibilityGroup__c,CampaignName__c,FriendCode__c,Agency__c,UseCategory__c,MeterType__c,Channel__c,Market__c,ClientAge__c,ListPriceName__c,ConsumptionRangeGAS__c,PowerFlow__c,ResidentDeliveryAddress__c,NewClient__c,SuperUser__c,ConsumptionRangeEE__c,SBQQ__PricebookId__c, SupplyCity__c, LoginGroup__c FROM SBQQ__Quote__c];
        quoteTest[0].SuperUser__c = 'Y';
        quoteTest[0].ConsumptionRangeEE__c = 20.00;
        quoteTest[0].ResidentDeliveryAddress__c = 'No';
        quoteTest[0].NewClient__c = 'No';
        System.runAs(userAdminSuperUser[0])
        {
            Test.startTest();
                Set<Id> testSet = HDT_UTL_EligibilityCriteria.getEligibleProducts(quoteTest[0]);
            Test.stopTest();
            System.assertEquals(true, testSet.isEmpty(), 'Test notAdminSuperUserTst fallito');
        }
    }

    @isTest
    static void convertSupplyCityCodeTst()
    {
        Test.startTest();
        String testResult = '';
        testResult = HDT_UTL_EligibilityCriteria.convertSupplyCityCode('97080');
        System.assertEquals(testResult, '16215');
        testResult = HDT_UTL_EligibilityCriteria.convertSupplyCityCode('20201');
        System.assertEquals(testResult, '20201');
        Test.stopTest();
    }

    @isTest
    static void findEligibleMunicipalityTst(){
        Test.startTest();
        List<EligibleMunicipality__c> eligibleMunicipality = HDT_QR_SearchPlug.findEligibleMunicipality(new Set<Id>(), new List<String>(), new List<String>(), 'supplyCity');
        System.assertEquals(eligibleMunicipality.size(), 0);
        Test.stopTest();
    }
    

}
