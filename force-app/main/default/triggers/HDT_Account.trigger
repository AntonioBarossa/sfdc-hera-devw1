trigger HDT_Account on Account (before update, before insert, after update) {

    new HDT_TRH_Account().run();

}
