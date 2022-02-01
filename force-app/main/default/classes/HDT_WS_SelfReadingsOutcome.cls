@RestResource(urlMapping='/SelfReadingsOutcomeInboundService/*')
global with sharing class HDT_WS_SelfReadingsOutcome {
    
    @HttpPost
    global static void doPost() {

        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        HDT_WRP_SelfReadingsOutcome.HDT_WRP_SelfReadingsOutcomeResponse responseWrap = new HDT_WRP_SelfReadingsOutcome.HDT_WRP_SelfReadingsOutcomeResponse();

        response.statusCode = 201;

        try {
            String requestBody = request.requestBody.toString();
            HDT_WRP_SelfReadingsOutcome.HDT_WRP_SelfReadingsOutcomeRequest requestWrap = (HDT_WRP_SelfReadingsOutcome.HDT_WRP_SelfReadingsOutcomeRequest) JSON.deserialize(requestBody, HDT_WRP_SelfReadingsOutcome.HDT_WRP_SelfReadingsOutcomeRequest.class);
            try {
                HDT_WRP_SelfReadingsOutcome.HDT_WRP_SelfReadingsOutcomeResponse outcomeResponse = handleRequest(requestWrap);
                responseWrap.outcome = 'OK';
                responseWrap.outcomeDescription = outcomeResponse.outcomeDescription;
            } catch (Exception e) {
                response.statusCode = 400;
                responseWrap.outcome = 'KO';
                responseWrap.outcomeDescription = e.getMessage();
            }
        } catch (Exception e) {
            //System.debug('Exception: ' + e.getMessage());
            response.statusCode = 500;
            responseWrap.outcome = 'KO';
            responseWrap.outcomeDescription = 'Error while parsing JSON body: ' + e.getMessage();
        } finally {
            response.responseBody = Blob.valueOf(JSON.serialize(responseWrap));
        }
    }

    /*
    @Author:        Francesco Vitiello
    CreatedDate:    21/10/2021
    Reason: Avoid Debug Statements
    */
    @SuppressWarnings('PMD.AvoidDebugStatements')
    static HDT_WRP_SelfReadingsOutcome.HDT_WRP_SelfReadingsOutcomeResponse handleRequest(HDT_WRP_SelfReadingsOutcome.HDT_WRP_SelfReadingsOutcomeRequest req) {
        
        System.debug(LoggingLevel.DEBUG, 'handleRequest - Req: ' + req);
        List<HDT_WRP_SelfReadingsOutcome.HDT_WRP_SelfReadingsOutcomeData> data = req.data;

        String objectName = 'wrts_prcgvr__ActivityTemplate__c';
        String queryStringKoMdm = 'Select Id from wrts_prcgvr__ActivityTemplate__c  where Name = \'CBS_AUT004__ESITO_KO_PRE-MDM\'';
        String queryStringKoSap = 'Select Id from wrts_prcgvr__ActivityTemplate__c  where Name = \'CBS_AUT002__ESITO_KO_DA_SAP\'';
        String queryStringKoGestioneManualeSap = 'Select Id from wrts_prcgvr__ActivityTemplate__c  where Name = \'Gestione Manuale SAP\'';
        List<SObject> templatesKoMdm = HDT_QR_GenericQuery.getGenericRecords(queryStringKoMdm, objectName);
        List<SObject> templatesKoSap = HDT_QR_GenericQuery.getGenericRecords(queryStringKoSap, objectName);
        List<SObject> templatesGestioneManualeSap = HDT_QR_GenericQuery.getGenericRecords(queryStringKoGestioneManualeSap, objectName);
        wrts_prcgvr__ActivityTemplate__c templateKoMdm = new wrts_prcgvr__ActivityTemplate__c();
        wrts_prcgvr__ActivityTemplate__c templateKoSap = new wrts_prcgvr__ActivityTemplate__c();
        wrts_prcgvr__ActivityTemplate__c templateGestioneManualeSap = new wrts_prcgvr__ActivityTemplate__c();

        if(templatesKoMdm.size() > 0) {
            templateKoMdm = (wrts_prcgvr__ActivityTemplate__c) templatesKoMdm[0];
        }

        if(templatesKoSap.size() > 0) {
            templateKoSap = (wrts_prcgvr__ActivityTemplate__c) templatesKoSap[0];
        }
        if(templatesGestioneManualeSap.size() > 0) {
            templateGestioneManualeSap = (wrts_prcgvr__ActivityTemplate__c) templatesGestioneManualeSap[0];
        }

        List<Case> casesToUpdate = new List<Case>();
        List<wrts_prcgvr__Activity__c> activitiesToCreate = new List<wrts_prcgvr__Activity__c>();

        Set<String> errorCodes = new Set<String>();
        Set<String> errorCodesDescriptionSet = new Set<String>();
        Set<Id> caseIdSet = new Set<Id>();
        for (HDT_WRP_SelfReadingsOutcome.HDT_WRP_SelfReadingsOutcomeData outcomeData : data) {
            if (String.isBlank(outcomeData.caseId)) {
                continue; 
            }
            caseIdSet.add(outcomeData.caseId);
            if (String.isNotBlank(outcomeData.activityType)) {
                if (outcomeData.activityType.equalsIgnoreCase('Esito KO da SAP') || outcomeData.activityType.equalsIgnoreCase('KO Pre-MDM')) {
                    errorCodes.add(outcomeData.errorCode);
                    if(String.isNotBlank(outcomeData.errorCode)){
                        errorCodesDescriptionSet.add(outcomeData.errorCode);
                    }else if(String.isNotBlank(outcomeData.errorDescription)) {
                        errorCodesDescriptionSet.add(outcomeData.errorDescription);
                    }
                }
            }
        }
        System.debug(LoggingLevel.DEBUG, 'handleRequest - errorCodes size: ' + errorCodes.size());
        System.debug(LoggingLevel.DEBUG, 'handleRequest - errorCodesDescriptionSet size: ' + errorCodesDescriptionSet.size());

        Map<String, Boolean> isAutomaticDiscardMap = HDT_UTL_SelfReadings.isAutomaticDiscard(errorCodesDescriptionSet);
        Map<Id, Boolean> isAutomaticDiscardCasesMap = new Map<Id,Boolean>();

        Map<Id,Case> mapCaseInAnnulato = new Map<Id,Case>([SELECT Id FROM Case WHERE Phase__c = 'Annullato' AND Id IN :caseIdSet]); 
        caseIdSet = null;
        // TODO: verificare quanti record ci passa mulesoft per non sforare i limiti di sfdc.
        Id actRecordTypeId;
        try {
            actRecordTypeId = Schema.SObjectType.wrts_prcgvr__Activity__c.getRecordTypeInfosByName().get('HDT_RT_Scarto').getRecordTypeId();
        } catch (Exception ex) {
            System.debug(LoggingLevel.DEBUG, 'Errore nella classe HDT_WS_SelfReadingsOutcome metodo handleRequest ' + ex.getMessage() + ' at line ' + ex.getLineNumber());
        }
        for (HDT_WRP_SelfReadingsOutcome.HDT_WRP_SelfReadingsOutcomeData outcomeData : data) {

            if (String.isBlank(outcomeData.caseId)) {
                continue;
            }

            Case caseToUpdate = new Case();
            caseToUpdate.Id = outcomeData.caseId;
            if (String.isNotBlank(outcomeData.activityType)) {
                if (outcomeData.activityType.equalsIgnoreCase('Esito OK da SAP') && !mapCaseInAnnulato.containsKey(outcomeData.caseId)) {
                    caseToUpdate.Phase__c = 'Esito OK da SAP';
                } else if (outcomeData.activityType.equalsIgnoreCase('Esito KO da SAP')) {
                    caseToUpdate.Phase__c = 'Esito KO da SAP';
                } else if (outcomeData.activityType.equalsIgnoreCase('KO Pre-MDM')) {
                    caseToUpdate.Phase__c = 'Esito KO pre-MDM';
                }
                
                if (mapCaseInAnnulato.containsKey(caseToUpdate.Id) && !'Esito OK da SAP'.equalsIgnoreCase(outcomeData.activityType)){
                    mapCaseInAnnulato.remove(caseToUpdate.Id);
                }
            }

            Boolean isAutomaticDiscard = false;
            if (String.isNotBlank(outcomeData.errorCode)) {
                try {
                    isAutomaticDiscard = isAutomaticDiscardMap.get(outcomeData.errorCode);
                } catch (Exception e) {
                    System.debug(LoggingLevel.DEBUG, 'Exception: ' + e.getMessage());
                    System.debug(LoggingLevel.DEBUG, 'Stacktrace: ' + e.getStackTraceString());
                }
            }else if(String.isNotBlank(outcomeData.errorDescription)){
                try {
                    isAutomaticDiscard = isAutomaticDiscardMap.get(outcomeData.errorDescription);
                } catch (Exception e) {
                    System.debug(LoggingLevel.DEBUG, 'Exception: ' + e.getMessage());
                    System.debug(LoggingLevel.DEBUG, 'Stacktrace: ' + e.getStackTraceString());
                }
            }
            
            if (isAutomaticDiscard) {
                System.debug(LoggingLevel.DEBUG, 'Entering isAutomaticDiscard');
                
                caseToUpdate.Status = 'Closed';
                String errorDescription = caseToUpdate.Phase__c; // Esito KO pre-MDM oppure Esito KO da SAP
                if (String.isNotBlank(outcomeData.errorDescription)) {
                    errorDescription += ' - ' + outcomeData.errorDescription;
                }
                caseToUpdate.Subject = errorDescription;  // tracciamo l'errore su Subject poichè Description potrebbe già contenere qualcosa e non possiamo permetterci di querare il case per andare in append.
            } else {
                System.debug(LoggingLevel.DEBUG, 'Entering NOT isAutomaticDiscard');
                
                // Creazione activity per successiva lavorazione dello scarto.
                String errorDescriptionAct = '';
                if(String.isNotBlank(outcomeData.errorDescription)){
                    errorDescriptionAct = outcomeData.errorDescription;
                }
                if(String.isNotBlank(outcomeData.errorCode)){
                    errorDescriptionAct = errorDescriptionAct + ' ' + outcomeData.errorCode;
                }
                System.debug(LoggingLevel.DEBUG, 'Switching on Case Phase: ' + caseToUpdate.Phase__c);

                switch on caseToUpdate.Phase__c {
                    when 'Esito KO da SAP' {
                        wrts_prcgvr__Activity__c activity = new wrts_prcgvr__Activity__c();
                        activity.wrts_prcgvr__ActivityTemplate__c = templateKoSap.Id;
                        activity.Case__c = caseToUpdate.Id;
                        activity.wrts_prcgvr__Description__c = outcomeData.errorDescription + ' ' + outcomeData.errorCode;
                        activity.Type__c = 'Esito KO da SAP';
                        activity.DiscardCategory__c = 'Scarto complesso';
                        if(String.isnotblank(actRecordTypeId)){
                            activity.RecordTypeId=actRecordTypeId;
                        }
                        activitiesToCreate.add(activity);
                    }
                    when 'Esito KO pre-MDM' {
                        wrts_prcgvr__Activity__c activity = new wrts_prcgvr__Activity__c();
                        activity.wrts_prcgvr__ActivityTemplate__c = templateKoMdm.Id;
                        activity.Case__c = caseToUpdate.Id;
                        activity.wrts_prcgvr__Description__c = outcomeData.errorDescription + ' ' + outcomeData.errorCode;
                        activity.Type__c = 'Esito KO pre-MDM';
                        activity.DiscardCategory__c = 'Scarto complesso';
                        if(String.isnotblank(actRecordTypeId)){
                            activity.RecordTypeId=actRecordTypeId;
                        }
                        activitiesToCreate.add(activity);
                    }
                }
            }

            /**
             * I case con Phase "annullato" pur ricevendo un 'Esito OK da SAP' non aggiornano la Phase.
             * Tuttavia se il campo isAutomiticDiscard == true allora vengono aggiunti alla lista perchè vengono aggiornati alcuni campi del case.
             */
            if (isAutomaticDiscard || !mapCaseInAnnulato.containsKey(caseToUpdate.Id)){
                isAutomaticDiscardCasesMap.put(caseToUpdate.Id, isAutomaticDiscard);
                casesToUpdate.add(caseToUpdate);
            }
        }

        for (Id caseId : mapCaseInAnnulato.keySet()){
            wrts_prcgvr__Activity__c activity = new wrts_prcgvr__Activity__c();
            activity.wrts_prcgvr__ActivityTemplate__c = templateGestioneManualeSAP.Id;
            activity.Case__c = caseId;
            activity.wrts_prcgvr__Description__c = 'Gestione Manuale SAP';
            activity.Type__c = 'Gestione Manuale SAP';
            activitiesToCreate.add(activity);
        }

        // Deleghiamo le DML ad un queueable per non fare andare in timeout Mulesoft.
        System.enqueueJob(new HDT_QBL_SelfReadingsOutcome(casesToUpdate, activitiesToCreate, isAutomaticDiscardCasesMap));

        HDT_WRP_SelfReadingsOutcome.HDT_WRP_SelfReadingsOutcomeResponse res = new HDT_WRP_SelfReadingsOutcome.HDT_WRP_SelfReadingsOutcomeResponse();
        if (casesToUpdate.isEmpty() && activitiesToCreate.isEmpty()) {
            res.outcomeDescription = 'No DML operation performed.';
        }

        return res;
    }
}