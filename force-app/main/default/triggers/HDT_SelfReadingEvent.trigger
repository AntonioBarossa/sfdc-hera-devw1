trigger HDT_SelfReadingEvent on HDT_PEV_SelfReading__e (after insert) {
    new HDT_TRH_SelfReadingEvent().run();
}