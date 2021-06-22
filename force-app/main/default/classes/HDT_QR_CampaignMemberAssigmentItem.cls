/**
* @author Fatjola Memishaj (fatjola.memishaj@dunegroup.it)
* @date 12/03/2021
* @description HDT_QR_CampaignMemberAssigmentItem – Contains queries for CampaignMemberAssigmentItem__c
* @history Fatjola Memishaj – 12/03/2021 – Created class
*/

public inherited sharing class HDT_QR_CampaignMemberAssigmentItem {
    
    public CampaignMemberAssigmentItem__c getRecordById(String Id) {
        return [
            SELECT 
            Id,
            Name,
            Agency__c,
            CampaingMemberAssigment__c,
            PercentageAllocation__c,
            ProcessingType__c
            FROM CampaignMemberAssigmentItem__c
            where Id = :Id
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
    }

    public List<CampaignMemberAssigmentItem__c> getItemsByCampaignMemberAssigmentId(String Id) {
        return [
            SELECT 
            Id,
            Name,
            Agency__c,
            CampaingMemberAssigment__c,
            PercentageAllocation__c,
            ProcessingType__c
            FROM CampaignMemberAssigmentItem__c
            where CampaingMemberAssigment__c = :Id
            WITH SECURITY_ENFORCED
        ];
    } 
}
