trigger HDT_SmsTracking on SMSTracking__c (before insert) {
    new HDT_TRH_SmsTracking().run();

}