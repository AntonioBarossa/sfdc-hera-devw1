@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing class HDT_WS_DocumentaryInvoices {

    public static HDT_WRP_ReturnObj sendFile(HttpRequest req) {

        HDT_WRP_ReturnObj returnObj = new HDT_WRP_ReturnObj();

        /*
            @Author: Davide Viola - 20/10/2021
            Description: PMD -> Commentate variabili non utilizzate.
        */
        /*Integer initialLimit = Limits.getHeapSize();
        Datetime startTime = Datetime.now();*/

        //HttpRequest req = new HttpRequest();

        try{
            //req.setEndpoint('https://monted-dev-ed.my.salesforce.com/services/apexrest/getFileToPrint/0');
            //req.setMethod('POST');
            //req.setHeader('Authorization', 'Bearer ' + Label.MockSessionId);
            //req.setHeader('Content-Type', 'application/json');
            //req.setbody(bodyString);
            //req.setTimeout(120000); // timeout in milliseconds
        
            // Create a new http object to send the request object
            // A response object is generated as a result of the request  
        
            Http http = new Http();
            HTTPResponse res = http.send(req);

            String responseStatus = res.getStatus();
            System.debug(LoggingLevel.DEBUG, '## Response status -> ' + responseStatus);

            HDT_WRP_ReponseObj responseObj = (HDT_WRP_ReponseObj)JSON.deserialize(res.getBody(), HDT_WRP_ReponseObj.class);

            System.debug(LoggingLevel.DEBUG, '### Response -> ' + responseObj.status);
            System.debug(LoggingLevel.DEBUG, '### Response -> ' + responseObj.correlationId);
            System.debug(LoggingLevel.DEBUG, '### Response -> ' + responseObj.timestamp);
            System.debug(LoggingLevel.DEBUG, '### Response -> ' + responseObj.message);

            if(responseObj.status != 'success'){
                returnObj.success = false;
                returnObj.message = responseObj.message;
                return returnObj;
            }

            returnObj.success = true;
            returnObj.bodyBase64 = responseObj.data.invoice;
            returnObj.message = '';
        } catch (Exception ex){
            System.debug(LoggingLevel.DEBUG, 'ERROR: line [' + ex.getLineNumber() + ']; ' + ex.getMessage());
            returnObj.success = false;
            returnObj.message = 'ERROR: line [' + ex.getLineNumber() + ']; ' + ex.getMessage();       
        }
        return returnObj;
    }

    public class  HDT_WRP_ReturnObj {
        public Boolean success;
        public String bodyBase64;
        public String message;
    }

    public class HDT_WRP_ReponseObj {
        String status;
        String correlationId;
        String timestamp;
        String message;
        HDT_WRP_DataObj data;
    }

    public class HDT_WRP_DataObj {
        String invoice;
    }

}