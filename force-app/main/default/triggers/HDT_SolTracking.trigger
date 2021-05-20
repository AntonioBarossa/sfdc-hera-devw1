trigger HDT_SolTracking on SolTracking__c (before insert) {

    new HDT_TRH_SolTracking().run();

}