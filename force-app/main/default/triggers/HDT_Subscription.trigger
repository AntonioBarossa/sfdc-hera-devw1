trigger HDT_Subscription on SBQQ__Subscription__c (before insert,after insert) {

    new HDT_TRH_Subscription().run();

}