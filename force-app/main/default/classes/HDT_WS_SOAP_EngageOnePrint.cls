public class HDT_WS_SOAP_EngageOnePrint {

    public static ReturnObj sendFile(String bodyString) {

        ReturnObj returnObj = new ReturnObj();

        Integer initialLimit = Limits.getHeapSize();
        Datetime startTime = Datetime.now();

        HttpRequest req = new HttpRequest();

        try{
            req.setEndpoint('https://monted-dev-ed.my.salesforce.com/services/apexrest/getFileToPrint/0');
            req.setMethod('POST');

            req.setHeader('Authorization', 'Bearer ' + Label.MockSessionId);
            req.setHeader('Content-Type', 'application/json');
            req.setbody(bodyString);
            req.setTimeout(120000); // timeout in milliseconds
        
            // Create a new http object to send the request object
            // A response object is generated as a result of the request  
        
            Http http = new Http();
            HTTPResponse res = http.send(req);

            String responseStatus = res.getStatus();
            System.debug('## Response status -> ' + responseStatus);

            ReponseObj responseObj = (ReponseObj)JSON.deserialize(res.getBody(), ReponseObj.class);

            System.debug('### Response -> ' + responseObj.status);
            System.debug('### Response -> ' + responseObj.correlationId);
            System.debug('### Response -> ' + responseObj.timestamp);
            System.debug('### Response -> ' + responseObj.message);

            if(responseObj.status != 'success'){
                returnObj.success = false;
                returnObj.message = responseObj.message;
                return returnObj;
            }

            returnObj.success = true;
            returnObj.bodyBase64 = responseObj.bodyBase64;
            returnObj.message = '';
        } catch (Exception ex){
            System.debug('ERROR: line [' + ex.getLineNumber() + ']; ' + ex.getMessage());
            returnObj.success = false;
            returnObj.message = 'ERROR: line [' + ex.getLineNumber() + ']; ' + ex.getMessage();       
        }
        return returnObj;
    }

    public class  ReturnObj {
        public Boolean success;
        public String bodyBase64;
        public String message;
    }

    public class ReponseObj {
        String status;
        String correlationId;
        String timestamp;
        String message;
        String bodyBase64;
    }

}