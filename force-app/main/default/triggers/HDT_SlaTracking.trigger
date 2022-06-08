trigger HDT_SlaTracking on SlaTracking__c (before update) {
    new HDT_TRH_SlaTracking().run();
}