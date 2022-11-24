public with sharing class HDT_BA_AppoitmentManagmentActivity implements Database.Batchable<SObject> {

    public Date dt= Date.today();
    public List<wrts_prcgvr__Activity__c> activitiesToInsert = new List<wrts_prcgvr__Activity__c>();
    HDT_QR_RecordType qrRecordType = new HDT_QR_RecordType();
    //
    public Database.QueryLocator start(Database.BatchableContext bc) {
        Id recType= qrRecordType.getRecordTypeIdByName('HDT_RT_DistributorAppointment');
        Date dtEmail= dt.addDays(3);
        Date dtSms= dt.addDays(1);
        System.debug('RecordType id: '+recType);
        System.debug('dtEmail value: '+dtEmail);
        System.debug('dtSms value: '+dtSms);
        String query = 'SELECT Id, AppointmentDate__c,DateTimeRef__c, Email__c, Mobile__c,Account__c FROM wrts_prcgvr__Activity__c Where wrts_prcgvr__Status__c IN (\'Appuntamento confermato\',\'Modifica confermata\') AND (RecordTypeId= :recType) AND (Type__c= \'Presa Appuntamento\') AND ( (Mobile__c!= NULL AND AppointmentDate__c<= :dtSms AND AppointmentDate__c >= :dt) OR (Email__c !=NULL AND AppointmentDate__c<= : dtEmail AND AppointmentDate__c >= :dt))';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<wrts_prcgvr__Activity__c> scope){
        Set<String> actvIds= new Set<String>();
        List<String> actvId = new List<String>();
        Id recType= qrRecordType.getRecordTypeIdByName('HDT_RT_Scarto');
        List<wrts_prcgvr__Activity__c> activitiesToInsert = new List<wrts_prcgvr__Activity__c>();
        for(wrts_prcgvr__Activity__c ac: scope){
            actvIds.add(ac.Id);
        }
        actvId.addAll(actvIds);
        List<SMSTracking__c> sms = [Select Id, DateTimeRef__c, Undelivered__c, Activity__c From SMSTracking__c Where Activity__c IN :actvIds ];

        Map<Id,SMSTracking__c> smsTracking= new Map<Id,SMSTracking__c>();
        for(SMSTracking__c s: sms){
            smsTracking.put(s.Activity__c,s);
        }

        List<et4ae5__IndividualEmailResult__c> ier = [Select Id, DateTimeRef__c, et4ae5__Opened__c , Activity__c From et4ae5__IndividualEmailResult__c Where Activity__c IN :actvIds ];
        
        Map<Id,et4ae5__IndividualEmailResult__c> emailResults= new Map<Id,et4ae5__IndividualEmailResult__c>();
        for(et4ae5__IndividualEmailResult__c e: ier){
            emailResults.put(e.Activity__c,e);
        }

        List<wrts_prcgvr__Activity__c> actReject= HDT_QR_ActivityCustom.getRecordByParentIds(actvIds, recType);
        Map<Id,wrts_prcgvr__Activity__c> rejectedActivities= new Map<Id,wrts_prcgvr__Activity__c>();
        for(wrts_prcgvr__Activity__c a: actReject){
            rejectedActivities.put(a.ParentActivity__c,a);
        }
        for(wrts_prcgvr__Activity__c ac: scope){
            if(!smsTracking.containsKey(ac.Id) && !emailResults.containsKey(ac.Id) && !rejectedActivities.containsKey(ac.Id)){
                wrts_prcgvr__Activity__c at = new wrts_prcgvr__Activity__c();
                at.Account__c = ac.Account__c; 
                at.ParentActivity__c = ac.Id;
                at.RecordTypeId = recType;
                at.DateTimeRef__c= ac.DateTimeRef__c;
                at.Type__c = 'Scarto Comunicazione';
                at.DiscardCategory__c = 'Manuale';
                activitiesToInsert.add(at);
            }else{
                if(smsTracking.containsKey(ac.Id)){
                    if(smsTracking.get(ac.Id).Undelivered__c == TRUE && smsTracking.get(ac.Id).DateTimeRef__c == ac.DateTimeRef__c ){
                        wrts_prcgvr__Activity__c at = new wrts_prcgvr__Activity__c();
                        at.Account__c = ac.Account__c; 
                        at.ParentActivity__c = ac.Id;
                        at.RecordTypeId = recType;
                        at.DateTimeRef__c= ac.DateTimeRef__c;
                        at.Type__c = 'Scarto Comunicazione';
                        at.DiscardCategory__c = 'Manuale';
                        activitiesToInsert.add(at);
                    }
                }else if(emailResults.containsKey(ac.Id)){
                    if(emailResults.get(ac.Id).et4ae5__Opened__c = FALSE && emailResults.get(ac.Id).DateTimeRef__c == ac.DateTimeRef__c ){
                        wrts_prcgvr__Activity__c at = new wrts_prcgvr__Activity__c();
                        at.Account__c = ac.Account__c; 
                        at.ParentActivity__c = ac.Id;
                        at.RecordTypeId = recType;
                        at.DateTimeRef__c= ac.DateTimeRef__c;
                        at.Type__c = 'Scarto Comunicazione';
                        at.DiscardCategory__c = 'Manuale';
                        activitiesToInsert.add(at);
                    }
                }
            }
        }
        Database.insert(activitiesToInsert, true);
    }


    public void finish(Database.BatchableContext bc){
        //insert activitiesToInsert;
    }
}