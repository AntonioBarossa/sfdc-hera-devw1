public without sharing class HDT_WS_MulesoftCaller {

    //public static ResponseCtrl retrieveDataCtrl(DataBodyRow dbr, HttpObj httpObj) {
    public static ResponseCtrl retrieveDataCtrl(String body, HttpObj httpObj) {

        ResponseCtrl respObj = new ResponseCtrl();

        Integer initialLimit = Limits.getHeapSize();
        Datetime startTime = Datetime.now();

        HttpRequest req = new HttpRequest();

        String endPoint;
        String authValueString;

        try{

            req.setEndpoint(httpObj.endPoint);
            req.setMethod(httpObj.httpMethod);

            for(String key : httpObj.headersMap.keySet()){
                req.setHeader(key, httpObj.headersMap.get(key));
            }

            req.setbody(body);
            req.setTimeout(120000); // timeout in milliseconds

            // Create a new http object to send the request object
            // A response object is generated as a result of the request
            Http http = new Http();
            HTTPResponse res = http.send(req);

            String responseStatus = res.getStatus();
            System.debug('## Response status -> ' + responseStatus);

            if(responseStatus != 'OK'){
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

            Datetime endTime = Datetime.now();
            Integer finalLimit = Limits.getHeapSize();
            Integer limitValue = Limits.getLimitHeapSize();

            System.debug('## **** ##');
            System.debug('## Heap size available: ' + limitValue + ' bytes');            
            System.debug('## Initial Heap size: ' + initialLimit + ' bytes');
            System.debug('## Final Heap size: ' + finalLimit + ' bytes');
            System.debug('## **** ##');

            Integer t = endTime.second() - startTime.second();
            System.debug('# Time of execution -> ' + t + ' [sec]');
            System.debug('# ' + endTime + ' - ' + startTime);

        } catch (Exception ex){
            System.debug('HDT_WS_MulesoftCaller -> ERROR: line [' + ex.getLineNumber() + ']; ' + ex.getMessage());
            respObj.success = false;
            respObj.message = 'HDT_WS_MulesoftCaller -> ERROR: line [' + ex.getLineNumber() + ']; ' + ex.getMessage();       
        }
        return respObj;
    }

    public class HttpObj {
        public String endPoint;
        public String httpMethod;
        public Map<String, String> headersMap;
    }

    public class ResponseCtrl {
        public Boolean success;
        public String message;
        public String body;
    }

    //RESPONSE OBJ RETURNED TO CONTROLLER
    public class ReponseObj {
        @AuraEnabled public Boolean success;
        @AuraEnabled public String message;
        @AuraEnabled public List<HDT_WRP_AccountStatement.DataWrapper> data;
        @AuraEnabled public Decimal totAmount;
    }

    //RETURN OBJ FROM MULESOFT
    public class ReturnObj{
        public String status;
        public String correlationId;
        public String timestamp;
        public ErrorDetails errorDetails;
        public List<HDT_WRP_AccountStatement.DataWrapper> data;
    }

    public class ErrorDetails {
        @AuraEnabled public String code;
        @AuraEnabled public String message;
        @AuraEnabled public String additionalInfo;
    }

    /*public static ReponseObj retrieveData(DataBodyRow dbr, HttpObj httpObj) {

        ReponseObj respObj = new ReponseObj();

        Integer initialLimit = Limits.getHeapSize();
        Datetime startTime = Datetime.now();

        HttpRequest req = new HttpRequest();

        String endPoint;
        String authValueString;

        try{
            String body = JSON.serialize(dbr);
            System.debug('---> ' + body);
            req.setEndpoint(httpObj.endPoint);
            req.setMethod('POST');
            req.setHeader('authorization', httpObj.authValueString);
            req.setHeader('Content-Type', 'application/json');
            req.setbody(body);
            req.setTimeout(120000); // timeout in milliseconds

            // Create a new http object to send the request object
            // A response object is generated as a result of the request
            Http http = new Http();
            HTTPResponse res = http.send(req);

            String responseStatus = res.getStatus();
            System.debug('## Response status -> ' + responseStatus);
            System.debug('## Body -> ' + body);

            if(responseStatus != 'OK'){

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
                ReturnObj restMessage = (ReturnObj)JSON.deserialize(res.getBody(), ReturnObj.class);

                System.debug('### Response - status -> ' + restMessage.status);
                System.debug('### Response - correlationId-> ' + restMessage.correlationId);
                System.debug('### Response - timestamp-> ' + restMessage.timestamp);

                if(restMessage.status != 'success'){
                    respObj.success = false;
                    respObj.message += 'Mulesoft side [code: ' + restMessage.errorDetails.code;
                    respObj.message += ']; Detail: ' + restMessage.errorDetails.message;
                    respObj.message += '; Additional Info' + restMessage.errorDetails.additionalInfo;
                    return respObj;
                }

                System.debug('Response from SAP');
                respObj.data = new List<HDT_WRP_AccountStatement.DataWrapper>();
                respObj.data = restMessage.data;
                respObj.success = true;
                respObj.message = '';
            }

            Datetime endTime = Datetime.now();
            Integer finalLimit = Limits.getHeapSize();
            Integer limitValue = Limits.getLimitHeapSize();

            System.debug('## **** ##');
            System.debug('## Heap size available: ' + limitValue + ' bytes');            
            System.debug('## Initial Heap size: ' + initialLimit + ' bytes');
            System.debug('## Final Heap size: ' + finalLimit + ' bytes');
            System.debug('## **** ##');

            Integer t = endTime.second() - startTime.second();
            System.debug('# Time of execution -> ' + t + ' [sec]');
            System.debug('# ' + endTime + ' - ' + startTime);

        } catch (Exception ex){
            System.debug('ERROR: line [' + ex.getLineNumber() + ']; ' + ex.getMessage());
            respObj.success = false;
            respObj.message = 'ERROR: line [' + ex.getLineNumber() + ']; ' + ex.getMessage();       
        }
        return respObj;
    }
    //REQUEST OBJ SEND TO MULESOFT
    public class DataBodyRow {
        public String applicativo;
        public String aggregazione;
        public String codiceCliente;
        public String tipoTransazione;
        public String tipoEstrattoConto;
        public String dataInizio;
        public String dataFine;
        public String numeroFattura;
        public String numeroBollettino;
        public String contoContrattuale;
        public String societa;
        public String contratto;
        public String loginId;
    }
    */

}