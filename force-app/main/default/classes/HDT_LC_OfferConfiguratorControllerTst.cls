@isTest
public class HDT_LC_OfferConfiguratorControllerTst {

    /*
        HDT_LC_OfferConfiguratorController  82%
        HDT_LC_OfferConfiguratorCtrlHelper  81%
        HDT_WRP_TechnicalOffer              0% 
        HDT_QR_TechnicalOffer               82%
        HDT_WS_MulesoftCallerCpq            87%     
    */
        
    @testSetup
    static void setup() {
        List<Product2> productList = HDT_UTL_DataFactoryTst.createProduct2(3, false);

        productList[0].ProductCode = 'pCode01';
        productList[0].Version__c = '01V1';
        productList[0].Family = Label.HDT_ProductFamilyTrigger;

        productList[1].ProductCode = 'pCode02';
        productList[1].Version__c = '01V1';
        productList[1].Family = '';

        productList[2].ProductCode = 'pCode03';
        productList[2].Version__c = '01V1';
        productList[2].Family = Label.HDT_ProductFamilyTrigger;
        productList[2].Status__c = 'Confermata';

        insert productList;

        List<OperandTemplate__c> operandTemplateList = new List<OperandTemplate__c>();
        OperandTemplate__c op1 = new OperandTemplate__c(Operands__c = 'ES_ADG_GO', ContractTemplate__c = 'ZELE_PREZZO', Typology__c = 'PDISCNT', Definition__c = 'DESCR ES_ADG_GO');
        operandTemplateList.add(op1);
        insert operandTemplateList;

        List<RateTemplate__c> rateList = new List<RateTemplate__c>();
        RateTemplate__c rateTemplate = new RateTemplate__c(Name = 'EVVUD', ContractTemplate__c = 'ZELE_DOMES', ServiceProduct__c = 'ELE_DOMES', Visibile__c = true);
        rateList.add(rateTemplate);
        insert rateList;

        List<Info1GroupList__c> infoList = new List<Info1GroupList__c>();
        Info1GroupList__c inf = new Info1GroupList__c(Name = 'E650_CCE', FilterTypeCategory__c = 'ELVND_FC0L', DetTariffa__c = 'DetTariffa__c');
        infoList.add(inf);
        insert infoList;

        List<Info2GroupList__c> info2List = new List<Info2GroupList__c>();
        Info2GroupList__c info2 = new Info2GroupList__c(ValueDescription__c = 'EE Sconto su Amount 10%', DetRate__c = 'DetTariffa__c');
        info2List.add(info2);
        insert info2List;

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

            System.assert(tableDataList.size() == 0, 'tableDataList.size() > 0 or tableDataList == Null');
        }

        List<DiscountListaA__c> discList = new List<DiscountListaA__c>();
        DiscountListaA__c dl = new DiscountListaA__c(Description__c = 'EE Sconto su Amount 10');
        discList.add(dl);
        insert discList;

        //DiscountListaA__c with alla params
        tableDataList = HDT_LC_OfferConfiguratorController.getTableData('DiscountListaA__c', 'ELVND_FC0L', 'E650_CCE', 'Description__c', 'EE Sconto su Amount 10%');
        System.assert(tableDataList.size() > 0, 'tableDataList.size() == 0 or tableDataList == Null');

        //infoGroup with TariffDetails
        tableDataList = HDT_LC_OfferConfiguratorController.getTableData('infoGroup', 'ELVND_FC0L', 'E650_CCE', 'Description__c', 'EE Sconto su Amount 10%');
        System.assert(tableDataList.size() > 0, 'tableDataList.size() == 0 or tableDataList == Null');

         //infoGroup with searchFields = ''
         tableDataList = HDT_LC_OfferConfiguratorController.getTableData('infoGroup', 'ELVND_FC0L', 'E650_CCE', '', '');
         System.assert(tableDataList.size() > 0, 'tableDataList.size() == 0 or tableDataList == Null');

        Test.stopTest();

    }

    @isTest
    static void getRateList(){

        List<RateTemplate__c> rateList;
        Test.startTest();
        rateList = HDT_LC_OfferConfiguratorController.getRateList('example');

        System.assert(rateList.size() == 0, 'rateList.size() > 0 or rateList == null');

        Test.stopTest();

    }

    @isTest
    static void getExistingOffer(){
        HDT_WRP_TechnicalOffer.HDT_WRP_ResponseTecOffer responseTecOffer;

        Product2 p = [
            SELECT Id, ProductCode, Version__c
            FROM Product2
            WHERE ProductCode = 'pCode01'
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];

        Product2 p2 = [
            SELECT Id, ProductCode, Version__c 
            FROM Product2
            WHERE ProductCode = 'pCode02'
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];

        Product2 p3 = [
            SELECT Id, ProductCode, Version__c 
            FROM Product2
            WHERE ProductCode = 'pCode03'
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
        responseTecOffer = HDT_LC_OfferConfiguratorController.getExistingOffer(p.Id);

        System.assertEquals(true, responseTecOffer.success, 'success != true');
        System.assert(String.isBlank(responseTecOffer.errorMessage), 'responseTecOffer.errorMessage != null');
        System.assert(responseTecOffer.data != null, 'data == null');

        //Product with Family = ''

        responseTecOffer = HDT_LC_OfferConfiguratorController.getExistingOffer(p2.Id);

        System.assertEquals(false, responseTecOffer.success, 'success != true');
        System.assert(!String.isBlank(responseTecOffer.errorMessage), 'responseTecOffer.errorMessage == null');
        System.assert(Label.HDT_OfferConfig_OfferType.equals(responseTecOffer.errorMessage), 'responseTecOffer.errorMessage != Label.HDT_OfferConfig_OfferType');


        //Product with Status != Label.HDT_InDevelopment

        responseTecOffer = HDT_LC_OfferConfiguratorController.getExistingOffer(p3.Id);

        System.assertEquals(true, responseTecOffer.success, 'success != true');
        System.assert(String.isBlank(responseTecOffer.errorMessage), 'responseTecOffer.errorMessage != null');
        System.assert(responseTecOffer.data != null, 'data == null');

        Test.stopTest();
    }

    @isTest
    static void getOfferMatrix(){

        HDT_WRP_TechnicalOffer.HDT_WRP_MatrixTable offerMatrix;
        Product2 p = [
            SELECT Id, ProductCode, Version__c
            FROM Product2
            WHERE ProductCode = 'pCode01'
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

        System.assertEquals(true, offerMatrix.success, 'offerMatrix != false');
        System.assert(offerMatrix.rowList.size() > 0, 'rowList.size() == 0 or rowList == null');

        offerMatrix = HDT_LC_OfferConfiguratorController.getOfferMatrix(p.Id, technicalOffer.Id, 'ZELE_PREZZO');

        System.assertEquals(true, offerMatrix.success, 'offerMatrix != true');
        System.assert(offerMatrix.rowList.size() > 0, 'rowList.size() == 0 or rowList == null');

        HDT_WRP_TechnicalOffer.HDT_WRP_TechnicalOfferWebService obj;
        obj = HDT_LC_OfferConfiguratorCtrlHelper.generateHttpBody(obj, technicalOffer);

        System.assertEquals(true, obj.success, 'success != true');
        System.debug('obj content: ' + obj);

        Test.stopTest();

    }

    @isTest
    static void getOfferMatrixHandleThrownException(){

        HDT_WRP_TechnicalOffer.HDT_WRP_MatrixTable offerMatrix;

        Test.startTest();

        try {

            offerMatrix = HDT_LC_OfferConfiguratorController.getOfferMatrix('0', '0', '0');
            
        } catch (AuraHandledException e) {

            System.assertNotEquals(null, e.getMessage(), 'AuraHandledException expected');
            
        }
        
        Test.stopTest();

    }

    @isTest
    static void saveNewOfferConfigured(){

        HDT_WRP_TechnicalOffer.HDT_WRP_SaveResponse saveResponse;
        Product2 p = [
            SELECT Id, ProductCode, Version__c
            FROM Product2
            WHERE ProductCode = 'pCode01'
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

        TechnicalOfferItem__c techOff = [SELECT Id FROM TechnicalOfferItem__c LIMIT 1];

        //update
        String offerJson = '[{"definition":"EE-Perd.reteperCert.GO","discountCode":{"enabled":true,"relatedTo":"DiscountListP__c"},"flag":{"enabled":false,"relatedTo":"","value":"true"},"g":false,"id":"0","infoGroup":{"enabled":false,"relatedTo":""},"m":false,"numValue":{"enabled":false,"relatedTo":""},"priceCode":{"enabled":false,"relatedTo":""},"rateType":{"enabled":false,"relatedTo":""},"s":"x","stringValue":{"enabled":false,"relatedTo":""},"tecName":"ES_ADG_GO","type":"PDISCNT","v":true,"rowId":"'+ techOff.Id +'"}]';
        saveResponse = HDT_LC_OfferConfiguratorController.saveNewOfferConfigured(JSON.serialize(technicalOffer), null, offerJson, p.Id, newTechnicalOffer.Id, 'EVVUD');

        System.assertEquals(true, saveResponse.success, 'success != true');
        
        List<TechnicalOfferItem__c> techOffList;
        techOffList = HDT_LC_OfferConfiguratorController.getTechnicalOfferRecords(newTechnicalOffer.Id);

        System.assert(techOffList.size() > 0, 'techOffList.size() == 0 or techOffList == null');
        
        Test.stopTest();

    }

    @isTest
    static void saveNewOfferConfiguredHandleThrownException(){


        Test.startTest();

        try {

            List<TechnicalOfferItem__c> techOffList;
            techOffList = HDT_LC_OfferConfiguratorController.getTechnicalOfferRecords(null);
            
        } catch (AuraHandledException e) {

            System.assertNotEquals(null, e.getMessage(), 'AuraHandledException expected');

        }
        
        Test.stopTest();

    }

    @isTest
    static void saveNewOfferConfiguredWithOfferlineFlagFalse(){

        HDT_WRP_TechnicalOffer.HDT_WRP_SaveResponse saveResponse;
        Product2 p = [
            SELECT Id, ProductCode, Version__c
            FROM Product2
            WHERE ProductCode = 'pCode01'
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
        String offerJson = '[{"definition":"EE-Perd.reteperCert.GO","discountCode":{"enabled":true,"relatedTo":"DiscountListP__c"},"flag":{"enabled":false,"relatedTo":"","value":"false"},"g":false,"id":"0","infoGroup":{"enabled":false,"relatedTo":""},"m":false,"numValue":{"enabled":false,"relatedTo":""},"priceCode":{"enabled":false,"relatedTo":""},"rateType":{"enabled":false,"relatedTo":""},"s":"x","stringValue":{"enabled":false,"relatedTo":""},"tecName":"ES_ADG_GO","type":"PDISCNT","v":true}]';
        saveResponse = HDT_LC_OfferConfiguratorController.saveNewOfferConfigured(JSON.serialize(technicalOffer), null, offerJson, p.Id, newTechnicalOffer.Id, 'EVVUD');

        System.assertEquals(true, saveResponse.success, 'success != true');
        
        List<TechnicalOfferItem__c> techOffList;
        techOffList = HDT_LC_OfferConfiguratorController.getTechnicalOfferRecords(newTechnicalOffer.Id);

        System.assert(techOffList.size() > 0, 'techOffList.size() == 0 or techOffList == null');
        
        Test.stopTest();

    }

    @isTest
    static void saveNewOfferConfiguredWithOfferlineWithThrownException(){

        HDT_WRP_TechnicalOffer.HDT_WRP_SaveResponse saveResponse;
        Product2 p = [
            SELECT Id, ProductCode, Version__c
            FROM Product2
            WHERE ProductCode = 'pCode01'
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
        String offerJson = '[{"definition":"EE-Perd.reteperCert.GO","discountCode":{"enabled":true,"relatedTo":"DiscountListP__c"},"flag":{"enabled":false,"relatedTo":"","value":"false"},"g":false,"id":"0","infoGroup":{"enabled":false,"relatedTo":""},"m":false,"numValue":{"enabled":false,"relatedTo":""},"priceCode":{"enabled":false,"relatedTo":""},"rateType":{"enabled":false,"relatedTo":""},"s":"x","stringValue":{"enabled":false,"relatedTo":""},"tecName":"ES_ADG_GO","type":"PDISCNT","v":true,"rowId":"0"}]';

        try {
            
            saveResponse = HDT_LC_OfferConfiguratorController.saveNewOfferConfigured(JSON.serialize(technicalOffer), null, offerJson, p.Id, newTechnicalOffer.Id, 'EVVUD');
    
            List<TechnicalOfferItem__c> techOffList;
            techOffList = HDT_LC_OfferConfiguratorController.getTechnicalOfferRecords(newTechnicalOffer.Id);
    
        } catch (Exception e) {

            System.assertNotEquals(null, e.getMessage(), 'Expected a Thrown Exception');
            
        }
        
        Test.stopTest();

    }
    

    @isTest
    static void sendTechOfferToSap(){
        HDT_WRP_TechnicalOffer.HDT_WRP_SaveResponse saveResponse;
        
        
        Product2 p = [
            SELECT Id, ProductCode, Version__c
            FROM Product2
            WHERE ProductCode = 'pCode01'
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

        System.assertEquals(true, saveResponse.success, 'success != true');
        System.assert(!String.isBlank(saveResponse.bodyResponse), 'saveResponse.bodyResponse == null');

        Test.stopTest();
    }

    @isTest
    static void sendTechOfferToSapFail(){
        HDT_WRP_TechnicalOffer.HDT_WRP_SaveResponse saveResponse;
        
        
        Product2 p = [
            SELECT Id, ProductCode, Version__c
            FROM Product2
            WHERE ProductCode = 'pCode01'
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

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new HDT_LC_OfferConfiguratorCtrlTstMockFail());

        saveResponse = HDT_LC_OfferConfiguratorController.sendTechOfferToSap(newTechnicalOffer.Id);

        System.assertEquals(false, saveResponse.success, 'success != false');

        Test.stopTest();
    }

    @isTest
    static void sendTechOfferToSapFail2(){
        HDT_WRP_TechnicalOffer.HDT_WRP_SaveResponse saveResponse;
        
        
        Product2 p = [
            SELECT Id, ProductCode, Version__c
            FROM Product2
            WHERE ProductCode = 'pCode01'
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
        newTechnicalOffer.NumberOfTimeUnits__c = '';
        newTechnicalOffer.UnitOfTimeMeasurement__c = '3';
        newTechnicalOffer.AdmittingProfileModification__c = false;
        newTechnicalOffer.OfferToBeModified__c = false;
        insert newTechnicalOffer;

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new HDT_LC_OfferConfiguratorCtrlTstMockFail());

        saveResponse = HDT_LC_OfferConfiguratorController.sendTechOfferToSap(newTechnicalOffer.Id);

        System.assertEquals(false, saveResponse.success, 'success != false');

        Test.stopTest();
    }

    @isTest
    static void sendTechOfferToSapHandleThrownException(){

        HDT_WRP_TechnicalOffer.HDT_WRP_SaveResponse saveResponse;

        Test.startTest();

        try {

            saveResponse = HDT_LC_OfferConfiguratorController.sendTechOfferToSap(null);
            
        } catch (AuraHandledException e) {

            System.assertNotEquals(null, e.getMessage(), 'AuraHandledException expected');
            
        }
        
        Test.stopTest();

    }
    
    @isTest
    static void cloneRecord(){

        Product2 p = [
            SELECT Id, ProductCode, Version__c
            FROM Product2
            WHERE ProductCode = 'pCode01'
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

        System.assertEquals(true, saveResponse.success, 'success != true');
        System.assert(saveResponse.errorData != null, 'saveResponse.errorData == null');
        System.assert('Offerta eliminata correttamente'.equalsIgnoreCase(saveResponse.message), 'saveResponse.message != Offerta eliminata correttamente');

        Test.stopTest();
    }

    @isTest
    static void getTableDataHandleThrownException(){

        List<sObject> resultsList;

        Test.startTest();

        try {

            resultsList = HDT_LC_OfferConfiguratorController.getTableData(null, null, null, null, null);
            
        } catch (AuraHandledException e) {

            System.assertNotEquals(null, e.getMessage(), 'AuraHandledException expected');
            
        }
        
        Test.stopTest();

    }

    @isTest
    static void cloneRecordHandleThrownException(){


        Test.startTest();

        try {

            String results = HDT_LC_OfferConfiguratorController.cloneRecord(null, null);
            
        } catch (AuraHandledException e) {

            System.assertNotEquals(null, e.getMessage(), 'AuraHandledException expected');
            
        }
        
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


    public class HDT_LC_OfferConfiguratorCtrlTstMockFail implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest request) {
            // Create a fake response
    
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"status": "failed","correlationId": "92293250-df3b-11eb-a73c-0200a41fc6da","timestamp": "2021-07-07T17:54:13","errorDetails":[{"code":"HTTP:INTERNAL_SERVER_ERROR","message":"Error"}],"data": [], "esito":"KO"}');
            response.setStatusCode(500);
            response.setStatus('KO');
            return response; 
        }
    }

}