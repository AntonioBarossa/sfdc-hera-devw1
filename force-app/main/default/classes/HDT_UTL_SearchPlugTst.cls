@isTest
public class HDT_UTL_SearchPlugTst {

    /*
        HDT_UTL_SearchPlug           32%
        HDT_QR_SearchPlug            61%
    */

    @TestSetup
    static void makeData(){
        List<Product2> productList = new List<Product2>();
        Product2 p = new Product2();
        p.ProductCode = 'pCode01';
        p.Version__c = '01V1';
        p.Name = 'ExampleProduct';
        p.Family = Label.HDT_ProductFamilyTrigger;
        p.IsActive = true;
        p.NoOrderable__c = false;
        productList.add(p);
        insert productList;
    
        List<EligibilityCriteria__c> criteriaList = new List<EligibilityCriteria__c>();
        EligibilityCriteria__c criteria = new EligibilityCriteria__c();
        criteria.Product__c = productList[0].Id;
        criteria.EligibleForAllCities__c = true;
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

        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.SBQQ__PricebookId__c = null;
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

        p.Status__c = 'Confermata';
        p.StartDate__c = Date.today().addDays(2);
        p.EndDate__c = Date.today().addDays(3);
        update p;

        HDT_BA_ProductStObjStatusUpdate batch = new HDT_BA_ProductStObjStatusUpdate();
        Id batchId = Database.executeBatch(batch); 

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
        controller.getAdditionalSuggestFilters(quote, null);
        Test.stopTest();

    }

    @isTest
    static void HDT_UTL_SearchPlug(){
        HDT_UTL_SearchPlug searchPlug = new HDT_UTL_SearchPlug();
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
        controller.isFilterHidden(quote, 'ProductCode');
        Test.stopTest();

    }

    @isTest
    static void getFilterDefaultValue(){

        Test.startTest();
        HDT_UTL_SearchPlug controller = new HDT_UTL_SearchPlug();
        controller.getFilterDefaultValue(null, 'ProductCode');
        Test.stopTest();

    } 
    
    @isTest
    static void isSearchCustom(){

        Test.startTest();
        HDT_UTL_SearchPlug controller = new HDT_UTL_SearchPlug();
        controller.isSearchCustom(null, null);
        Test.stopTest();

    }
    
    @isTest
    static void getAdditionalSearchFilters(){

        SBQQ__Quote__c quote = [
            SELECT Id, SBQQ__PricebookId__c
            FROM SBQQ__Quote__c
            WITH SECURITY_ENFORCED
            LIMIT 1 
        ];

        Test.startTest();
        HDT_UTL_SearchPlug controller = new HDT_UTL_SearchPlug();
        controller.getAdditionalSearchFilters(quote, null);
        Test.stopTest();

    }
    
    //@isTest
    //static void search(){
//
    //    SBQQ__Quote__c quote = [
    //        SELECT Id, SBQQ__PricebookId__c
    //        FROM SBQQ__Quote__c
    //        WITH SECURITY_ENFORCED
    //        LIMIT 1 
    //    ];
//
    //    Map<String,Object> fieldValuesMap = new Map<String,Object>();
    //    Test.startTest();
    //    HDT_UTL_SearchPlug controller = new HDT_UTL_SearchPlug();
    //    controller.search(quote, fieldValuesMap);
    //    Test.stopTest();
//
    //}

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
        controller.isInputHidden(quote, 'Comune__c');
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
        controller.getInputDefaultValue(quote, '');
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
        controller.isSuggestCustom(quote, null);
        Test.stopTest();

    }
    
    @isTest
    static void suggest(){
        Test.startTest();
        HDT_UTL_SearchPlug controller = new HDT_UTL_SearchPlug();
        controller.suggest(null, null);
        Test.stopTest();

    }

}