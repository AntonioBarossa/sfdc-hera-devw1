trigger HDT_Campaign on Campaign (after insert, before update) {
    
    new HDT_TRH_Campaign().run();
}