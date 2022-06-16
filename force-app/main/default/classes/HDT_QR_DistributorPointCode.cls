 /**
* @author Luca Molino (Luca.Molino@dunegroup.it)
* @date 08/07/21
* @description HDT_QR_DistributorPointCode
* @history Luca Molino – 08/07/21 – created class
*/
public inherited sharing class HDT_QR_DistributorPointCode {

    public List<DistributorPointCode__c> getDistributorPointCode(String code, String commodity, String comune, String presenzaAllaccio){

	    List<DistributorPointCode__c> listDistributorPoint = new List<DistributorPointCode__c>();
		if(presenzaAllaccio == 'No' || commodity.equalsIgnoreCase('Ambiente') || commodity.equalsIgnoreCase('Acqua') ){
	    	listDistributorPoint = [SELECT Name, PointCode__c, Commodity__c, Account__r.Name, SkipDimensione__c, OwnerId FROM DistributorPointCode__c WHERE Commodity__c =: commodity AND IsActive__c = true AND City__c =: comune WITH SECURITY_ENFORCED];
		}
		else{
	    	listDistributorPoint = [SELECT Name, PointCode__c, Commodity__c, Account__r.Name, SkipDimensione__c, OwnerId FROM DistributorPointCode__c WHERE (PointCode__c =: code OR PointCode__c = null) AND Commodity__c =: commodity AND IsActive__c = true AND City__c =: comune WITH SECURITY_ENFORCED];
		}
	    return listDistributorPoint;
    }
}