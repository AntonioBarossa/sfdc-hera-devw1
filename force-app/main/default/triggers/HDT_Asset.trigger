trigger HDT_Asset on Asset (before insert) {
    new HDT_TRH_Asset().run();
}