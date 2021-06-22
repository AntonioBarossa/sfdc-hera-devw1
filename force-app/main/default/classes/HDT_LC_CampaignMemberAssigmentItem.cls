public inherited sharing class HDT_LC_CampaignMemberAssigmentItem {
    private static HDT_QR_CampaignMemberAssigmentItem campMembAssignItemQr = new HDT_QR_CampaignMemberAssigmentItem();

    @AuraEnabled(cacheable=true)
    public static List <CampaignMemberAssigmentItem__c> getItemsByMemberAssignment(String Id) {
        List <CampaignMemberAssigmentItem__c> res = campMembAssignItemQr.getItemsByCampaignMemberAssigmentId(Id);
        return res;
    }

}
