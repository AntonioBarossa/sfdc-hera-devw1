trigger HDT_SmsTracking on SMSTracking__c (before insert, after update) {
    new HDT_TRH_SmsTracking().run();

}