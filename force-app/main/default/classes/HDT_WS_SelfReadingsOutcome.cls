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
            System.debug('Exception: ' + e.getMessage());
            response.statusCode = 500;
            responseWrap.outcome = 'KO';
            responseWrap.outcomeDescription = 'Error while parsing JSON body: ' + e.getMessage();
        } finally {
            response.responseBody = Blob.valueOf(JSON.serialize(responseWrap));
        }
    }

    static HDT_WRP_SelfReadingsOutcome.HDT_WRP_SelfReadingsOutcomeResponse handleRequest(HDT_WRP_SelfReadingsOutcome.HDT_WRP_SelfReadingsOutcomeRequest req) {
        List<HDT_WRP_SelfReadingsOutcome.HDT_WRP_SelfReadingsOutcomeData> data = req.data;

        String objectName = 'wrts_prcgvr__ActivityTemplate__c';
        String queryStringKoMdm = 'Select Id from wrts_prcgvr__ActivityTemplate__c  where Name = \'Esito KO pre-MDM\'';
        String queryStringKoSap = 'Select Id from wrts_prcgvr__ActivityTemplate__c  where Name = \'Esito KO da SAP\'';
        List<SObject> templatesKoMdm = HDT_QR_GenericQuery.getGenericRecords(queryStringKoMdm, objectName);
        List<SObject> templatesKoSap = HDT_QR_GenericQuery.getGenericRecords(queryStringKoSap, objectName);
        wrts_prcgvr__ActivityTemplate__c templateKoMdm = new wrts_prcgvr__ActivityTemplate__c();
        wrts_prcgvr__ActivityTemplate__c templateKoSap = new wrts_prcgvr__ActivityTemplate__c();

        if(templatesKoMdm.size() > 0) {
            templateKoMdm = (wrts_prcgvr__ActivityTemplate__c) templatesKoMdm[0];
        }

        if(templatesKoSap.size() > 0) {
            templateKoSap = (wrts_prcgvr__ActivityTemplate__c) templatesKoSap[0];
        }

        List<Case> casesToUpdate = new List<Case>();
        List<wrts_prcgvr__Activity__c> activitiesToCreate = new List<wrts_prcgvr__Activity__c>();
        // TODO: verificare quanti record ci passa mulesoft per non sforare i limiti di sfdc.
        for (HDT_WRP_SelfReadingsOutcome.HDT_WRP_SelfReadingsOutcomeData outcomeData : data) {

            if (String.isBlank(outcomeData.caseId)) {
                continue;
            }

            Case caseToUpdate = new Case();
            caseToUpdate.Id = outcomeData.caseId;
            if (String.isNotBlank(outcomeData.activityType)) {
                if (outcomeData.activityType.equalsIgnoreCase('Esito OK da SAP')) {
                    caseToUpdate.Phase__c = 'Esito OK da SAP';
                } else if (outcomeData.activityType.equalsIgnoreCase('Esito KO da SAP')) {
                    caseToUpdate.Phase__c = 'Esito KO da SAP';
                } else if (outcomeData.activityType.equalsIgnoreCase('KO Pre-MDM')) {
                    caseToUpdate.Phase__c = 'Esito KO pre-MDM';
                }
            }

            if (String.isNotBlank(outcomeData.errorCode) || String.isNotBlank(outcomeData.errorDescription)) {
                switch on caseToUpdate.Phase__c {
                    when 'Esito KO da SAP' {
                        wrts_prcgvr__Activity__c activity = new wrts_prcgvr__Activity__c();
                        activity.wrts_prcgvr__ActivityTemplate__c = templateKoSap.Id;
                        activity.Case__c = caseToUpdate.Id;
                        activity.wrts_prcgvr__Description__c = outcomeData.errorDescription + ' ' + outcomeData.errorCode;
                        activitiesToCreate.add(activity);
                    }
                    when 'Esito KO pre-MDM' {
                        wrts_prcgvr__Activity__c activity = new wrts_prcgvr__Activity__c();
                        activity.wrts_prcgvr__ActivityTemplate__c = templateKoMdm.Id;
                        activity.Case__c = caseToUpdate.Id;
                        activity.wrts_prcgvr__Description__c = outcomeData.errorDescription + ' ' + outcomeData.errorCode;
                        activitiesToCreate.add(activity);
                    }
                }
            }

            casesToUpdate.add(caseToUpdate);
        }

        // Deleghiamo le DML ad un queueable per non fare andare in timeout Mulesoft.
        System.enqueueJob(new HDT_QBL_SelfReadingsOutcome(casesToUpdate, activitiesToCreate));

        HDT_WRP_SelfReadingsOutcome.HDT_WRP_SelfReadingsOutcomeResponse res = new HDT_WRP_SelfReadingsOutcome.HDT_WRP_SelfReadingsOutcomeResponse();
        if (casesToUpdate.isEmpty() && activitiesToCreate.isEmpty()) {
            res.outcomeDescription = 'No DML operation performed.';
        }

        return res;
    }
}