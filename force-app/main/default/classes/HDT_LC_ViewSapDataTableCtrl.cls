public without sharing class HDT_LC_ViewSapDataTableCtrl {

    @AuraEnabled
    public static HDT_WRP_ReturnMetadataObj getTableConfig(String recordId, String type){
        
        HDT_WRP_ReturnMetadataObj retObj = new HDT_WRP_ReturnMetadataObj();
        retObj.tables = new List<HDT_WRP_TableMetadata>();
        
        try {

            List<AccountDataEnrichment__mdt> enrichmentbMetadataList;
            enrichmentbMetadataList = HDT_QR_AccountDataEnrichment.getAccountDataEnrichment(enrichmentbMetadataList, type);

            if(enrichmentbMetadataList.size()==0){
                retObj.success = false;
                retObj.message = 'No metadata found';
                return retObj;
            }

            retObj.tables = (List<HDT_WRP_TableMetadata>)JSON.deserialize(enrichmentbMetadataList[0].ColumnData__c, List<HDT_WRP_TableMetadata>.class);

            if(retObj.tables.size()==0){
                retObj.success = false;
                retObj.message = 'Something goes wrong converting metadata';
                return retObj;
            }

            /*if(type.equalsIgnoreCase('cmor')){
                retObj.tables = (List<HDT_WRP_TableMetadata>)JSON.deserialize(enrichmentbMetadataList[0].ColumnData__c, List<HDT_WRP_TableMetadata>.class);
            } else {
                HDT_WRP_TableMetadata tdata = new HDT_WRP_TableMetadata();
                tdata.columns = new List<HDT_WRP_ColumnObj>();
                tdata = (HDT_WRP_TableMetadata)JSON.deserialize(enrichmentbMetadataList[0].ColumnData__c, HDT_WRP_TableMetadata.class);
                retObj.tables.add(tdata);
            }*/

            retObj.success = true;

        } catch (Exception e) {
            retObj.success = false;
            retObj.message = 'ERROR > ' + e.getMessage() + '; at line [' + String.valueOf(e.getLineNumber()) + ']';
        }

        return retObj;
    }
    
    // Action method
    @AuraEnabled(continuation=true cacheable=true)
    public static Object startRequest(String recordId, String type) {

        System.debug('>>> recordId > ' + recordId);

        String httpBody = '';

        List<AccountDataEnrichment__mdt> enrichmentbMetadataList;
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
        req.setEndpoint(enrichmentbMetadataList[0].Credential__c);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', enrichmentbMetadataList[0].Authorization__c);
        req.setbody(httpBody);
        req.setTimeout(120000);
        // Add callout request to continuation
        con.addHttpRequest(req);
        // Return the continuation
        return con;
    }
    
    // Callback method
    @AuraEnabled(cacheable=true)
    public static Object processResponse(List<String> labels, Object state) {
        // Get the response by using the unique label
        HttpResponse response = Continuation.getResponse(labels[0]);
        // Set the result variable
        //String result = response.getBody();
        
        Integer statusCode = response.getStatusCode();
        if (statusCode == 200) {
            return response.getBody();
        } else if(statusCode >= 2000) {
            throw new AuraHandledException('Continuation Error: ' + statusCode + ' - ' + response.getBody());
        } else {
            throw new AuraHandledException('HTTP Request Error: ' + statusCode + ' - ' + response.getBody());
        }

    }

    public class HDT_WRP_ReturnMetadataObj {
        @AuraEnabled public Boolean success;
        @AuraEnabled public String message;
        @AuraEnabled public List<HDT_WRP_TableMetadata> tables;
    }

    public class HDT_WRP_TableMetadata {
        @AuraEnabled public String tableTitle;
        @AuraEnabled public String iconName;
        @AuraEnabled public List<HDT_WRP_ColumnObj> columns;
    }

    public class HDT_WRP_ColumnObj {
        @AuraEnabled public String fieldName;
        @AuraEnabled public String label;
    }

    public class HDT_WRP_RequestResponse {
        @AuraEnabled public Boolean success;
        @AuraEnabled public String message;
        @AuraEnabled public String resultBody;       
    }

}