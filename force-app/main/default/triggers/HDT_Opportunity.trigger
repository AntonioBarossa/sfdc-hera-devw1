trigger HDT_Opportunity on Opportunity (before insert) {

    new HDT_TRH_Opportunity().run();

}