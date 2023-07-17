trigger HDT_Interaction on Interaction__c (before update, before insert) {
    new HDT_TRH_Interaction().run();
}