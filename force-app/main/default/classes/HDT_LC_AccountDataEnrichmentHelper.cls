public inherited sharing class HDT_LC_AccountDataEnrichmentHelper {

    public static HDT_WRP_AccountDataEnrichment.HDT_WRP_ReturnMetadataObj getTableConfigHelper(String recordId, String type, HDT_WRP_AccountDataEnrichment.HDT_WRP_ReturnMetadataObj retObj){
        
        retObj = new HDT_WRP_AccountDataEnrichment.HDT_WRP_ReturnMetadataObj();
        retObj.tables = new List<HDT_WRP_AccountDataEnrichment.HDT_WRP_TableMetadata>();
        
        try {

            List<HDT_AccountDataEnrichment__mdt> enrichmentbMetadataList;
            enrichmentbMetadataList = HDT_QR_AccountDataEnrichment.getAccountDataEnrichment(enrichmentbMetadataList, type);

            if(enrichmentbMetadataList.size()==0){
                retObj.success = false;
                retObj.message = 'No metadata found';
                return retObj;
            }

            retObj.tables = (List<HDT_WRP_AccountDataEnrichment.HDT_WRP_TableMetadata>)JSON.deserialize(enrichmentbMetadataList[0].ColumnData__c, List<HDT_WRP_AccountDataEnrichment.HDT_WRP_TableMetadata>.class);

            if(retObj.tables.size()==0){
                retObj.success = false;
                retObj.message = 'Something goes wrong converting metadata';
                return retObj;
            }

            retObj.success = true;

        } catch (Exception e) {
            retObj.success = false;
            retObj.message = 'ERROR > ' + e.getMessage() + '; at line [' + String.valueOf(e.getLineNumber()) + ']';
        }

        return retObj;
    }

    public static Object startRequestHelper(String recordId, String type) {

        System.debug('>>> recordId > ' + recordId);

        String httpBody = '';

        List<HDT_AccountDataEnrichment__mdt> enrichmentbMetadataList;
        enrichmentbMetadataList = HDT_QR_AccountDataEnrichment.getAccountDataEnrichment(enrichmentbMetadataList, type);

        if(enrichmentbMetadataList.size()==0){
            throw new AuraHandledException('No enrichment Metadata!');
        }

        List<Account> accList;
        accList = HDT_QR_AccountDataEnrichment.getAccountRecords(accList, recordId);

        if(accList.size() == 0 || String.isEmpty(accList[0].CustomerCode__c)){
            throw new AuraHandledException('No Customer Code!');
        }

        httpBody = '{"bp": "' + accList[0].CustomerCode__c + '"}';

        // Create continuation. Argument is timeout in seconds.
        Continuation con = new Continuation(40);
        // Set callback method
        con.continuationMethod = 'processResponse';
        // Set state
        con.state = type;
        // Create callout request
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        
        if(enrichmentbMetadataList[0].UseMock__c){
/*             req.setEndpoint('https://monted-dev-ed.my.salesforce.com/services/apexrest/' + type);
            req.setHeader('Authorization', 'Bearer ' + Label.MockSessionId);
            switch on type {
                when 'cmor' {
                    httpBody = '{"bp": "1001475349"}';
                }
                when 'raiFee' {
                    httpBody = '{"bp": "1001635149"}';
                }
                when 'socialBonus' {
                    httpBody = '{"bp": "1001803014"}';
                }
            } */
        } else {
            req.setEndpoint(enrichmentbMetadataList[0].Credential__c);
            req.setHeader('Authorization', enrichmentbMetadataList[0].Authorization__c);
        }

        req.setHeader('Content-Type', 'application/json');
        req.setbody(httpBody);
        req.setTimeout(120000);
        // Add callout request to continuation
        con.addHttpRequest(req);
        // Return the continuation
        return con;
    }

    public static Object processResponseHelper(List<String> labels, Object state){
        HttpResponse response = Continuation.getResponse(labels[0]);
        
        Integer statusCode = response.getStatusCode();
        return response.getBody();
    }

    //public static Object processResponseHelper(List<String> labels, Object state){
    //    HttpResponse response = Continuation.getResponse(labels[0]);
    //    
    //    Integer statusCode = response.getStatusCode();
    //    if (statusCode == 200) {
    //        return response.getBody();
    //    } else if(statusCode >= 2000) {
    //        throw new AuraHandledException('Continuation Error: ' + statusCode + ' - ' + response.getBody());
    //    } else {
    //        throw new AuraHandledException(response.getBody());
    //    }
    //}

}