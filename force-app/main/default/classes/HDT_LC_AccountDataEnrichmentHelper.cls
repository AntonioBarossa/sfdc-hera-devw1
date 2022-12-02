/**
 * @description       : 
 * @author            : Giacinto Florio
 * @group             : 
 * @last modified on  : 02-12-2022
 * @last modified by  : Giacinto Florio
**/
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

    public static Object startRequestHelper(String recordId, String relatedToId, String metadataType) {

        System.debug(LoggingLevel.DEBUG, '>>> recordId > ' + recordId + ' - type: ' + metadataType + ' - relatedToId: ' + relatedToId);

        String httpBody = '';

        List<HDT_AccountDataEnrichment__mdt> enrichmentbMetadataList;
        enrichmentbMetadataList = HDT_QR_AccountDataEnrichment.getAccountDataEnrichment(enrichmentbMetadataList, metadataType);

        if(enrichmentbMetadataList.size()==0){
            throw new AuraHandledException('No enrichment Metadata!');
        }

        Type t = Type.forName(enrichmentbMetadataList[0].ApexClass__c);

        HDT_SRV_AccountDataEnrichmentSupport support = (HDT_SRV_AccountDataEnrichmentSupport)t.newInstance();
        support.setMetadata(enrichmentbMetadataList);
        support.setRecordIds(recordId, relatedToId);
        support.execute();

        if(!support.success){
            throw new AuraHandledException(support.errorMessage);
        }

        httpBody = support.body;
        System.debug(LoggingLevel.DEBUG, '>>> httpBody > ' + httpBody);

        //List<Account> accList;
        //accList = HDT_QR_AccountDataEnrichment.getAccountRecords(accList, recordId);

        //if(accList.size() == 0 || String.isEmpty(accList[0].CustomerCode__c)){
        //    throw new AuraHandledException('No Customer Code!');
        //}

        //httpBody = '{"bp": "' + accList[0].CustomerCode__c + '"';

        //if(type.equalsIgnoreCase('bonusSocialeIdrico')){
        //    httpBody += ', "codiceFiscaleRichiedente": "' + accList[0].FiscalCode__c + '"';
        //}

        //httpBody += '}';

        // Create continuation. Argument is timeout in seconds.
        Continuation con = new Continuation(40);
        // Set callback method
        con.continuationMethod = 'processResponse';
        // Set state
        con.state = metadataType;
        // Create callout request
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint(support.endPoint);
        
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
            when 'Case' {
                fieldApiName = 'AccountId';
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