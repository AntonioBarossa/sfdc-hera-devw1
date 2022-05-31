trigger HDT_CustomActivityChangeEvent on wrts_prcgvr__Activity__ChangeEvent (after insert) {
    HDT_THR_CustomActivityChangeEvent.afterInsert(Trigger.New);
}