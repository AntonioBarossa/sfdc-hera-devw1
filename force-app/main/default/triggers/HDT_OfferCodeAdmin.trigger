trigger HDT_OfferCodeAdmin on OfferCode32Admin__c (before update, before insert, after update) {
    new HDT_TRH_OfferCodeAdmin().run();
}