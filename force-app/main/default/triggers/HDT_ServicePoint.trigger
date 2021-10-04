trigger HDT_ServicePoint on ServicePoint__c (before update) {

    new HDT_TRH_ServicePoint().run();
}