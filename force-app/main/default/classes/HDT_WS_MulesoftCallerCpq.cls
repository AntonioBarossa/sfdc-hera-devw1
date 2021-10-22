@SuppressWarnings('PMD.AvoidDebugStatements')
public without sharing class HDT_WS_MulesoftCallerCpq {

    public static HDT_WRP_Response retrieveDataCtrl(String body, HDT_WRP_HttpObj httpObj) {

        HDT_WRP_Response respObj = new HDT_WRP_Response();

        HttpRequest req = new HttpRequest();

        //String endPoint;
        //String authValueString;

        try{

            req.setEndpoint(httpObj.endPoint);
            req.setMethod(httpObj.httpMethod);

            if(httpObj.headersMap.keySet().size() > 0){
                for(String key : httpObj.headersMap.keySet()){
                    req.setHeader(key, httpObj.headersMap.get(key));
                }
            }

            req.setbody(body);
            req.setTimeout(120000);

            Http http = new Http();
            HTTPResponse res = http.send(req);

            String responseStatus = res.getStatus();
            Integer statusCode = res.getStatusCode();
            System.debug(LoggingLevel.DEBUG, '## Response status -> ' + responseStatus + ' - ' + statusCode);

            //if(statusCode != 200){
            //    switch on res.getStatusCode() {
            //        when 500 {
            //            respObj.message = 'Something goes wrong on Mulesoft side';
            //        }	
            //        when 401 {
            //            respObj.message = 'Expired session Id';
            //        }
            //        when 400 {
            //            respObj.message = 'Bad Request';
            //        } when  else {
            //            respObj.message = 'It\'s seems there is no signal';
            //        }
            //    }
            //    respObj.success = false;
            //    respObj.message += '; [CODE: ' + String.valueOf(res.getStatusCode() + ' - STATUS: ' + res.getStatus() + ']; ');
//
            //} else {
                respObj.success = true;
                respObj.body = res.getBody();
            //}

        } catch (Exception ex){
            System.debug(LoggingLevel.DEBUG, 'HDT_WS_MulesoftCaller -> ERROR: line [' + ex.getLineNumber() + ']; ' + ex.getMessage());
            respObj.success = false;
            respObj.message = 'HDT_WS_MulesoftCaller -> ERROR: line [' + ex.getLineNumber() + ']; ' + ex.getMessage();       
        }
        return respObj;
    }

    public class HDT_WRP_HttpObj {
        public String endPoint;
        public String httpMethod;
        public Map<String, String> headersMap;
    }

    public class HDT_WRP_Response {
        public Boolean success;
        public String message;
        public String body;
    }

    public class HDT_WRP_MulesoftResponse {
        public String status;
        public String correlationId;
        public String timestamp;
        public String keysap;
        public String message;
        public String esito;
        public List<HDT_WRP_ErrorObj> errorDetails;
    }

    public class HDT_WRP_ErrorObj {
        public String code;
        public String message;
        public String additionalInfo;
    }

}