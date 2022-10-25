/**
* @author Sabina Levonja (sabina.levonja@dunegroup.it)
* @date 16/06/21
* @description HDT_LC_RecordEditFormSales
* @history Sabina Levonja – 16/06/21 – created class
*/
public with sharing class HDT_LC_RecordEditFormSales {

    public static HDT_SRV_Case caseSRV= new HDT_SRV_Case();
    public static HDT_SRV_ActivityCustom activitySrv= new HDT_SRV_ActivityCustom();
    public static HDT_QR_RecordType rctype= new HDT_QR_RecordType();
    public static HDT_QR_Case caseQr = new HDT_QR_Case();
  //  public static HDT_QR_Recordtype rctype = new HDT_QR_Recordtype();
    @AuraEnabled
    public static void cancelCase(String caseId){
        try {
            Case cs= new Case(Id= caseId, Phase__c='Annullato', Status='Closed');
            caseSRV.updateRecord(cs);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static wrapReturn getActivity(String caseId){
        List<Case> caseList = caseQr.getRecordsById(new List<String>{caseId},'id,AccountId,Channel__c,CopyType__c,sendmode__c,order__c,OperationSubType__c,OperationType__c,Contract__c');
        List<wrts_prcgvr__Activity__c> listActiv = HDT_QR_ActivityCustom.getRecordByCaseId(caseId);
        Case res = new Case();
        wrapReturn wrp = new wrapReturn();
        wrp.c = res;

        //List<wrts_prcgvr__Activity__c> obbList = HDT_QR_ActivityCustom.getRecordByCaseId(caseid);
      //  wrts_prcgvr__Activity__c res;
        if(caseList != null && !caseList.isEmpty()){
            res = caseList[0];
        } 
        if(listActiv != null && !listActiv.isEmpty() && listActiv[0].approved__c != null){
            wrp.disabled = true;
        }
        wrp.c = res;
        return wrp;
    }

    
    @AuraEnabled
    public static Boolean confirmForApproval(String caseId, String accountId){
        try {
           // Case cs= new Case(Id=caseId);
           // caseSRV.updateRecord(cs); 
            List<wrts_prcgvr__Activity__c> activities= HDT_QR_ActivityCustom.getRecordByCaseId(caseId);
            if(activities != null && activities.isEmpty()){
                Id recTypeId= null;
                RecordType rc= rctype.getRecordType('HDT_RT_AttivitaGestionali', 'wrts_prcgvr__Activity__c');
                if(rc !=null){
                    recTypeId= rc.Id;
                }
                wrts_prcgvr__Activity__c activity= new wrts_prcgvr__Activity__c(Case__c= caseId, Account__c= accountId, RecordTypeId= recTypeId, Type__c= 'Contratti/Bonus Commerciale');
                System.debug('LOG_ACTIVITY_MISSING2:');
                System.debug(activity);
                //activitySrv.createRecord(activity);
                System.debug('LOG_ACTIVITY_MISSING2:');
                return false;
            }else{
                return true;
            }
        } catch (Exception e) {
            System.debug('LOG_ACTIVITY_MISSING:' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String savePractice(String caseId, String accountId, Map<String,Object> caseob){
        try {
            Case cs= new Case(Id=caseId,status='Closed', Phase__c='Completata');
            String note = '';
            if(caseob.containsKey('OperationSubType__c')){
                cs.put('OperationSubType__c',String.valueOf(caseob.get('OperationSubType__c')));
            }
            if(caseob.containsKey('Contract__c')){
                cs.put('Contract__c',String.valueOf(caseob.get('Contract__c')));
            }
           /* if(caseob.containsKey('ReassignmentReason__c')){
                cs.put('ReassignmentReason__c',String.valueOf(caseob.get('ReassignmentReason__c')));
            }*/
            if(caseob.containsKey('OperationType__c')){
                cs.put('OperationType__c',String.valueOf(caseob.get('OperationType__c')));
            }
            if(caseob.containsKey('Note__c')){
                cs.put('Note__c',String.valueOf(caseob.get('Note__c')));
                note = String.valueOf(caseob.get('Note__c'));
            }
           // caseSRV.updateRecord(cs); 
            List<wrts_prcgvr__Activity__c> activities= HDT_QR_ActivityCustom.getRecordByCaseId(caseId);
            if(activities != null && !activities.isEmpty() && activities[0].wrts_prcgvr__status__c == 'Chiusa' && activities[0].approved__c == 'Si'){
                caseSRV.updateRecord(cs); 
                Id recTypeId= null;
                RecordType rc= rctype.getRecordType('HDT_RT_AttivitaGestionali', 'wrts_prcgvr__Activity__c');
                if(rc !=null){
                    recTypeId= rc.Id;
                }
                wrts_prcgvr__Activity__c activity= new wrts_prcgvr__Activity__c(Case__c= caseId, Account__c= accountId, RecordTypeId= recTypeId, Type__c= 'Contratti/Bonus Commerciale');
                System.debug(activity);
                activitySrv.createRecord(activity);
                return 'success';
            }
            else if(activities != null && !activities.isEmpty() && activities[0].wrts_prcgvr__status__c == 'Chiusa' && activities[0].approved__c == 'No'){
                return 'annulla';
            }
            else if(activities != null && !activities.isEmpty() && activities[0].wrts_prcgvr__status__c != 'Chiusa'){
                return 'aperta';
            }
            else if(activities != null && activities.isEmpty()){
                cs.status = 'In Lavorazione';
                cs.Phase__c = 'In Lavorazione';
                caseSRV.updateRecord(cs);
                Id recTypeId= null;
                RecordType rc= rctype.getRecordType('HDT_RT_AttivitaGestionali', 'wrts_prcgvr__Activity__c');
                if(rc !=null){
                    recTypeId= rc.Id;
                }
                wrts_prcgvr__Activity__c activity= new wrts_prcgvr__Activity__c(Case__c= caseId, Account__c= accountId, RecordTypeId= recTypeId, Type__c= 'Approvazione Bonus Commerciale');
                activity.OpeningNote__c = note;
                activitySrv.createRecord(activity);
                return 'success2';
            }
            else{
                return 'errore';
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
           // return 'errore';
        }
    }
    @AuraEnabled
    public static void saveDraft(String caseId, String accountId, Map<String,Object> caseob){
        try {
            Case cs= new Case(Id=caseId);

            if(caseob.containsKey('OperationSubType__c')){
                cs.put('OperationSubType__c',String.valueOf(caseob.get('OperationSubType__c')));
            }
            if(caseob.containsKey('Contract__c')){
                cs.put('Contract__c',String.valueOf(caseob.get('Contract__c')));
            }
            if(caseob.containsKey('ReassignmentReason__c')){
                cs.put('ReassignmentReason__c',String.valueOf(caseob.get('ReassignmentReason__c')));
            }
            if(caseob.containsKey('OperationType__c')){
                cs.put('OperationType__c',String.valueOf(caseob.get('OperationType__c')));
            }
            if(caseob.containsKey('Note__c')){
                cs.put('Note__c',String.valueOf(caseob.get('Note__c')));
            }
            caseSRV.updateRecord(cs); 
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
   
    public class wrapReturn{
        @AuraEnabled public Case c {get;set;}
        @AuraEnabled public boolean disabled = false;
    }
}
