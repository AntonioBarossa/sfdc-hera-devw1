@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing class HDT_SRV_PracticesView {

    public static HDT_WRP_Practices.HDT_WRP_ReturnMetadataObj getTableConfigHelper(String recordId, String type, HDT_WRP_Practices.HDT_WRP_ReturnMetadataObj retObj){
        
        retObj = new HDT_WRP_Practices.HDT_WRP_ReturnMetadataObj();
        retObj.tables = new List<HDT_WRP_Practices.HDT_WRP_TableMetadata>();
        
        try {

            List<HDT_AccountDataEnrichment__mdt> enrichmentbMetadataList;
            enrichmentbMetadataList = HDT_QR_AccountDataEnrichment.getAccountDataEnrichment(enrichmentbMetadataList, type);

            if(enrichmentbMetadataList.size()==0){
                retObj.success = false;
                retObj.message = 'No metadata found';
                return retObj;
            }

            retObj.tables = (List<HDT_WRP_Practices.HDT_WRP_TableMetadata>)JSON.deserialize(enrichmentbMetadataList[0].ColumnData__c, List<HDT_WRP_Practices.HDT_WRP_TableMetadata>.class);

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

        System.debug(LoggingLevel.DEBUG, '>>> recordId > ' + recordId);

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
        con.continuationMethod = 'processResponse';
        con.state = 'HDT_UTL_VasPractices';

        // Create callout request
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
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

        Type t = Type.forName(String.valueOf(state));
        HDT_UTL_PracticesSupport support = (HDT_UTL_PracticesSupport)t.newInstance();
        support.execute(response.getBody());

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