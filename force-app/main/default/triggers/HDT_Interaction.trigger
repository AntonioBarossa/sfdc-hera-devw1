trigger HDT_Interaction on Interaction__c (before update) {
    new HDT_TRH_Interaction().run();
}