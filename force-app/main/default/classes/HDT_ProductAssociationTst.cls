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

        SBQQ__ProductRule__c rule = new SBQQ__ProductRule__c();
        rule.Name = 'ruleTest';
        rule.SBQQ__EvaluationEvent__c = 'Always';
        rule.SBQQ__ConditionsMet__c = 'All';
        rule.SBQQ__Type__c = 'Selection';
        rule.SBQQ__Scope__c = 'Product';
        insert rule;

    }

    @isTest
    public static void getFieldSet(){
        List<String> fieldSetListProductOption = HDT_LC_ProductAssociation.getFieldSet('SBQQ__ProductOption__c', 'Bonus_EE');
        List<String> fieldSetListProductRule = HDT_LC_ProductAssociation.getFieldSet('SBQQ__ProductRule__c', 'Bonus_EE');
        System.assertEquals(6, fieldSetListProductOption.size(),'');
        System.assertEquals(6, fieldSetListProductOption.size(),'');
    }

    @isTest
    public static void getProductList(){
        
        String optionalSkuId = [SELECT Id FROM Product2 WHERE Family = 'Punto Fornitura' LIMIT 1].Id;

        Product2 prodWrp = new Product2();
        prodWrp.Name = 'Example Offerta';
        prodWrp.DescriptionSAP__c = 'HERA';
        prodWrp.ProductCode = 'Example_OFF_NON_DOM_EE';
        prodWrp.Version__c = 'v1';
        prodWrp.Status__c = 'In Sviluppo';
        prodWrp.TypeOffer__c = 'Scaffale';
        prodWrp.CategoryFamily__c = 'A.R.E.R.A';
        String filterString = JSON.serialize(prodWrp);
        
        Test.startTest();
        Object respObj1 = HDT_LC_ProductAssociation.getProductList('SBQQ__ProductOption__c', filterString, optionalSkuId, 'insert', false, '1');

        //test try catch error
        Object respObj2 = HDT_LC_ProductAssociation.getProductList('SBQQ__ProductOption__c', '******', optionalSkuId, 'insert', false, '1');

        //test delete context
        Object respObj3 = HDT_LC_ProductAssociation.getProductList('SBQQ__ProductOption__c', filterString, optionalSkuId, 'delete', false, '1');
        Test.stopTest();

        HDT_WRP_ProductAssociation.HDT_WRP_RespQueryObj obj1 = (HDT_WRP_ProductAssociation.HDT_WRP_RespQueryObj)respObj1;
        HDT_WRP_ProductAssociation.HDT_WRP_RespQueryObj obj2 = (HDT_WRP_ProductAssociation.HDT_WRP_RespQueryObj)respObj2;
        HDT_WRP_ProductAssociation.HDT_WRP_RespQueryObj obj3 = (HDT_WRP_ProductAssociation.HDT_WRP_RespQueryObj)respObj3;
        System.assertEquals(false, obj1.success,'');
        System.assertEquals(false, obj2.success,'');
        System.assertEquals(false, obj2.success,'');

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

        Test.startTest();
        //test confirm selection button
        Object respObj1 = HDT_LC_ProductAssociation.runProductOptionAssociation('SBQQ__ProductOption__c', '', productOptionObj, recordList, executionType, filterString, dmlContext);
        Object respObj2 = HDT_LC_ProductAssociation.runProductOptionAssociation('SBQQ__ProductOption__c', '', null, recordList, executionType, filterString, dmlContext);

        for(Product2 p : [SELECT Id FROM Product2 WHERE Family = 'Offerta Commerciale' AND Name LIKE '%offertaExample%']){
            recordList.add(p.Id);
        }

        Object respObj3 = HDT_LC_ProductAssociation.runProductOptionAssociation('SBQQ__ProductOption__c', '', productOptionObj, recordList, executionType, filterString, dmlContext);

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

        Object respObj4 = HDT_LC_ProductAssociation.runProductOptionAssociation('SBQQ__ProductOption__c', '', productOptionObj, recordList, executionType, filterString, dmlContext);

        //test exception
        recordList.add('$%&%&');
        Object respObj5 = HDT_LC_ProductAssociation.runProductOptionAssociation('SBQQ__ProductOption__c', '***', '%$&', recordList, '%$&', '%$&', 'insert');

        //test exception insert error AND(TEXT(SBQQ__AppliedImmediatelyContext__c) != null, SBQQ__AppliedImmediately__c == false)
        
        List<String> recordListForException = new List<String>();
        String offerIdForException = [SELECT Id FROM Product2 WHERE Family = 'Offerta Commerciale' LIMIT 1].Id;
        recordListForException.add(offerIdForException);

        //test insert error
        prodOptionWrp.SBQQ__AppliedImmediatelyContext__c = 'Always';
        prodOptionWrp.SBQQ__AppliedImmediately__c = false;
        productOptionObj = JSON.serialize(prodOptionWrp);
        Object respObj6 = HDT_LC_ProductAssociation.runProductOptionAssociation('SBQQ__ProductOption__c', '', productOptionObj, recordListForException, executionType, filterString, dmlContext);
        Test.stopTest();

        HDT_WRP_ProductAssociation.HDT_WRP_RespRunBatchObj obj1 = (HDT_WRP_ProductAssociation.HDT_WRP_RespRunBatchObj)respObj1;
        HDT_WRP_ProductAssociation.HDT_WRP_RespRunBatchObj obj2 = (HDT_WRP_ProductAssociation.HDT_WRP_RespRunBatchObj)respObj2;
        HDT_WRP_ProductAssociation.HDT_WRP_RespRunBatchObj obj3 = (HDT_WRP_ProductAssociation.HDT_WRP_RespRunBatchObj)respObj3;
        HDT_WRP_ProductAssociation.HDT_WRP_RespRunBatchObj obj4 = (HDT_WRP_ProductAssociation.HDT_WRP_RespRunBatchObj)respObj4;
        HDT_WRP_ProductAssociation.HDT_WRP_RespRunBatchObj obj5 = (HDT_WRP_ProductAssociation.HDT_WRP_RespRunBatchObj)respObj5;
        HDT_WRP_ProductAssociation.HDT_WRP_RespRunBatchObj obj6 = (HDT_WRP_ProductAssociation.HDT_WRP_RespRunBatchObj)respObj6;
        System.assertEquals(true, obj1.success,'L\'associazione è stata eseguita correttamente');
        System.assertEquals(false, obj2.success,'Errore durante l\'elaborazione del prodotto opzione configurato');
        System.assertEquals(true, obj3.success,'L\'operazione durerà pochi minuti');
        System.assertEquals(true, obj4.success,'L\'operazione durerà pochi minuti');
        System.assertEquals(false, obj5.success,'error');
        System.assertEquals(true, obj6.success,'L\'operazione durerà pochi minuti');

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

        Test.startTest();
        //test confirm selection button
        //Id productOptionIdToDelete = [SELECT Id FROM SBQQ__ProductOption__c LIMIT 1].Id;
        Object respObj1 = HDT_LC_ProductAssociation.runProductOptionAssociation('SBQQ__ProductOption__c', prodOptionalId, productOptionObj, recordList, executionType, filterString, dmlContext);

        for(Product2 p : [SELECT Id FROM Product2 WHERE Family = 'Offerta Commerciale' AND Name LIKE '%offertaExample%']){
            recordList.add(p.Id);
        }

        Object respObj2 = HDT_LC_ProductAssociation.runProductOptionAssociation('SBQQ__ProductOption__c', prodOptionalId, productOptionObj, recordList, executionType, filterString, dmlContext);

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
        
        Object respObj3 = HDT_LC_ProductAssociation.runProductOptionAssociation('SBQQ__ProductOption__c', prodOptionalId, productOptionObj, recordList, executionType, filterString, dmlContext);
        Test.stopTest();

        HDT_WRP_ProductAssociation.HDT_WRP_RespRunBatchObj obj1 = (HDT_WRP_ProductAssociation.HDT_WRP_RespRunBatchObj)respObj1;
        HDT_WRP_ProductAssociation.HDT_WRP_RespRunBatchObj obj2 = (HDT_WRP_ProductAssociation.HDT_WRP_RespRunBatchObj)respObj2;
        HDT_WRP_ProductAssociation.HDT_WRP_RespRunBatchObj obj3 = (HDT_WRP_ProductAssociation.HDT_WRP_RespRunBatchObj)respObj3;
        System.assertEquals(true, obj1.success, 'L\'associazione è stata eliminata correttamente');
        System.assertEquals(true, obj2.success, 'L\'operazione durerà pochi minuti');
        System.assertEquals(true, obj3.success, 'L\'operazione durerà pochi minuti');

    }

    @isTest
    public static void getAsyncApexJob(){
        HDT_LC_ProductAssociation.getAsyncApexJob('SBQQ__ProductOption__c');
        HDT_LC_ProductAssociation.getAsyncApexJob('SBQQ__ProductRule__c');
    }

    @isTest
    public static void testSendNotificationException(){
        HDT_UTL_ProductAssociation.sendCustomNotification(null);
    }

    @isTest
    public static void runProductRuleAssociation_create(){

        String productRuleId = [SELECT Id FROM SBQQ__ProductRule__c WHERE Name = 'ruleTest' LIMIT 1].Id;

        Product2 prodWrp = new Product2();
        prodWrp.Name = '';
        prodWrp.DescriptionSAP__c = '';
        prodWrp.ProductCode = '';
        prodWrp.Version__c = '';
        prodWrp.Status__c = 'In Sviluppo';
        prodWrp.TypeOffer__c = '';
        prodWrp.CategoryFamily__c = '';
        String filterString = JSON.serialize(prodWrp);

        //test getProductList
        Object respObj1 = HDT_LC_ProductAssociation.getProductList('SBQQ__ConfigurationRule__c', filterString, productRuleId, 'insert', false, '1');

        //test try catch error
        Object respObj2 = HDT_LC_ProductAssociation.getProductList('SBQQ__ConfigurationRule__c', '******', productRuleId, 'insert', false, '1');

        //test complete filter
        Product2 prodFilterWrp = new Product2();
        prodFilterWrp.Name = 'Example Offerta';
        prodFilterWrp.DescriptionSAP__c = 'HERA';
        prodFilterWrp.ProductCode = 'Example_OFF_NON_DOM_EE';
        prodFilterWrp.Version__c = 'v1';
        prodFilterWrp.Status__c = 'In Sviluppo';
        prodFilterWrp.TypeOffer__c = 'Scaffale';
        prodFilterWrp.CategoryFamily__c = 'A.R.E.R.A';
        Object respObj3 = HDT_LC_ProductAssociation.getProductList('SBQQ__ConfigurationRule__c', JSON.serialize(prodFilterWrp), productRuleId, 'insert', false, '1');

        //test insert with select
        List<String> recordList = new List<String>();
        String offerId = [SELECT Id FROM Product2 WHERE Family = 'Offerta Commerciale' LIMIT 1].Id;
        recordList.add(offerId);

        SBQQ__ConfigurationRule__c confRuleObj = new SBQQ__ConfigurationRule__c();
        confRuleObj.SBQQ__Active__c = true;
        confRuleObj.SBQQ__ProductRule__c = productRuleId;

        Test.startTest();
        //test confirm selection button
        Object respObj4 = HDT_LC_ProductAssociation.runProductOptionAssociation('SBQQ__ConfigurationRule__c', '', JSON.serialize(confRuleObj), recordList, 'select', filterString, 'insert');
        Object respObj5 = HDT_LC_ProductAssociation.runProductOptionAssociation('SBQQ__ConfigurationRule__c', '', JSON.serialize(confRuleObj), recordList, 'filter', filterString, 'insert');

        List<String> recordCompleteList = new List<String>();
        for(Product2 p : [SELECT Id FROM Product2 WHERE Family = 'Offerta Commerciale']){
            recordCompleteList.add(p.Id);
        }
        Object respObj6 = HDT_LC_ProductAssociation.runProductOptionAssociation('SBQQ__ConfigurationRule__c', '', JSON.serialize(confRuleObj), recordCompleteList, 'select', filterString, 'insert');
       
        //test String.isEmpty(confRuleObj)
        Object respObj7 = HDT_LC_ProductAssociation.runProductOptionAssociation('SBQQ__ConfigurationRule__c', '', null, recordCompleteList, 'select', filterString, 'insert');

        //test exception
        recordList.add('$%&%&');
        Object respObj8 = HDT_LC_ProductAssociation.runProductOptionAssociation('SBQQ__ConfigurationRule__c', '***', '%$&', recordList, '%$&', '%$&', 'insert');
        
        //test insert error
        //TEXT(SBQQ__AscendingNestedLevel__c) != null && TEXT(SBQQ__AscendingNestedLevel__c) != '1') ||
        //(TEXT(SBQQ__DescendingNestedLevel__c) != null && TEXT(SBQQ__DescendingNestedLevel__c) != '1') ||
        //(TEXT(SBQQ__DescendingActionNesting__c) != null && TEXT(SBQQ__DescendingActionNesting__c) != '1')
        
        confRuleObj.SBQQ__DescendingActionNesting__c = '2';

        List<String> recordForErrorList = new List<String>();
        String offerForErrorId = [SELECT Id FROM Product2 WHERE Family = 'Offerta Commerciale' LIMIT 1].Id;
        recordForErrorList.add(offerForErrorId);
        Object respObj9 = HDT_LC_ProductAssociation.runProductOptionAssociation('SBQQ__ConfigurationRule__c', '', JSON.serialize(confRuleObj), recordForErrorList, 'select', filterString, 'insert');

        Test.stopTest();

        HDT_WRP_ProductAssociation.HDT_WRP_RespQueryObj obj1 = (HDT_WRP_ProductAssociation.HDT_WRP_RespQueryObj)respObj1;
        HDT_WRP_ProductAssociation.HDT_WRP_RespQueryObj obj2 = (HDT_WRP_ProductAssociation.HDT_WRP_RespQueryObj)respObj2;
        HDT_WRP_ProductAssociation.HDT_WRP_RespQueryObj obj3 = (HDT_WRP_ProductAssociation.HDT_WRP_RespQueryObj)respObj3;
        System.assertEquals(true, obj1.success,'');
        System.assertEquals(false, obj2.success,'');
        System.assertEquals(true, obj3.success,'');

        HDT_WRP_ProductAssociation.HDT_WRP_RespRunBatchObj obj4 = (HDT_WRP_ProductAssociation.HDT_WRP_RespRunBatchObj)respObj4;
        HDT_WRP_ProductAssociation.HDT_WRP_RespRunBatchObj obj5 = (HDT_WRP_ProductAssociation.HDT_WRP_RespRunBatchObj)respObj5;
        HDT_WRP_ProductAssociation.HDT_WRP_RespRunBatchObj obj6 = (HDT_WRP_ProductAssociation.HDT_WRP_RespRunBatchObj)respObj6;
        HDT_WRP_ProductAssociation.HDT_WRP_RespRunBatchObj obj7 = (HDT_WRP_ProductAssociation.HDT_WRP_RespRunBatchObj)respObj7;
        HDT_WRP_ProductAssociation.HDT_WRP_RespRunBatchObj obj8 = (HDT_WRP_ProductAssociation.HDT_WRP_RespRunBatchObj)respObj8;
        System.assertEquals(true, obj4.success, 'L\'associazione è stata eliminata correttamente');
        System.assertEquals(true, obj5.success, 'L\'operazione durerà pochi minuti');
        System.assertEquals(true, obj6.success, 'L\'operazione durerà pochi minuti');
        System.assertEquals(false, obj7.success, 'L\'operazione durerà pochi minuti');
        System.assertEquals(false, obj8.success, 'L\'operazione durerà pochi minuti');

    }

    @isTest
    public static void runProductRuleAssociation_delete(){

        String productRuleId = [SELECT Id FROM SBQQ__ProductRule__c WHERE Name = 'ruleTest' LIMIT 1].Id;
        List<SBQQ__ConfigurationRule__c> confRuleList = new List<SBQQ__ConfigurationRule__c>();
        SBQQ__ConfigurationRule__c confRuleObj;

        for(Product2 p : [SELECT Id FROM Product2 WHERE Family = 'Offerta Commerciale']){
            confRuleObj = new SBQQ__ConfigurationRule__c();
            confRuleObj.SBQQ__Active__c = true;
            confRuleObj.SBQQ__ProductRule__c = productRuleId;
            confRuleObj.SBQQ__Product__c = p.Id;
            confRuleList.add(confRuleObj);
        }

        insert confRuleList;

        Product2 prodWrp = new Product2();
        prodWrp.Name = '';
        prodWrp.DescriptionSAP__c = '';
        prodWrp.ProductCode = '';
        prodWrp.Version__c = '';
        prodWrp.Status__c = 'In Sviluppo';
        prodWrp.TypeOffer__c = '';
        prodWrp.CategoryFamily__c = '';
        String filterString = JSON.serialize(prodWrp);

        List<String> recordList = new List<String>();
        recordList.add(confRuleList[0].Id);

        Test.startTest();
        //test getProductList
        Object respObj1 = HDT_LC_ProductAssociation.getProductList('SBQQ__ConfigurationRule__c', filterString, productRuleId, 'delete', false, '1');

        //test confirm selection button
        Object respObj2 = HDT_LC_ProductAssociation.runProductOptionAssociation('SBQQ__ConfigurationRule__c', productRuleId, '', recordList, 'select', '', 'delete');

        //delete records size > 10
        List<String> allProductList = new List<String>();
        for(Product2 p : [SELECT Id FROM Product2 WHERE Family = 'Offerta Commerciale']){
            allProductList.add(confRuleList[0].Id);
        }
        Object respObj3 = HDT_LC_ProductAssociation.runProductOptionAssociation('SBQQ__ConfigurationRule__c', productRuleId, '', allProductList, 'select', '', 'delete');

        Object respObj4 = HDT_LC_ProductAssociation.runProductOptionAssociation('SBQQ__ConfigurationRule__c', productRuleId, '', recordList, 'filter', filterString, 'delete');
        Test.stopTest();

        HDT_WRP_ProductAssociation.HDT_WRP_RespQueryObj obj1 = (HDT_WRP_ProductAssociation.HDT_WRP_RespQueryObj)respObj1;
        HDT_WRP_ProductAssociation.HDT_WRP_RespRunBatchObj obj2 = (HDT_WRP_ProductAssociation.HDT_WRP_RespRunBatchObj)respObj2;
        HDT_WRP_ProductAssociation.HDT_WRP_RespRunBatchObj obj3 = (HDT_WRP_ProductAssociation.HDT_WRP_RespRunBatchObj)respObj3;
        HDT_WRP_ProductAssociation.HDT_WRP_RespRunBatchObj obj4 = (HDT_WRP_ProductAssociation.HDT_WRP_RespRunBatchObj)respObj4;
        System.assertEquals(true, obj1.success,'');
        System.assertEquals(true, obj2.success, 'L\'associazione è stata eliminata correttamente');
        System.assertEquals(true, obj3.success, 'L\'associazione è stata eliminata correttamente');
        System.assertEquals(true, obj4.success, 'L\'associazione è stata eliminata correttamente');

    }

    @isTest
    public static void groupMembers(){

        Id profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = 'Amministratore del sistema' LIMIT 1].Id;
        //User u = HDT_UTL_DataFactoryTst.createInternalUser(profileId, false);
        //insert u;

        User internalUser=new User(Alias='crmuser', FirstName='FirstName', LastName='LastName', Email='crmuser@test.com', EmailEncodingKey='UTF-8', LanguageLocaleKey='it', LocaleSidKey='it', ProfileId=profileId, TimeZoneSidKey='Europe/Rome', UserName='crmuser@test.com'+DateTime.now().getTime());
        insert internalUser;


        GroupMember grpMem1 = new GroupMember();
        grpMem1.UserOrGroupId = internalUser.Id;
        grpMem1.GroupId = [SELECT Id FROM Group WHERE DeveloperName = 'CpqAssociationTool' LIMIT 1].Id;
        insert grpMem1;
        Boolean result;

        Test.startTest();
        System.runAs(internalUser) {
        result = HDT_LC_ProductAssociation.getEnabledUser();
        }
        Test.stopTest();
        System.assertEquals(true, result, 'User not enabled');
    }

}