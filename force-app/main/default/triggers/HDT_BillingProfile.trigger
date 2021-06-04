trigger HDT_BillingProfile on BillingProfile__c (before insert) {
    new HDT_TRH_BillingProfile().run();
}