@RestResource(urlMapping='/SelfReadingsInboundService/*')
global with sharing class HDT_WS_SelfReadings {
    
    @HttpPost
    global static void doPost() {

        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        HDT_WRP_SelfReadings.HDT_WRP_SelfReadingsResponse responseWrap = new HDT_WRP_SelfReadings.HDT_WRP_SelfReadingsResponse();

        response.statusCode = 201;

        try {
            String requestBody = request.requestBody.toString();
            HDT_WRP_SelfReadings.HDT_WRP_SelfReadingsRequest requestWrap = (HDT_WRP_SelfReadings.HDT_WRP_SelfReadingsRequest) JSON.deserialize(requestBody, HDT_WRP_SelfReadings.HDT_WRP_SelfReadingsRequest.class);
            try {
                HDT_WRP_SelfReadings.HDT_WRP_SelfReadingsResponse outcomeResponse = handleRequest(requestWrap);
                responseWrap.outcome = 'OK';
                responseWrap.caseId = outcomeResponse.caseId;
                responseWrap.readingId = outcomeResponse.readingId;
                responseWrap.integrationId = requestWrap.integrationId;
            } catch (Exception e) {
                /*
                System.debug('Exception (ERROR 400): ' + e.getMessage());
                System.debug('STACK TRACE STRING: ' + e.getStackTraceString());
                */
                response.statusCode = 400;
                responseWrap.outcome = 'KO';
                responseWrap.outcomeDescription = e.getMessage();
            }
        } catch (Exception e) {
            /*
            System.debug('Exception (ERROR 500): ' + e.getMessage());
            System.debug('STACK TRACE STRING: ' + e.getStackTraceString());
            */
            response.statusCode = 500;
            responseWrap.outcome = 'KO';
            responseWrap.outcomeDescription = 'Error while parsing JSON body: ' + e.getMessage();
        } finally {
            response.responseBody = Blob.valueOf(JSON.serialize(responseWrap));
        }
    }

    static HDT_WRP_SelfReadings.HDT_WRP_SelfReadingsResponse handleRequest(HDT_WRP_SelfReadings.HDT_WRP_SelfReadingsRequest req) {
        if (String.isBlank(req.commodity)) {
            throw new HDT_UTL_HeraException('Required field missing: commodity');
        }

        if (String.isBlank(req.contractCode)) {
            throw new HDT_UTL_HeraException('Required field missing: contractCode');
        }

        if (req.readings == null) {
            throw new HDT_UTL_HeraException('Required child object missing: readings');
        }

        HDT_WRP_SelfReadings.HDT_WRP_SelfReadingsResponse res = new HDT_WRP_SelfReadings.HDT_WRP_SelfReadingsResponse();
        HDT_UTL_SelfReadings.upsertInboundSelfReading(req, res);

        return res;
    }
}