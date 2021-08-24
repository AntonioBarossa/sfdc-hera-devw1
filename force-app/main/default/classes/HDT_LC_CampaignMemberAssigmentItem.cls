/**
 * @author Fatjola Memishaj (fatjola.memishaj@dunegroup.it)
 * @date 18/03/2021
 * @description HDT_LC_CampaignMemberAssigmentItem Class
 * @history Fatjola Memishaj - 18/03/2021 - Class Creation
 */

public inherited sharing class HDT_LC_CampaignMemberAssigmentItem {
    private static HDT_QR_CampaignMemberAssigmentItem campMembAssignItemQr = new HDT_QR_CampaignMemberAssigmentItem();

    @AuraEnabled(cacheable=true)
    public static List <CampaignMemberAssigmentItem__c> getItemsByMemberAssignment(String Id) {
        List <CampaignMemberAssigmentItem__c> res = campMembAssignItemQr.getItemsByCampaignMemberAssigmentId(Id);
        return res;
    }
}
