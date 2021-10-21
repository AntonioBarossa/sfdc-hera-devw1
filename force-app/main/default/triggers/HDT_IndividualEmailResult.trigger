trigger HDT_IndividualEmailResult on et4ae5__IndividualEmailResult__c (before insert, before update, after update) {

    new HDT_TRH_IndividualEmailResult().run();

}