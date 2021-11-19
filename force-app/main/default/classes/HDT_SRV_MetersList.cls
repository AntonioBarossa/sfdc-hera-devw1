public inherited sharing class HDT_SRV_MetersList {

    public static Object getDatatableStructure(){

        HDT_WRP_MetersList.HDT_WRP_Table wrpObj = new HDT_WRP_MetersList.HDT_WRP_Table();
        wrpObj.columnList = new List<HDT_WRP_MetersList.HDT_WRP_SingleColumn>();

        List<HDT_MetersListColumnTable__mdt> columnTableList;
        columnTableList = HDT_QR_MetersList.getMetersListColumnTable(columnTableList);

        if(columnTableList.size() == 0){
            throw new AuraHandledException('Non sono presenti i metadati per la tabella');
        }

        HDT_WRP_MetersList.HDT_WRP_SingleColumn singleColumn;
        for(HDT_MetersListColumnTable__mdt singleColumnMdt : columnTableList){
            singleColumn = new HDT_WRP_MetersList.HDT_WRP_SingleColumn();
            singleColumn.label = singleColumnMdt.MasterLabel;
            singleColumn.fieldName = singleColumnMdt.DeveloperName;
            wrpObj.columnList.add(singleColumn);
        }

        return wrpObj;
    }

    public static Object startRequest(String recordId){

        System.debug(LoggingLevel.DEBUG, '>>> startRequest');
        System.debug(LoggingLevel.DEBUG, '>>> recordId: ' + recordId);

        Continuation con = new Continuation(40);
        con.continuationMethod = 'processResponse';
        con.state = recordId;

        /*List<HDT_ServicePointMetersList__mdt> metadataList;
        metadataList = HDT_QR_MetersList.getNamedCredential(metadataList, 'MetersList');

        if(metadataList.size() == 0){
            throw new AuraHandledException('Non sono presenti i metadati');
        }

        System.debug(LoggingLevel.DEBUG, '>>> metadataList: ' + String.valueOf(metadataList[0]));*/

        String body = createHttpBody(recordId);

        if(String.isEmpty(body)){
            throw new AuraHandledException('Attenzione! il POD non è presente. [Codice Punto]');
        }

        System.debug(LoggingLevel.DEBUG, '>>> body: ' + body);

        HttpRequest req = new HttpRequest();
        //req.setEndpoint(metadataList[0].Endpoint__c);
        req.setEndpoint('callout:meterLocationSearch');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setbody(body);
        req.setTimeout(120000);

        con.addHttpRequest(req);

        System.debug(LoggingLevel.DEBUG, '>>> req: ' + String.valueOf(req));

        return con;

    }

    public static String createHttpBody(String recordId){

        List<ServicePoint__c> servicePointList;
        servicePointList = HDT_QR_MetersList.getServicePoint(servicePointList, recordId);

        if(servicePointList.size() == 0){
            return null;
        }

        if(String.isEmpty(servicePointList[0].ServicePointCode__c)){
            return null;
        }

        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField('pod', servicePointList[0].ServicePointCode__c);
        gen.writeEndObject();
        return gen.getAsString();
    }

}