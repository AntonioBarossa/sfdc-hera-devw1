public with sharing class HDT_WS_SelfReadingsIntegrationAdapter implements HDT_UTL_SapIntegrationInterface {
    /*
    @Author:        Francesco Vitiello
    CreatedDate:    21/10/2021
    Reason: Avoid Debug Statements
    */
    @SuppressWarnings('PMD.AvoidDebugStatements')
    public HDT_WRP_GenericSapIntegration submitRequest(HDT_WRP_GenericSapIntegration inputParameters) {
        inputParameters = HDT_SRV_SelfReadings.generateJson(inputParameters);
        if(inputParameters.requestBody != null){
            System.debug(LoggingLevel.DEBUG, 'request body: ' + inputParameters.requestBody);
            HttpRequest req = new HttpRequest();
            req.setEndpoint(inputParameters.namedCredential);
            req.setMethod('POST');
            req.setBody(inputParameters.requestBody);
            req.setTimeout(120000);
            req.setHeader('Content-Type','application/json');
            Http http = new Http();
            HTTPResponse res = http.send(req);
    
            inputParameters.responseBody = res.getBody();
            inputParameters.responseCode = res.getStatusCode();
            inputParameters.responseStatus = res.getStatus();
        }
        return inputParameters;
    }
}