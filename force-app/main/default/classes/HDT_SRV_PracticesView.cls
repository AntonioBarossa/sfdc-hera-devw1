@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing class HDT_SRV_PracticesView {

    public static HDT_WRP_Practices.HDT_WRP_ReturnMetadataObj getTableConfigHelper(String recordId, String type, HDT_WRP_Practices.HDT_WRP_ReturnMetadataObj retObj){
        
        retObj = new HDT_WRP_Practices.HDT_WRP_ReturnMetadataObj();
        retObj.tables = new List<HDT_WRP_Practices.HDT_WRP_TableMetadata>();

        List<HDT_AccountDataEnrichment__mdt> enrichmentbMetadataList;
        enrichmentbMetadataList = HDT_QR_AccountDataEnrichment.getAccountDataEnrichment(enrichmentbMetadataList, type);

        if(enrichmentbMetadataList.size()==0){
            throw new AuraHandledException('Attenzione! mancano i metadati delle tabelle.');
        }

        try {
            retObj.tables = (List<HDT_WRP_Practices.HDT_WRP_TableMetadata>)JSON.deserialize(enrichmentbMetadataList[0].ColumnData__c, List<HDT_WRP_Practices.HDT_WRP_TableMetadata>.class);
        } catch (Exception e) {
            System.debug('ERROR > ' + e.getMessage() + '; at line [' + String.valueOf(e.getLineNumber()) + ']');
            throw new AuraHandledException('Errore durante l\'elaborazione dei metadati delle tabelle.');
        }

        if(retObj.tables.size()==0){
            throw new AuraHandledException('Errore durante l\'elaborazione dei metadati delle tabelle.');
        }

        return retObj;
    }

    private static HttpRequest setHttpRequest(HDT_AccountDataEnrichment__mdt metadataRecord, HttpRequest req, Map<String, String> headerMap, String addonUrl){
        
        // Create callout request
        req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint(metadataRecord.Credential__c + addonUrl);
      
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

    public static Object callWebService(String recordId, String serviceType){
        System.debug(LoggingLevel.DEBUG, '>>> recordId > ' + recordId);

        Map<String, String> headerMap = new Map<String, String>();
        List<HDT_AccountDataEnrichment__mdt> enrichmentbMetadataList;
        List<Account> accList;
        HttpRequest req;
        Http http = new Http();
        HTTPResponse res;

        enrichmentbMetadataList = HDT_QR_AccountDataEnrichment.getAccountDataEnrichment(enrichmentbMetadataList, serviceType);
        accList = HDT_QR_AccountDataEnrichment.getAccountRecords(accList, recordId);

        if(enrichmentbMetadataList.size()==0){
            throw new AuraHandledException('Attenzione! mancano i metadati delle tabelle.');
        }

        if(accList.size() == 0 || String.isEmpty(accList[0].CustomerCode__c)){
            throw new AuraHandledException('Il Customer Code non è stato trovato!');
        }

        //headerMap.put('partner', accList[0].CustomerCode__c);
        req = setHttpRequest(enrichmentbMetadataList[0], req, headerMap, '?partner=' + accList[0].CustomerCode__c);

        try{
            res = http.send(req);
        } catch (Exception ex){
            throw new AuraHandledException('WebService error: line [' + ex.getLineNumber() + ']; ' + ex.getMessage());
        }

        Type t = Type.forName(enrichmentbMetadataList[0].ApexClass__c);
        HDT_UTL_PracticesSupport support = (HDT_UTL_PracticesSupport)t.newInstance();
        support.execute(res);

        if(!support.success){
            throw new AuraHandledException(support.errorMessage);
        }

        return support.result;

    }

}