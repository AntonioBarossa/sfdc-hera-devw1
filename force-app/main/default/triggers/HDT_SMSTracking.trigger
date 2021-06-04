trigger HDT_SMSTracking on SMSTracking__c (before insert) {

    new HDT_TRH_SmsTracking().run();

}