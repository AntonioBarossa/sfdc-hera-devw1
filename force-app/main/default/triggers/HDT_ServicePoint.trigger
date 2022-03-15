trigger HDT_ServicePoint on ServicePoint__c (before insert, before update) {

    new HDT_TRH_ServicePoint().run();
}