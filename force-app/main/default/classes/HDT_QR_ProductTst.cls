/**
* @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
* @date 21/07/2021
* @description Test Class for HDT_QR_Product.cls
* @history Fabricio Petkevicius Nunes – 21/07/2021 – Created class
*/
@isTest
public class HDT_QR_ProductTst{
    @TestSetup
    static void setup(){
        
        List<Product2> prodList=HDT_UTL_DataFactoryTst.createProduct2(1, false);
        prodList[0].ProductCode='123';
        prodList[0].Version__c='V1';
        prodList[0].Family='Offerta commerciale';
        insert prodList;
    }
    
    @isTest
    static void testgetRecordByProductCode(){
        
        Test.startTest();
        
        Product2 tProd=[SELECT Id, Name, ProductCode
                        FROM Product2
                        WHERE ProductCode='123'
                        LIMIT 1];
        
        HDT_QR_Product qrProduct=new HDT_QR_Product();
        
        Product2 testProd=qrProduct.getRecordByProductCode(tProd.ProductCode);
        
        System.debug('testProd = '+testProd);
        
        
        System.assertEquals('123', testProd.ProductCode, 'ProductCode not populated correctly');
        
        System.assertNotEquals(null, testProd.ProductCode, 'Value of parameter is not matching');
        
        Test.stopTest();
    }
    
    @isTest
    static void testgetProductsByCodeVersion(){
        
        Test.startTest();
        
        Product2 tProd=[SELECT Id, Name, ProductCode, Version__c
                        FROM Product2
                        WHERE ProductCode='123'
                        LIMIT 1];
        
        Set <String> prodCodes=new Set <String>();
        Set <String> versions=new Set <String>();
        
        prodCodes.add(tProd.ProductCode);
        versions.add(tProd.Version__c);
        List <Product2> testProd=HDT_QR_Product.getProductsByCodeVersion(prodCodes, Versions);
        
        System.assertEquals('123', testProd[0].ProductCode, 'ProductCode not populated correctly');
        System.assertEquals('V1', testProd[0].Version__c, 'Version not populated correctly');
        System.assertNotEquals(null, testProd[0].ProductCode, 'Value of parameter is not matching');
        
        Test.stopTest();
    }
    
    @isTest
    static void testgetAllProducts(){
        
        Test.startTest();
        
        Product2 tProd=[SELECT Id, Name, ProductCode, Version__c
                        FROM Product2
                        WHERE ProductCode='123'
                        LIMIT 1];
        
        List <Product2> testProd=HDT_QR_Product.getAllProducts('test');
        
        System.assertEquals(null, testProd[0].CampaignEleggibilityGroup__c, 'CampaignEleggibilityGroup__c not populated correctly');
        System.assertNotEquals('test', testProd[0].CampaignEleggibilityGroup__c, 'Value of parameter is not matching');
        
        Test.stopTest();
    }
}