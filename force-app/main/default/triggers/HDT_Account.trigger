trigger HDT_Account on Account (before update, before insert) {

    new HDT_TRH_Account().run();

}
