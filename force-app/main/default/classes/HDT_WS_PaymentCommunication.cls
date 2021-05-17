global inherited sharing class HDT_WS_PaymentCommunication implements wrts_prcgvr.Interfaces_1_0.IApexCalloutAction{

    HDT_SRV_PaymentCommunication paymentSrv = new HDT_SRV_PaymentCommunication();
    HDT_UTL_CreatePaymentsRequestBody paymentsUtl = new HDT_UTL_CreatePaymentsRequestBody();

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
        requestBody = paymentSrv.createRequestBody(recordId);

        try{

            request.setEndpoint('Callout:HDT_PaymentCommunication');
            request.setMethod('POST');
            request.setBody(requestBody);
            request.setHeader('Accept','application/json');
            request.setHeader('Content-Type','application/json');

            response = http.send(request);

        }catch(Exception e){

            //blank code

        }

        paymentsUtl.handleResponse(recordId, response);

        return responseReturn;
    }




}


