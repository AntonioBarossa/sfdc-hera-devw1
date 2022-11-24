@SuppressWarnings('PMD.AvoidDebugStatements')
public with sharing class HDT_UTL_CaseProcess {
    private static HDT_QR_Contact contactQr = new HDT_QR_Contact();
    private static HDT_QR_Account accountQr = new HDT_QR_Account();
    private static HDT_UTL_CommunicationLog commUtl = new HDT_UTL_CommunicationLog();
    private static HDT_SRV_CommunicationLog commSrv = new HDT_SRV_CommunicationLog();
    private static HDT_SRV_Account accountSrv = new HDT_SRV_Account();
    private static HDT_QR_CampaignMember campaignMemberQr = new HDT_QR_CampaignMember();
    private static HDT_SRV_CampaignMember campaignMemberSrv = new HDT_SRV_CampaignMember();

    public static void checkSatisfationIndex(Map<Id,SObject> newMap, Map<Id,SObject> oldMap) {
        List<Account> accountsToUpdate = new List<Account>();
        for(Case newCase : (List<Case>) newMap.values()) {
            if(((Case) oldMap.get(newCase.Id)).PraxidiaOverrallSatisfaction__c != newCase.PraxidiaOverrallSatisfaction__c) {
                accountsToUpdate.add(new Account(
                    Id = newCase.AccountId,
                    SatisfactionIndexCtrl__c = newCase.PraxidiaOverrallSatisfaction__c,
                    PraxidiaUpdateDate__c = newCase.PraxidiaDateOutcome__c  
                ));
            } 
        }
        accountSrv.updateRecordsWithCheck(accountsToUpdate);
        //update accountsToUpdate; 
    }

    public static void caseBpcaSieManagement(Map<Id, Sobject> newCasesMap, Map<Id, Sobject> oldCasesMap) {
        Set<Id> accountIdsBpca = new Set<Id>();
        for(Case caseNew : (List<Case>) newCasesMap.values()){
            if(String.isNotBlank(caseNew.Type) && String.isNotBlank(caseNew.Phase__c) && caseNew.Type.equals('BP/CA - errata categoria') && caseNew.Phase__c.equals('Completata') && caseNew.Phase__c != oldCasesMap.get(caseNew.Id).get('Phase__c')){
                accountIdsBpca.add(caseNew.AccountId);
            }
        }
        if(!accountIdsBpca.isEmpty()){
            system.debug('accountIdsBpca: ' + accountIdsBpca);
            new HDT_SRV_SieXiv().checkBpcaChanges(accountIdsBpca);
        }
    }

    public static void casePhaseManagementAfterUpdate(List<Case> newCasesList, List<Case> oldCasesList) {

        
        Map<String,Case> caseMapNewToOld = new Map<String,Case>();
        Map<String,Case> caseMapOld = new Map<String,Case>();
        Map<String,Case> caseMapNew = new Map<String,Case>();
        
        ////// stesso Case se phase__c diverso tra old e new chiamiamo funzione di una classe HDT_UTL_CommunicationLog
        
        for (Case oldCase : oldCasesList) {
            CaseMapOld.put(oldCase.id,oldCase);
        }
        for (Case newCase : newCasesList) {
           	caseMapNew.put(newCase.id,newCase);
            if(caseMapOld.get(newCase.id)!= null){
                caseMapNewToOld.put(newCase.id,caseMapOld.get(newCase.id));
            }
        }
        
        insertLogForCaseChangedPhase(caseMapOld,caseMapNew);

    }

    private static void insertLogForCaseChangedPhase(Map<String,Case> CaseMapOld, Map<String,Case> CaseMapNew){
        List<CommunicationLog__c> commList = new List<CommunicationLog__c>();
        Map<String,String> mapCaseToContact = new map<String,String>();
        Map<String,String> mapCaseToAccount = new map<String,String>();
        for (Case c : CaseMapNew.values()){
            mapCaseToContact.put(c.id,c.contactId);
            mapCaseToAccount.put(c.id,c.accountId);
        }
        Map<String,Contact> mapContact = new Map<String,Contact>(contactQr.getRecordsById(mapCaseToContact.values()));
        map<String,Account> mapAccount = new Map<String,Account>(accountQr.getRecordsById(mapCaseToAccount.values(),'Id,CompanyOwner__c'));
        for(String cas : CaseMapOld.keyset()){
           Case oldCase =  CaseMapOld.get(cas);
           if(CaseMapNew.get(cas) != null){
               Case newCase = CaseMapNew.get(cas);
               if(oldCase.phase__c != newCase.Phase__c){
                   Contact c = null;
                   Account a = null;
                   if(mapContact.get(newCase.Contactid) != null){
                       c = mapContact.get(newCase.Contactid);
                   }
                   if(mapAccount.get(newCase.AccountId) != null){
                       a = mapAccount.get(newCase.AccountId);
                   }
                   if(a != null && c != null && newCase.Lead__c == null){
                    commList.add(commUTL.instanceCommunicationLog(newCase.cluster__c,newCase.type,newCase.Phase__c,newCase.status,newCase.CancellationReasonDescription__c,'',newCase.id,newCase.ContactId,newCase.AccountId,c != null ? c.company__c : 'ND',a != null ? a.CompanyOwner__c : ''));
                   }  
               }
           }
        }
        if(commList != null && !commList.isEmpty()){
            commSRV.createRecords(commList);
        }
    }
    public static Boolean checkSkipExportSie(List<Case> caseList, Map<Id,SObject> caseOldMap){
        Case caseNew = caseList[0];
		Case caseOld = (Case) caseOldMap.get(caseNew.Id);
		Boolean newCmor = caseNew.IsExportCMOR__c;
		Boolean oldCmor = caseOld.IsExportCMOR__c;
        if( !oldCmor && newCmor) return true;
        return false;
    }
    public static Boolean manageCancellationProcess(List<Case> caseList, Map<Id,SObject> caseOldMap){
        HDT_QR_Case caseQr = new HDT_QR_Case();
		Case caseNew = caseList[0];
		Case caseOld = (Case) caseOldMap.get(caseNew.Id);
		String newPhase = caseNew.Phase__c;
		String oldPhase = caseOld.Phase__c;
        DateTime nowDateTime = DateTime.now();
		if(String.isNotBlank(newPhase) && String.isNotBlank(oldPhase) && newPhase != oldPhase){
            /**@frpanico
             * Added comment:
             * Se la fase di arrivo e' di annullamento o Annullato
             * si entra nell'if per tutte le gestioni ad hoc dei processi
             */
			if(newPhase.indexOf('Annullamento') > -1 || newPhase.equalsIgnoreCase('Annullato') || newPhase.indexOf('Ripensamento') > -1 || newPhase.equalsIgnoreCase('Ripensato')){
                //Annullamento Case di Richiesta Parere legati al case di Reclamo
                //Annullamento activities legate al case di Richiesta Parere
                if(caseNew.Type.equalsIgnoreCase('Reclamo Scritto/Rich. Info')){    
                    List<Case> childCases = new List<Case>();
                    List<String> caseIds = new List<String>();
                    List<wrts_prcgvr__Activity__c> activities = new List<wrts_prcgvr__Activity__c>();
                    List<SObject> updateList = new List<SObject>();
                    Set<String> activitiesOwnerId = new Set<String>();
                    String activityId = '';
                    childCases = caseQr.getChildCase(caseNew.Id);
                    if(childCases != null){
                        for(Case child : childCases){
                            if(!(child.Phase__c.equalsIgnoreCase('Completata'))){
                                caseIds.add(child.Id);
                                child.Phase__c = 'Annullato';
                                child.Status = 'Closed';
                            }
                        }
                        if(caseIds != null){
                            try{
                                HDT_QR_Knowledge knowledgeQr = new HDT_QR_Knowledge();
                                CustomNotificationType customNotif = new CustomNotificationType();
                                customNotif = knowledgeQr.getCustomNotificationType();
                                activities = caseQr.getCaseActivities(caseIds);
                                if(activities != null){
                                    List<wrts_prcgvr__Activity__c> activitiesToUpdate = new List<wrts_prcgvr__Activity__c>();
                                    for(wrts_prcgvr__Activity__c activity : activities){
                                        if (!'Eseguire Gestione Manuale SAP'.equalsIgnoreCase(activity.Type__c)){
                                            activitiesOwnerId.clear();
                                            if(activity.OwnedByUser__c != null && String.isNotBlank(activity.OwnedByUser__c)){
                                                activityId = activity.OwnedByUser__c;
                                            }else{
                                                activityId = activity.OwnerId;
                                            }
                                            activitiesOwnerId.add(activityId);
                                            activity.wrts_prcgvr__Status__c = 'Annullata';
                                            //Notification Fire to activity's owner
                                            try{
                                                if(customNotif != null && activitiesOwnerId.size() > 0){
                                                    String title = 'Activity Annullata';
                                                    String body = 'L\'Activity ' + activity.wrts_prcgvr__ActivityTemplate__r.Name + ' è stata annullata';
                                                    HDT_UTL_NewsNotificationCenter.fireNotification(title,body,activity.Id,activitiesOwnerId);
                                                }
                                            } catch(Exception e){
                                                System.debug(LoggingLevel.DEBUG, 'Impossibile inviare notifica: ' + e.getMessage() + '. Error at line: ' + e.getLineNumber());
                                            }
                                            activitiesToUpdate.add(activity);
                                        }
                                    }
                                    if (!activitiesToUpdate.isEmpty()){
                                        updateList.addAll(activitiesToUpdate);
                                    }
                                }
                            }catch(Exception e){
                                System.debug(LoggingLevel.DEBUG, 'Exception: ' + e.getMessage() + '. At Line: ' + e.getLineNumber());
                            }
                        }
                        updateList.addAll(childCases);
                        HDT_UTL_DatabaseService.updateSObject(updateList);
                    }
                }
                /* Richiesta Parere
                * Il case padre (reclamo scritto) viene riportato In Lavorazione
                */
                if(caseNew.Type.equalsIgnoreCase('Richiesta Parere') && newPhase.equalsIgnoreCase('Annullato') && caseNew.ParentId != null)
                {
                    Case complaintCase = new Case();
                    complaintCase.Id = caseNew.ParentId;
                    complaintCase.Phase__c = 'In Lavorazione';
                    HDT_UTL_DatabaseService.updateSObject(complaintCase);
                }
                //Contratto Non Richiesto
                if(newPhase.equalsIgnoreCase('Annullato')){
                    Case nonReqContr = new Case();
                    nonReqContr = caseQr.getNonReqContrCase(caseNew.Id);
                    System.debug(LoggingLevel.DEBUG, 'Id ' + nonReqContr.Id);
                    System.debug(LoggingLevel.DEBUG, 'Id Cond ' + String.isBlank(nonReqContr.Id));
                    if(!(String.isBlank(nonReqContr.Id))){
                        nonReqContr.Phase__c = 'Completata';
                        HDT_UTL_DatabaseService.updateSObject(nonReqContr);
                    }
                    /**@frpanico 17/01/2022
                     * Annullamento activity al passaggio nella fase Annullato
                     */
                    List<wrts_prcgvr__Activity__c> activitiesToCancel = new List<wrts_prcgvr__Activity__c>();
                    for(wrts_prcgvr__Activity__c activity : caseQr.getCaseActivities(new List<String>{caseNew.Id}))
                    {
                        if ('Autolettura'.equalsIgnoreCase(caseNew.Cluster__c) && 'Gestione Manuale SAP'.equalsIgnoreCase(activity.Type__c)){
                            continue;
                        }
                        activity.wrts_prcgvr__Status__c = 'Annullata';
                        activitiesToCancel.add(activity);
                    }
                    if(!activitiesToCancel.isEmpty())
                    {
                        HDT_UTL_DatabaseService.updateSObject(activitiesToCancel);
                    }
                }
                //Variazione Indirizzzo di Fornitura
                if(caseNew.Type.containsIgnoreCase('Variazione indirizzo di fornitura') || caseNew.Type.containsIgnoreCase('Marcatura/Uso PdR')){
                    System.debug(LoggingLevel.DEBUG, 'Inside Condition');
                    HDT_UTL_Case.createActivity(caseNew.Id, 'Annullare Case di Allineamento Anagrafica o crearne uno opposto', 'Annullamento Allineamento', 'Annullamento Allineamento');
                }
                /*if(caseNew.Cluster__c == 'Autolettura'){
                    // Annullamento dopo l'invio al DL
                    if (caseNew.PhaseStory__c != null && caseNew.PhaseStory__c.containsIgnoreCase('Comunicazione verso Heroku OK')){
                        HDT_UTL_Case.createActivity(caseNew.Id, 'Gestione M01/M02','Gestione M01/M02','Gestione M01/M02');
                    }
                    // Annullamento dopo la validazione da MDM ma prima dell'invio al DL
                    else if (caseNew.PhaseStory__c != null && caseNew.PhaseStory__c.containsIgnoreCase('Esito OK da SAP') && !caseNew.PhaseStory__c.containsIgnoreCase('Comunicazione verso Heroku OK')){
                        HDT_UTL_Case.createActivity(caseNew.Id, 'Gestione Manuale SAP','Gestione Manuale SAP','Gestione Manuale SAP');
                    }
                }*/
                /**@frpanico 22/10/2021
                 * Reintrodotto PhaseManager per annullamento
                 * viene skippato solo in entrata e in uscita dall'annullamento dove non sono previste activity
                 * Viene mantenuto per gli annullamenti passivi dove la fase é Annullamento SII
                 * L'if in questione skippa il phase manager solo se la fase di partenza non e' di annullamento.
                 * Nelle fasi di annullamento si fase di partenza che fase di arrivo sono Annullamento - o Annullato.
                 */
                if((oldPhase.indexOf('Annullamento - ') == -1 && oldPhase.indexOf('Ripensamento - ') == -1)
                    || newPhase.equalsIgnoreCase('Annullato') || newPhase.equalsIgnoreCase('Ripensato'))
                {
                    caseNew.PhaseStory__c = oldPhase+'@@'+newPhase+'@@'+nowDateTime.getTime()+'@@A||'+caseNew.PhaseStory__c;
                    return true;
                }
                //Gestione Risottomissione Annullamento
                if ((oldPhase.equalsIgnoreCase('Annullamento - Ammissibilità KO') || oldPhase.equalsIgnoreCase('Annullamento - Esito KO da DL/SII')) && newPhase.equalsIgnoreCase('Annullamento - Da Inviare')){
                    caseNew.PhaseStory__c = !String.isBlank(caseNew.PhaseStory__c) 
                        ? oldPhase+'@@'+newPhase+'@@'+nowDateTime.getTime()+'@@A||'+caseNew.PhaseStory__c
                        : oldPhase+'@@'+newPhase+'@@'+nowDateTime.getTime()+'@@A||';
                    return true;
                }
                return false;
            /**@frpanico 22/10/2021
             * Add Comment:
             * Si entra in questo blocco quando la fase di partenza e' di annullamento e la nuova non lo e'  
             */    
			}else if(oldPhase.indexOf('Annullamento - ') > -1 || oldPhase.indexOf('Ripensamento - ') > -1){
                caseNew.PhaseStory__c = oldPhase+'@@'+newPhase+'@@'+nowDateTime.getTime()+'@@A||'+caseNew.PhaseStory__c;

				return true;
			}
		}
		return false;
	}
    
    public static void updateMemberStatusforClosedCases(List<Case> newCasesList, List<Case> oldCasesList) {
        try{
            List<Id> closedCaseIds = new List<Id>();
            Map<String,Case> oldCaseMap = new Map<String,Case>();
            for(Case c : oldCasesList){
                oldCaseMap.put(c.id,c);
            }
            Map<String,String> accountIdCase = new Map<String,String> ();
            Map<String,String> campaignIdCase = new Map<String,String>();
            for (Case newCase : newCasesList) {// Start 27/08/2021 HRAWRM-314 per processi autoconclusivi (newCase.Status == 'In Lavorazione')||newCase.Status == 'Closed')
                if (oldCaseMap.get(newCase.id) != null && (oldCaseMap.get(newCase.id).status == 'New' && (newCase.Status == 'In Lavorazione')||newCase.Status == 'Closed')) {
                    closedCaseIds.add(newCase.Id);
                    accountIdCase.put(newCase.AccountId, newCase.Id);
                    campaignIdCase.put(newCase.Campaign__c, newCase.Id);
                }
            }

            List<String> accountIds = new List<String>(accountIdCase.keySet());
            List<String> campaignIds = new List<String>(campaignIdCase.keySet());
            if(!campaignIds.isEmpty()){
                List<CampaignMember> membersToUpdate = new List<CampaignMember>();
                List<CampaignMember> cmembers = campaignMemberQr.getMembersByAccountAndCampaign(accountIds, campaignIds);
                for (CampaignMember cm : cmembers) {
                    if (accountIdCase.get(cm.Contact.AccountId) == campaignIdCase.get(cm.CampaignId)) {
                        CampaignMember updateMember = new CampaignMember();
                        updateMember.Id = cm.Id;
                        updateMember.Status = 'Positivo';
                        membersToUpdate.add(updateMember);
                    }
                }
                //update campaignMember siblings Status a 'Non Proposto Auto'
                List<CampaignMember> siblingMembers = HDT_QR_CampaignMember.getSiblingMembersByAccountId(accountIds, newCasesList[0].Campaign__r.Channel__c);
                List<String> campaignMembersIdList = new List<String>(new Map<String, CampaignMember>(siblingMembers).keySet());
                if (campaignMembersIdList.size()>0) {
                    HDT_LC_CampaignsController.updateCampaignMembersStatus(campaignMembersIdList, 'Non Proposto Auto');
                }
                campaignMemberSrv.updateRecords(membersToUpdate);
            }
		}catch(Exception e)
		{
            System.debug(LoggingLevel.DEBUG, '*******Error:' + e);
		}
    }

    public static void updateServiceRequest(List<Case> newCasesList, List<Case> oldCasesList){
        Map<String,Case> mapCases = new Map<String,Case>();
        Map<String,String> caseStatuses= new Map<String,String>();
        List<ServiceRequest__c> sReqToUpdate= new List<ServiceRequest__c>();
        Set<Id> caseIds= new Set<Id>();
        for(Case o: oldCasesList){
            mapCases.put(o.id, o);
        }
        for (Case cs: newCasesList){
            Case oldCase= mapCases.get(cs.id);
            
            if(cs.Status != oldCase.Status ){
                caseIds.add(cs.Id);
                caseStatuses.put(cs.Id, cs.Status);
            }
        }
        if (!caseIds.isEmpty()){
            List<ServiceRequest__c> srvRequests = HDT_QR_ServiceRequest.getServiceRequestByOrderCaseIds(caseIds, 'Case__c');
            List<ServiceRequest__c> srvRequestsToDelete = new List<ServiceRequest__c>();
            for(ServiceRequest__c s: srvRequests){
                s.Status__c= HDT_UTL_MatrixCompatibility.getStatus(caseStatuses.get(s.Case__c), 'Case');
                if( s.Status__c.equalsIgnoreCase('Chiuso') ){
                    srvRequestsToDelete.add(s);
                } else {
                    sReqToUpdate.add(s);
                }
            }
            if (!srvRequestsToDelete.isEmpty()){
                HDT_SRV_ServiceRequest.deleteRecord(srvRequestsToDelete);
            }
            HDT_SRV_ServiceRequest.updateRecord(sReqToUpdate);
        }
    }

    /**
    * @author Andrea Arosio (andrea.arosio@webresults.it)
    * @description metodo per il collegamento dell'oggetto tecnico serviceRequest al case di riferimento
    * @date 16/09/2021
    * @param1 List<Case> lista dei cases inseriti
    */
    public static void linkServiceRequestToCase(List<Case> newCasesList){
        List<ServiceRequest__c> sReqToUpdate= new List<ServiceRequest__c>();
        for (Case cs: newCasesList){
            
            if(!String.isEmpty(cs.ServiceRequestID__c)){
                ServiceRequest__c sReq = new ServiceRequest__c(Id= cs.ServiceRequestID__c);
                sReq.Case__c = cs.Id;
                sReqToUpdate.add(sReq);
            }
        }
        HDT_SRV_ServiceRequest.updateRecord(sReqToUpdate);
    }

    public static void setCloseStatusForAll(List<Case> caseList){
        for(Case c : caseList) {
            setCloseStatus(c);
        }
    }

    public static void setCloseStatus(Case c){
        if ('Chiuso'.equalsIgnoreCase(c.Status)){
            c.Status = 'Closed';
        }
    }


}