public inherited sharing class HDT_WS_Reimbursement {

    public String calloutAccountBalance(String requestString){

        HttpRequest request = new HttpRequest();
        Http http = new Http();
        HttpResponse response = new HttpResponse();
        String result;

        try{

            request.setEndpoint('Callout:HDT_AccountBalance');
            request.setMethod('POST');
            request.setBody(requestString);
            request.setHeader('Accept','application/json');
            request.setHeader('Content-Type','application/json');

            response = http.send(request);

        }catch(Exception e){

            //blank code

        }

        if(response != null){

            switch on response.getStatusCode(){

                when 500{

                    HDT_WRP_ErrorResponse errorResponse = 
                        (HDT_WRP_ErrorResponse) JSON.deserialize(response.getBody(), HDT_WRP_ErrorResponse.class);

                    System.debug('WS_Reimbursement errorResponse--> ' + errorResponse);

                    result = 'Error';

                }

                when 200{

                    //CAPIRE LA STRUTTURA DELLA RISPOSTA POSITIVA;

                }


            }

        }

        // System.debug('WS_Reimbursement StatusCode --> ' + response.getStatusCode());
        // System.debug('WS_Reimbursement Body --> ' + response.getBody());

        return result;

    }

    // Wrappers for response 

    public class HDT_WRP_ErrorResponse{

        public String status;
        public String correlationId;
        public String timestamp;
        public List<HDT_WRP_Error> errorDetails;
    }


    public class HDT_WRP_Error{

        public string code;
        public string message;
        public string additionalInfo;

    }


}
