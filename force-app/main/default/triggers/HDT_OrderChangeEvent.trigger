trigger HDT_OrderChangeEvent on OrderChangeEvent (after insert) {
    HDT_TRH_OrderChangeEvent.afterInsert(Trigger.New);
}