public inherited sharing class HDT_QR_DistributorPointCode {
    private static HDT_SRV_Account accountSrv = new HDT_SRV_Account();

   
    /*public List<DistributorPointCode__c> getDistributorPointCode(String code,String g) 
    {
        accountSrv.checkReadAccess('PointCode__c,Commodity__c,Account__c,OwnerId');
	    List<DistributorPointCode__c> listDistributorPoint = new List<DistributorPointCode__c>();
	    String query ='SELECT PointCode__c,Commodity__c,Account__c,OwnerId FROM DistributorPointCode__c WHERE PointCode__c =: code';
	    listDistributorPoint = Database.query(query);
	    return listDistributorPoint;
    }*/

    public List<DistributorPointCode__c> getDistributorPointCode(String code,String commodity){

        accountSrv.checkReadAccess('PointCode__c,Commodity__c,Account__c,OwnerId');
	    List<DistributorPointCode__c> listDistributorPoint = new List<DistributorPointCode__c>();
	    String query ='SELECT Name,PointCode__c,Commodity__c,Account__r.Name,OwnerId FROM DistributorPointCode__c WHERE PointCode__c =: code AND Commodity__c=:commodity';
	    listDistributorPoint = Database.query(query);
	    return listDistributorPoint;
    }

}
