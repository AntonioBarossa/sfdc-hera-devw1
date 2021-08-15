public inherited sharing class HDT_QR_Activity {

    private static HDT_SRV_Account accountSrv = new HDT_SRV_Account();

    public HDT_QR_Activity() {

    }
    public wrts_prcgvr__Activity__c getLastActivity(){
        accountSrv.checkReadAccess('Id, OwnerId, Name, RecordTypeId, CreatedDate, Type__c,Account__c,Approved__c');
        return [SELECT Id, OwnerId, Name, RecordTypeId, CreatedDate, Type__c,Account__c,Approved__c  FROM wrts_prcgvr__Activity__c WHERE Type__c='Approvazione Offerte' ORDER BY CreatedDate desc LIMIT 1 ];
    }
    
}
