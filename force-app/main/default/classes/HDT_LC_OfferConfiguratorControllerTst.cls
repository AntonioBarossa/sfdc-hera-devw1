@isTest
public class HDT_LC_OfferConfiguratorControllerTst {

    /*
        HDT_LC_OfferConfiguratorController  76%
        HDT_LC_OfferConfiguratorCtrlHelper  65%
        HDT_WRP_TechnicalOffer              0% 
        HDT_QR_TechnicalOffer               82%
        HDT_WS_MulesoftCallerCpq            87%     
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
            tableDataList = HDT_LC_OfferConfiguratorController.getTableData(s, '', '', '', '');
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

        HDT_WRP_TechnicalOffer.HDT_WRP_TechnicalOfferWebService obj;
        HDT_LC_OfferConfiguratorCtrlHelper.generateHttpBody(obj, technicalOffer);
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

        List<HDT_WRP_TechnicalOffer.HDT_WRP_MatrixSingleRow> matrixSingleRowList = new List<HDT_WRP_TechnicalOffer.HDT_WRP_MatrixSingleRow>();
        HDT_WRP_TechnicalOffer.HDT_WRP_MatrixSingleRow matrixSingleRow = new HDT_WRP_TechnicalOffer.HDT_WRP_MatrixSingleRow();
        matrixSingleRow.id = '';
        matrixSingleRow.rowId = '0';
        matrixSingleRow.tecName = '';
        matrixSingleRow.definition = '';
        matrixSingleRow.type = '';
        matrixSingleRow.g = true;
        matrixSingleRow.m = true;
        matrixSingleRow.v = true;
        matrixSingleRow.s = '';

        matrixSingleRow.rateType = new HDT_WRP_TechnicalOffer.HDT_WRP_RowDetail();
        matrixSingleRow.rateType.value = '';
        matrixSingleRow.rateType.label = '';
        matrixSingleRow.rateType.relatedTo = '';
        matrixSingleRow.rateType.enabled = true;

        matrixSingleRow.infoGroup = new HDT_WRP_TechnicalOffer.HDT_WRP_RowDetail();
        matrixSingleRow.infoGroup.value = '';
        matrixSingleRow.infoGroup.label = '';
        matrixSingleRow.infoGroup.relatedTo = '';
        matrixSingleRow.infoGroup.enabled = true;

        matrixSingleRow.numValue = new HDT_WRP_TechnicalOffer.HDT_WRP_RowDetail();
        matrixSingleRow.numValue.value = '';
        matrixSingleRow.numValue.label = '';
        matrixSingleRow.numValue.relatedTo = '';
        matrixSingleRow.numValue.enabled = true;

        matrixSingleRow.flag = new HDT_WRP_TechnicalOffer.HDT_WRP_RowDetail();
        matrixSingleRow.flag.value = '';
        matrixSingleRow.flag.label = '';
        matrixSingleRow.flag.relatedTo = '';
        matrixSingleRow.flag.enabled = true;

        matrixSingleRow.priceCode = new HDT_WRP_TechnicalOffer.HDT_WRP_RowDetail();
        matrixSingleRow.priceCode.value = '';
        matrixSingleRow.priceCode.label = '';
        matrixSingleRow.priceCode.relatedTo = '';
        matrixSingleRow.priceCode.enabled = true;

        matrixSingleRow.discountCode = new HDT_WRP_TechnicalOffer.HDT_WRP_RowDetail();
        matrixSingleRow.discountCode.value = '';
        matrixSingleRow.discountCode.label = '';
        matrixSingleRow.discountCode.relatedTo = '';
        matrixSingleRow.discountCode.enabled = true;

        matrixSingleRow.stringValue = new HDT_WRP_TechnicalOffer.HDT_WRP_RowDetail();
        matrixSingleRow.stringValue.value = '';
        matrixSingleRow.stringValue.label = '';
        matrixSingleRow.stringValue.relatedTo = '';
        matrixSingleRow.stringValue.enabled = true;
        matrixSingleRowList.add(matrixSingleRow);


        Test.startTest();
        //insert
        saveResponse = HDT_LC_OfferConfiguratorController.saveNewOfferConfigured(JSON.serialize(technicalOffer), null, JSON.serialize(matrixSingleRowList), p.Id, '', 'EVVUD');

        TechnicalOffer__c newTechnicalOffer = new TechnicalOffer__c();
        newTechnicalOffer.Name = p.ProductCode + ' [' + p.Version__c + '] [EVVUD]';
        newTechnicalOffer.NameExternalId__c = newTechnicalOffer.Name;
        newTechnicalOffer.Product__c = p.Id;
        newTechnicalOffer.RateCategory__c = rate.Id;
        insert newTechnicalOffer;

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
        
        List<TechnicalOfferItem__c> techOffList;
        techOffList = HDT_LC_OfferConfiguratorController.getTechnicalOfferRecords(newTechnicalOffer.Id);
        
        Test.stopTest();

    }

    @isTest
    static void sendTechOfferToSap(){
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

        TechnicalOffer__c newTechnicalOffer = new TechnicalOffer__c();
        newTechnicalOffer.Name = p.ProductCode + ' [' + p.Version__c + '] [EVVUD]';
        newTechnicalOffer.NameExternalId__c = newTechnicalOffer.Name;
        newTechnicalOffer.Product__c = p.Id;
        newTechnicalOffer.RateCategory__c = rate.Id;
        newTechnicalOffer.Market__c = 'mm';
        newTechnicalOffer.StartDate__c = Date.today();
        newTechnicalOffer.EndDate__c = Date.today().addDays(1);
        newTechnicalOffer.StepAllowed__c = 'N';
        newTechnicalOffer.ContractId__c = '1';
        newTechnicalOffer.NumberTimeExtension__c = '1';
        newTechnicalOffer.UnitTimeExtension__c = '1';
        newTechnicalOffer.NumberDaysMonthsYears__c = '1';
        newTechnicalOffer.UnitTerminationTime__c = '3';
        newTechnicalOffer.CancellationAllowed__c = 'N';
        newTechnicalOffer.RecessAdmitted__c = 'N';
        newTechnicalOffer.NumberOfTimeUnits__c = '3';
        newTechnicalOffer.UnitOfTimeMeasurement__c = '3';
        newTechnicalOffer.AdmittingProfileModification__c = false;
        newTechnicalOffer.OfferToBeModified__c = false;
        insert newTechnicalOffer;

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

        Test.setMock(HttpCalloutMock.class, new HDT_LC_OfferConfiguratorCtrlTstMock());

        Test.startTest();
        saveResponse = HDT_LC_OfferConfiguratorController.sendTechOfferToSap(newTechnicalOffer.Id);
        Test.stopTest();
    }
    

    @isTest
    static void cloneRecord(){

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

        TechnicalOffer__c newTechnicalOffer = new TechnicalOffer__c();
        newTechnicalOffer.Name = p.ProductCode + ' [' + p.Version__c + '] [EVVUD]';
        newTechnicalOffer.NameExternalId__c = newTechnicalOffer.Name;
        newTechnicalOffer.Product__c = p.Id;
        newTechnicalOffer.RateCategory__c = rate.Id;
        insert newTechnicalOffer;

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

        Test.startTest();
        String s = HDT_LC_OfferConfiguratorController.cloneRecord(newTechnicalOffer.Id, p.Id);
        HDT_WRP_TechnicalOffer.HDT_WRP_SaveResponse saveResponse;
        saveResponse = HDT_LC_OfferConfiguratorController.deleteTechnicalOffer(p.Id, newTechnicalOffer.Id);
        List<TechnicalOfferItem__c> technicalOfferItemList = HDT_LC_OfferConfiguratorController.getTechnicalOfferRecords(newTechnicalOffer.Id);
        Test.stopTest();
    }

    //@isTest
    //static void getTechnicalOfferRecords(){
    //    TechnicalOffer__c offTech = [SELECT Id FROM TechnicalOffer__c LIMIT 1];
//
    //    Test.startTest();
    //    
    //    Test.stopTest();
    //}

}