trigger HDT_AnagAlignmentEvent on HDT_PEV_AnagAlignment__e (after insert) {
    new HDT_TRH_AnagAlignmentEvent().run();
}