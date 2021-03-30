public without sharing class HDT_LC_ViewSapDataTableCtrl {

    @AuraEnabled
    public static HDT_WRP_ReturnMetadataObj getTableConfig(String recordId, String type){
        
        HDT_WRP_ReturnMetadataObj retObj = new HDT_WRP_ReturnMetadataObj();
        retObj.tables = new List<HDT_WRP_TableMetadata>();
        
        try {

            List<AccountDataEnrichment__mdt> enrichmentbMetadataList;
            enrichmentbMetadataList = HDT_QR_AccountDataEnrichment.getAccountDataEnrichment(enrichmentbMetadataList, type);

            if(enrichmentbMetadataList.size()==0){
                //handle error here
            }

            switch on type {
                when 'cmor' {
                    HDT_WRP_TableMetadata tdata = new HDT_WRP_TableMetadata();
                    tdata.columns = new List<HDT_WRP_ColumnObj>();
                    tdata = (HDT_WRP_TableMetadata)JSON.deserialize(cmorColumns1, HDT_WRP_TableMetadata.class);
                    tdata.tableTitle = 'CMOR - Venditore entrante';
                    tdata.iconName = 'standard:record_update';
                    retObj.tables.add(tdata);
    
                    HDT_WRP_TableMetadata tdata2 = new HDT_WRP_TableMetadata();
                    tdata2.columns = new List<HDT_WRP_ColumnObj>();
                    tdata2 = (HDT_WRP_TableMetadata)JSON.deserialize(cmorColumns2, HDT_WRP_TableMetadata.class);
                    tdata2.tableTitle = 'CMOR - Venditore uscente';
                    tdata2.iconName = 'standard:record_update';
                    retObj.tables.add(tdata2);
                }	
                when 'socialBonus' {
                    HDT_WRP_TableMetadata tdata = new HDT_WRP_TableMetadata();
                    tdata.columns = new List<HDT_WRP_ColumnObj>();
                    tdata = (HDT_WRP_TableMetadata)JSON.deserialize(enrichmentbMetadataList[0].ColumnData__c, HDT_WRP_TableMetadata.class);
                    tdata.tableTitle = 'Bonus Sociale';
                    tdata.iconName = 'standard:customer_lifecycle_analytics';
                    retObj.tables.add(tdata);
                }
                when 'raiFee' {
                    HDT_WRP_TableMetadata tdata = new HDT_WRP_TableMetadata();
                    tdata.columns = new List<HDT_WRP_ColumnObj>();
                    tdata = (HDT_WRP_TableMetadata)JSON.deserialize(enrichmentbMetadataList[0].ColumnData__c, HDT_WRP_TableMetadata.class);
                    tdata.tableTitle = 'Canone RAI';
                    tdata.iconName = 'standard:expense';
                    retObj.tables.add(tdata);
                }
            }

            /*if(type == 'cmor'){
                HDT_WRP_TableMetadata tdata = new HDT_WRP_TableMetadata();
                tdata.columns = new List<HDT_WRP_ColumnObj>();
                tdata = (HDT_WRP_TableMetadata)JSON.deserialize(cmorColumns1, HDT_WRP_TableMetadata.class);
                tdata.tableTitle = 'CMOR - Venditore entrante';
                tdata.iconName = 'standard:record_update';
                retObj.tables.add(tdata);

                HDT_WRP_TableMetadata tdata2 = new HDT_WRP_TableMetadata();
                tdata2.columns = new List<HDT_WRP_ColumnObj>();
                tdata2 = (HDT_WRP_TableMetadata)JSON.deserialize(cmorColumns2, HDT_WRP_TableMetadata.class);
                tdata2.tableTitle = 'CMOR - Venditore uscente';
                tdata2.iconName = 'standard:record_update';
                retObj.tables.add(tdata2);

            } else if(type == 'socialBonus'){
                HDT_WRP_TableMetadata tdata = new HDT_WRP_TableMetadata();
                tdata.columns = new List<HDT_WRP_ColumnObj>();
                tdata = (HDT_WRP_TableMetadata)JSON.deserialize(socialBonusColumns, HDT_WRP_TableMetadata.class);
                tdata.tableTitle = 'Bonus Sociale';
                tdata.iconName = 'standard:customer_lifecycle_analytics';
                retObj.tables.add(tdata);
            } else if(type == 'raiFee'){
                HDT_WRP_TableMetadata tdata = new HDT_WRP_TableMetadata();
                tdata.columns = new List<HDT_WRP_ColumnObj>();
                tdata = (HDT_WRP_TableMetadata)JSON.deserialize(raiFeeColumns, HDT_WRP_TableMetadata.class);
                tdata.tableTitle = 'Canone RAI';
                tdata.iconName = 'standard:expense';
                retObj.tables.add(tdata);
            }*/
            
        } catch (Exception e) {
            //throw new AuraHandledException(e.getMessage());
        }
        return retObj;
    }
    
    // Action method
    @AuraEnabled(continuation=true cacheable=true)
    public static Object startRequest(String recordId, String type) {
        // Create continuation. Argument is timeout in seconds.
        Continuation con = new Continuation(40);
        // Set callback method
        con.continuationMethod = 'processResponse';
        // Set state
        con.state = type;
        // Create callout request
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint('https://monted-dev-ed.my.salesforce.com/services/apexrest/' + type);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + Label.MockSessionId);
        req.setbody('body');
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
        String result = response.getBody();
        return result;
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

    public static String cmorColumns1 = '{ "columns": [{ "label": "POD/PDR", "fieldName": "POD"},'+
    '{ "label": "Impianto", "fieldName": "ANLAGE"},'+
    '{ "label": "Numero business partner", "fieldName": "PARTNER"},'+
    '{ "label": "Contratto", "fieldName": "CONTRATTO"},'+
    '{ "label": "Importo Cmor", "fieldName": "CMOR"},'+
    '{ "label": "Stato CMOR", "fieldName": "STATO"},'+
    '{ "label": "codice pratica gestore", "fieldName": "ID_RICH"},'+
    '{ "label": "data ricezione", "fieldName": "DATA_COM"},'+
    '{ "label": "data di ultimo aggiornamento", "fieldName": "DATA_AGG"},'+
    '{ "label": "Settore merceologico", "fieldName": "SPARTE"},'+
    '{ "label": "Società", "fieldName": "SERVICEID"},'+
    '{ "label": "Importo Cmor stornato", "fieldName": "CMOR_STORNATO"},'+
    '{ "label": "Importo Cmor rettificato", "fieldName": "CMOR_RETT"}]}';

    public static String cmorColumns2 = '{ "columns": [{ "label": "Stato Richiesta Indennizzo", "fieldName": "status"},'+
    '{ "label": "N. conto contrattuale", "fieldName": "VKONT"},'+
    '{ "label": "Numero business partner", "fieldName": "GPART"},'+
    '{ "label": "Contratto", "fieldName": "VERTRAG"},'+
    '{ "label": "Codice POD/PDR", "fieldName": "POD"},'+
    '{ "label": "IMPORTO CMOR", "fieldName": "IMPORTO_CMOR"},'+
    '{ "label": "IMPORTO CMOR PREGRESSO ", "fieldName": "CMOR_1"},'+
    '{ "label": "codice gestore", "fieldName": "ID_ESTERNO"},'+
    '{ "label": "invio richiesta", "fieldName": "DATA_RICHIESTA"},'+
    '{ "label": "data ultima modifica", "fieldName": "DATA_FLUSSO"},'+
    '{ "label": "Data switch out", "fieldName": "DATA_SWITCH"},'+
    '{ "label": "Settore merceologico", "fieldName": "SPARTE"},'+
    '{ "label": "Società", "fieldName": "SERVICEID"}]}';

    /*public static String raiFeeColumns = '{ "columns": [{ "label": "Stato Pratica", "fieldName": "statoPratica"},'+
    '{ "label": "Società", "fieldName": "societa"},'+
    '{ "label": "B.partner", "fieldName": "bpartner"},'+
    '{ "label": "Pod", "fieldName": "pod"},'+
    '{ "label": "Contratto", "fieldName": "contratto"},'+
    '{ "label": "Mese di riferimento", "fieldName": "meseRiferimento"},'+
    '{ "label": "Id.addebito", "fieldName": "idAddebito"},'+
    '{ "label": "Periodo Riferimento", "fieldName": "periodoRiferimento"},'+
    '{ "label": "Num.Documento", "fieldName": "numDocumento"},'+
    '{ "label": "Importo Rata", "fieldName": "importoRata"},'+
    '{ "label": "Data scadenza Rata", "fieldName": "dataScadenzaRata"}]}';

    public static String socialBonusColumns = '{ "columns": [{ "label": "BP", "fieldName": "BP"},'+
    '{ "label": "POD", "fieldName": "POD"},'+
    '{ "label": "CONTRATTO", "fieldName": "CONTRATTO"},'+
    '{ "label": "data attivazione contratto", "fieldName": "dataAttivazione"},'+
    '{ "label": "data cessazione contratto", "fieldName": "dataCessazione"},'+
    '{ "label": "Decodifica Società", "fieldName": "decodificaSocieta"},'+
    '{ "label": "Data Attivazione Bonus", "fieldName": "dataAttivazioneBonus"},'+
    '{ "label": "Data Cessazione Bonus", "fieldName": "dataCessazioneBonus"},'+
    '{ "label": "Tipo Compensazione Sap", "fieldName": "tipoCompensazioneSap"},'+
    '{ "label": "Descrizione Tipo Compensazione", "fieldName": "descrizioneTipo"}]}';*/

}