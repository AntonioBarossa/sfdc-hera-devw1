trigger HDT_Quote on SBQQ__Quote__c (before insert, after insert, before update, after update, before delete, after delete) {
    new HDT_TRH_Quote().run();
}