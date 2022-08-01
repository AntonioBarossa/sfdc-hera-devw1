@SuppressWarnings('PMD.AvoidGlobalModifier')
global inherited sharing class HDT_WS_Agevolazione implements wrts_prcgvr.Interfaces_1_0.IApexCalloutAction {

    HDT_WS_SalesApexCalloutAction calloutUtl = new HDT_WS_SalesApexCalloutAction();
    private final static String PHASE_OK = 'Documentazione Validata';

    global HDT_WS_Agevolazione() {
        return;
    }

    global Object execute(Object args) {
        Map<String,Object> argsMap = (Map<String,Object>) args;
        wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse response = new wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse();
        SObject action = (SObject) argsMap.get('action');
        SObject obj = (sObject) argsMap.get('sender');
        wrts_prcgvr.MRR_1_0.MultiRequest multirequestObj = calloutUtl.getMrrObj(argsMap);
        String endpoint = calloutUtl.getEndpoint(obj);
        //setHeader(multirequestObj);
        try{
            wrts_prcgvr.MRR_1_0.MultiResponse responseService = calloutUtl.makeCallout(multirequestObj, action, endpoint);

            map<String,String> fieldValueResponse = new map<String,String>();
            List<wrts_prcgvr.MRR_1_0.field> fieldsResponse = responseService?.responses?.get(0)?.objects?.get(0)?.fields;
            fieldsResponse=fieldsResponse?.isEmpty()==false? fieldsResponse : new List<wrts_prcgvr.MRR_1_0.field>();
            for(wrts_prcgvr.MRR_1_0.field field : fieldsResponse){                        
                fieldValueResponse.put(field.name,field.value);
            }

            Order ord = (Order) obj;
            Order ordToUpdate = new Order(Id=ord.Id);

            if ( !'OK'.equalsIgnoreCase(fieldValueResponse.get('result'))) {
                ordToUpdate.TecnicalPhase__c=PHASE_OK;
                //KO
            }else{
                ordToUpdate.TecnicalPhase__c=PHASE_OK;
                //OK
            }
            if(!Test.isRunningTest()){
                HDT_UTL_DatabaseService.updateSObject(ordToUpdate);
            }

        }catch(Exception e ) {
            response.success = false;
            response.message = 'KO';
            return response;
        }
        
        response.success = true;
        response.message = 'OK';
        return response;
    }
}
