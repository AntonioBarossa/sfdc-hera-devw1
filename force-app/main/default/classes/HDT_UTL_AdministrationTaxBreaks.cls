public class HDT_UTL_AdministrationTaxBreaks{

	public static List<WasteAdministrationTaxBreaks__c> getTexTaxBreaks(String city,String productCode){
		List <WasteAdministrationTaxBreaks__c> records=new list <WasteAdministrationTaxBreaks__c>();
		
		records = HDT_QR_GenericQuery.getGenericRecords('Id, TextRemove__c, TextRequest__c','WasteAdministrationTaxBreaks__c', 'city__c = ' + city + ' and  productCode__c = ' + productCode);
		
		return records;
	}
}