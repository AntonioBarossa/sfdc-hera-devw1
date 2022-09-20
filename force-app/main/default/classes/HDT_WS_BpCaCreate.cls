/* Classe Che si occupa di eseguire la chiamata al servizio per la creazione del BP-CA 
* Viene richiamata da Process Click sulla fase "Creazione BP-CA"
* Chiama il servizio 
* In caso di risposta positiva: Aggiorna Account, BillingProfile e tutti gli ordini in corso con stesso Account e Billing Profile e aggiorna la fase dell'order per l'invio pratica
* In caso di risposta negativa: Crea activity sull'order per la gestione dello scarto
*/
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

        request.setHeader('Accept','application/json');
        request.setHeader('Content-Type','application/json');
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
