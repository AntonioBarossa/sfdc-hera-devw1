@isTest
public with sharing class HDT_UTL_AdministrationTaxBreaksTst {

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
		risultati = HDT_UTL_AdministrationTaxBreaks.getTexTaxBreaks(citytest,productCodetest);
		isEmptyVar = risultati.isEmpty();
		
		Test.stopTest();
		
		//ASSERTS
		
		System.assertEquals(false, isEmptyVar);
    }
}