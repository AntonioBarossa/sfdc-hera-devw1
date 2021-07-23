trigger HDT_User on User (after insert) {

    new HDT_TRH_User().run();

}