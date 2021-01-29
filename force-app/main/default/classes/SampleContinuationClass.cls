public with sharing class SampleContinuationClass {
    
    // Action method
    @AuraEnabled(continuation=true)
    public static Object startRequest(String techObj, String requestObj) {

        Boolean success = true;

        TechnicalObj tObj = new TechnicalObj();
        tObj.tab = 'tab1';
        tObj.obj = '9';

        if(success){
            // Create continuation. Argument is timeout in seconds.
            Continuation con = new Continuation(40);
            // Set callback method
            con.continuationMethod='processResponse';
            // Set state
            con.state = tObj;
            // Create callout request

            HttpRequest req = setHttpRequest();

            // Add callout request to continuation
            con.addHttpRequest(req);
            // Return the continuation
            return con;
        } else {
            ResponseCtrl r = new ResponseCtrl();
            r.success = false;
            r.message = 'Error occurred';
            return r;
        }


    }
    
    // Callback method
    @AuraEnabled
    public static Object processResponse(List<String> labels, Object state) {
      System.debug('#### processResponse ####');
      // Get the response by using the unique label
      HttpResponse response = Continuation.getResponse(labels[0]);
      // Set the result variable
      String result = response.getBody();
      String responseStatus = response.getStatus();
      Integer i = response.getStatusCode();
      System.debug('## Response status -> ' + responseStatus + ' - ' + i);
      
      TechnicalObj tObj = (TechnicalObj)state;
      System.debug('## Continuation state -> ' + tObj.tab);

      HDT_WRP_AccountStatement.ReturnObj restMessage = (HDT_WRP_AccountStatement.ReturnObj)JSON.deserialize(result, HDT_WRP_AccountStatement.ReturnObj.class);

      ResponseCtrl r = new ResponseCtrl();
      r.success = true;
      r.message = String.valueOf(restMessage.status + ' - ' + String.valueOf(restMessage.data.size()));

      for(Integer n=0; n<restMessage.data.size(); n++){
        System.debug('# ' + restMessage.data[n].idPrimoLivelloSAP);   
    }

      System.debug('#### FINISH ####');
      return r;
    }

    public static HttpRequest setHttpRequest(){

        HDT_WRP_HttpDataBodyRow bodyRow = new HDT_WRP_HttpDataBodyRow();
        bodyRow.applicativo = 'home';
        String body = JSON.serialize(bodyRow, true);

        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint('https://monted-dev-ed.my.salesforce.com/services/apexrest/getAccountStatement/0');
        req.setHeader('Authorization', 'Bearer ' + Label.MockSessionId);
        req.setHeader('Content-Type', 'application/json');
        req.setbody(body);
        return req;
    }

    public class TechnicalObj {
        public String tab;
        public String obj;
    }

    public class ResponseCtrl {
        @AuraEnabled public Boolean success;
        @AuraEnabled public String message;
        @AuraEnabled public String body;
    }

}