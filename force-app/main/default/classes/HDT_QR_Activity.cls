/**
* @author Luca Molino (Luca.Molino@dunegroup.it)
* @date 15/08/21
* @description HDT_QR_Activity
* @history Luca Molino – 15/08/21 – created class
*/
public inherited sharing class HDT_QR_Activity {

    private static HDT_SRV_ActivityCustom activitySrv = new HDT_SRV_ActivityCustom();
    String fields= 'Id, OwnerId, Name, RecordTypeId, CreatedDate, Type__c,Account__c,Approved__c';
    
    public HDT_QR_Activity() {

    }


    public wrts_prcgvr__Activity__c getLastActivity(String idAcc,SObject o){
        activitySrv.checkReadAccess(fields);

        String saleId =  (String)o.get('Id');

        String type = 'Approvazione Offerte';
        String status ='Creata';
        String query = 'SELECT '+ fields +
                ' FROM wrts_prcgvr__Activity__c WHERE Type__c=: type AND Account__c =: idAcc AND Status__c=:status AND Sale__c=: saleId WITH SECURITY_ENFORCED';

        List<wrts_prcgvr__Activity__c> activityList = Database.query(query);
        
        wrts_prcgvr__Activity__c activity = new wrts_prcgvr__Activity__c();

        if (!activityList.isEmpty()) {
            activity = activityList[0];
        }
        
        return activity;
    }

}
