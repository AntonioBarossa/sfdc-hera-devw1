trigger HDT_PushTracking on PushTracking__c (before insert) {

    new HDT_TRH_PushTracking().run();

}