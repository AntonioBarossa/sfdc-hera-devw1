trigger HDT_CustomActivityChangeEvent on wrts_prcgvr__Activity__ChangeEvent (after insert) {
    HDT_TRH_CustomActivityChangeEvent.afterInsert(Trigger.New);
}