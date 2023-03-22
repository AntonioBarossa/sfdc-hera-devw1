@isTest
public with sharing class HDT_TRH_WasteAdministrationTaxBreaksTst {


    @isTest
    private static void validateWasteAdministrationTaxBreaks(){
        
        //DEBUG
        System.debug('classe test HDT_TRH_WasteAdministrationTaxBreaksTst metodo validateWasteAdministrationTaxBreaks');
        
        //SETUP
		List<WasteAdministrationTaxBreaks__c> records = new List<WasteAdministrationTaxBreaks__c>();
		records.add(new WasteAdministrationTaxBreaks__c(TextRequest__c = 'Test\nRecord', TextRemove__c = 'Another\rTest\nRecord'));
		
        //TESTING
        Test.startTest();
        Try{
			insert records;
		        }
				catch(DmlException e) {
				System.debug('The following exception has occurred: ' + e.getMessage());
			  }
        Test.stopTest();
		
			records = [SELECT TextRequest__c,TextRemove__c FROM WasteAdministrationTaxBreaks__c];          
       
			System.assertEquals('TestRecord' , records[0].TextRequest__c);
			System.assertEquals('AnotherTestRecord', records[0].TextRemove__c);
    }
}