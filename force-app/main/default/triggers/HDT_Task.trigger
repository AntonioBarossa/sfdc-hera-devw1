trigger HDT_Task on Task (before insert, before update, after insert) {

    new HDT_TRH_Task().run();

}