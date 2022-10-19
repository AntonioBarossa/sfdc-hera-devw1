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
    public static void predefaultCaseValues(List<Case> caseList, Map<Id,SObject> caseOldMap){
        //variable allocation
        String servicePoint = '';
        String servicePointOld = '';
        String commodity = '';
        Boolean enableSearch = false;
        Map<Id,String> spCommodityMap = new Map<Id,String>();
        List<Id> spIds = new List<Id>();
        Map<Id,Boolean> needUpdate = new Map<Id,Boolean>();
        //First check if is from Insert or Update
        //1. Is From insert
        if(caseList != null && !caseList.isEmpty() && caseOldMap == null){
            //Commodity Management
            for(Case singleNewCase : caseList){
                servicePoint = singleNewCase.ServicePoint__c;
                commodity = singleNewCase.Commodity__c;
                if (servicePoint != null && String.isNotBlank(servicePoint) && String.isBlank(commodity)) {
                    spIds.add(servicePoint);
                    needUpdate.put(servicePoint, true);
                }
            }
        }
        //2. Is From Updated
        else if(caseList != null && !caseList.isEmpty() && caseOldMap != null) {
            //Commodity Management
            for(Case singleCase : caseList){
                Case caseNew = singleCase;
		        Case caseOld = (Case) caseOldMap.get(caseNew.Id);
                servicePoint = caseNew.ServicePoint__c;
                servicePointOld = caseOld.ServicePoint__c;
                if((String.isBlank(commodity) && String.isBlank(servicePointOld) && String.isNotBlank(servicePoint)) || (String.isNotBlank(servicePointOld) && String.isNotBlank(servicePoint) && servicePoint != servicePointOld)){
                    spIds.add(servicePoint);
                    needUpdate.put(servicePoint, true);
                }
            }
        }
        if(spIds!=null && !spIds.isEmpty()){
            HDT_QR_ServicePoint spQrClass = new HDT_QR_ServicePoint();
            List<ServicePoint__c> spList = spQrClass.getRecordByIdList(spIds,'Id,CommoditySector__c');
            if(!spList.isEmpty()){
                Map<Id, ServicePoint__c> spMap = new Map<Id, ServicePoint__c>(spList);
                for(Case singleCaseToUpdate : caseList){
                    if(needUpdate.get(singleCaseToUpdate.ServicePoint__c) != null && needUpdate.get(singleCaseToUpdate.ServicePoint__c)){
                        singleCaseToUpdate.Commodity__c = spMap.get(singleCaseToUpdate.ServicePoint__c).CommoditySector__c;
                    }
                }
            }
        }
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
                    commList.add(commUTL.instanceCommunicationLog(newCase.cluster__c,newCase.type,newCase.Phase__c,newCase.status,newCase.CancellationReasonDescription__c,'',newCase.id,newCase.ContactId,newCase.AccountId, STRING.isNotBlank(c?.company__c) ? c.company__c : 'ND',a != null ? a.CompanyOwner__c : ''));
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

    /**
    * @author Marco Arci (marco.arci@webresults.it)
    * @description metodo per la chiusura delle activity "aprire cessazione" correlate al case al suo completamento
    * @date 17/05/2022
    * @param1 List<Case> lista dei cases inseriti
    * @param1 Map<Id,SObject> Mappa della vecchia versione dei cases inseriti
    */
    public static void closeRelatedActivity(List<Case> triggerNew, Map<Id,SObject> oldMap){
        list<Id> effectiveCase = new List<Id>();
        for(Case currCase : triggerNew){
            if('Confermato'.equalsIgnoreCase(currCase.Phase__c) && 
               'HDT_RT_CessazioniTari'.equalsIgnoreCase(currCase.RecordType.DeveloperName) &&
               'Cessazione post accertamento'.equalsIgnoreCase(currCase.Type) &&
               ((Case)oldMap.get(currCase.Id)).Phase__c != currCase.Phase__c){
                effectiveCase.add(currCase.Id);
            }
        }
        List<wrts_prcgvr__Activity__c> toClose = [SELECT Id, Case__c, wrts_prcgvr__Status__c, Type__c 
                                                     FROM wrts_prcgvr__Activity__c 
                                                     WHERE Case__c IN: effectiveCase
                                                     AND Type__c = 'Aprire cessazione'
                                                     AND wrts_prcgvr__Status__c != 'Chiusa'
                                                     AND wrts_prcgvr__Status__c != 'Annullata'];
        for(wrts_prcgvr__Activity__c currAct : toClose){
            currAct.wrts_prcgvr__Status__c = 'Chiusa';
        }
        Database.update(toClose);
    }

    /**
    * @author Marco Arci (marco.arci@webresults.it)
    * @description metodo chiamato dal batch HDT_BA_PostSalesMasterBatch per generare activity se sono stati trovati contratti per i processi di post accertamento di variazioni tari e disattivazioni tari
    * @date 18/05/2022
    * @param1 List<Case> lista dei cases inseriti
    */
    public static void createActivityFromContract(List<Case> cases){
        try{
            Map<String, List<String>> fieldsMap = new Map<String,List<String>>{'AccountId' => new List<String>(), 'SupplyCity__c' => new List<String>(), 'SupplyStreetName__c' => new List<String>()};
            List<Case> toAnnul = new List<Case>();
            List<String> caseIds = new List<String>();
            for(Case currCase : cases){
                system.debug('@@@ Case Id:'+currCase.Id);
                caseIds.add(currCase.Id);
                //casesMap.put(currCase.Id, new Map<String,String>{'AccountId' => currCase.AccountId, 'SupplyCity__c' => currCase.SupplyCity__c, 'SupplyStreetName__c' => currCase.SupplyStreetName__c});
                fieldsMap.get('AccountId').add(currCase.AccountId);
                fieldsMap.get('SupplyCity__c').add(currCase.SupplyCity__c);
                fieldsMap.get('SupplyStreetName__c').add(currCase.SupplyStreetName__c);
                system.debug('@@@ Case AccountId:'+fieldsMap.get('AccountId'));
                system.debug('@@@ Case SupplyCity__c:'+fieldsMap.get('SupplyCity__c'));
                system.debug('@@@ Case SupplyStreetName__c:'+fieldsMap.get('SupplyStreetName__c'));
            }
            //verificare che selezione fornitura effettui questo controllo in fase di UAT
            //querare tabella 'dato tecnico comunale' con chiave i comuni del case e verificare se il flag di gestione è attivo
            // o se la data odierna rientra nel range tra 'data da' e 'data cutover',
            //con il risultato modificare la lista fieldsMap.get('SupplyCity__c') lasciando quelli trovati e togliendo quelli non trovati nella tabella
            List<Contract> relatedContracts = [SELECT Id, AccountId, BillingCity, BillingStreet
                                            FROM Contract
                                            WHERE AccountId IN: fieldsMap.get('AccountId')
                                            AND BillingCity IN: fieldsMap.get('SupplyCity__c')
                                            AND BillingStreet IN: fieldsMap.get('SupplyStreetName__c')
                                            AND Status = 'Attivo'];
            system.debug('@@@@ related contract: '+relatedContracts);
            List<wrts_prcgvr__Activity__c> notInsertActivity = HDT_QR_Activity.getActivityFromTypeList(caseIds, new Set<String>{'Aprire variazione','Aprire Cessazione'});
            
            List<Id> excludedCases = new List<Id>();
            for(wrts_prcgvr__Activity__c currAct : notInsertActivity){
                excludedCases.add(currAct.Case__c);
            }
            
            List<wrts_prcgvr__Activity__c> newActivityToInsert = new List<wrts_prcgvr__Activity__c>();
            boolean findContract;
            for(Case caseItem : cases){
                findContract = false;
                for(Contract currContract : relatedContracts){
                    system.debug('@@@ serching contract: '+currContract.Id);
                    if( ((String)caseItem.AccountId)?.equalsIgnoreCase(currContract.AccountId) &&
                        caseItem.SupplyCity__c?.equalsIgnoreCase(currContract.BillingCity) == true && 
                        caseItem.SupplyStreetName__c?.equalsIgnoreCase(currContract.BillingStreet) &&
                        !excludedCases.contains(CaseItem.Id) ){
                            if('Modifica post accertamento'.equalsIgnoreCase(caseItem.Type)){
                                findContract = true;
                                newActivityToInsert.add(new wrts_prcgvr__Activity__c(Account__c=caseItem.AccountId, 
                                                                                     Case__c=caseItem.Id, 
                                                                                     ServicePoint__c=caseItem.ServicePoint__c, 
                                                                                     wrts_prcgvr__Status__c ='Aperta',
                                                                                     DiscardCategory__c = 'Manuale',
                                                                                     Type__c='Aprire Variazione'));
                                break;
                            }else if('Cessazione post accertamento'.equalsIgnoreCase(caseItem.Type)){
                                findContract = true;
                                newActivityToInsert.add(new wrts_prcgvr__Activity__c(Account__c=caseItem.AccountId,
                                                                                     Case__c=caseItem.Id, 
                                                                                     ServicePoint__c=caseItem.ServicePoint__c,
                                                                                     wrts_prcgvr__Status__c ='Aperta',
                                                                                     DiscardCategory__c = 'Manuale',
                                                                                     Type__c='Aprire Cessazione'));
                                break;
                            }
                    }
                }
                if(findContract == false && Date.valueOf(caseItem.CreatedDate).daysBetween(Date.valueOf(system.today()))>=30){
                    caseitem.Status='Closed';
                    caseItem.Phase__c='Chiuso';
                    toAnnul.add(caseitem);
                }
            }
            system.debug('@@@ before dml operation');
            update toAnnul;
            insert newActivityToInsert;
        }catch(exception e){
            system.debug(e);
        }
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