/* This class calls the BP/CA creation web service exposed by mulesoft
* This service is mandatory for "Acqua" and "Ambiente" commodity
* Since CustomerCode__c on the account and ContractAccountCode__c on BillingProfile need to be populated
* If the request is successful Account, Billing Profile and all orders that shares the same Account and/or Billing Profile are update
* If the request fails a Discard Activity (wrts_prcgvr__Activity__c) is created to track the KO
*/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global inherited sharing class HDT_WS_BpCaCreate implements wrts_prcgvr.Interfaces_1_0.IApexCalloutAction 
{

    private HDT_SRV_BpCaCreate bpCaCreateSrv = new HDT_SRV_BpCaCreate();

    global Object execute(Object args)
    {
        Map<String,Object> argsMap = (Map<String, Object>) args;
        String method = (String) argsMap.get('method');
        SObject inputSobj = (SObject) argsMap.get('sender');


        Http http = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        try
        {
            request.setHeader('Accept','application/json');
            request.setHeader('Content-Type','application/json');
            /* If needed is possible to send the request to a mock
            * It is necessary to configure in the PClick callout
            * the method "mock"
            */
            if(method.equalsIgnoreCase('mock'))
            {
                request.setEndpoint('https://demo4882803.mockable.io/createBpCa');
            }
            else
            {
                request.setEndpoint('Callout:MulesoftBasePath/customer-data/billing-profile');
            }
            request.setMethod('POST');
            request.setBody(bpCaCreateSrv.generateRequest((Order)inputSobj));
            request.setTimeout(12000);


            response = http.send(request);
        }
        /**If request generation/send fails
         * A KO is simulated in order to allow the server to create the 
         * Discard Activity
         */
        catch(Exception e)
        {
            HDT_UTL_BpCaCreate.HDT_WRP_BpCaCreateResponse mockResponse = new HDT_UTL_BpCaCreate.HDT_WRP_BpCaCreateResponse();
            List<HDT_UTL_BpCaCreate.HDT_WRP_ErrorDetails> errorDetails = new List<HDT_UTL_BpCaCreate.HDT_WRP_ErrorDetails>();
            HDT_UTL_BpCaCreate.HDT_WRP_ErrorDetails errorDetail = new HDT_UTL_BpCaCreate.HDT_WRP_ErrorDetails();
            mockResponse.status = 'failed';
            errorDetail.code = 'Error';
            errorDetail.message = e.getMessage();
            errorDetail.additionalInfo = 'Errore Creazione BP CA';
            errorDetails.add(errorDetail);
            mockResponse.errorDetails = errorDetails;
            response.setBody(JSON.serialize(mockResponse));
            response.setStatusCode(500);
        }
        /* Response Handling
        * for further details check HDT_SRV_BpCaCreate
        */
        if(response != null)
        {
            bpCaCreateSrv.handleResponse(response, (Order)inputSobj);
        }

        wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse responseReturn = new wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse();
        responseReturn.success = true;
        responseReturn.message = 'OK';
        return responseReturn;
    }
}
