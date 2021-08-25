public inherited sharing class HDT_QR_Activity {

    private static HDT_SRV_ActivityCustom activitySrv = new HDT_SRV_ActivityCustom();
    String fields= 'Id, OwnerId, Name, RecordTypeId, CreatedDate, Type__c,Account__c,Approved__c';
    
    public HDT_QR_Activity() {

    }


    public wrts_prcgvr__Activity__c getLastActivity(String idAcc,Object o){
        activitySrv.checkReadAccess(fields);
        String type = 'Approvazione Offerte';
        String status ='Creata';
        String query = 'SELECT '+ fields +
                ' FROM wrts_prcgvr__Activity__c WHERE Type__c=: type AND Account__c =: idAcc AND Status__c=:status AND Sale__c=: o.id WITH SECURITY_ENFORCED';

        List<wrts_prcgvr__Activity__c> activityList = Database.query(query);
        
        wrts_prcgvr__Activity__c activity = new wrts_prcgvr__Activity__c();

        if (!activityList.isEmpty()) {
            activity = activityList[0];
        }
        
        return activity;
    }

}
