global inherited sharing class HDT_SRV_HerokuPostSalesManager implements wrts_prcgvr.Interfaces_1_0.IApexCalloutAction {

    private static HDT_QR_HerokuPostSalesManager hpsmQr = new HDT_QR_HerokuPostSalesManager();
    private static HDT_UTL_HerokuPostSalesManager hpsmUtl = new HDT_UTL_HerokuPostSalesManager();

    global Object execute(Object args) {

        wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse response = new wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse();
        wrts_prcgvr.MRR_1_0.MultiResponse responseMrr  = new wrts_prcgvr.MRR_1_0.MultiResponse();
        wrts_prcgvr__CalloutTemplate__c record = new wrts_prcgvr__CalloutTemplate__c();
        Map<String,Object> arg = new Map<String,Object>();
        List<Case> caseToUpdate = new List<Case>();
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
        SObject obj = (SObject) argsMap.get('sender');
        Object templateMap = argsMap.get('templateMap');
        Map<String,String> parameters = (Map<String,String>)argsMap.get('parameters');
       

     try{
        ticket = (String) obj.get('Id');
        currentCase = (Case) obj;
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

        System.debug('mrrList--> '+mrrList);

        wrts_prcgvr.Interfaces_1_0.ICalloutClient client = 
            (wrts_prcgvr.Interfaces_1_0.ICalloutClient) wrts_prcgvr.VersionManager.newClassInstance('CalloutClient');
        responseMrr  =  (wrts_prcgvr.MRR_1_0.MultiResponse) client.send(arg);
       /*HttpRequest req = new HttpRequest();
         req.setEndpoint(endpoint);
         req.setMethod('POST');
         req.setBody(wrts_prcgvr.MRR_1_0.serializeMultiRequest(mrrList));
         Http http = new Http();
         HTTPResponse res = http.send(req);
 
         System.debug('Body --> '+res.getBody());
         System.debug(res.getStatusCode());
         System.debug(res.getStatus());*/


       

    }catch(Exception ex){

        System.debug(ex.getMessage());
        return ex.getMessage();

    }

    System.debug('ResponseMrr --> '+responseMrr);

    wrpResponses = hpsmUtl.manipulateResponse(responseMrr);

    System.debug('WRPResponse --> '+wrpResponses);
    caseToUpdate = hpsmUtl.handleResponse(wrpResponses, currentCase);
    
    if(caseToUpdate != null && caseToUpdate.size() > 0){
        String serializedCase = JSON.serialize(caseToUpdate[0]);
        updateFuture(serializedCase);
    }
    

    response.success = true;
    response.message = 'OK';
    return response;
     
}

    @Future
    private static void updateFuture(String inputString){

        Case c = (Case) JSON.deserialize(inputString, Case.class);

        HDT_UTL_DatabaseService.updateSObject(c);

    }


    public String handleInboundRequest(HDT_WRP_MrrRequest.HDT_WRP_Request request){

        List<Case> caseUpdate = new List<Case>();

        HDT_WRP_HerokuPostSalesManager reqWrp = hpsmUtl.manipulateRequest(request);
        
        caseUpdate = hpsmUtl.handleRequest(reqWrp);

        if(caseUpdate.size() > 0){
            
            HDT_UTL_DatabaseService.updateSObject(caseUpdate);

        }

        return null;

    }

 }
