trigger HDT_AlertAccountConfiguration on AlertAccountConfiguration__c (after insert, after update) {

    new HDT_TRH_AlertAccountConfiguration().run();

}