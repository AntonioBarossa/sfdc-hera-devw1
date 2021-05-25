trigger HDT_Account on Account (before update) {

    new HDT_TRH_Account().run();

}