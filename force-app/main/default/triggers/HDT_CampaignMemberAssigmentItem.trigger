trigger HDT_CampaignMemberAssigmentItem on CampaignMemberAssigmentItem__c (before insert, before update) {
    new HDT_TRH_CampaignMemberAssigmentItem().run();
}