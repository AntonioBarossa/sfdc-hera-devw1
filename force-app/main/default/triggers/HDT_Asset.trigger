trigger HDT_Asset on Asset (before insert, before update) {
    new HDT_TRH_Asset().run();
}