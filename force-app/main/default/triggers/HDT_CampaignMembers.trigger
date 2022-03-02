trigger HDT_CampaignMembers on CampaignMember (before insert, after insert, before update, after update) {
    new HDT_TRH_CampaignMember().run();
}