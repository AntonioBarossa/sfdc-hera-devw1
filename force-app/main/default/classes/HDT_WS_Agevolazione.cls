/**
 * @description       : 
 * @author            : Giacinto Florio
 * @group             : 
 * @last modified on  : 19-01-2023
 * @last modified by  : Giacinto Florio
**/
@SuppressWarnings('PMD.AvoidGlobalModifier, PMD.AvoidDebugStatements')
global inherited sharing class HDT_WS_Agevolazione implements wrts_prcgvr.Interfaces_1_0.IApexCalloutAction {

    private static final String REQUEST_PATH = '/notice';
    private static final String PHASE = 'Inviata a SAP';
    private static final HDT_UTL_GarbageMan utlGarbage = new HDT_UTL_GarbageMan();
    HDT_WS_SalesApexCalloutAction calloutUtl = new HDT_WS_SalesApexCalloutAction();

    global HDT_WS_Agevolazione() {
        return;
    }

    public class HDT_WS_AgevolazioneResponse extends HDT_WS_SegnalazioniTari.HDT_WRP_SegnalazioniTariResponse {
        
    }

    global Object execute(Object args) {
        wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse response = new wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse();

        Map<String,Object> argsMap = (Map<String,Object>) args;
        SObject obj = (sObject) argsMap.get('sender');

        String commercialProduct = (String) obj.get('CommercialProduct__c');
        if('Istruttoria DL116'.equalsIgnoreCase(commercialProduct)){
            List<Case> cases = [SELECT Id 
                                FROM Case 
                                WHERE Order__c=:obj.Id
                                WITH SECURITY_ENFORCED];
                                 
            List<Wrts_prcgvr__PhaseTransition__c> transitions = [SELECT id 
                                                                 FROM Wrts_prcgvr__PhaseTransition__c 
                                                                 WHERE wrts_prcgvr__CalloutTemplate__c = 'HDT_SegnalazioniAmbientali'
                                                                 WITH SECURITY_ENFORCED];
            if (cases.isEmpty() || transitions.isEmpty() ) {
                System.debug(LoggingLevel.DEBUG, 'No Cases or Transitions found.');
                return null;
            }
            return utlGarbage.launchCalloutTemplateSync(cases[0].Id, transitions[0].Id);
        }
        List<Case> lcs = [ SELECT Id FROM Case Where Order__c=:obj.Id AND RecordTypeId=:Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_Segnalazioni').getRecordTypeId() WITH SECURITY_ENFORCED LIMIT 1 ];
        wrts_prcgvr.MRR_1_0.MultiRequest multirequestObj = calloutUtl.getMrrObj(argsMap);

        Map<String,String> mapObj = new Map<String,String>();
        for(wrts_prcgvr.MRR_1_0.WObject w : multirequestObj.requests[0].objects){
            for(wrts_prcgvr.MRR_1_0.Field f : w.fields){
                if('_' != f.name){ mapObj.put(f.name, f.value);}
            }
        }
        mapObj.put('srnumber', lcs[0].Id);
        
        HDT_UTL_GenerateMultilevelJson generate = new HDT_UTL_GenerateMultilevelJson(mapObj);
        Map<String, Object> request = generate.generateMap();

        System.debug(LoggingLevel.DEBUG,'request '+JSON.serializePretty(request));

        //Case caso = lcs[0];

        HDT_WS_AgevolazioneResponse res = (HDT_WS_AgevolazioneResponse)HDT_WS_HTTPServiceCall.sendRequest('MulesoftHergoPath',REQUEST_PATH,'POST', request, HDT_WS_AgevolazioneResponse.class);
        System.debug(LoggingLevel.DEBUG,'response -> ' + JSON.serializePretty(res)); 
        
        try{
            if(STRING.isNotBlank(res?.data?.noticeId)){
                Case caseToUpdate = new Case(Id=lcs[0].Id, Phase__c = PHASE, Outcome__c = HDT_WS_SegnalazioniTari.formatEsito(res?.data));
                caseToUpdate.NoticeId__c = res?.data?.noticeId;
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