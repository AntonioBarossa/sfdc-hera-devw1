/**​
* @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)​
* @date 13/04/2021
* @description HDT_WS_SalesApexCalloutAction – Callout action for custom behavior of Sales Phase Manager
* @history Inserire Nome Cognome – Data Modifica – Descrizione della modifica​
*/
global class HDT_WS_SalesApexCalloutAction implements wrts_prcgvr.Interfaces_1_0.IApexCalloutAction {
    global Object execute(Object args) {
        Map<String,Object> argsMap = (Map<String,Object>) args;
        SObject transition = (SObject) argsMap.get('transition'); //phase transition
        String idTemplate = (String)transition.get('wrts_prcgvr__CalloutTemplate__c');
        wrts_prcgvr__CalloutTemplate__c tm = [select id, wrts_prcgvr__Code__c, wrts_prcgvr__ConfigurationFile__c, wrts_prcgvr__IncludeNullFields__c,wrts_prcgvr__ObjectType__c, wrts_prcgvr__Structure__c from wrts_prcgvr__CalloutTemplate__c where wrts_prcgvr__Code__c = :idTemplate][0];
        SObject action = (SObject) argsMap.get('action'); //phase transition detail
        String method = (String) argsMap.get('method');
        Sobject obj = (sObject) argsMap.get('sender');
        wrts_prcgvr.MRR_1_0.field headerAddValue = new  wrts_prcgvr.MRR_1_0.field();
        headerAddValue.fieldType = 'STRING';
        headerAddValue.name = 'PROCESS_CATEGORY';
        headerAddValue.value = 'sales';
        list<wrts_prcgvr.MRR_1_0.field> headerAttributetoAdd = new list<wrts_prcgvr.MRR_1_0.field>{headerAddValue};
        Object templateMap = argsMap.get('templateMap');
        Map<String,String> parameters = (Map<String,String>)argsMap.get('parameters');

        //custom logic ...
       
        System.debug('********INPUTFIELD:' + argsMap);
        
        System.debug('********tem:' + idTemplate);
        
        System.debug('********sender:' + obj);
        // Aggiungere if basato su Method e parte static nell header struttura ad oggetto
        
        if('SwitchInEECreaRich'.equalsIgnoreCase(method) || 'SwitchInGasCreaRich'.equalsIgnoreCase(method)) {
            //////////// Recupero endpoint in base a contesto di oggetto
            wrts_prcgvr.Interfaces_1_0.IEndpointRulesIntegration endpointUtils = ( wrts_prcgvr.Interfaces_1_0.IEndpointRulesIntegration)  wrts_prcgvr.VersionManager.newClassInstance('EndpointRulesIntegration');
            String endpoint = endpointUtils.getEndpoint(obj);
            System.debug('********endpoint:' + endpoint);
        
            //////////// genero MRR per il payload del servizio
            Map<String,Object> inputTemplateFunction = new Map<String,Object>();
            inputTemplateFunction.put('sender',obj);
            inputTemplateFunction.put('template',tm);
            inputTemplateFunction.put('parameters',parameters);
        
            wrts_prcgvr.Interfaces_1_0.ICalloutTemplateMng templateEngine = (wrts_prcgvr.Interfaces_1_0.ICalloutTemplateMng) wrts_prcgvr.VersionManager.newClassInstance('CalloutTemplateMng');
            Object objTemp = templateEngine.getTemplate(inputTemplateFunction);
            //inputTemplateFunction.put('templateObject',objTemp);
            Map<String,Object> templateReturn = (Map<String,Object>)templateEngine.applyTemplate(objTemp);
            wrts_prcgvr.MRR_1_0.MultiRequest multirequestObj = (wrts_prcgvr.MRR_1_0.MultiRequest)templateReturn.get('multirequest');
            multirequestObj.requests[0].header.fields = headerAttributetoAdd;
        
            System.debug('********MRRequest:' + multirequestObj);
        
            ///////////// instanzio e effettuo la chiamata con la request
            Map<String,Object> inputClientFunction = new Map<String,Object>();
            inputClientFunction.put('endpoint',endpoint);
            inputClientFunction.put('timeout',120);
            inputClientFunction.put('payload',multirequestObj);
            inputClientFunction.put('clientType','REST');
            inputClientFunction.put('contentType','application/json');
            wrts_prcgvr.Interfaces_1_0.ICalloutClient client = (wrts_prcgvr.Interfaces_1_0.ICalloutClient) wrts_prcgvr.VersionManager.newClassInstance ('CalloutClient');
        
            try{

                map<String,String> fieldValueResponse = new map<String,String>();
                wrts_prcgvr.MRR_1_0.MultiResponse responseService = (wrts_prcgvr.MRR_1_0.MultiResponse)client.send(inputClientFunction);

                System.debug('********MRRequest:' + responseService);
                wrts_prcgvr.MRR_1_0.WObject objResponse = responseService.responses[0].objects[0];
                for(wrts_prcgvr.MRR_1_0.field field : objResponse.fields){
                    fieldValueResponse.put(field.name,field.value);
                }
                if(fieldValueResponse.get('result') != null){
                    Order ord = new Order();
                    ord.id = (id)obj.get('Id');
                    if('OK'.equalsIgnoreCase(fieldValueResponse.get('result'))){
                        System.debug('********INSIDE RESULT OK');
                        if(fieldValueResponse.get('FASE') != null){
                            System.debug('********INSIDE FASE NOT NULL');
                            ord.Phase__c = fieldValueResponse.get('FASE');
                            System.debug('********AFTER UPDATE');
                        }
                    }
                    else{
                        ord.DiscardReason__c = fieldValueResponse.get('errorMessage');
                        ord.Phase__c = 'Comunicazione verso Heroku KO';
                    }
                    HDT_SRV_Order ordSrv = new HDT_SRV_Order();
                    ordSrv.updateRecord(ord);
                }

            } catch(Exception e ) {
                System.debug('ERRORE RESPONSE 500');
            }
        }
        
       wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse response = new wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse();
        response.success = true;
        response.message = 'OK';
        return response;
  		//return responseService;
    }

}