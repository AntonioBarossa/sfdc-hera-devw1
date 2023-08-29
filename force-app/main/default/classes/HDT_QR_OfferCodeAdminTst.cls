@isTest
public class HDT_QR_OfferCodeAdminTst {
    @testSetup
    static void setup() {      
		Product2 p = new Product2();
        p.ProductCode = 'pCode01';
        p.Version__c = '01V1';
        p.Name = 'ExampleProduct';
        p.Family = Label.HDT_ProductFamilyTrigger;
        p.DescriptionSAP__c = 'descr';
        insert p;
        
        List <OfferCode32Admin__c> offerCodes = new List <OfferCode32Admin__c>();
        OfferCode32Admin__c offCode=new OfferCode32Admin__c(OfferCode32__c='nkjankjnfkjnadkjangkngalnrlaagld', Company__c='7030', OfferProductCode__c='pCode01', OfferProductVersion__c='01V1', MarketType__c='Libero', Service__c='E', CodT0__c='Y', EffectiveDate__c=5);
        offerCodes.add(offCode);
        insert offerCodes;
    }

    @isTest
    static void testgetAllProducts(){
        
        Test.startTest();
        
        OfferCode32Admin__c offCode=[SELECT Id, OfferProductCode__c, OfferProductVersion__c
                        FROM OfferCode32Admin__c
                        WHERE OfferProductCode__c='pCode01'
                        LIMIT 1];
        
        Set <String> prodCodes=new Set <String>();
        Set <String> versions=new Set <String>();
        prodCodes.add(offCode.OfferProductCode__c);
        versions.add(offCode.OfferProductVersion__c);

        List <OfferCode32Admin__c> testOffer=HDT_QR_OfferCodeAdmin.getOfferCodesByProdVersion(prodCodes, Versions);
        
        System.assertEquals('pCode01', testOffer[0].OfferProductCode__c, 'ProductCode not populated correctly');
        System.assertEquals('01V1', testOffer[0].OfferProductVersion__c, 'Version not populated correctly');
        System.assertNotEquals(null, testOffer[0].OfferProductCode__c, 'Value of parameter is not matching');
        
        Test.stopTest();
    }
}