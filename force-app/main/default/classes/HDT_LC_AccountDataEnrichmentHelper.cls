@SuppressWarnings('PMD.AvoidDebugStatements')
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

        System.debug(LoggingLevel.DEBUG, '>>> recordId > ' + recordId + ' - type: ' + type);

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

        httpBody = '{"bp": "' + accList[0].CustomerCode__c + '"';

        if(type.equalsIgnoreCase('bonusSocialeIdrico')){
            httpBody += ', "codiceFiscaleRichiedente": "' + accList[0].FiscalCode__c + '"';
        }

        httpBody += '}';

        // Create continuation. Argument is timeout in seconds.
        Continuation con = new Continuation(40);
        // Set callback method
        con.continuationMethod = 'processResponse';
        // Set state
        con.state = type;
        // Create callout request
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');

        if(type.equalsIgnoreCase('bonusSocialeIdrico')){
            req.setEndpoint('Callout:MulesoftBasePath/transfers/lock-unlock-calculations');
        } else {
            req.setEndpoint(enrichmentbMetadataList[0].Credential__c);
        }
        
        //if(!enrichmentbMetadataList[0].Credential__c.containsIgnoreCase('callout:') && !String.isEmpty(enrichmentbMetadataList[0].Authorization__c)){
        //    req.setHeader('Authorization', enrichmentbMetadataList[0].Authorization__c);
        //}

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
        
        /*
            @Author: Davide Viola - 19/10/2021
            Description: PMD -> Commentata variabile non utilizzata.
        */
        //Integer statusCode = response.getStatusCode();
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


    // W2 29/07/2022
    public static void generateHttpBody(){}

    // W2
    public static Id getAccountId(String recordId){
        Id myId = Id.valueOf(recordId);
        String sObectType = String.valueOf(myId.getSobjectType());

        System.debug('--> sObectType ' + sObectType);

        String fieldApiName = '';
        String queryString = '';
        
        switch on sObectType {
            when 'Contract' {
                fieldApiName = 'AccountId';
            }	
            when 'ServicePoint__c' {
                fieldApiName = 'Account__c';
            }
        }

        queryString += 'SELECT Id, ' + fieldApiName + ' ';
        queryString += 'FROM ' + sObectType + ' ';
        queryString += 'WHERE Id = \'' + recordId + '\' LIMIT 1';

        System.debug('--> sObectType ' + queryString);

        List<sObject> sObjectList = new List<sObject>();
        sObjectList = HDT_QR_AccountDataEnrichment.getRecordsList(sObjectList, queryString, sObectType);
        sObject obj = sObjectList[0];

        String returnId = (Id)obj.get(fieldApiName);
        return returnId;

    }

}