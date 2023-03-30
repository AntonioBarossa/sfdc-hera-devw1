trigger HDT_Subscription on SBQQ__Subscription__c (before insert) {

    new HDT_TRH_Subscription().run();

}