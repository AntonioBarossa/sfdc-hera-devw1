public class HDT_UTL_AdministrationTaxBreaks{

	public static List<WasteAdministrationTaxBreaks__c> getTexTaxBreaks(String city,String productCode){
		if(String.isBlank(city) || String.isBlank(productCode))return new List<WasteAdministrationTaxBreaks__c>();
		return[SELECT Id, TextRemove__c, TextRequest__c FROM WasteAdministrationTaxBreaks__c WHERE City__c =:city AND  ProductCode__c =: productCode WITH SECURITY_ENFORCED];
	}
}