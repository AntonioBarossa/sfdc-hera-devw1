trigger HDT_CaseChangeEvent on CaseChangeEvent (after insert) {
    HDT_TRH_CaseChangeEvent.afterInsert(Trigger.New);
}