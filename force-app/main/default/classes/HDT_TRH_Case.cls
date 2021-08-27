public inherited sharing class  HDT_TRH_Case extends HDT_TRH_TriggerHandler {
	
    public override void beforeInsert(){

        markCasesFromCurrentUser();
        HDT_UTL_CompanyOwner.feedCompanyOwner(trigger.new);

    }

 	public override void beforeDelete(){}
 	public override void afterDelete(){}
  	public override void afterUndelete(){}
    
    public override void beforeUpdate(){
        //Check Quotation Type && set technical phase
        try{
            for(Case caseNew : (List<Case>) Trigger.new)
            {
                Case caseOld = (Case) Trigger.oldMap.get(caseNew.Id);
                if(caseOld.Amount__c != null && caseNew.Amount__c != caseOld.Amount__c && caseOld.QuotationType__c == 'Rapido'){
                    caseNew.QuotationType__c = 'Predeterminabile';
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
            }   
        }catch(Exception ex){
            System.debug('Error ' + ex.getMessage() + ' at line ' + ex.getLineNumber());
        }

        HDT_UTL_CaseProcess.updateServiceRequest(trigger.new, trigger.old);

        Boolean skipForCancellation = HDT_UTL_CaseProcess.manageCancellationProcess(trigger.new,Trigger.oldMap);
        if(!skipForCancellation){
        //Checks Phase Transition
            ((wrts_prcgvr.Interfaces_1_2.IPhaseManagerIntegration) wrts_prcgvr.VersionManager.newClassInstance('PhaseManagerIntegration'))
                    .beforeUpdate(new Map<String, Object> { 'oldObjects' => Trigger.old, 'newObjects' => Trigger.new });
        }
        // Checks Mandatory Activity
        ((wrts_prcgvr.Interfaces_1_0.IActivityUtils) wrts_prcgvr.VersionManager.newClassInstance('ActivityUtils'))
                .bulkCheckCompleted(new Map<String,Object>{'triggerNew'=>Trigger.new, 'triggerOld' => Trigger.old});

        HDT_UTL_Dependencies.processSequentializationBefore(Trigger.newMap,Trigger.oldMap,'Case'); 

    }

    public override void afterUpdate() {
        //Execute creation Activities 
        ((wrts_prcgvr.Interfaces_1_0.IActivityUtils) wrts_prcgvr.VersionManager.newClassInstance('ActivityUtils'))
                .bulkSaveActivityContext(null);
        
        //Handles callout (update only)
        ((wrts_prcgvr.Interfaces_1_0.ICalloutUtils) wrts_prcgvr.VersionManager.newClassInstance('CalloutUtils'))
                .bulkSend(new Map<String,Object>{'newObjects'=>Trigger.new, 'oldObjects' => Trigger.old});

        HDT_UTL_CaseProcess.checkSatisfationIndex(trigger.newMap, trigger.oldMap);

        HDT_UTL_CaseProcess.casePhaseManagementAfterUpdate(trigger.new,trigger.old);  

        //***INIZIO SVILUPPO CAMPAGNE */
        HDT_UTL_CaseProcess.updateMemberStatusforClosedCases(trigger.new, trigger.old); 
        //**FINE SVILUPPO */
    }
    // Start 27/08/2021 HRAWRM-314 per processi autoconclusivi
    public override void afterInsert(){  
        HDT_UTL_CaseProcess.updateMemberStatusforClosedCases(trigger.new);
    }
    // Start 27/08/2021 HRAWRM-314 per processi autoconclusivi
    
    //Andrei Necsulescu - 02/07/2021: Commented as it created an exception when importing more than a certain number of Cases at a time.
    /*
    public override void afterInsert(){   
        wrts_prcgvr.Interfaces_1_0.IObjectCompatibilityInt ObjectCompatibility =
            (wrts_prcgvr.Interfaces_1_0.IObjectCompatibilityInt) wrts_prcgvr.VersionManager.newClassInstance('ObjectCompatibility');

        for(Case c : (Case[])trigger.New){
            //call the check for the candidate SObject
            wrts_prcgvr.ObjectCompatibility_1_0.CheckResult result =
                (wrts_prcgvr.ObjectCompatibility_1_0.CheckResult) ObjectCompatibility.check(new Map<String,Object>{'sObject' => c});

            if(result.incompatibilities.size() > 0) {
                String msg = (result.incompatibilities.size() == 1) ? 'Incompatibility found on Case: ' : 'Incompatibilities found on Cases: ';
                c.addError(msg + getIncompatibilityMessage((Case[])result.incompatibilities));
            }
        }
    }   
    
    private static String getIncompatibilityMessage(Case[] incomps){
        Set<Id> conflictIds = new Set<Id>();
        for(Case c : incomps){
            conflictIds.add(c.Id);
        }

        Set<String> conflicts = new Set<String>();
        
        for(Case c : [SELECT Id, CaseNumber, RecordType.Name FROM Case WHERE Id IN :conflictIds]) {
            conflicts.add(c.CaseNumber + ' (' + c.RecordType.Name + ')');
        }
        System.debug('conflicts: '+ conflicts);

        String[] conflictsString = new List<String>(conflicts);
        return String.join(conflictsString, ', ');
    }
    */

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
