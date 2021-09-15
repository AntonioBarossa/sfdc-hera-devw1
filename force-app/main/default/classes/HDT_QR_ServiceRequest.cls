/**
 * @author Sabina Levonja (sabina.levonja@dunegroup.it)
 * @date 19/07/2021
 * @description Class that holds Query for ServiceRequest__c
 */
public inherited sharing class HDT_QR_ServiceRequest {
    
    public static List<ServiceRequest__c> getServiceRequestByOrderCaseIds(Set<Id> ids, String field){

        String query = 'SELECT  Id, Status__c, Order__c, Case__c FROM ServiceRequest__c WHERE '+field+' IN :ids WITH SECURITY_ENFORCED';
        List<ServiceRequest__c> srvRequests = Database.query(query);   
        return srvRequests;
    }
}
