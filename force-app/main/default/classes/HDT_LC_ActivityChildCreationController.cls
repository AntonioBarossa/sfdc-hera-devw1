public with sharing class HDT_LC_ActivityChildCreationController {

    public static HDT_QR_RecordType rcTypeQR= new HDT_QR_RecordType();
    public static HDT_SRV_ActivityCustom activitySrv= new HDT_SRV_ActivityCustom();
    
    @AuraEnabled
    public static Id createActivityChild(String activityId, String tipology){
        try {
            List<wrts_prcgvr__Activity__c> activity= HDT_QR_ActivityCustom.getRecordById(activityId);
            System.debug(activity);
            if(activity != null && !activity.isEmpty()){
                Id recordTypeId= rcTypeQR.getRecordTypeIdByName('HDT_RT_DistributorCommunication');
                System.debug(recordTypeId);
                wrts_prcgvr__Activity__c at= new wrts_prcgvr__Activity__c(Type__c= tipology, ParentActivity__c= activityId, RecordTypeId= recordTypeId, Account__c= activity[0].Account__c, Contact__c= activity[0].Contact__c, Distributor__c= activity[0].Distributor__c, AppointmentDate__c= activity[0].AppointmentDate__c, wrts_prcgvr__Status__c='Creata' );
                System.debug(at);
                wrts_prcgvr__Activity__c atv= activitySrv.createRecord(at);
                System.debug(atv);

                return atv.Id;
            }else{
                return null;
            }

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
