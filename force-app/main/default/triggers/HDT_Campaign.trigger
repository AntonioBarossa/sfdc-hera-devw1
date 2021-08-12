trigger HDT_Campaign on Campaign (before insert, after insert, before update) {
    
    new HDT_TRH_Campaign().run();
}