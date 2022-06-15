trigger HDT_Queue on Queue__c (before insert, after insert) {
    new HDT_TRH_Queue().run();
}