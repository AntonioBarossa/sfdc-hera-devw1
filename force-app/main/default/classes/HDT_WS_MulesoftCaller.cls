public without sharing class HDT_WS_MulesoftCaller {

    /*
    * @Author: Salvatore A. Sarà 19/10/2021
    * Risoluzione "Debug Should Use Logging Level"
    * Risoluzione "Avoid debug statements since they impact on performance"
    * Risoluzione "Local variable is declared and-or assigned but not used"
    */
    @SuppressWarnings('PMD.AvoidDebugStatements')
    public static HDT_WRP_Response retrieveDataCtrl(String body, HDT_WRP_HttpObj httpObj) {

        HDT_WRP_Response respObj = new HDT_WRP_Response();

        //Integer initialLimit = Limits.getHeapSize();
        //Datetime startTime = Datetime.now();

        HttpRequest req = new HttpRequest();

        String endPoint;
        // String authValueString;

        try{

            req.setEndpoint(httpObj.endPoint);
            req.setMethod(httpObj.httpMethod);

            if(httpObj.headersMap.keySet().size() > 0){
                for(String key : httpObj.headersMap.keySet()){
                    req.setHeader(key, httpObj.headersMap.get(key));
                }
            }

            if(String.isNotEmpty(body)){
                req.setbody(body);
            }
            
            req.setTimeout(120000); // timeout in milliseconds

            // Create a new http object to send the request object
            // A response object is generated as a result of the request
            Http http = new Http();
            HTTPResponse res = http.send(req);

            String responseStatus = res.getStatus();
            System.debug(LoggingLevel.DEBUG, '## Response status -> ' + responseStatus);

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
                respObj.body = res.getBody();

            } else {
                respObj.success = true;
                respObj.body = res.getBody();
            }

            /*Datetime endTime = Datetime.now();
            Integer finalLimit = Limits.getHeapSize();
            Integer limitValue = Limits.getLimitHeapSize();

            System.debug('## **** ##');
            System.debug('## Heap size available: ' + limitValue + ' bytes');            
            System.debug('## Initial Heap size: ' + initialLimit + ' bytes');
            System.debug('## Final Heap size: ' + finalLimit + ' bytes');
            System.debug('## **** ##');

            Integer t = endTime.second() - startTime.second();
            System.debug('# Time of execution -> ' + t + ' [sec]');
            System.debug('# ' + endTime + ' - ' + startTime);*/

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

}