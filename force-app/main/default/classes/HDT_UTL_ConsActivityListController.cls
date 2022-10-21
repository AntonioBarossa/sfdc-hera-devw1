@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing class HDT_UTL_ConsActivityListController {

    public static Object startRequestHelper(String type, String requestObj) {

        System.debug(LoggingLevel.DEBUG, '>>> type > ' + type);
        System.debug(LoggingLevel.DEBUG, '>>> requestObj > ' + requestObj);
        HDT_QR_Contract qrContract = new HDT_QR_Contract();

        String httpBody = '';

        List<HDT_AccountDataEnrichment__mdt> enrichmentbMetadataList;
        enrichmentbMetadataList = HDT_QR_AccountDataEnrichment.getAccountDataEnrichment(enrichmentbMetadataList, type);
 
        if(enrichmentbMetadataList.size()==0){
            throw new AuraHandledException('No enrichment Metadata!');
        }

        JSONGenerator gen = JSON.createGenerator(true);        
        gen.writeStartObject();
        gen.writeFieldName('request');
        gen.writeObject(requestObj);
        gen.writeEndObject();
        httpBody = gen.getAsString();

        System.debug(LoggingLevel.DEBUG, '>>> httpBody: ' + httpBody);

        // Create continuation. Argument is timeout in seconds.
        Continuation con = new Continuation(40);
        // Set callback method
        con.continuationMethod = 'processResponse';
        // Set state
        con.state = type;
        // Create callout request
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint(enrichmentbMetadataList[0].Credential__c);

        req.setHeader('Content-Type', 'application/json');
        req.setbody(httpBody);
        req.setTimeout(120000);

        System.debug(LoggingLevel.DEBUG, '>>> ' + String.valueOf(req));

        // Add callout request to continuation
        con.addHttpRequest(req);
        // Return the continuation
        return con;
    }

    public static Object processResponseHelper(List<String> labels, Object state){
        HttpResponse response = Continuation.getResponse(labels[0]);
        System.debug('>>> response.getBody ' + response.getBody());
        return response.getBody();
    }

}