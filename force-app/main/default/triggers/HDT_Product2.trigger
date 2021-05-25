trigger HDT_Product2 on Product2 (before insert, before update) {
    if(Test.isRunningTest()){
        new HDT_TRH_Product2().run();
    }
}