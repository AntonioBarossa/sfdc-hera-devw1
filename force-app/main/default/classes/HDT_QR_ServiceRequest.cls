/**
 * @author Sabina Levonja (sabina.levonja@dunegroup.it)
 * @date 19/07/2021
 * @description Class that holds Query for ServiceRequest__c
 */
public inherited sharing class HDT_QR_ServiceRequest {
    
    public static List<ServiceRequest__c> getServiceRequestByOrderCaseIds(Set<Id> ids, String field){

        String query = 'SELECT  Id, Status__c, Order__c, Case__c, Order__r.OrderNumber, Case__r.CaseNumber,Type__c FROM ServiceRequest__c WHERE '+field+' IN :ids WITH SECURITY_ENFORCED';
        List<ServiceRequest__c> srvRequests = Database.query(String.escapeSingleQuotes(query));   
        return srvRequests;
    }

    public static List<ServiceRequest__c> getServiceRequestsSameServicePoint(String servicePointCode, String processType){

        return [SELECT id 
                FROM ServiceRequest__c 
                WHERE type__c = 'Case' 
                AND isClosed__c = false 
                AND Case__c = null 
                AND ServicePointCode__c = :servicePointCode
                AND processtype__c = :processType
                WITH SECURITY_ENFORCED
        ];
    }

    public static List<ServiceRequest__c> getCanceledServiceRequests(String servicePointCode){

        return [SELECT ID 
                FROM ServiceRequest__c 
                WHERE Status__c = 'Annullato' 
                AND ServicePointCode__c =: servicePointCode
                WITH SECURITY_ENFORCED
        ];
    }

    public static List<ServiceRequest__c> getCanceledServiceRequestsBySpId(String servicePointId){
        
        return [SELECT ID 
            FROM ServiceRequest__c 
            WHERE Status__c = 'Annullato' 
            AND ServicePoint__c =: servicePointId
            WITH SECURITY_ENFORCED
        ];
        
    }

    public static List<ServiceRequest__c> getTransitoryServiceRequest(Set<Id> orderIds,Set<Id> orderReferenceIds, Set<Id> quoteIds){

        return quoteIds.isEmpty()?
        [
            SELECT Id, 
                Order__c,
                Order__r.SBQQ__Quote__c,
                Order__r.OrderReference__c,
                Order__r.Process__c,
                Order__r.RecordTypeId,
                Order__r.isBillableVas__c,
                NextPhase__c
            FROM ServiceRequest__c 
            WHERE Order__c IN :orderIds
            AND Order__r.IsTransition__c = true WITH SECURITY_ENFORCED
        ]
        :
        [
            SELECT Id, 
                Order__c,
                Order__r.SBQQ__Quote__c,
                Order__r.OrderReference__c,
                Order__r.Process__c,
                Order__r.RecordTypeId,
                Order__r.isBillableVas__c,
                NextPhase__c
            FROM ServiceRequest__c 
            WHERE (
            Order__c IN :orderIds
            OR Order__r.OrderReference__c IN :orderReferenceIds 
            OR Order__r.SBQQ__Quote__c IN :quoteIds
            ) 
            AND Order__r.IsTransition__c = true WITH SECURITY_ENFORCED
        ];
    
    }
}