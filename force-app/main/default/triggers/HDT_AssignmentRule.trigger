trigger HDT_AssignmentRule on AssignmentRule__c (before update, before insert) {
    new HDT_TRH_AssignmentRule().run();
}