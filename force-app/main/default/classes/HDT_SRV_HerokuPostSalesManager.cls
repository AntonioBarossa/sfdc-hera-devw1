global inherited sharing class HDT_SRV_HerokuPostSalesManager implements wrts_prcgvr.Interfaces_1_0.IApexCalloutAction {

    private static HDT_QR_HerokuPostSalesManager hpsmQr = new HDT_QR_HerokuPostSalesManager();
    private static HDT_UTL_HerokuPostSalesManager hpsmUtl = new HDT_UTL_HerokuPostSalesManager();

    global Object execute(Object args) {

        wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse response = new wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse();
        wrts_prcgvr.MRR_1_0.MultiResponse responseMrr  = new wrts_prcgvr.MRR_1_0.MultiResponse();
        wrts_prcgvr__CalloutTemplate__c record = new wrts_prcgvr__CalloutTemplate__c();
        Map<String,Object> arg = new Map<String,Object>();
        Case currentCase = new Case();
        String ticket;
        String code;

        //fake code

        HDT_WRP_HerokuPostSalesProva.HDT_WRP_MultiResponse mrrResponse = new HDT_WRP_HerokuPostSalesProva.HDT_WRP_MultiResponse();

        //fake code

        List<HDT_WRP_HerokuPostSalesManager> wrpResponses = new List<HDT_WRP_HerokuPostSalesManager>();
        String outputResult;


        Map<String,Object> argsMap = (Map<String,Object>) args;
        SObject transition = (SObject) argsMap.get('transition'); //phase transition
        SObject action = (SObject) argsMap.get('action'); //phase transition detail
        String method = (String) argsMap.get('method');
        Sobject obj = (sObject) argsMap.get('sender');
        Object templateMap = argsMap.get('templateMap');
        Map<String,String> parameters = (Map<String,String>)argsMap.get('parameters');
       

     try{
        ticket = (String) obj.get('Id');
        currentCase = hpsmQr.getCurrentCaseById(ticket);
        code = hpsmUtl.getCodeFromPhaseTransition(currentCase);
        record = hpsmQr.getCalloutTemplateByCode(code);

        wrts_prcgvr.Interfaces_1_0.IEndpointRulesIntegration endpointUtils = 
            (wrts_prcgvr.Interfaces_1_0.IEndpointRulesIntegration) wrts_prcgvr.VersionManager.newClassInstance('EndpointRulesIntegration');
      
       String endpoint = endpointUtils.getEndpoint(new Map<String,Object>{'Case'=>currentCase});
       System.debug('endpoint ' + endpointUtils.getEndpoint(new Map<String,Object>{'Case'=>currentCase}));
       
       argsMap.put('template', record);
        wrts_prcgvr.Interfaces_1_0.ICalloutTemplateMng templateEngine =
            (wrts_prcgvr.Interfaces_1_0.ICalloutTemplateMng) wrts_prcgvr.VersionManager.newClassInstance('CalloutTemplateMng');

        argsMap = (Map<String,Object>) templateEngine.getTemplate(argsMap);
        argsMap = (Map<String,Object>) templateEngine.applyTemplate(argsMap);
        System.debug('parameters ' + parameters);
        System.debug('argsMap ' + argsMap);

        wrts_prcgvr.MRR_1_0.MultiRequest mrrList = (wrts_prcgvr.MRR_1_0.MultiRequest) argsMap.get('multirequest');
        
        

        arg.put('endpoint', endpoint);
        arg.put('timeout', 12000);
        arg.put('payload',mrrList);
        arg.put('clientType','REST');
        arg.put('contentType','application/json');

        wrts_prcgvr.Interfaces_1_0.ICalloutClient client = 
            (wrts_prcgvr.Interfaces_1_0.ICalloutClient) wrts_prcgvr.VersionManager.newClassInstance('CalloutClient');
        //Da riabilitare quando sarà chiaro che la response venga correttamente valorizzata.
        //responseMrr  =  (wrts_prcgvr.MRR_1_0.MultiResponse) client.send(arg);
        //Da riabilitare quando sarà chiaro che la response venga correttamente valorizzata.
       /*HttpRequest req = new HttpRequest();
         req.setEndpoint(endpoint);
         req.setMethod('POST');
         req.setBody(wrts_prcgvr.MRR_1_0.serializeMultiRequest(mrrList));
         Http http = new Http();
         HTTPResponse res = http.send(req);
 
         System.debug('Body --> '+res.getBody());
         System.debug(res.getStatusCode());
         System.debug(res.getStatus());*/


        //fake code

        mrrResponse = hpsmUtl.createFakeResponse(currentCase);

        //fake code

       

    }catch(Exception ex){

        System.debug(ex.getMessage());
        return ex.getMessage();

    }

    wrpResponses = hpsmUtl.manipulateResponse(mrrResponse);
    outputResult = hpsmUtl.handleResponse(wrpResponses, currentCase);
    

    System.debug('ResponseMrr --> '+responseMrr);

    /*for (wrts_prcgvr.MRR_1_0.Response responseTry : responseMrr.responses){


        System.debug('#Header Response --> '+responseTry.header);
        System.debug('#Code Response --> '+responseTry.code);
        System.debug('#Description Response --> '+responseTry.description);
        System.debug('#Object Response --> '+responseTry.objects);

    }*/

    response.success = true;
    response.message = 'OK';
    return response;
     
    }

 }
