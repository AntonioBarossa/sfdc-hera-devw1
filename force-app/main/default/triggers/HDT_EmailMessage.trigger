trigger HDT_EmailMessage on EmailMessage (before insert, before update, before delete, 
                              after insert, after update, after delete, after undelete) {

    new HDT_TRH_EmailMessage().run();

}