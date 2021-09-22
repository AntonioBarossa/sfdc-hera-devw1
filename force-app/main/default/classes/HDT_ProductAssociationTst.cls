@isTest
public class HDT_ProductAssociationTst {

    @testSetup
    static void setup() {

        List<Product2> productList = new List<Product2>();
        Product2 productOption0 = new Product2();
        productOption0.Name = 'alreadyOptioned';
        productOption0.Status__c = 'In Sviluppo';
        productOption0.Family = 'Punto Fornitura';
        productOption0.IsActive = true;
        productList.add(productOption0);

        Product2 productOptionStandard = new Product2();
        productOptionStandard.Name = 'standardOption';
        productOptionStandard.Status__c = 'In Sviluppo';
        productOptionStandard.Family = 'Bonus Eur/kWh';
        productOptionStandard.IsActive = true;
        productList.add(productOptionStandard);

        Product2 productOption = new Product2();
        productOption.Name = 'productOptionExample';
        productOption.Status__c = 'In Sviluppo';
        productOption.Family = 'Punto Fornitura';
        productOption.IsActive = true;

        productList.add(productOption);

        for(Integer i=0; i<20; i++){
            Product2 offerta1 = new Product2();
            offerta1.Name = 'offertaExample_' + String.valueOf(i);
            offerta1.Status__c = 'In Sviluppo';
            offerta1.Family = 'Offerta commerciale';
            offerta1.IsActive = true;
            productList.add(offerta1);       
        }

        insert productList;

        List<SBQQ__ProductOption__c> prodOptionList = new List<SBQQ__ProductOption__c>();
        Id prodOptionalId = [SELECT Id FROM Product2 WHERE Name = 'standardOption' LIMIT 1].Id;

        for(Product2 p : productList){
            SBQQ__ProductOption__c prodOption = new SBQQ__ProductOption__c();
            prodOption.SBQQ__ConfiguredSKU__c = p.Id;
            prodOption.SBQQ__OptionalSKU__c = prodOptionalId;
            prodOption.SBQQ__Number__c = 1;
            prodOption.SBQQ__Quantity__c = null;
            prodOption.SBQQ__QuantityEditable__c = false;
            prodOption.SBQQ__Selected__c = false;
            prodOption.SBQQ__Feature__c = null;
            prodOption.SBQQ__Type__c = 'Component';
            prodOptionList.add(prodOption);
        }

        insert prodOptionList;

        List<SBQQ__ProductFeature__c> featureList = new List<SBQQ__ProductFeature__c>();

        for(Product2 p : productList){
            SBQQ__ProductFeature__c feature = new SBQQ__ProductFeature__c();
            feature.Name = 'Punto Fornitura';
            feature.SBQQ__ConfiguredSKU__c = p.Id;
            feature.SBQQ__Number__c = 1;
            featureList.add(feature);
        }

        insert featureList;

    }

    @isTest
    public static void getFieldSet(){
        List<String> fieldSetListProductOption = HDT_LC_ProductAssociation.getFieldSet('SBQQ__ProductOption__c', 'Bonus_EE');
        List<String> fieldSetListProductRule = HDT_LC_ProductAssociation.getFieldSet('SBQQ__ProductRule__c', 'Bonus_EE');
    }

    @isTest
    public static void getProductList(){
        
        String optionalSkuId = [SELECT Id FROM Product2 WHERE Family = 'Punto Fornitura' LIMIT 1].Id;

        Product2 prodWrp = new Product2();
        prodWrp.Name = 'template Offerta';
        prodWrp.DescriptionSAP__c = 'HERA';
        prodWrp.ProductCode = 'TEMPLATE_OFF_NON_DOM_EE';
        prodWrp.Version__c = 'v1';
        prodWrp.Status__c = 'In Sviluppo';
        prodWrp.TypeOffer__c = 'Scaffale';
        prodWrp.CategoryFamily__c = 'A.R.E.R.A';
        String filterString = JSON.serialize(prodWrp);
        
        HDT_LC_ProductAssociation.getProductList('SBQQ__ProductOption__c', filterString, optionalSkuId, 'insert', false, '1');

        //test try catch error
        filterString = '******';
        HDT_LC_ProductAssociation.getProductList('SBQQ__ProductOption__c', filterString, optionalSkuId, 'insert', false, '1');

        //test delete context
        HDT_LC_ProductAssociation.getProductList('SBQQ__ProductOption__c', filterString, optionalSkuId, 'delete', false, '1');

    }

    @isTest
    public static void runProductOptionAssociation_create(){

        String optionalSkuId = [SELECT Id FROM Product2 WHERE Family = 'Punto Fornitura' LIMIT 1].Id;
        
        SBQQ__ProductOption__c prodOptionWrp = new SBQQ__ProductOption__c();
        prodOptionWrp.SBQQ__OptionalSKU__c = optionalSkuId;
        prodOptionWrp.SBQQ__Number__c = 3;
        prodOptionWrp.SBQQ__Quantity__c = null;
        prodOptionWrp.SBQQ__QuantityEditable__c = false;
        prodOptionWrp.SBQQ__Selected__c = false;
        prodOptionWrp.SBQQ__Feature__c = null;
        prodOptionWrp.SBQQ__Type__c = 'Component';
        String productOptionObj = JSON.serialize(prodOptionWrp);
        
        List<String> recordList = new List<String>();
        String offerId = [SELECT Id FROM Product2 WHERE Family = 'Offerta Commerciale' LIMIT 1].Id;
        recordList.add(offerId);

        String executionType = 'select';

        Product2 prodWrp = new Product2();
        prodWrp.Name = null;
        prodWrp.DescriptionSAP__c = null;
        prodWrp.ProductCode = '';
        prodWrp.Version__c = null;
        prodWrp.Status__c = 'In Sviluppo';
        prodWrp.TypeOffer__c = null;
        prodWrp.CategoryFamily__c = null;
        String filterString = JSON.serialize(prodWrp);

        String dmlContext = 'insert';

        //test confirm selection button
        HDT_LC_ProductAssociation.runProductOptionAssociation('SBQQ__ProductOption__c', '', productOptionObj, recordList, executionType, filterString, dmlContext);

        //test batch
        executionType = 'filter';

        Product2 prodWrp2 = new Product2();
        prodWrp2.Name = null;
        prodWrp2.DescriptionSAP__c = null;
        prodWrp2.ProductCode = '';
        prodWrp2.Version__c = null;
        prodWrp2.Status__c = 'In Sviluppo';
        prodWrp2.TypeOffer__c = null;
        prodWrp2.CategoryFamily__c = null;
        filterString = JSON.serialize(prodWrp2);

        HDT_LC_ProductAssociation.runProductOptionAssociation('SBQQ__ProductOption__c', '', productOptionObj, recordList, executionType, filterString, dmlContext);

    }

    @isTest
    public static void runProductOptionAssociation_delete(){

        List<SBQQ__ProductOption__c> prodOptionList = new List<SBQQ__ProductOption__c>();
        Id prodOptionalId = [SELECT Id FROM Product2 WHERE Name = 'alreadyOptioned' LIMIT 1].Id;

        for(Product2 p : [SELECT Id FROM Product2 WHERE Family = 'Offerta commerciale']){
            SBQQ__ProductOption__c prodOption = new SBQQ__ProductOption__c();
            prodOption.SBQQ__ConfiguredSKU__c = p.Id;//[SELECT Id FROM Product2 WHERE Family = 'Offerta commerciale' LIMIT 1].Id;
            prodOption.SBQQ__OptionalSKU__c = prodOptionalId;
            prodOption.SBQQ__Number__c = 1;
            prodOption.SBQQ__Quantity__c = null;
            prodOption.SBQQ__QuantityEditable__c = false;
            prodOption.SBQQ__Selected__c = false;
            prodOption.SBQQ__Feature__c = null;
            prodOption.SBQQ__Type__c = 'Component';
            prodOptionList.add(prodOption);
        }

        insert prodOptionList;
        System.debug('>>> TEST Prod Option list size: ' + prodOptionList.size());

        String optionalSkuId = [SELECT Id FROM Product2 WHERE Family = 'Punto Fornitura' LIMIT 1].Id;

        SBQQ__ProductOption__c prodOptionWrp = new SBQQ__ProductOption__c();
        prodOptionWrp.SBQQ__OptionalSKU__c = optionalSkuId;
        prodOptionWrp.SBQQ__Number__c = 3;
        prodOptionWrp.SBQQ__Quantity__c = null;
        prodOptionWrp.SBQQ__QuantityEditable__c = false;
        prodOptionWrp.SBQQ__Selected__c = false;
        prodOptionWrp.SBQQ__Feature__c = null;
        prodOptionWrp.SBQQ__Type__c = 'Component';
        String productOptionObj = JSON.serialize(prodOptionWrp);
        
        List<String> recordList = new List<String>();
        String offerId = [SELECT Id FROM Product2 WHERE Family = 'Offerta Commerciale' AND Name = 'offertaExample_1' LIMIT 1].Id;
        recordList.add(offerId);

        String executionType = 'select';

        Product2 prodWrp = new Product2();
        prodWrp.Name = null;
        prodWrp.DescriptionSAP__c = null;
        prodWrp.ProductCode = '';
        prodWrp.Version__c = null;
        prodWrp.Status__c = 'In Sviluppo';
        prodWrp.TypeOffer__c = null;
        prodWrp.CategoryFamily__c = null;
        String filterString = JSON.serialize(prodWrp);

        String dmlContext = 'delete';

        //test confirm selection button
        //Id productOptionIdToDelete = [SELECT Id FROM SBQQ__ProductOption__c LIMIT 1].Id;
        HDT_LC_ProductAssociation.runProductOptionAssociation('SBQQ__ProductOption__c', prodOptionalId, productOptionObj, recordList, executionType, filterString, dmlContext);

        //test batch
        executionType = 'filter';

        Product2 prodWrp2 = new Product2();
        prodWrp2.Name = null;
        prodWrp2.DescriptionSAP__c = null;
        prodWrp2.ProductCode = '';
        prodWrp2.Version__c = null;
        prodWrp2.Status__c = 'In Sviluppo';
        prodWrp2.TypeOffer__c = null;
        prodWrp2.CategoryFamily__c = null;
        filterString = JSON.serialize(prodWrp2);
        
        HDT_LC_ProductAssociation.runProductOptionAssociation('SBQQ__ProductOption__c', prodOptionalId, productOptionObj, recordList, executionType, filterString, dmlContext);

    }

    @isTest
    public static void getAsyncApexJob(){
        HDT_LC_ProductAssociation.getAsyncApexJob('SBQQ__ProductOption__c');
    }

}