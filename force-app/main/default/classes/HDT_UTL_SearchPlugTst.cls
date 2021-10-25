@isTest
public class HDT_UTL_SearchPlugTst {

    /*
        HDT_UTL_SearchPlug           87%
        HDT_QR_SearchPlug            87%
    */

    @TestSetup
    static void makeData(){

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
		List<PricebookEntry> pricebookEntry=HDT_UTL_DataFactoryTst.createPricebookEntry(productList, true, pricebookId);
        List<Order> orderList = HDT_UTL_DataFactoryTst.createOrderWithPricebook(1, true, accList[0].Id, saleList, pricebookId);
    
        List<EligibilityCriteria__c> criteriaList = new List<EligibilityCriteria__c>();
        EligibilityCriteria__c criteria = new EligibilityCriteria__c();
        criteria.Product__c = productList[0].Id;
        criteria.EligibleForAllCities__c = false;
        criteria.ClientAgeMin__c = null;
        criteria.ClientAgeMax__c = null;
        criteria.LoginGroup__c = null;
        criteria.ConsumptionRangeEEmin__c = null;
        criteria.ConsumptionRangeEEmax__c = null;
        criteria.ConsumptionRangeGASmin__c = null;
        criteria.ConsumptionRangeGASmax__c = null;
        criteria.PowerRangeMin__c = null;
        criteria.PowerRangeMax__c = null;
        criteria.ResidentDeliveryAddress__c = null;
        criteria.NewClient__c = null;
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

        List<Pricebook2> pbList = HDT_UTL_DataFactoryTst.createPricebook(1, true);

        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.SBQQ__PricebookId__c = pbList[0].Id;
        quote.SupplyCity__c = 'Roma';
        insert quote;

        List<OperandTemplate__c> operandTemplateList = new List<OperandTemplate__c>();
        OperandTemplate__c op1 = new OperandTemplate__c(Operands__c = 'ES_ADG_GO', ContractTemplate__c = 'ZELE_PREZZO', Typology__c = 'PDISCNT', Definition__c = 'DESCR ES_ADG_GO');
        operandTemplateList.add(op1);
        insert operandTemplateList;

        List<RateTemplate__c> rateList = new List<RateTemplate__c>();
        RateTemplate__c rateTemplate = new RateTemplate__c(Name = 'EVVUD', ContractTemplate__c = 'ZELE_DOMES', ServiceProduct__c = 'ELE_DOMES', Visibile__c = true);
        rateList.add(rateTemplate);
        insert rateList;

        TechnicalOffer__c technicalOffer = new TechnicalOffer__c();
        technicalOffer.Name = productList[0].ProductCode + ' [' + productList[0].Version__c + '] [EVVUD]';
        technicalOffer.NameExternalId__c = technicalOffer.Name;
        technicalOffer.Product__c = productList[0].Id;
        technicalOffer.RateCategory__c = rateList[0].Id;
        technicalOffer.SapCode__c = '00001';
        technicalOffer.Status__c = 'Status OK';
        insert technicalOffer;

        List<TechnicalOfferItem__c> techOffeItems = new List<TechnicalOfferItem__c>();
        TechnicalOfferItem__c tecOffItem = new TechnicalOfferItem__c();
        tecOffItem.TechnicalOffer__c = technicalOffer.Id;
        tecOffItem.Type__c = 'PDISCNT';
        tecOffItem.Definition__c = 'DESCR ES_ADG_GO';
        tecOffItem.G__c = false;
        tecOffItem.V__c = false;
        tecOffItem.M__c = false;
        tecOffItem.S__c = null;
        tecOffItem.Operand__c = 'ES_ADG_GO';
        tecOffItem.FareType__c = 'TEST';
        tecOffItem.FareTypeValue__c = 'TEST';
        tecOffItem.InfoGroup__c = 'TEST';
        tecOffItem.InfoGroupValue__c = 'TEST';
        tecOffItem.NumericValue__c = '0.00001';
        tecOffItem.Flag__c = false;
        tecOffItem.PriceCode__c = 'TEST';
        tecOffItem.PriceCodeValue__c = 'TEST';
        tecOffItem.DiscountCode__c = 'TEST';
        tecOffItem.DiscountCodeValue__c = 'TEST';
        tecOffItem.StringValue__c = 'TEST';
        techOffeItems.add(tecOffItem);
        insert techOffeItems;

        productList[0].Status__c = 'Confermata';
        productList[0].StartDate__c = Date.today().addDays(2);
        productList[0].EndDate__c = Date.today().addDays(3);
        update productList;

        HDT_BA_ProductStObjStatusUpdate batch = new HDT_BA_ProductStObjStatusUpdate();
        Id batchId = Database.executeBatch(batch); 

        LoginGroup__c loginGroup = new LoginGroup__c(NameGroup__c = 'Sportello Imola');
        insert loginGroup;

    }

    @isTest
    static void getAdditionalSuggestFilters(){

        SBQQ__Quote__c quote = [
            SELECT Id, SBQQ__PricebookId__c
            FROM SBQQ__Quote__c
            WITH SECURITY_ENFORCED
            LIMIT 1 
        ];

        Test.startTest();

        HDT_UTL_SearchPlug controller = new HDT_UTL_SearchPlug();
        String result = controller.getAdditionalSuggestFilters(quote, null);
        
        System.assertNotEquals(null, result, 'result = null');
        System.assertNotEquals('', result, 'result = \'\'');

        Test.stopTest();

    }

    @isTest
    static void HDT_UTL_SearchPlug(){
        HDT_UTL_SearchPlug searchPlug = new HDT_UTL_SearchPlug();
        System.assertNotEquals(null, searchPlug, 'searchPlug != null');
    }

    @isTest
    static void isFilterHidden(){

        SBQQ__Quote__c quote = [
            SELECT Id, SBQQ__PricebookId__c,SBQQ__Status__c
            FROM SBQQ__Quote__c
            WITH SECURITY_ENFORCED
            LIMIT 1 
        ];

        Test.startTest();
        HDT_UTL_SearchPlug controller = new HDT_UTL_SearchPlug();
        Boolean result = controller.isFilterHidden(quote, 'ProductCode');
        System.assertEquals(null, result, 'result2 = false');

        quote.SBQQ__Status__c = 'Approved';
        update quote;

        Boolean result2 = controller.isFilterHidden(quote, 'ProductCode');
        System.assertEquals(null, result2, 'result2 = false');

        Test.stopTest();

    }

    @isTest
    static void getFilterDefaultValue(){

        Test.startTest();

        HDT_UTL_SearchPlug controller = new HDT_UTL_SearchPlug();
        String result = controller.getFilterDefaultValue(null, 'ProductCode');

        System.assertEquals(null, result, 'result != null');

        Test.stopTest();

    } 
    
    @isTest
    static void isSearchCustom(){

        Test.startTest();


        HDT_UTL_SearchPlug controller = new HDT_UTL_SearchPlug();
        Boolean result = controller.isSearchCustom(null, null);

        System.assertEquals(true, result, 'result = false');

        Test.stopTest();

    }
    
    @isTest
    static void getAdditionalSearchFilters(){

        SBQQ__Quote__c quote = [
            SELECT Id, SBQQ__PricebookId__c, SuperUser__c, SupplyCity__c
            FROM SBQQ__Quote__c
            WITH SECURITY_ENFORCED
            LIMIT 1 
        ];

        quote.ConsumptionRangeEE__c = 20.00;
        quote.NewClient__c = 'Y';
        update quote;

        EligibilityCriteria__c criteria = [SELECT Id,ConsumptionRangeEEmin__c, ConsumptionRangeEEmax__c, NewClient__c FROM EligibilityCriteria__c WITH SECURITY_ENFORCED LIMIT 1];
        criteria.ConsumptionRangeEEmin__c = 10;
        criteria.ConsumptionRangeEEmax__c = null;
        criteria.NewClient__c = 'Si';
        update criteria;

        Test.startTest();

        HDT_UTL_SearchPlug controller = new HDT_UTL_SearchPlug();
        String result = controller.getAdditionalSearchFilters(quote, null);

        System.assertNotEquals(null, result, 'result = null');
        System.assertNotEquals('', result, 'result = \'\'');

        quote.SuperUser__c = 'Y';
        update quote;

        String result2 = controller.getAdditionalSearchFilters(quote, null);

        System.assertNotEquals(null, result2, 'result = null');
        System.assertNotEquals('', result2, 'result = \'\'');

        Test.stopTest();

    }

    @isTest
    static void getAdditionalSearchFiltersWithSuperUser(){

        SBQQ__Quote__c quote = [
            SELECT Id, SBQQ__PricebookId__c, SuperUser__c, SupplyCity__c
            FROM SBQQ__Quote__c
            WITH SECURITY_ENFORCED
            LIMIT 1 
        ];

        quote.SuperUser__c = 'Y';
        quote.ConsumptionRangeEE__c = 20.00;
        update quote;

        EligibilityCriteria__c criteria = [SELECT Id,ConsumptionRangeEEmin__c, ConsumptionRangeEEmax__c FROM EligibilityCriteria__c WITH SECURITY_ENFORCED LIMIT 1];
        criteria.ConsumptionRangeEEmin__c = null;
        criteria.ConsumptionRangeEEmax__c = 60;
        update criteria;

        Test.startTest();

        HDT_UTL_SearchPlug controller = new HDT_UTL_SearchPlug();
        String result = controller.getAdditionalSearchFilters(quote, null);

        System.assertNotEquals(null, result, 'result = null');
        System.assertNotEquals('', result, 'result = \'\'');

        Test.stopTest();

    }
    
    @isTest
    static void search(){

        SBQQ__Quote__c quote = [
            SELECT Id, SBQQ__PricebookId__c
            FROM SBQQ__Quote__c
            WITH SECURITY_ENFORCED
            LIMIT 1 
        ];

        quote.SuperUser__c = 'Y';
        quote.ConsumptionRangeEE__c = 20.00;
        quote.NewClient__c = 'N';
        update quote;

        LoginGroup__c lg = [SELECT Id FROM LoginGroup__c WITH SECURITY_ENFORCED LIMIT 1];

        EligibilityCriteria__c criteria = [SELECT Id, LoginGroup__c, ConsumptionRangeEEmin__c, ConsumptionRangeEEmax__c, NewClient__c FROM EligibilityCriteria__c WITH SECURITY_ENFORCED LIMIT 1];
        criteria.LoginGroup__c = lg.Id;
        criteria.ConsumptionRangeEEmin__c = 10;
        criteria.ConsumptionRangeEEmax__c = 60;
        criteria.NewClient__c = 'No';
        update criteria;

        Map<String,Object> fieldValuesMap = new Map<String,Object>();
        Test.startTest();

        HDT_UTL_SearchPlug controller = new HDT_UTL_SearchPlug();
        List<PriceBookEntry> pbe = controller.search(quote, fieldValuesMap);

        System.assert(pbe.size() == 0, 'pbe == null or pbe.size() > 0');

        Test.stopTest();

    }

    @isTest
    static void isInputHidden(){

        SBQQ__Quote__c quote = [
            SELECT Id, SBQQ__PricebookId__c
            FROM SBQQ__Quote__c
            WITH SECURITY_ENFORCED
            LIMIT 1 
        ];

        Test.startTest();


        HDT_UTL_SearchPlug controller = new HDT_UTL_SearchPlug();
        Boolean result = controller.isInputHidden(quote, 'Comune__c');

        System.assertEquals(true, result, 'result = false');

        Test.stopTest();

    }
    
    @isTest
    static void getInputDefaultValue(){

        SBQQ__Quote__c quote = [
            SELECT Id, SBQQ__PricebookId__c
            FROM SBQQ__Quote__c
            WITH SECURITY_ENFORCED
            LIMIT 1 
        ];

        Test.startTest();

        HDT_UTL_SearchPlug controller = new HDT_UTL_SearchPlug();
        String result = controller.getInputDefaultValue(quote, '');

        System.assertEquals(null, result, 'result != null');

        Test.stopTest();

    }

    @isTest
    static void isSuggestCustom(){

        SBQQ__Quote__c quote = [
            SELECT Id, SBQQ__PricebookId__c
            FROM SBQQ__Quote__c
            WITH SECURITY_ENFORCED
            LIMIT 1 
        ];

        Test.startTest();

        HDT_UTL_SearchPlug controller = new HDT_UTL_SearchPlug();
        Boolean result = controller.isSuggestCustom(quote, null);

        System.assertEquals(false, result, 'result = true');

        Test.stopTest();

    }
    
    @isTest
    static void suggest(){

        Test.startTest();

        HDT_UTL_SearchPlug controller = new HDT_UTL_SearchPlug();
        List<PricebookEntry> pbeList = controller.suggest(null, null);

        System.assert(pbeList.size() > 0, 'pbeList == null or pbeList.size() = 0');

        Test.stopTest();

    }

}