/**
 * @description       : 
 * @author            : Giacinto Florio
 * @group             : 
 * @last modified on  : 21-10-2022
 * @last modified by  : Giacinto Florio
**/
@SuppressWarnings('PMD.AvoidGlobalModifier, PMD.AvoidDebugStatements')
global inherited sharing class HDT_WS_Agevolazione implements wrts_prcgvr.Interfaces_1_0.IApexCalloutAction {

    private static final String REQUEST_PATH = '/notice';
    private final static String PHASE = 'Documentazione Validata';
    HDT_WS_SalesApexCalloutAction calloutUtl = new HDT_WS_SalesApexCalloutAction();

    global HDT_WS_Agevolazione() {
        return;
    }

    public class HDT_WS_AgevolazioneResponse extends HDT_WS_Response{
        @AuraEnabled public List<HDT_WRP_MulesoftResponse.HDT_WRP_ErrorDetails> errorDetails {get;set;}
        @AuraEnabled public String status {get;set;}
        @AuraEnabled public String correlationId {get;set;}
        @AuraEnabled public String timestamp {get;set;}
        @AuraEnabled public HDT_WRP_ResponseData data {get;set;}
    }

    public class HDT_WRP_ResponseData{
        @AuraEnabled public String esito {get;set;}
    }
    global Object execute(Object args) {
        Map<String,Object> argsMap = (Map<String,Object>) args;
        SObject obj = (sObject) argsMap.get('sender');
        wrts_prcgvr.MRR_1_0.MultiRequest multirequestObj = calloutUtl.getMrrObj(argsMap);

        Map<String,String> mapObj = new Map<String,String>();

        for(wrts_prcgvr.MRR_1_0.WObject w : multirequestObj.requests[0].objects){
            for(wrts_prcgvr.MRR_1_0.Field f : w.fields){
                mapObj.put(f.name, f.value);
            }
        }
        
        HDT_UTL_GenerateMultilevelJson generate = new HDT_UTL_GenerateMultilevelJson(mapObj);
        Map<String, Object> request = generate.generateMap();

        Order ord = (Order) obj;
        Order ordToUpdate = new Order(Id=ord.Id);

        HDT_WS_AgevolazioneResponse res = (HDT_WS_AgevolazioneResponse)HDT_WS_HTTPServiceCall.sendRequest('MulesoftBasePath',REQUEST_PATH,'POST', request, HDT_WS_AgevolazioneResponse.class);
        System.debug(LoggingLevel.DEBUG,'response -> ' + res);

        wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse response = new wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse();
        
        try{
            if(res.status.equalsIgnoreCase('success')){
                ordToUpdate.TecnicalPhase__c=PHASE;

            }else{
                ordToUpdate.TecnicalPhase__c=PHASE;
            }

            if(!Test.isRunningTest()){
                HDT_UTL_DatabaseService.updateSObject(ordToUpdate);
            }

        }catch(Exception ex ) {
            System.debug(LoggingLevel.DEBUG,'exception --> ' + ex.getStackTraceString());
            System.debug(LoggingLevel.DEBUG,'atLine --> ' + ex.getLineNumber());
            System.debug(LoggingLevel.DEBUG,ex.getMessage());
            response.success = false;
            response.message = 'KO';
            return response;
        }
        
        response.success = true;
        response.message = 'OK';
        return response;
    }
}