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

    private static HttpRequest setHttpRequest(HDT_AccountDataEnrichment__mdt metadataRecord, HttpRequest req, Map<String, String> headerMap){
        // Create callout request
        req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint(metadataRecord.Credential__c);

        if(metadataRecord.UseMock__c){
            req.setHeader('Authorization', metadataRecord.Authorization__c);
        }

        req.setHeader('Content-Type', 'application/json');

        for(String keyMap : headerMap.keySet()){
            req.setHeader(keyMap, headerMap.get(keyMap));
        }
        
        req.setTimeout(120000);
        return req;
    } 

    public static Object startRequestHelper(String recordId, String type) {

        System.debug(LoggingLevel.DEBUG, '>>> recordId > ' + recordId);
        Map<String, String> headerMap = new Map<String, String>();

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

        headerMap.put('value', accList[0].CustomerCode__c);

        // Create continuation. Argument is timeout in seconds.
        Continuation con = new Continuation(40);
        con.continuationMethod = 'processResponse';
        con.state = enrichmentbMetadataList[0].ApexClass__c;

        HttpRequest req;
        req = setHttpRequest(enrichmentbMetadataList[0], req, headerMap);

        System.debug(LoggingLevel.DEBUG, '>>> ' + String.valueOf(req));

        // Add callout request to continuation
        con.addHttpRequest(req);
        // Return the continuation
        return con;
    }

    public static Object processResponseHelper(List<String> labels, Object state){
        HttpResponse response = Continuation.getResponse(labels[0]);

        Map<Integer, String> errorMap = new Map<Integer, String>();
        errorMap.put(2000, 'The timeout was reached, and the server didn’t get a chance to respond');
        errorMap.put(2001, 'There was a connection failure');
        errorMap.put(2002, 'Exceptions occurred');
        errorMap.put(2003, 'The response hasn’t arrived (which also means that the Apex asynchronous callout framework hasn’t resumed)');
        errorMap.put(2004, 'The response size is too large (greater than 1 MB)');

        Integer statusCode = response.getStatusCode();
        if (statusCode == 200) {
            Type t = Type.forName(String.valueOf(state));
            HDT_UTL_PracticesSupport support = (HDT_UTL_PracticesSupport)t.newInstance();
            support.execute(response.getBody());
            return support.result;
        } else if(statusCode >= 2000) {
            throw new AuraHandledException('Continuation Error: ' + statusCode + ' - ' + errorMap.get(statusCode));
        } else {
            throw new AuraHandledException(response.getBody());
        }

    }

    public static Object callWebService(String recordId, String serviceType){
        System.debug(LoggingLevel.DEBUG, '>>> recordId > ' + recordId);

        Map<String, String> headerMap = new Map<String, String>();
        List<HDT_AccountDataEnrichment__mdt> enrichmentbMetadataList;
        List<Account> accList;
        HttpRequest req;

        enrichmentbMetadataList = HDT_QR_AccountDataEnrichment.getAccountDataEnrichment(enrichmentbMetadataList, serviceType);

        if(enrichmentbMetadataList.size()==0){
            throw new AuraHandledException('No enrichment Metadata!');
        }

        accList = HDT_QR_AccountDataEnrichment.getAccountRecords(accList, recordId);

        if(accList.size() == 0 || String.isEmpty(accList[0].CustomerCode__c)){
            throw new AuraHandledException('No Customer Code!');
        }

        headerMap.put('value', accList[0].CustomerCode__c);

        req = setHttpRequest(enrichmentbMetadataList[0], req, headerMap);
        HDT_WRP_Practices.HDT_WRP_Response response = sendHttpRequest(req);

        Type t = Type.forName(enrichmentbMetadataList[0].ApexClass__c);
        HDT_UTL_PracticesSupport support = (HDT_UTL_PracticesSupport)t.newInstance();
        support.execute(response.body);
        return support.result;

    }

    private static HDT_WRP_Practices.HDT_WRP_Response sendHttpRequest(HttpRequest req) {

        HDT_WRP_Practices.HDT_WRP_Response respObj = new HDT_WRP_Practices.HDT_WRP_Response();

        try{

            Http http = new Http();
            HTTPResponse res = http.send(req);

            String responseStatus = res.getStatus();
            Integer statusCode = res.getStatusCode();
            System.debug(LoggingLevel.DEBUG, '## Response status -> ' + responseStatus + ' - ' + statusCode);

            if(statusCode != 200){
                switch on res.getStatusCode() {
                    when 500 {
                        respObj.message = 'Something goes wrong on Mulesoft side';
                    }	
                    when 401 {
                        respObj.message = 'Expired session Id';
                    }
                    when 400 {
                        respObj.message = 'Bad Request';
                    } when  else {
                        respObj.message = 'It\'s seems there is no signal';
                    }
                }
                respObj.success = false;
                respObj.message += '; [CODE: ' + String.valueOf(res.getStatusCode() + ' - STATUS: ' + res.getStatus() + ']; ');

            } else {
                respObj.success = true;
                respObj.body = res.getBody();
            }

        } catch (Exception ex){
            System.debug(LoggingLevel.DEBUG, 'HDT_WS_MulesoftCaller -> ERROR: line [' + ex.getLineNumber() + ']; ' + ex.getMessage());
            respObj.success = false;
            respObj.message = 'HDT_WS_MulesoftCaller -> ERROR: line [' + ex.getLineNumber() + ']; ' + ex.getMessage();       
        }
        return respObj;
    }

}