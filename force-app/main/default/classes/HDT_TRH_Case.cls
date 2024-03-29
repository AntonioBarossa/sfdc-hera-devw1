@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing class HDT_TRH_Case extends HDT_TRH_TriggerHandler {
	
    public override void beforeInsert(){
        HDT_UTL_CaseProcess.predefaultCaseValues(Trigger.new, null);
        HDT_UTL_CaseProcess.setCloseStatusForAll(Trigger.new);
        markCasesFromCurrentUser();
        HDT_UTL_CompanyOwner.feedCompanyOwner(trigger.new);
        //HDT_UTL_CaseProcess.predefaultCaseValues((List<Case>)Trigger.new,null);

        for(Case caseNew : (List<Case>) Trigger.new){
            if(String.isNotBlank(caseNew.Origin) && (caseNew.Origin == 'SOL' || caseNew.Origin == 'APP' || caseNew.Origin == 'WEB') && caseNew.Cluster__c == 'Reclami'){
                caseNew.SendDate__c = date.today();
            }
        }


        for(Case caseNew : (List<Case>) Trigger.new){
            if(String.isNotBlank(caseNew.Origin) && (caseNew.Origin == 'SOL' || caseNew.Origin == 'APP' || caseNew.Origin == 'WEB') && caseNew.Cluster__c == 'Reclami'){
                caseNew.SendDate__c = date.today();
            }
        }


    }

 	//public override void beforeDelete(){}
 	//public override void afterDelete(){}
  //	public override void afterUndelete(){}
    
    public override void beforeUpdate(){
        //Check Quotation Type && set technical phase
        Boolean skipForSap = false;
        Boolean skipForDatesUpdate = HDT_UTL_CaseProcess.checkSkipDatePopulation(trigger.new,Trigger.oldMap);
        if (!skipForDatesUpdate){

            try{
                skipForSap = HDT_UTL_Scarti.changeSapPhaseHandler(Trigger.newMap, Trigger.oldMap);
                HDT_UTL_CaseProcess.predefaultCaseValues(Trigger.new, Trigger.oldMap);
                for(Case caseNew : (List<Case>) Trigger.new){
                    if (String.isNotBlank(caseNew.CancellationNote__c) && caseNew.CancellationNote__c.length() > 255){
                        caseNew.CancellationNote__c = caseNew.CancellationNote__c.substring(0,255);
                    }
                    HDT_UTL_CaseProcess.setCloseStatus(caseNew);
                    Case caseOld = (Case) Trigger.oldMap.get(caseNew.Id);
                    
                    //AF W2 Inserito controllo sulla fase Bozza
                    if(caseOld.Amount__c != null && caseNew.Amount__c != caseOld.Amount__c && caseOld.QuotationType__c == 'Rapido' && caseNew.Phase__c != 'Bozza' && caseNew.Phase__c != 'Da Inviare'){
                        caseNew.QuotationType__c = 'Predeterminabile';
                        caseNew.PaymentDetails__c = 'Change Quotation';
                    }
                    //Inserito questo controllo per gestire la casistica di un Preventivo Analitico che riceve più ammissibilità causa esecuzione lavori.
                    //pertanto se il Preventivo è Analitico, ho già ricevuto un ammissibilità OK e sto ricevendo un importo, non devo riclassificare.
                    if(String.isBlank(String.valueOf(caseOld.Amount__c)) && String.isNotBlank(String.valueOf(caseNew.Amount__c)) && caseOld.QuotationType__c != null && caseOld.QuotationType__c.equalsIgnoreCase('Analitico')
                        && !(caseOld.PhaseStory__c != null && caseOld.PhaseStory__c.containsIgnoreCase('Ammissibilità OK'))){
                            caseNew.QuotationType__c = 'Predeterminabile';
                    }
                    if(caseNew.TecnicalPhase__c	!= null && caseNew.TecnicalPhase__c  == caseOld.TecnicalPhase__c){
                        caseNew.Phase__c = caseNew.TecnicalPhase__c;
                        caseNew.TecnicalPhase__c = null;
                    }
    
                    if(caseNew.SendDate__c == null && String.isNotBlank(caseNew.Origin) && (caseNew.Origin == 'SOL' || caseNew.Origin == 'APP' || caseNew.Origin == 'WEB') && caseNew.Cluster__c == 'Reclami'){
                        DateTime dt = caseNew.CreatedDate;
                        caseNew.SendDate__c = date.newinstance(dt.year(), dt.month(), dt.day());
                    }
                }   
            } catch (Exception ex) {
                System.debug(LoggingLevel.DEBUG, 'Error ' + ex.getMessage() + ' at line ' + ex.getLineNumber());
                
            }
    
    
            Boolean skipForCancellation = HDT_UTL_CaseProcess.manageCancellationProcess(trigger.new,Trigger.oldMap);
            Boolean skipForExportSie = HDT_UTL_CaseProcess.checkSkipExportSie(trigger.new,Trigger.oldMap);
            //EVERIS: Gestione Scarti SAP
            Boolean skipForGestioneScarti = skipForSap || HDT_UTL_Scarti.manageSapDiscard(Trigger.new, Trigger.oldMap);
            if(!skipForCancellation && !skipForGestioneScarti && !skipForExportSie){
            //Checks Phase Transition
                ((wrts_prcgvr.Interfaces_1_2.IPhaseManagerIntegration) wrts_prcgvr.VersionManager.newClassInstance('PhaseManagerIntegration'))
                        .beforeUpdate(new Map<String, Object> { 'oldObjects' => Trigger.old, 'newObjects' => Trigger.new });
            }
    
            // Checks Mandatory Activity
            ((wrts_prcgvr.Interfaces_1_0.IActivityUtils) wrts_prcgvr.VersionManager.newClassInstance('ActivityUtils'))
                    .bulkCheckCompleted(new Map<String,Object>{'triggerNew'=>Trigger.new, 'triggerOld' => Trigger.old});
    
            HDT_UTL_CaseProcess.updateServiceRequest(trigger.new, trigger.old);
            
            HDT_UTL_Dependencies.processSequentializationBefore(Trigger.newMap,Trigger.oldMap,'Case');
            HDT_UTL_CaseProcess.predefaultCaseValues((List<Case>)Trigger.new,Trigger.oldMap);
        }

    }

    public override void afterUpdate() {
        Boolean skipForDatesUpdate = HDT_UTL_CaseProcess.checkSkipDatePopulation(trigger.new,Trigger.oldMap);
        if(!skipForDatesUpdate){
            Boolean skipForExportSie = HDT_UTL_CaseProcess.checkSkipExportSie(trigger.new,Trigger.oldMap);
            if(!skipForExportSie){
                //Execute creation Activities 
                ((wrts_prcgvr.Interfaces_1_0.IActivityUtils) wrts_prcgvr.VersionManager.newClassInstance('ActivityUtils'))
                        .bulkSaveActivityContext(null);
                
                //Handles callout (update only)
                /*sostituito dal metodo sotto che esclude eventuali chiamate doppie eseguite negli ultimi 30 secondi 
                ((wrts_prcgvr.Interfaces_1_0.ICalloutUtils) wrts_prcgvr.VersionManager.newClassInstance('CalloutUtils'))
                        .bulkSend(new Map<String,Object>{'newObjects'=>Trigger.new, 'oldObjects' => Trigger.old}); */
                if(HDT_UTL_CaseProcess.isChangedPhase(trigger.new,Trigger.oldMap)){
                    HDT_UTL_DoubleCalloutPrevention.checkAndCallout(Trigger.new, Trigger.oldMap, 'Case');
                }
            }
            HDT_UTL_CaseProcess.checkSatisfationIndex(trigger.newMap, trigger.oldMap);
            HDT_UTL_CaseProcess.casePhaseManagementAfterUpdate(trigger.new,trigger.old);  
            HDT_UTL_CaseProcess.caseBpcaSieManagement(Trigger.newMap, Trigger.oldMap);
            //***INIZIO SVILUPPO CAMPAGNE */
            HDT_UTL_CaseProcess.updateMemberStatusforClosedCases(trigger.new, trigger.old); 
            //**FINE SVILUPPO */
    
            //***INIZIO SVILUPPO Marco Arci 17/05/2022 Cluster Disattivazioni Tari, chiusura activity correlate*/
            //HDT_UTL_CaseProcess.closeRelatedActivity(Trigger.new, Trigger.oldMap); //non più necessario, motivazione nel metodo
            //**FINE SVILUPPO */
            
            HDT_UTL_PrClickDoubleTransaction.enqueueDoublePhaseTransactions();
            HDT_UTL_PrClickEndSubscriptionBulk.updateCorrelatedObjects();
            HDT_UTL_Scarti.closeActivityOnCompleted(Trigger.new, Trigger.oldMap);
            HDT_UTL_CaseProcess.handleAfterUpdate(Trigger.new, Trigger.oldMap);
        }
        
    }

    public override void afterInsert(){
        HDT_UTL_CaseProcess.linkServiceRequestToCase(trigger.new);

        List<Case> caseToUpdateList = new List<Case>();
        Boolean toUpdate = false;
        for(Case caseNew : (List<Case>) Trigger.new){
            Case caseToUpdate = new Case(Id = caseNew.Id);
            if(caseNew.CustomerRequestDate__c == null){
                caseToUpdate.CustomerRequestDate__c = Date.today();
                toUpdate = true;
            }
            if(caseNew.WrittenReceiptRequestDate__c == null){
                caseToUpdate.WrittenReceiptRequestDate__c = Date.today();
                toUpdate = true;
            }
            
            if(toUpdate){
                caseToUpdateList.add(caseToUpdate);
            }
        }

        if(caseToUpdateList.size() > 0){
            HDT_UTL_DatabaseService.updateSObject(caseToUpdateList);
        }
    }

    /**
     * Ribalta i campi Canale/Gruppo/Postazione dall'utenza in contesto al Case.
     */
    private void markCasesFromCurrentUser() {

        Id currentUserId = UserInfo.getUserId();
        if (currentUserId == null) {
            return;
        }

        User currentUser = HDT_QR_UserQueries.getCurrentUser(currentUserId);
        if (currentUser == null) {
            return;
        }

        for (Case c : (List<Case>) Trigger.new) {

            if (String.isBlank(c.Origin)) {
                c.Origin = !String.isBlank(currentUser.LoginChannel__c) ? currentUser.LoginChannel__c : 'Telefono Inbound'; // Origin è obbligatorio, prevediamo un default per sicurezza.
            }

            if (String.isBlank(c.Station__c)) {
                c.Station__c = currentUser.Station__c;
            }

            if (String.isBlank(c.CreatorGroup__c)) {
                c.CreatorGroup__c = currentUser.CreatorGroup__c;
            }

        }
    }

}