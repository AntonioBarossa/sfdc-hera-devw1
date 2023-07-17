 /**
* @author Luca Molino (Luca.Molino@dunegroup.it)
* @date 08/07/21
* @description HDT_QR_DistributorPointCode
* @history Luca Molino – 08/07/21 – created class
* 09/11/22 Fabio Palladino - Adeguamento per non Energy Wave2
*/
public inherited sharing class HDT_QR_DistributorPointCode {

    public List<DistributorPointCode__c> getDistributorPointCode(String code, String commodity, String comune, String presenzaAllaccio){

	    List<DistributorPointCode__c> listDistributorPoint = new List<DistributorPointCode__c>();
		if('Ambiente'.equalsIgnoreCase(commodity) || 'Acqua'.equalsIgnoreCase(commodity) ){
			listDistributorPoint = [SELECT Name, PointCode__c, Commodity__c, Account__r.Name, SkipDimensione__c, OwnerId FROM DistributorPointCode__c WHERE Commodity__c =: commodity AND IsActive__c = true WITH SECURITY_ENFORCED];
		}else if('No'.equalsIgnoreCase(presenzaAllaccio)){
			listDistributorPoint = [SELECT Name, PointCode__c, Commodity__c, Account__r.Name, SkipDimensione__c, OwnerId FROM DistributorPointCode__c WHERE Commodity__c =: commodity AND IsActive__c = true AND City__c =: comune WITH SECURITY_ENFORCED];
		}else {
	    	listDistributorPoint = [SELECT Name, PointCode__c, Commodity__c, Account__r.Name, SkipDimensione__c, OwnerId FROM DistributorPointCode__c WHERE (PointCode__c =: code OR PointCode__c = null) AND Commodity__c =: commodity AND IsActive__c = true AND City__c =: comune WITH SECURITY_ENFORCED];
		}
	    return listDistributorPoint;
    }
}