@isTest
public with sharing class HDT_UTL_AdministrationTaxBreaksTst {
	@TestSetup
	static void makeData(){
		Product2 testerProduct = new Product2(Name = 'NomeTest', ProductCode = 'TestProductCode', Family = 'Opzioni Tari', Service__c = 'Ambiente');
		insert testerProduct;
		WasteAdministrationTaxBreaks__c tester = new WasteAdministrationTaxBreaks__c(TextRemove__c = 'TextRmT1', TextRequest__c = 'TextRqT1', city__c = 'Roma');
		insert tester;
        tester.Product__c = testerProduct.Id;
        update tester;
	}
    @isTest
    private static void validategetTexTaxBreaks(){
		//DEBUG
		
        System.debug('Test classe HDT_UTL_AdministrationTaxBreaksTst metodo validategetTexTaxBreaks');
	
		//SETUP
		
		Boolean isEmptyVar = false;
		String citytest = 'Roma';
		String productCodetest = 'TestProductCode';
		List <WasteAdministrationTaxBreaks__c> risultati = new list <WasteAdministrationTaxBreaks__c>();
		
		//TESTING
		
		Test.startTest();
          
		String fields1 = 'Id, TextRemove__c, TextRequest__c,city__c,productCode__c';
		String obj1 = 'WasteAdministrationTaxBreaks__c';

        List <WasteAdministrationTaxBreaks__c> records=new list <WasteAdministrationTaxBreaks__c>();
		records = HDT_QR_GenericQuery.getGenericRecords(fields1,obj1,'');

        
		risultati = HDT_UTL_AdministrationTaxBreaks.getTexTaxBreaks(citytest,productCodetest);
		isEmptyVar = risultati.isEmpty();
		
		Test.stopTest();
		
		//ASSERTS
		
		System.assertEquals(false, isEmptyVar,'');
    }
}