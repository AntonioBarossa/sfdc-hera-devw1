trigger HDT_PaperProcessing on PaperProcessing__c (before insert, before update) {
    new HDT_TRH_PaperProcessing().run();
}