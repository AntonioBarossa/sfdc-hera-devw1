public without sharing class HDT_LC_ViewSapDataTableCtrl {

    @AuraEnabled
    public static TableMetaData getTableConfig(String recordId, String type){
        TableMetaData tdata = new TableMetaData();
        try {
            tdata.columns = new List<ColumnObj>();
            tdata = (TableMetaData)JSON.deserialize(s, TableMetaData.class);

            if(type == 'cmor'){
                tdata.tableTitle = 'CMOR';
            } else if(type == 'socialBonus'){
                tdata.tableTitle = 'Bonus Sociale';
            } else if(type == 'raiFee'){
                tdata.tableTitle = 'Canone RAI';
            }

        } catch (Exception e) {
            //throw new AuraHandledException(e.getMessage());
        }
        return tdata;
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

    public class TableMetaData {
        @AuraEnabled public String tableTitle;
        @AuraEnabled public List<ColumnObj> columns;
    }

    public class ColumnObj {
        @AuraEnabled public String fieldName;
        @AuraEnabled public String label;
    }

    public static String s = '{ "columns": [{ "label": "POD/PDR", "fieldName": "POD"},'+
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

}