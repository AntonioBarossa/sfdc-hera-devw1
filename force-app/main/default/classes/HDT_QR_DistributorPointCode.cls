 /**
* @author Luca Molino (Luca.Molino@dunegroup.it)
* @date 08/07/21
* @description HDT_QR_DistributorPointCode
* @history Luca Molino – 08/07/21 – created class
*/
public inherited sharing class HDT_QR_DistributorPointCode {
    private static HDT_SRV_Account accountSrv = new HDT_SRV_Account();

    public List<DistributorPointCode__c> getDistributorPointCode(String code, String commodity, String comune){

	    List<DistributorPointCode__c> listDistributorPoint = new List<DistributorPointCode__c>();

        accountSrv.checkReadAccess('PointCode__c,Commodity__c,Account__c,OwnerId');
	    listDistributorPoint = [SELECT Name, PointCode__c, Commodity__c, Account__r.Name, OwnerId FROM DistributorPointCode__c WHERE (PointCode__c =: code OR PointCode__c = null) AND Commodity__c =: commodity AND IsActive__c = true AND Comune__c =: comune WITH SECURITY_ENFORCED];
	    return listDistributorPoint;
    }
}