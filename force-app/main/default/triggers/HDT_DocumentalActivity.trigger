trigger HDT_DocumentalActivity on DocumentalActivity__c (before insert) {

    new HDT_TRH_DocumentalActivity().run();

}