@SuppressWarnings('PMD.AvoidDebugStatements')
public with sharing class HDT_BA_HandleSelfReadingRequest implements Database.Batchable<SObject>{
    private wrts_prcgvr__ActivityTemplate__c templateKoMdm;
	private wrts_prcgvr__ActivityTemplate__c templateKoSap;
	private wrts_prcgvr__ActivityTemplate__c templateGestioneManualeSap;
    private Set<Id> casesWorked;
    private Id actRecordTypeId;
    
    public HDT_BA_HandleSelfReadingRequest(){
        String objectName = 'wrts_prcgvr__ActivityTemplate__c';
        String queryStringKoMdm = 'Select Id from wrts_prcgvr__ActivityTemplate__c  where Name = \'CBS_AUT004__ESITO_KO_PRE-MDM\'';
        String queryStringKoSap = 'Select Id from wrts_prcgvr__ActivityTemplate__c  where Name = \'CBS_AUT002__ESITO_KO_DA_SAP\'';
        String queryStringKoGestioneManualeSap = 'Select Id from wrts_prcgvr__ActivityTemplate__c  where Name = \'Gestione Manuale SAP\'';
        List<SObject> templatesKoMdm = HDT_QR_GenericQuery.getGenericRecords(queryStringKoMdm, objectName);
        List<SObject> templatesKoSap = HDT_QR_GenericQuery.getGenericRecords(queryStringKoSap, objectName);
        List<SObject> templatesGestioneManualeSap = HDT_QR_GenericQuery.getGenericRecords(queryStringKoGestioneManualeSap, objectName);
        this.templateKoMdm = new wrts_prcgvr__ActivityTemplate__c();
        this.templateKoSap = new wrts_prcgvr__ActivityTemplate__c();
        this.templateGestioneManualeSap = new wrts_prcgvr__ActivityTemplate__c();
        if(templatesKoMdm.size() > 0) {
            this.templateKoMdm = (wrts_prcgvr__ActivityTemplate__c) templatesKoMdm[0];
        }

        if(templatesKoSap.size() > 0) {
            this.templateKoSap = (wrts_prcgvr__ActivityTemplate__c) templatesKoSap[0];
        }
        if(templatesGestioneManualeSap.size() > 0) {
            this.templateGestioneManualeSap = (wrts_prcgvr__ActivityTemplate__c) templatesGestioneManualeSap[0];
        }
        this.actRecordTypeId = Schema.SObjectType.wrts_prcgvr__Activity__c.getRecordTypeInfosByDeveloperName().get('HDT_RT_Scarto').getRecordTypeId();
        this.casesWorked = new Set<Id>();
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id, Case__c, ErrorDescription__c, ErrorCode__c, ActivityType__c, Request_Json__c,Case__r.Phase__c, Case__r.ServicePoint__r.CommoditySector__c,Case__r.Id, Status__c FROM SelfReadingOutcomeRequest__c WHERE Status__c =\'PENDING\' ORDER BY CreatedDate DESC');
    }

    public void execute(Database.BatchableContext context, List<SObject> scope){
        Map<Id,List<String>> errorMessageRequestMap = new Map<Id,List<String>>();
        Map<String,List<Case>> phaseToCaseMap = new Map<String,List<Case>>();
        Map<Id,wrts_prcgvr__Activity__c> activitiesToCreateMap = new Map<Id,wrts_prcgvr__Activity__c>();
        List<SelfReadingOutcomeRequest__c> requestToUpdate = new List<SelfReadingOutcomeRequest__c>();
        List<Id> requestToDelete = new List<Id>();
        Set<String> errorCodesDescriptionSet = new Set<String>();
        Map<Id,Case> mapCaseInAnnulato = new Map<Id,Case>(); 
        Map<Id,String> mapCaseCommodity = new Map<Id,String>();
        for (SelfReadingOutcomeRequest__c selfReadingRequest : (List<SelfReadingOutcomeRequest__c>) scope) {
            try{
                Case c = selfReadingRequest.Case__r;
                if (this.casesWorked.contains(selfReadingRequest.Case__c)){
                    selfReadingRequest.Status__c = 'ERROR';
                    selfReadingRequest.StatusDescription__c = 'In presenza di più esiti è stato lavorato l\'ultimo inviato.';
                    requestToUpdate.add(selfReadingRequest);
                    continue;
                }
                this.casesWorked.add(selfReadingRequest.Case__c);
                if ('Annullato'.equalsIgnoreCase(c.Phase__c)){
                    mapCaseInAnnulato.put(c.Id,c);
                }
                if (String.isNotBlank(selfReadingRequest.ActivityType__c) &&(selfReadingRequest.ActivityType__c.equalsIgnoreCase('Esito KO da SAP') || selfReadingRequest.ActivityType__c.equalsIgnoreCase('KO Pre-MDM'))) {
                    if (c.ServicePoint__r != null && String.isNotBlank(c.ServicePoint__r.CommoditySector__c)){
                        mapCaseCommodity.put(c.Id, (c.ServicePoint__r.CommoditySector__c));
                    }
                    if(String.isNotBlank(selfReadingRequest.ErrorCode__c)){
                        errorCodesDescriptionSet.add(selfReadingRequest.ErrorCode__c);
                    }else if(String.isNotBlank(selfReadingRequest.ErrorDescription__c)) {
                        errorCodesDescriptionSet.add(HDT_UTL_Accents.removeDiacritics(selfReadingRequest.ErrorDescription__c));
                    }
                }
            }catch(Exception e){
                selfReadingRequest.Status__c = 'ERROR';
                selfReadingRequest.StatusDescription__c = e.getMessage();
                requestToUpdate.add(selfReadingRequest);
            }
            
        }
        
        
        System.debug(LoggingLevel.DEBUG, 'handleRequest - errorCodesDescriptionSet size: ' + errorCodesDescriptionSet.size());

        Map<String, DiscardAnnullmentRule__c> isAutomaticDiscardMap = HDT_UTL_SelfReadings.isAutomaticDiscard(errorCodesDescriptionSet);
        Map<Id, Boolean> isAutomaticDiscardCasesMap = new Map<Id,Boolean>();
        
        for (SelfReadingOutcomeRequest__c selfReadingRequest : (List<SelfReadingOutcomeRequest__c>) scope) {
            if ('ERROR'.equalsIgnoreCase(selfReadingRequest.Status__c)){
                continue;
            }
            try{
                Case caseToUpdate = new Case();
                caseToUpdate.Id = selfReadingRequest.Case__c;
                if (String.isNotBlank(selfReadingRequest.ActivityType__c)) {
                    if (selfReadingRequest.ActivityType__c.equalsIgnoreCase('Esito OK da SAP') && !mapCaseInAnnulato.containsKey(selfReadingRequest.Case__c)) {
                        caseToUpdate.Phase__c = 'Esito OK da SAP';
                    } else if (selfReadingRequest.ActivityType__c.equalsIgnoreCase('Esito KO da SAP')) {
                        caseToUpdate.Phase__c = 'Esito KO da SAP';
                    } else if (selfReadingRequest.ActivityType__c.equalsIgnoreCase('KO Pre-MDM')) {
                        caseToUpdate.Phase__c = 'Esito KO pre-MDM';
                    }else if(selfReadingRequest.ActivityType__c.equalsIgnoreCase('Autolettura Forzata')){
                        caseToUpdate.Phase__c = 'Esito OK da SAP';
                        caseToUpdate.Description = 'Autolettura Forzata';
                    }
                    
                    if (mapCaseInAnnulato.containsKey(caseToUpdate.Id) && !'Esito OK da SAP'.equalsIgnoreCase(selfReadingRequest.ActivityType__c)){
                        mapCaseInAnnulato.remove(caseToUpdate.Id);
                    }
                }

                DiscardAnnullmentRule__c dar;
                if (String.isNotBlank(selfReadingRequest.ErrorCode__c)) {
                    try {
                        dar = isAutomaticDiscardMap.get(selfReadingRequest.ErrorCode__c);
                    } catch (Exception e) {
                        System.debug(LoggingLevel.DEBUG, 'Exception: ' + e.getMessage());
                        System.debug(LoggingLevel.DEBUG, 'Stacktrace: ' + e.getStackTraceString());
                    }
                }else if(String.isNotBlank(selfReadingRequest.ErrorDescription__c)){
                    try {
                        dar = isAutomaticDiscardMap.get(HDT_UTL_Accents.removeDiacritics(selfReadingRequest.ErrorDescription__c).toLowerCase());
                    } catch (Exception e) {
                        System.debug(LoggingLevel.DEBUG, 'Exception: ' + e.getMessage());
                        System.debug(LoggingLevel.DEBUG, 'Stacktrace: ' + e.getStackTraceString());
                    }
                }
                if(dar != null) {
                    caseToUpdate.abnormalReading__c = dar.DiscardReason__c;
                } 
                Boolean isAutomaticDiscard = (dar != null && dar.IsActive__c && dar.ActivityType__c.equalsIgnoreCase(caseToUpdate.Phase__c) && (String.isBlank(dar.ControllingCommodity__c)  || dar.ControllingCommodity__c.equalsIgnoreCase(mapCaseCommodity.get(caseToUpdate.Id))));
                
                if (isAutomaticDiscard) {
                    System.debug(LoggingLevel.DEBUG, 'Entering isAutomaticDiscard');
                    
                    caseToUpdate.Status = 'Closed';
                    String errorDescription = caseToUpdate.Phase__c; // Esito KO pre-MDM oppure Esito KO da SAP
                    if (String.isNotBlank(selfReadingRequest.ErrorDescription__c)) {
                        errorDescription += ' - ' + selfReadingRequest.ErrorDescription__c;
                    }
                    caseToUpdate.Subject = errorDescription;  // tracciamo l'errore su Subject poichè Description potrebbe già contenere qualcosa e non possiamo permetterci di querare il case per andare in append.
                    //caseToUpdate.Phase__c = 'Annullato'; // skippiamo le fasi Esito KO pre-MDM / Esito KO da SAP poichè non possiamo permetterci un doppio update di fase.
                } else {
                    System.debug(LoggingLevel.DEBUG, 'Entering NOT isAutomaticDiscard');
                    
                    // Creazione activity per successiva lavorazione dello scarto.
                    String errorDescriptionAct = '';
                    if(String.isNotBlank(selfReadingRequest.ErrorDescription__c)){
                        errorDescriptionAct = selfReadingRequest.ErrorDescription__c;
                    }
                    if(String.isNotBlank(selfReadingRequest.ErrorCode__c)){
                        errorDescriptionAct = errorDescriptionAct + ' ' + selfReadingRequest.ErrorCode__c;
                    }
                    System.debug(LoggingLevel.DEBUG, 'Switching on Case Phase: ' + caseToUpdate.Phase__c);

                    switch on caseToUpdate.Phase__c {
                        when 'Esito KO da SAP' {
                            wrts_prcgvr__Activity__c activity = new wrts_prcgvr__Activity__c();
                            activity.wrts_prcgvr__ActivityTemplate__c = this.templateKoSap.Id;
                            activity.Case__c = caseToUpdate.Id;
                            activity.wrts_prcgvr__Description__c = errorDescriptionAct;
                            activity.Type__c = 'Esito KO da SAP';
                            activity.DiscardCategory__c = 'Scarto complesso';
                            if(String.isnotblank(actRecordTypeId)){
                                activity.RecordTypeId=actRecordTypeId;
                            }
                            activitiesToCreateMap.put(caseToUpdate.Id, activity);
                        }
                        when 'Esito KO pre-MDM' {
                            wrts_prcgvr__Activity__c activity = new wrts_prcgvr__Activity__c();
                            activity.wrts_prcgvr__ActivityTemplate__c = this.templateKoMdm.Id;
                            activity.Case__c = caseToUpdate.Id;
                            activity.wrts_prcgvr__Description__c = errorDescriptionAct;
                            activity.Type__c = 'Esito KO pre-MDM';
                            activity.DiscardCategory__c = 'Scarto complesso';
                            if(String.isnotblank(actRecordTypeId)){
                                activity.RecordTypeId=actRecordTypeId;
                            }
                            activitiesToCreateMap.put(caseToUpdate.Id, activity);
                        }
                    }
                }

                /**
                 * I case con Phase "annullato" pur ricevendo un 'Esito OK da SAP' non aggiornano la Phase.
                 * Tuttavia se il campo isAutomiticDiscard == true allora vengono aggiunti alla lista perchè vengono aggiornati alcuni campi del case.
                 */
                if (isAutomaticDiscard || !mapCaseInAnnulato.containsKey(caseToUpdate.Id)){
                    isAutomaticDiscardCasesMap.put(caseToUpdate.Id, isAutomaticDiscard);
                    this.orderCaseByPhase(caseToUpdate, phaseToCaseMap);
                }
            }catch (Exception e){
                selfReadingRequest.Status__c = 'ERROR';
                selfReadingRequest.StatusDescription__c = e.getMessage();
                requestToUpdate.add(selfReadingRequest);
            }
        }

        for (Id caseId : mapCaseInAnnulato.keySet()){
            wrts_prcgvr__Activity__c activity = new wrts_prcgvr__Activity__c();
            activity.wrts_prcgvr__ActivityTemplate__c = this.templateGestioneManualeSAP.Id;
            activity.Case__c = caseId;
            activity.wrts_prcgvr__Description__c = 'Gestione Manuale SAP';
            activity.Type__c = 'Gestione Manuale SAP';
            activitiesToCreateMap.put(caseId, activity);
        }

        List<Case> automaticDiscard = new List<Case>();

        this.updateCaseList(phaseToCaseMap.get('Esito OK da SAP'), isAutomaticDiscardCasesMap, automaticDiscard, errorMessageRequestMap);
        this.updateCaseList(phaseToCaseMap.get('Esito KO pre-MDM'), isAutomaticDiscardCasesMap, automaticDiscard, errorMessageRequestMap);
        this.updateCaseList(phaseToCaseMap.get('Esito KO da SAP'), isAutomaticDiscardCasesMap, automaticDiscard, errorMessageRequestMap);
        
        if (!automaticDiscard.isEmpty()){
            List<Database.SaveResult> dsList = Database.update(automaticDiscard, false);
            for (Database.SaveResult ds : dsList){
                if (!ds.isSuccess()){
                    this.setErrorMap(errorMessageRequestMap, ds.getId(), ds.getErrors());
                }
            }
        }

        if (!activitiesToCreateMap.isEmpty()){
            Integer index = 0;
            for (Id caseId : errorMessageRequestMap.keySet()){
                if (activitiesToCreateMap.containsKey(caseId)){
                    activitiesToCreateMap.remove(caseId);
                }
            }
            List<wrts_prcgvr__Activity__c> activitiesToCreate = activitiesToCreateMap.values();
            List<Database.SaveResult> dsList = Database.insert(activitiesToCreate, false);
            for (Database.SaveResult ds : dsList){
                if (!ds.isSuccess()){
                    this.setErrorMap(errorMessageRequestMap, activitiesToCreate.get(index).Case__c, ds.getErrors());
                }
                index++;
            }
        }

        for (SelfReadingOutcomeRequest__c selfReadingRequest : (List<SelfReadingOutcomeRequest__c>) scope) {
            if ('ERROR'.equalsIgnoreCase(selfReadingRequest.Status__c)){
                continue;
            }
            if (errorMessageRequestMap.containsKey(selfReadingRequest.Case__c)){
                String errorMessage = String.join(errorMessageRequestMap.get(selfReadingRequest.Case__c), ' \n');
                selfReadingRequest.StatusDescription__c = errorMessage.length() > 255 ? errorMessage.substring(0,254) : errorMessage;
                selfReadingRequest.Status__c = 'ERROR';
                requestToUpdate.add(selfReadingRequest);
            }else{
                requestToDelete.add(selfReadingRequest.Id);
            }
        }

        if (!requestToDelete.isEmpty()){
            List<Database.DeleteResult> dsList = Database.delete(requestToDelete, false);
            for (Database.DeleteResult ds :dsList){
                if(!ds.isSuccess()){
                    requestToUpdate.add(
                        new SelfReadingOutcomeRequest__c(
                            Id = ds.getId(),
                            Status__c = 'ERROR',
                            StatusDescription__c = 'Error Delete'
                        )
                    );
                }
            }
        }
        if (!requestToUpdate.isEmpty()){
            List<Database.SaveResult> dsList = Database.update(requestToUpdate, false);
            for (Database.SaveResult ds : dsList){
                if(!ds.isSuccess()){
                    for (Database.Error error : ds.getErrors()){
                        System.debug(LoggingLevel.ERROR, 'Id : ' + ds.getId()+ ' Errore: ' + error.getMessage());
                    }
                }
            }
        }
    }

    private void setErrorMap(Map<Id,List<String>> errorMessageRequestMap,Id caseId, List<Database.Error> errors){
        if (!errorMessageRequestMap.containsKey(caseId)){
            errorMessageRequestMap.put(caseId,new List<String>());
        }
        for (Database.Error error : errors){
            if (String.isNotBlank(error.getMessage())){
                errorMessageRequestMap.get(caseId).add(error.getMessage());
            }
        }
    }

    private void orderCaseByPhase(Case caseToUpdate, Map<String,List<Case>> phaseToCaseMap){
        if (caseToUpdate == null){
            return;
        }
        if (!phaseToCaseMap.containsKey(caseToUpdate.Phase__c)){
            phaseToCaseMap.put(caseToUpdate.Phase__c, new List<Case>());
        }
        phaseToCaseMap.get(caseToUpdate.Phase__c).add(caseToUpdate);
    }

    private void updateCaseList(List<Case> casesToUpdate, Map<Id,Boolean> isAutomaticDiscardCasesMap,List<Case> automaticDiscard,Map<Id,List<String>> errorMessageRequestMap ){
        if (casesToUpdate != null && !casesToUpdate.isEmpty()){
            List<Database.SaveResult> dsList = Database.update(casesToUpdate, false);
            for (Database.SaveResult ds : dsList){
                if (ds.isSuccess() && isAutomaticDiscardCasesMap.containsKey(ds.getId()) && isAutomaticDiscardCasesMap.get(ds.getId())){
                    automaticDiscard.add(
                        new Case(
                            Id = ds.getId(),
                            Phase__c = 'Annullato'
                        )
                    );
                }else if (!ds.isSuccess()){
                    this.setErrorMap(errorMessageRequestMap, ds.getId(), ds.getErrors());
                }
            }
        }
    }

    public void finish(Database.BatchableContext context) {
        System.debug(LoggingLevel.DEBUG, 'HDT_BA_HandleSelfReadingRequest - finish method');
    }
}
