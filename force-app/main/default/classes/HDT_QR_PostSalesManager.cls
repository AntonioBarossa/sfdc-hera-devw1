public inherited sharing class HDT_QR_PostSalesManager {

    public Integer checkLocalDispatcher(String dispatcherName){

        return [SELECT COUNT() 
        FROM HDT_LocalDispatcherInrete__mdt 
        WHERE DispatcherDesc__c = :dispatcherName
        WITH SECURITY_ENFORCED]; 

    }

}
