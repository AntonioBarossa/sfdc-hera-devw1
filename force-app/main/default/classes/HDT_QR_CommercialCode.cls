/**
* @author Fatjola Memishaj (fatjola.memishaj@dunegroup.it)
* @date 05/07/2021
* @description HDT_QR_CommercialCode – Contains query for CommercialCode__c
* @history Fatjola Memishaj – 05/07/2021 – Created class
*/ 

public with sharing class HDT_QR_CommercialCode {
    

    public CommercialCode__c getRecordById(String Id) {
        return [
            SELECT 
            Id,
            Name,
            AvailabilityUsesEE__c,
            AvailabilityUsesGAS__c,
            AvailabilityUsesVAS__c,
            ActualUsesEE__c,
            ActualUsesGAS__c,
            ActualUsesVAS__c
            FROM CommercialCode__c
            where Id = :Id
            WITH SECURITY_ENFORCED
        ];
    }
    public List<AggregateResult> getCommercialCodeNumber(Set<Id> listIdCampaign){
        return [SELECT count(Id) conteggio,Campaign__c FROM CommercialCode__c WHERE Campaign__c IN: listIdCampaign WITH SECURITY_ENFORCED GROUP BY Campaign__c ];
    }
}