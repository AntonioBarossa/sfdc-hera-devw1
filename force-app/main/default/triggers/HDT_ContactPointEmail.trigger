trigger HDT_ContactPointEmail on ContactPointEmail (before insert,before update,after insert,after update) {
    new HDT_TRH_ContactPointEmail().run();
}