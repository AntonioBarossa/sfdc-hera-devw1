trigger HDT_Sale on Sale__c (before insert) {

    new HDT_TRH_Sale().run();

}