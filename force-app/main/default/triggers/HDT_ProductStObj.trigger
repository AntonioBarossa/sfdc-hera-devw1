trigger HDT_ProductStObj on Product2 (before insert, before update) {
    new HDT_TRH_ProductStObj().run();
}