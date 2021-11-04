@SuppressWarnings('PMD.AvoidGlobalModifier')
global inherited sharing class HDT_SRV_BillableVasDeactivation implements wrts_prcgvr.Interfaces_1_0.IApexCalloutAction {

    
    private static HDT_QR_HerokuPostSalesManager hpsmQr = new HDT_QR_HerokuPostSalesManager();
    private static HDT_UTL_HerokuPostSalesManager hpsmUtl = new HDT_UTL_HerokuPostSalesManager();

    private final static String PHASE_OK = 'Comunicazione verso Heroku OK';
    private final static String PHASE_KO = 'Comunicazione verso Heroku KO';

    private Map<String,String> mapRequestFields = new Map<String,String>();
    
    global HDT_SRV_BillableVasDeactivation(){
        return;
    }

    /*public HDT_SRV_BillableVasDeactivation(HDT_WRP_MrrRequest.HDT_WRP_Request request){
        if (request?.objects?.size()> 0 && request?.objects?.get(0)?.fields?.size() > 0) {
            for(HDT_WRP_MrrRequest.HDT_WRP_Field field : request.objects.get(0).fields){
                if(this.mapRequestFields.get(field.name) == null){
                    this.mapRequestFields.put(field.name,field.value);
                }
            }
        }
    }*/

    public static void handlerAsyncronousNotify(HDT_WRP_MrrRequest.HDT_WRP_Request request){
        HDT_WRP_MrrRequest.HDT_WRP_Field fieldId;
        if (request?.objects?.size()> 0 && request?.objects?.get(0)?.fields?.size() > 0) {
            for(HDT_WRP_MrrRequest.HDT_WRP_Field field : request.objects.get(0).fields){
                if(field.name == 'RECORD_ID'){
                    fieldId=field;
                }
            }
        }
        List<Case> cases;
        if(STRING.isNotBlank(fieldId?.value) && fieldId.value.startsWithIgnoreCase('O-')){
            cases = [SELECT Id FROM Case
                        WHERE RecordType.DeveloperName='HDT_RT_PostSalesVAS' AND Type='Disattivazione VAS'
                        AND (Asset.SBQQ__OrderProduct__r.Order.OrderNumber=:fieldId.value OR Subscription__r.SBQQ__Contract__r.SBQQ__Order__r.OrderNumber=:fieldId.value) AND Status NOT IN ('Closed', 'Bozza')
                        WITH SECURITY_ENFORCED LIMIT 1];
        }
        if(cases?.size()>0){
            fieldId.value=cases[0].Id;
        }
    }
    

    
    public static wrts_prcgvr__Log__c createLogObj(wrts_prcgvr.MRR_1_0.MultiRequest multirequestObj, wrts_prcgvr.MRR_1_0.MultiResponse responseService, Map<String, Object> argsMap) {
        String method = (String) argsMap.get('method');
        wrts_prcgvr__Log__c calloutLog = new wrts_prcgvr__Log__c();
        calloutLog.wrts_prcgvr__Code__c = String.valueof(
            system.now().format('yyyyMMddHHmmssSSS')
        );
        calloutLog.wrts_prcgvr__Message__c = 'PClick CALLOUT-' + method;
        calloutLog.wrts_prcgvr__Description__c =
            'request: \n' +
            wrts_prcgvr.MRR_1_0.serializeMultiRequest(
                new Map<String, Object>{
                    'object' => multirequestObj,
                    'format' => 'JSON'
                }
            ) +
            '\n\n\n\nresponse:\n' +
            wrts_prcgvr.MRR_1_0.serializeMultiResponse(
                new Map<String, Object>{
                    'object' => responseService,
                    'format' => 'JSON'
                }
            );
        return calloutLog; //those debug logs must violate crud permission, those are registered for admins only
    }

    global Object execute(Object args) {
        wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse response = new wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse();
        wrts_prcgvr.MRR_1_0.MultiResponse responseMrr = new wrts_prcgvr.MRR_1_0.MultiResponse();
        wrts_prcgvr__CalloutTemplate__c record = new wrts_prcgvr__CalloutTemplate__c();
        Map<String, Object> arg = new Map<String, Object>();
        //List<Case> caseToUpdate = new List<Case>();
        Case currentCase = new Case();
        String ticket;
        String code;
        Case caseToUpdate;

        //fake code

        //Deprecato
        // HDT_WRP_HerokuPostSalesProva.HDT_WRP_MultiResponse mrrResponse = new HDT_WRP_HerokuPostSalesProva.HDT_WRP_MultiResponse();

        //fake code

        List<HDT_WRP_HerokuPostSalesManager> wrpResponses = new List<HDT_WRP_HerokuPostSalesManager>();
        //String outputResult;

        Map<String, Object> argsMap = (Map<String, Object>) args;
        //SObject transition = (SObject) argsMap.get('transition'); //phase transition
        //SObject action = (SObject) argsMap.get('action'); //phase transition detail
        //String method = (String) argsMap.get('method');
        SObject obj = (SObject) argsMap.get('sender');
        //Object templateMap = argsMap.get('templateMap');
        Map<String, String> parameters = (Map<String, String>) argsMap.get(
            'parameters'
        );

        try {
            ticket = (String) obj.get('Id');
            currentCase = (Case) obj;
            caseToUpdate = new Case(Id=currentCase.Id);
            code = hpsmUtl.getCodeFromPhaseTransition(currentCase);
            record = hpsmQr.getCalloutTemplateByCode(code);

            wrts_prcgvr.Interfaces_1_0.IEndpointRulesIntegration endpointUtils = (wrts_prcgvr.Interfaces_1_0.IEndpointRulesIntegration) wrts_prcgvr.VersionManager.newClassInstance(
                'EndpointRulesIntegration'
            );

            String endpoint = endpointUtils.getEndpoint(
                new Map<String, Object>{ 'Case' => currentCase }
            );
            System.debug(
                'endpoint ' +
                endpointUtils.getEndpoint(
                    new Map<String, Object>{ 'Case' => currentCase }
                )
            );

            argsMap.put('template', record);
            wrts_prcgvr.Interfaces_1_0.ICalloutTemplateMng templateEngine = (wrts_prcgvr.Interfaces_1_0.ICalloutTemplateMng) wrts_prcgvr.VersionManager.newClassInstance(
                'CalloutTemplateMng'
            );

            argsMap = (Map<String, Object>) templateEngine.getTemplate(argsMap);
            argsMap = (Map<String, Object>) templateEngine.applyTemplate(
                argsMap
            );
            System.debug('parameters ' + parameters);
            System.debug('argsMap ' + argsMap);

            wrts_prcgvr.MRR_1_0.MultiRequest mrrList = (wrts_prcgvr.MRR_1_0.MultiRequest) argsMap.get(
                'multirequest'
            );

            arg.put('endpoint', endpoint);
            arg.put('timeout', 12000);
            arg.put('payload', mrrList);
            arg.put('clientType', 'REST');
            arg.put('contentType', 'application/json');

            System.debug('mrrList--> ' + mrrList);

            wrts_prcgvr.Interfaces_1_0.ICalloutClient client = (wrts_prcgvr.Interfaces_1_0.ICalloutClient) wrts_prcgvr.VersionManager.newClassInstance(
                'CalloutClient'
            );
            responseMrr = (wrts_prcgvr.MRR_1_0.MultiResponse) client.send(arg);
            /*HttpRequest req = new HttpRequest();
         req.setEndpoint(endpoint);
         req.setMethod('POST');
         req.setBody(wrts_prcgvr.MRR_1_0.serializeMultiRequest(mrrList));
         Http http = new Http();
         HTTPResponse res = http.send(req);
 
         System.debug('Body --> '+res.getBody());
         System.debug(res.getStatusCode());
         System.debug(res.getStatus());*/

            insert createLogObj(mrrList, responseMrr, argsMap);
        } catch (Exception ex) {
            //Error Handling
            System.debug(ex.getMessage());
        }

        System.debug('ResponseMrr --> ' + responseMrr);

        //wrpResponses = hpsmUtl.manipulateResponse(responseMrr);

        System.debug('WRPResponse --> ' + wrpResponses);
        //caseToUpdate = hpsmUtl.handleResponse(wrpResponses, currentCase);

        if (responseMrr.responses[0].objects == null) {
            // ord.DiscardReason__c = responseService.responses[0].description;
            //ord.Phase__c = 'Comunicazione verso Heroku KO';
            caseToUpdate.Phase__c=PHASE_KO;
        }else{
            map<String,String> fieldValueResponse = new map<String,String>();
            wrts_prcgvr.MRR_1_0.WObject objResponse = responseMrr.responses[0].objects[0];
            for(wrts_prcgvr.MRR_1_0.field field : objResponse.fields){
                fieldValueResponse.put(field.name,field.value);
            }
            if(String.isNotBlank(fieldValueResponse.get('COD_PRAT_UTENTE'))){
                caseToUpdate.HerokuPracticeCode__c = fieldValueResponse.get('COD_PRAT_UTENTE');
            }else if(String.isNotBlank(responseMrr.responses[0].header.requestId)){
                caseToUpdate.HerokuPracticeCode__c = responseMrr.responses[0].header.requestId;
            }
            caseToUpdate.Phase__c = 'OK'.equalsIgnoreCase(fieldValueResponse.get('result'))? PHASE_OK : PHASE_KO;
        }

        system.debug(caseToUpdate);
        if(!Test.isRunningTest()){
            system.enqueueJob(new HDT_QBL_UpdateQueueable(caseToUpdate));
        }

        response.success = true;
        response.message = 'OK';
        return response;
    }

    public class HDT_QBL_UpdateQueueable implements Queueable {
        private Case caseToUpdate;
        public HDT_QBL_UpdateQueueable(){
            return;
        }
        public HDT_QBL_UpdateQueueable(Case c){
            this.caseToUpdate = c;
        }
        public void execute(QueueableContext context){
            HDT_UTL_DatabaseService.updateSObject(caseToUpdate);
        }
    }

    /*@Future
    private static void updateFuture(String inputString){
        system.debug('ivaste updatefuture');
        Case c = (Case) JSON.deserialize(inputString, Case.class);
        HDT_UTL_DatabaseService.updateSObject(c);
    }

    public Boolean isPostSalesOrder(){
        return this.mapRequestFields.get('RECORD_ID').startsWithIgnoreCase('O-');
    }*/
    
}