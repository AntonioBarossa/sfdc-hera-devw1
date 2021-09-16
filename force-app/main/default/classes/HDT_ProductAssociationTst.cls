@isTest
public class HDT_ProductAssociationTst {

    @testSetup
    static void setup() {

        List<Product2> productList = new List<Product2>();
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

    }

    @isTest
    public static void getProductList(){
        
        String optionalSkuId = [SELECT Id FROM Product2 WHERE Family = 'Punto Fornitura' LIMIT 1].Id;
        String filterString = '{"Name":"emplate Offerta ","DescriptionSAP__c":"HERA ","ProductCode":"TEMPLATE_OFF_NON_DOM_EE","Version__c":"v1","Status__c":"In Sviluppo","TypeOffer__c":"Scaffale","CategoryFamily__c":"A.R.E.R.A"}';
        HDT_LC_ProductAssociation.getProductList(filterString, optionalSkuId, 'insert', false, '1');

        //test try catch error
        filterString = '******';
        HDT_LC_ProductAssociation.getProductList(filterString, optionalSkuId, 'insert', false, '1');

        //test delete context
        HDT_LC_ProductAssociation.getProductList(filterString, optionalSkuId, 'delete', false, '1');

    }

    @isTest
    public static void runProductOptionAssociation_create(){

        String optionalSkuId = [SELECT Id FROM Product2 WHERE Family = 'Punto Fornitura' LIMIT 1].Id;
        String productOptionObj = '{"SBQQ__OptionalSKU__c":"' + optionalSkuId + '","SBQQ__Number__c":"3","SBQQ__Quantity__c":null,"SBQQ__QuantityEditable__c":false,"SBQQ__Selected__c":false,"SBQQ__Feature__c":null,"SBQQ__Type__c":"Component"}';
        
        List<String> recordList = new List<String>();
        String offerId = [SELECT Id FROM Product2 WHERE Family = 'Offerta Commerciale' LIMIT 1].Id;
        recordList.add(offerId);

        String executionType = 'select';
        String filterString = '{"Name":null,"DescriptionSAP__c":null,"ProductCode":"","Version__c":null,"Status__c":"In Sviluppo","TypeOffer__c":null,"CategoryFamily__c":null}';
        String dmlContext = 'insert';

        //test confirm selection button
        HDT_LC_ProductAssociation.runProductOptionAssociation('', productOptionObj, recordList, executionType, filterString, dmlContext);

        //test batch
        executionType = 'filter';
        filterString = '{"Name":null,"DescriptionSAP__c":null,"ProductCode":"","Version__c":null,"Status__c":"In Sviluppo","TypeOffer__c":null,"CategoryFamily__c":null}';
        HDT_LC_ProductAssociation.runProductOptionAssociation('', productOptionObj, recordList, executionType, filterString, dmlContext);

    }

    @isTest
    public static void runProductOptionAssociation_delete(){

        String optionalSkuId = [SELECT Id FROM Product2 WHERE Family = 'Punto Fornitura' LIMIT 1].Id;
        String productOptionObj = '{"SBQQ__OptionalSKU__c":"' + optionalSkuId + '","SBQQ__Number__c":"3","SBQQ__Quantity__c":null,"SBQQ__QuantityEditable__c":false,"SBQQ__Selected__c":false,"SBQQ__Feature__c":null,"SBQQ__Type__c":"Component"}';
        
        List<String> recordList = new List<String>();
        String offerId = [SELECT Id FROM Product2 WHERE Family = 'Offerta Commerciale' LIMIT 1].Id;
        recordList.add(offerId);

        String executionType = 'select';
        String filterString = '{"Name":null,"DescriptionSAP__c":null,"ProductCode":"","Version__c":null,"Status__c":"In Sviluppo","TypeOffer__c":null,"CategoryFamily__c":null}';
        String dmlContext = 'delete';

        //test confirm selection button
        HDT_LC_ProductAssociation.runProductOptionAssociation('', productOptionObj, recordList, executionType, filterString, dmlContext);

        //test batch
        executionType = 'filter';
        filterString = '{"Name":null,"DescriptionSAP__c":null,"ProductCode":"","Version__c":null,"Status__c":"In Sviluppo","TypeOffer__c":null,"CategoryFamily__c":null}';
        HDT_LC_ProductAssociation.runProductOptionAssociation('', productOptionObj, recordList, executionType, filterString, dmlContext);

    }

}