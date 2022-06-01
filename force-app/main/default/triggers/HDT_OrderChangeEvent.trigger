trigger HDT_OrderChangeEvent on OrderChangeEvent (after insert) {
    HDT_THR_OrderChangeEvent.afterInsert(Trigger.New);
}