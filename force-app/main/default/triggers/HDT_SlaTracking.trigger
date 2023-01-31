trigger HDT_SlaTracking on SlaTracking__c (before update, before insert) {
    new HDT_TRH_SlaTracking().run();
}