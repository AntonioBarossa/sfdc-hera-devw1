trigger HDT_DocumentSendTracking on DocumentSendTracking__c (before insert) {

    new HDT_TRH_DocumentSendTracking().run();

}