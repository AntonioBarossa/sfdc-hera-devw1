trigger HDT_ActivityCustom on wrts_prcgvr__Activity__c (after update) {


    new HDT_TRH_ActivityCustom().run();
}