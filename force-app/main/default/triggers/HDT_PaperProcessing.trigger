trigger HDT_PaperProcessing on PaperProcessing__c (before insert, before update,after update,after insert) {
    new HDT_TRH_PaperProcessing().run();
}