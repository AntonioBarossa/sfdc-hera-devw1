trigger HDT_ActivityCustom on wrts_prcgvr__Activity__c (before insert, before update, before delete, 
after insert, after update, after delete, after undelete) {


    new HDT_TRH_ActivityCustom().run();
}