public class HDT_WS_MakeMulesoftCall {

    // APEX CLASS NOT IN USE - EVALUATE TO DELETE

    /*
    public static ResponseCtrl makeHttpRequest(String body, HttpObj httpObj) {

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
            respObj.success = true;
            respObj.httpReq = req;

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
        public HttpRequest httpReq;
    }
*/
}