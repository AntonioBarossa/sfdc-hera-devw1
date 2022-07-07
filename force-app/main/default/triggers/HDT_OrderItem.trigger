trigger HDT_OrderItem on OrderItem (before insert) {
    new HDT_TRH_OrderItem().run();
}