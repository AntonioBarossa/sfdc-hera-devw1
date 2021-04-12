public inherited sharing class HDT_WS_GenericSapIntegrationAdapter implements HDT_UTL_SapIntegrationInterface {
   public HDT_WRP_GenericSapIntegration submitRequest(HDT_WRP_GenericSapIntegration inputParameters){
        inputParameters = HDT_SRV_GenerateJsonSAPFacade.generateJSON(inputParameters);
        HttpRequest req = new HttpRequest();
        req.setEndpoint('Callout:'+inputParameters.namedCredential);
        req.setMethod('POST');
        req.setBody(inputParameters.requestBody);
        Http http = new Http();
        HTTPResponse res = http.send(req);

        inputParameters.responseBody = res.getBody();
        inputParameters.responseCode = res.getStatusCode();
        inputParameters.responseStatus = res.getStatus();
        return inputParameters;
   }
}