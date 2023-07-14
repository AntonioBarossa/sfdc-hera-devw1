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
        List<SelfReadingOutcomeRequest__c> selfReadingOutcomeRequestList = new List<SelfReadingOutcomeRequest__c>();

        for (HDT_WRP_SelfReadingsOutcome.HDT_WRP_SelfReadingsOutcomeData outcomeData : data) {
            //if istanceOf Id
            if (String.isBlank(outcomeData.caseId) || !(outcomeData.caseId instanceof Id)) {
                continue; 
            }
            String errorCode = '';
            String errorDescription = '';
            if (outcomeData.activityType.equalsIgnoreCase('Esito KO da SAP') || outcomeData.activityType.equalsIgnoreCase('KO Pre-MDM')){
                errorCode = checkLength(outcomeData.errorCode,255);
                errorDescription = checkLength(outcomeData.errorDescription,255);
            }
            selfReadingOutcomeRequestList.add(
                new SelfReadingOutcomeRequest__c(
                    Case__c = outcomeData.caseId,
                    ErrorCode__c = errorCode,
                    ErrorDescription__c = errorDescription,
                    ActivityType__c = checkLength(outcomeData.activityType,255),
                    Request_Json__c = checkLength(JSON.serialize(outcomeData),500)
                )
            );
        }
        System.debug(LoggingLevel.DEBUG, 'handleRequest - selfReadingOutcomeRequestList size: ' + selfReadingOutcomeRequestList.size());
    
        HDT_WRP_SelfReadingsOutcome.HDT_WRP_SelfReadingsOutcomeResponse res = new HDT_WRP_SelfReadingsOutcome.HDT_WRP_SelfReadingsOutcomeResponse();
        if (selfReadingOutcomeRequestList.isEmpty()) {
            res.outcomeDescription = 'No DML operation performed.';
        }else if (SelfReadingOutcomeRequest__c.SObjectType.getDescribe().isCreateable()){
            Database.insert(selfReadingOutcomeRequestList, false);
            List<AsyncApexJob> selfReadingJob = [SELECT Id FROM AsyncApexJob WHERE ApexClass.Name = 'HDT_BA_HandleSelfReadingRequest' AND Status IN ('Queued','Processing','Preparing','Holding') WITH SECURITY_ENFORCED];
            if (selfReadingJob.isEmpty()){
                Database.executeBatch(new HDT_BA_HandleSelfReadingRequest(), 40);
            }
        }

        return res;
    }

    private static String checkLength(String item, Integer length){
        return String.isNotBlank(item) && item.length() > length ? item.substring(0,length-1) : item;
    }
}