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
    private final static String PHASE = 'Inviata a SAP';
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
        @AuraEnabled public String noticeId {get;set;}
    }
    global Object execute(Object args) {
        Map<String,Object> argsMap = (Map<String,Object>) args;
        SObject obj = (sObject) argsMap.get('sender');
        List<Case> lcs = [ SELECT Id FROM Case Where Order__c=:obj.Id AND RecordTypeId=:Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_Segnalazioni').getRecordTypeId() WITH SECURITY_ENFORCED LIMIT 1 ];
        wrts_prcgvr.MRR_1_0.MultiRequest multirequestObj = calloutUtl.getMrrObj(argsMap);

        Map<String,String> mapObj = new Map<String,String>();

        for(wrts_prcgvr.MRR_1_0.WObject w : multirequestObj.requests[0].objects){
            for(wrts_prcgvr.MRR_1_0.Field f : w.fields){
                mapObj.put(f.name, f.value);
            }
        }
        mapObj.put('srid', lcs[0].Id);
        
        HDT_UTL_GenerateMultilevelJson generate = new HDT_UTL_GenerateMultilevelJson(mapObj);
        Map<String, Object> request = generate.generateMap();

        system.debug('request '+JSON.serializePretty(request));

        //Case caso = lcs[0];
        Case caseToUpdate = new Case(Id=lcs[0].Id);

        HDT_WS_AgevolazioneResponse res = (HDT_WS_AgevolazioneResponse)HDT_WS_HTTPServiceCall.sendRequest('MulesoftHergoPath',REQUEST_PATH,'POST', request, HDT_WS_AgevolazioneResponse.class);
        System.debug(LoggingLevel.DEBUG,'response -> ' + res);

        wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse response = new wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse();
        
        try{
            if(res.status.equalsIgnoreCase('success')){
                caseToUpdate.Phase__c=PHASE;
            }

            if(STRING.isNotBlank(res.data.noticeId)){//Aggiornare Case Istruttoria
                caseToUpdate.NoticeId__c=res.data.noticeId;
            }
            if(!Test.isRunningTest()){
                system.debug('ivaste update case');
                HDT_UTL_DatabaseService.updateSObject(caseToUpdate);
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