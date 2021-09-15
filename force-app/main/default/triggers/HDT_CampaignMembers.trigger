trigger HDT_CampaignMembers on CampaignMember (before insert, after insert) {
    new HDT_TRH_CampaignMember().run();
}