/**
* @author Lorenzo (lorenzo.gulotta@webresults.it)
* @date 25/05/2021
* @description HDT_TRH_ActivityCustom
* @history Lorenzo – 25/05/2021 – created class
*/
public inherited sharing class  HDT_TRH_ActivityCustom extends HDT_TRH_TriggerHandler {
	private  Id recordTypeD2DId = Schema.SObjectType.wrts_prcgvr__Activity__c.getRecordTypeInfosByDeveloperName().get('HDT_RT_VisitaD2D').getRecordTypeId();

    public override void beforeInsert(){
        HDT_UTL_ActivityCustom.setConvertCloseStatus((List<wrts_prcgvr__Activity__c>) trigger.new);
        //Start>>> modifica marco.arci@webresults.it 11/10/21
        wrts_prcgvr.Interfaces_1_1.IActivityIntegration activityIntegration =(wrts_prcgvr.Interfaces_1_1.IActivityIntegration)
        wrts_prcgvr.VersionManager.newClassInstance('ActivityIntegration');
        activityIntegration.handleStatusChange(new Map<String, Object>{
            'newActivities' => Trigger.new,
            'oldActivities' => Trigger.old
        });
        //End>>> modifica marco.arci@webresults.it 11/10/21
        HDT_UTL_CompanyOwner.feedCompanyOwner(trigger.new);
        HDT_UTL_Scarti.setLookupFields(trigger.new);
        HDT_UTL_ActivityCustom.inheritUserFields((List<wrts_prcgvr__Activity__c>) trigger.new);
        HDT_UTL_ActivityCustom.checkForProcessFields(Trigger.new, new Map<Id, wrts_prcgvr__Activity__c>());
        HDT_UTL_ActivityCustom.setAccountIdFromCaseOrder(trigger.new);
        HDT_UTL_ActivityCustom.postSurvayWorkActivity(trigger.new);
    }

 	//public override void beforeDelete(){}
 //	public override void afterDelete(){}
  //	public override void afterUndelete(){}
    
    public override void beforeUpdate(){
        HDT_UTL_ActivityCustom.setConvertCloseStatus((List<wrts_prcgvr__Activity__c>) trigger.new);
        //Start>>> modifica marco.arci@webresults.it 11/10/21
        wrts_prcgvr.Interfaces_1_1.IActivityIntegration activityIntegration =(wrts_prcgvr.Interfaces_1_1.IActivityIntegration)
        wrts_prcgvr.VersionManager.newClassInstance('ActivityIntegration');
        activityIntegration.handleStatusChange(new Map<String, Object>{
            'newActivities' => Trigger.new,
            'oldActivities' => Trigger.old
        });
        //End>>> modifica marco.arci@webresults.it 11/10/21
        // HRAWRM-672 22/09/2021 EC
        //wrts_prcgvr__Status__c='Chiusa';
        String varStatus='Chiusa';
        Map<Id, wrts_prcgvr__Activity__c> mapNew = (Map<Id, wrts_prcgvr__Activity__c>)trigger.newMap;
        Map<Id, wrts_prcgvr__Activity__c> mapOld = (Map<Id, wrts_prcgvr__Activity__c>)trigger.oldMap;
        for (wrts_prcgvr__Activity__c tempAct :(List<wrts_prcgvr__Activity__c>)trigger.new) {
            if (mapNew.get(tempAct.id)!=null && mapOld.get(tempAct.id)!=null
                && mapNew.get(tempAct.id).OwnerId !=  mapOld.get(tempAct.id).OwnerId
                && mapNew.get(tempAct.id).wrts_prcgvr__Status__c!=varStatus&& mapNew.get(tempAct.id).RecordTypeId==recordTypeD2DId ) {
                    tempAct.wrts_prcgvr__Status__c=varStatus;
            }
        }
        // HRAWRM-672 22/09/2021 EC
        // HRAWRM-880 LG
        HDT_UTL_ActivityCustom.updateTimeRefAppointment(trigger.old,trigger.new);
        HDT_UTL_ActivityCustom.setNoteRicontattoCliente(trigger.old,trigger.new);
        HDT_UTL_ActivityCustom.checkForProcessFields(Trigger.new, (Map<Id, wrts_prcgvr__Activity__c>)Trigger.oldMap);
        HDT_UTL_ActivityCustom.setAccountIdFromCaseOrder(trigger.new);
        // Assessment Gestione Scarti: rimossa chiamata a method poichè errato.
        //HDT_UTL_Scarti.handleEditButtonPress(trigger.new, (Map<Id, wrts_prcgvr__Activity__c>) trigger.oldMap);//>>> costanzo.lomele@webresults.it 14/10/21
    }

    public override void afterUpdate(){

        HDT_UTL_ActivityCustomProcess.changeAssignRelatedRecord(trigger.new,trigger.old);

        // @Picchiri 08.06.21 Credit Check Annullamento Ordine  
        HDT_UTL_ActivityCustomProcess.annullamentoActivityCustom(trigger.new,(Map<Id, wrts_prcgvr__Activity__c>)trigger.oldMap);

        // @Picchiri 14.06.21 Credit innesco credi check al cambio dello stato        
        HDT_UTL_ActivityCustomProcess.creditCheckKoPrecedenteCliente(trigger.new,trigger.old);

        //cancel orders from quality call activities with 'No esito' and ActiveMonitoring__c = true
        HDT_UTL_ActivityCustomProcess.cancelQualityNoResult(trigger.new,trigger.old);
        
       // marco.arci@webresults.it 01/09/2021 gestione scarti documentali
       // NTTDATA 17/11/2021: commentato perchè non gestisce la casistica di più di 200 activity aggiornate da stessa DML (scoppia l'enqueueJob)
       // Da capire se ha senso questo method o si può proprio rimuovere.
       //HDT_UTL_Scarti.updatePraticaForScartoDocumentale(trigger.new, trigger.old);

        //f. defelice Chiusura case Proroga Temp
        //HDT_UTL_ActivityCustomProcess.closeSobjectOnActivityClosing(trigger.new, trigger.old);
        HDT_UTL_ActivityCustomProcess.closeParentEntityCanceledActivity(trigger.new, trigger.old);
        HDT_UTL_ActivityCustom.checkForMandatoryAttachment((Map<Id, wrts_prcgvr__Activity__c>) trigger.newMap);

        //GiFlorio  
        HDT_UTL_ActivityCustom.executeOnCloseActions((List<wrts_prcgvr__Activity__c>) trigger.new, (Map<Id, wrts_prcgvr__Activity__c>) trigger.oldMap);
        // Assessment Gestione Scarti: rimossa chiamata a method poichè errato.
        // HDT_UTL_Scarti.handleEditButtonPress(trigger.new, (Map<Id, wrts_prcgvr__Activity__c>) trigger.oldMap);
        HDT_UTL_ActivityCustomProcess.sendCloseNotification(Trigger.new, Trigger.oldMap);
        HDT_UTL_ActivityCustomProcess.shareRecordAppointmentSelf(Trigger.new, Trigger.oldMap);
    }

    public override void afterInsert(){
        HDT_UTL_Scarti.checkForEsitiIntermedi(trigger.new);
        HDT_UTL_ActivityCustom.setCompanyName(trigger.new);
    }

}