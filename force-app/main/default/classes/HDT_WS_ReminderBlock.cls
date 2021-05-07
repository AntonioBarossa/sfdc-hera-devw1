global inherited sharing class HDT_WS_ReminderBlock implements wrts_prcgvr.Interfaces_1_0.IApexCalloutAction{
    
    HDT_SRV_ReminderBlock reminderSrv = new HDT_SRV_ReminderBlock();

    global Object execute(Object args){

        wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse responseReturn = new wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse();

        Map<String,Object> argsMap = (Map<String,Object>) args;
        SObject transition = (SObject) argsMap.get('transition'); //phase transition
        SObject action = (SObject) argsMap.get('action'); //phase transition detail
        String method = (String) argsMap.get('method');
        SObject obj = (SObject) argsMap.get('sender');

        HttpRequest request = new HttpRequest();
        Http http = new Http();
        HttpResponse response = new HttpResponse();
        String result;
        String recordId;
        String requestBody;

        recordId = (String) obj.get('Id');
        requestBody = reminderSrv.createRequestBody(recordId);


        try{

            request.setEndpoint('Callout:HDT_ReminderBlock');
            request.setMethod('POST');
            request.setBody(requestBody);
            request.setHeader('Accept','application/json');
            request.setHeader('Content-Type','application/json');

            response = http.send(request);

        }catch(Exception e){

            //blank code

        }

        if(response != null){

            switch on response.getStatusCode(){

                when 200{

                    HDT_WRP_SuccessResponse successResponse = 
                        (HDT_WRP_SuccessResponse) JSON.deserialize(response.getBody(), HDT_WRP_SuccessResponse.class);

                    System.debug('WS_ReminderBlock successResponse--> ' + successResponse);

                }
                when else{

                    HDT_WRP_ErrorResponse errorResponse = 
                        (HDT_WRP_ErrorResponse) JSON.deserialize(response.getBody(), HDT_WRP_ErrorResponse.class);

                    System.debug('WS_ReminderBlock errorResponse--> ' + errorResponse);

                }


            }


        }

        return responseReturn;
    }


    public class HDT_WRP_SuccessResponse{

        public String status;
        public String correlationId;
        public String timestamp;

    }

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
