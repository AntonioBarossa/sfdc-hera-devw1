/*
    @Author:        Francesco Vitiello
    CreatedDate:    21/10/2021
    Reason: Avoid Using Global Modifier
*/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global inherited sharing class HDT_WS_Payments implements wrts_prcgvr.Interfaces_1_0.IApexCalloutAction {

    HDT_SRV_Payments paymentsSrv = new HDT_SRV_Payments();
    HDT_UTL_CreatePaymentsRequestBody paymentsUtl = new HDT_UTL_CreatePaymentsRequestBody();

    global Object execute(Object args){

        wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse responseReturn = new wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse();

        Map<String,Object> argsMap = (Map<String,Object>) args;
        //SObject transition = (SObject) argsMap.get('transition'); //phase transition
        //SObject action = (SObject) argsMap.get('action'); //phase transition detail
        String method = (String) argsMap.get('method');
        SObject obj = (SObject) argsMap.get('sender');

        HttpRequest request = new HttpRequest();
        Http http = new Http();
        HttpResponse response = new HttpResponse();
        //String result;
        String recordId;
        String depositMode;
        String process;
        String requestBody;
        String endpoint = 'Callout:' + method;

        recordId = (String) obj.get('Id');
        depositMode = (String) obj.get('DepositPaymentMode__c');
        process = (String) obj.get('Type');
        requestBody = paymentsSrv.createRequestBody(method, recordId);

        try{

            request.setEndpoint(endpoint);
            request.setMethod('POST');
            request.setBody(requestBody);
            request.setTimeout(120000);
            request.setHeader('Accept','application/json');
            request.setHeader('Content-Type','application/json');

            response = http.send(request);

        }catch(Exception e){

            response = null;

        }

        
        paymentsUtl.handleResponse(recordId, process, depositMode, response);
        
        responseReturn.success = true;
        responseReturn.message = 'OK';
        return responseReturn;

    }

}
