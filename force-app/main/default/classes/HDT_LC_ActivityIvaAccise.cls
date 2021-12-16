public with sharing class HDT_LC_ActivityIvaAccise {
    
    private static HDT_SRV_ActivityCustom activitySRV = new HDT_SRV_ActivityCustom();

    @AuraEnabled
    public static wrts_prcgvr__Activity__c getInitActivity(String recordId){
        return HDT_QR_ActivityCustom.getRecordByIdAccise(recordId);
    }

    @AuraEnabled
    public static void saveActivity(wrts_prcgvr__Activity__c act,boolean closeActivity){
        system.debug('********::' + act);
        if(closeActivity){
            act.wrts_prcgvr__Status__c = 'Chiusa';
            act.ageing__c =  ((system.today()).daysBetween(Date.valueOf(act.CreatedDate)))*-1;
            act.CompletationDateDocument__c = system.today();
        }
        update act;
    }
    @AuraEnabled
    public static boolean sospendiActivity(String actid){
        try{
            wrts_prcgvr__Activity__c w = new wrts_prcgvr__Activity__c();
            w.id = actid;
            w.wrts_prcgvr__Status__c = 'Sospeso';
            activitySRV.updateRecord(w); 
            return true;    
        }catch(Exception e){
            return false;
        }
    
    }
    @AuraEnabled
    public static boolean riprendiActivity(String actid){
        try{
            wrts_prcgvr__Activity__c w = new wrts_prcgvr__Activity__c();
            w.id = actid;
            w.wrts_prcgvr__Status__c = 'Aperta';
            activitySRV.updateRecord(w);
            return true;
        }catch(Exception e){
            return false;
        }
    }
    @AuraEnabled
    public static boolean saveAttempt(String actid, String attempt){
        try{
            system.debug('********PRE:' + attempt);
            system.debug('********PRE:' + actid);
            wrts_prcgvr__Activity__c w = new wrts_prcgvr__Activity__c();
            w.id = actid;
            if(attempt != null){
                w.NumberOfAttempt__c = Integer.valueOf(attempt);
                activitySRV.updateRecord(w);
            }
            return true;
        }catch(Exception e){
            return false;
        }
    }
}
