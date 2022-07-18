trigger HDT_BillingProfile on BillingProfile__c (before insert, before update) {
    new HDT_TRH_BillingProfile().run();
}