trigger HDT_Activity on wrts_prcgvr__Activity__c (before insert) {

    new HDT_TRH_Activity().run();

}