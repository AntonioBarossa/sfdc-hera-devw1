trigger HDT_Individual on Individual (before insert) {
    new HDT_TRH_Individual().run();
}