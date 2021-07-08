@isTest
public class HDT_LC_OfferConfiguratorControllerTst {

    /*
        HDT_LC_OfferConfiguratorController  63%
        HDT_LC_OfferConfiguratorCtrlHelper  26%
        HDT_WRP_TechnicalOffer              0% 
        HDT_QR_TechnicalOffer               67%
        HDT_UTL_ProductStObjProcess         3% 
        HDT_TRH_ProductStObj                8% 
        HDT_ProductStObj                    100%
    */
        
    @testSetup
    static void setup() {
        List<Product2> productList = new List<Product2>();
        Product2 p = new Product2();
        p.ProductCode = 'pCode01';
        p.Version__c = '01V1';
        p.Name = 'ExampleProduct';
        p.Family = Label.HDT_ProductFamilyTrigger;
        productList.add(p);
        insert productList;

        List<OperandTemplate__c> operandTemplateList = new List<OperandTemplate__c>();
        OperandTemplate__c op1 = new OperandTemplate__c(Operands__c = 'ES_ADG_GO', ContractTemplate__c = 'ZELE_PREZZO', Typology__c = 'PDISCNT', Definition__c = 'DESCR ES_ADG_GO');
        operandTemplateList.add(op1);
        insert operandTemplateList;

        List<RateTemplate__c> rateList = new List<RateTemplate__c>();
        RateTemplate__c rateTemplate = new RateTemplate__c(Name = 'EVVUD', ContractTemplate__c = 'ZELE_DOMES', ServiceProduct__c = 'ELE_DOMES', Visibile__c = true);
        rateList.add(rateTemplate);
        insert rateList;

    }

    @isTest
    static void getTableData(){

        List<String> objList = new List<String>();
        objList.add('FareTypeList__c');
        objList.add('DiscountListaA__c');
        objList.add('DiscountListP__c');
        objList.add('PriceListT__c');
        objList.add('PriceListL__c');
        objList.add('PriceListQ__c');
        objList.add('infoGroup');

        List<sObject> tableDataList;
        Test.startTest();
        for(String s : objList){
            tableDataList = HDT_LC_OfferConfiguratorController.getTableData(s, '', '', '');
        }
        Test.stopTest();

    }

    @isTest
    static void getRateList(){

        List<RateTemplate__c> rateList;
        Test.startTest();
        rateList = HDT_LC_OfferConfiguratorController.getRateList('example');
        Test.stopTest();

    }

    @isTest
    static void getExistingOffer(){
        HDT_WRP_TechnicalOffer.HDT_WRP_ResponseTecOffer responseTecOffer;

        Product2 p = [
            SELECT Id
            FROM Product2
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];

        Test.startTest();
        responseTecOffer = HDT_LC_OfferConfiguratorController.getExistingOffer(p.Id);
        Test.stopTest();
    }

    @isTest
    static void getOfferMatrix(){

        HDT_WRP_TechnicalOffer.HDT_WRP_MatrixTable offerMatrix;
        Product2 p = [
            SELECT Id, ProductCode, Version__c
            FROM Product2
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];

        RateTemplate__c rate = [
            SELECT Id
            FROM RateTemplate__c
            WITH SECURITY_ENFORCED
            LIMIT 1    
        ];

        TechnicalOffer__c technicalOffer = new TechnicalOffer__c();
        technicalOffer.Name = p.ProductCode + ' [' + p.Version__c + '] [EVVUD]';
        technicalOffer.NameExternalId__c = technicalOffer.Name;
        technicalOffer.Product__c = p.Id;
        technicalOffer.RateCategory__c = rate.Id;
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

        Test.startTest();
        offerMatrix = HDT_LC_OfferConfiguratorController.getOfferMatrix(p.Id, '', 'ZELE_PREZZO');
        offerMatrix = HDT_LC_OfferConfiguratorController.getOfferMatrix(p.Id, technicalOffer.Id, 'ZELE_PREZZO');
        Test.stopTest();

    }

    @isTest
    static void saveNewOfferConfigured(){

        HDT_WRP_TechnicalOffer.HDT_WRP_SaveResponse saveResponse;
        Product2 p = [
            SELECT Id, ProductCode, Version__c
            FROM Product2
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];

        RateTemplate__c rate = [
            SELECT Id
            FROM RateTemplate__c
            WITH SECURITY_ENFORCED
            LIMIT 1    
        ];

        TechnicalOffer__c technicalOffer = new TechnicalOffer__c();
        technicalOffer.Name = p.ProductCode + ' [' + p.Version__c + '] [EVVUD]';
        technicalOffer.NameExternalId__c = technicalOffer.Name;
        technicalOffer.Product__c = p.Id;
        technicalOffer.RateCategory__c = rate.Id;


        Test.startTest();
        //insert
        saveResponse = HDT_LC_OfferConfiguratorController.saveNewOfferConfigured(JSON.serialize(technicalOffer), null, '', p.Id, '', 'EVVUD');

        TechnicalOffer__c newTechnicalOffer = new TechnicalOffer__c();
        newTechnicalOffer.Name = p.ProductCode + ' [' + p.Version__c + '] [EVVUD]';
        newTechnicalOffer.NameExternalId__c = technicalOffer.Name;
        newTechnicalOffer.Product__c = p.Id;
        newTechnicalOffer.RateCategory__c = rate.Id;
        insert technicalOffer;

        List<TechnicalOfferItem__c> techOffeItems = new List<TechnicalOfferItem__c>();
        TechnicalOfferItem__c tecOffItem = new TechnicalOfferItem__c();
        tecOffItem.TechnicalOffer__c = newTechnicalOffer.Id;
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

        //update
        saveResponse = HDT_LC_OfferConfiguratorController.saveNewOfferConfigured(JSON.serialize(technicalOffer), null, '', p.Id, newTechnicalOffer.Id, 'EVVUD');
        Test.stopTest();

    }
}