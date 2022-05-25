trigger HDT_CaseChangeEvent on CaseChangeEvent (after insert) {
    HDT_THR_CaseChangeEvent.afterInsert(Trigger.New);
}