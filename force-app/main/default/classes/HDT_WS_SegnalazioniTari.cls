/**
 * @description       : 
 * @author            : Giacinto Florio
 * @group             : 
 * @last modified on  : 20-10-2022
 * @last modified by  : Carmine Scalise
**/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global inherited sharing class HDT_WS_SegnalazioniTari implements wrts_prcgvr.Interfaces_1_0.IApexCalloutAction {

    private static final String REQUEST_PATH = '/notice';
    private static HDT_QR_Account qrAccount = new HDT_QR_Account();
    //private final static String PHASE = 'Documentazione Validata';
    HDT_WS_SalesApexCalloutAction calloutUtl = new HDT_WS_SalesApexCalloutAction();

    global HDT_WS_SegnalazioniTari() {
        return;
    }

    public virtual class HDT_WRP_SegnalazioniTariResponse extends HDT_WS_Response{
        @AuraEnabled public List<HDT_WRP_MulesoftResponse.HDT_WRP_ErrorDetails> errorDetails {get;set;}
        @AuraEnabled public String status {get;set;}
        @AuraEnabled public String correlationId {get;set;}
        @AuraEnabled public String timestamp {get;set;}
        @AuraEnabled public HDT_WRP_ResponseData data {get;set;}
    }

    public class HDT_WRP_ResponseData{
        @AuraEnabled public String outcome {get;set;}
        @AuraEnabled public String errorMessage {get;set;}
        @AuraEnabled public String noticeId {get;set;}
    }

    global Object execute(Object args) {
        wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse response = new wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse();
        wrts_prcgvr.MRR_1_0.MultiResponse responseMrr = new wrts_prcgvr.MRR_1_0.MultiResponse();
        wrts_prcgvr__CalloutTemplate__c record = new wrts_prcgvr__CalloutTemplate__c();
        Map<String, Object> arg = new Map<String, Object>();

        List<HDT_WRP_HerokuPostSalesManager> wrpResponses = new List<HDT_WRP_HerokuPostSalesManager>();
        Map<String, Object> argsMap = (Map<String, Object>) args;
        Case caso = (Case) argsMap.get('sender');
        Map<String, String> parameters = (Map<String, String>) argsMap.get(
            'parameters'
        );

        try {
            wrts_prcgvr.MRR_1_0.MultiRequest multirequestObj = calloutUtl.getMrrObj(argsMap);
    
            Map<String,String> mapObj = new Map<String,String>();
            for(wrts_prcgvr.MRR_1_0.WObject w : multirequestObj.requests[0].objects){
                for(wrts_prcgvr.MRR_1_0.Field f : w.fields){
                    if('_' != f.name){ mapObj.put(f.name, f.value);}
                }
            }
            handleModifyRequest(caso, mapObj);

            HDT_UTL_GenerateMultilevelJson gen = new HDT_UTL_GenerateMultilevelJson(mapObj);
            Map<String, Object> mapToSendCallout = gen.generateMap();
            system.debug(LoggingLevel.DEBUG, json.serializePretty(mapToSendCallout));
            HDT_WRP_SegnalazioniTariResponse res = (HDT_WRP_SegnalazioniTariResponse)HDT_WS_HTTPServiceCall.sendRequest('MulesoftHergoPath',REQUEST_PATH,'POST', mapToSendCallout, HDT_WRP_SegnalazioniTariResponse.class);
            System.debug(LoggingLevel.DEBUG,'response -> ' + JSON.serializePretty(res)); 
            //if(STRING.isNotBlank(res?.data?.noticeId) && STRING.isBlank(caso.NoticeId__c)){
            Case caseToUpdate = new Case(Id=caso.Id, Phase__c = 'Inviata a SAP', Outcome__c = formatEsito(res?.data));
            if(STRING.isNotBlank(res?.data?.noticeId)){
                caseToUpdate.NoticeId__c = res?.data?.noticeId;
            }
            HDT_UTL_DatabaseService.updateSObject(caseToUpdate);
            //}

        } catch (Exception ex) {
            //Error Handling
            System.debug('exception --> ' + ex.getStackTraceString());
            System.debug('atLine --> ' + ex.getLineNumber());
            System.debug(ex.getMessage());
            response.success = false;
            response.message = 'KO';
            return response;
        }

        response.success = true;
        response.message = 'OK';
        return response;
    }

    public static String formatEsito(HDT_WRP_ResponseData data){
        if(STRING.isBlank(data?.outcome)){      return 'KO - Mulesoft'; }
        String esito = data?.outcome + (String.isBlank(data?.errorMessage)? ''  : ' '+data.errorMessage);
        return esito.abbreviate(100);
    }

    private static void handleModifyRequest(Case caso, Map<String, String> mapObj){

        Account acc;
        if(caso.AccountId != null){  acc = qrAccount.getRecordById(caso.AccountId, 'Name, CustomerCode__c');    }

        /*  HANDLE BP FITTIZIO  */
        if(caso.AccountId == null){
            mapObj.putAll(new Map<String, String>
                {
                    'accountIntegrationId' => '1000000000',
                    'csn' => '1000000000'                    
                }
            );
        }
        
        if(STRING.isBlank(acc?.CustomerCode__c)){
            mapObj.putAll(new Map<String, String>
                {
                    'hercontactLastName' => caso.DifferentNameFromTheApplicant__c
                }
            );
        }
        /*  HANDLE BP FITTIZIO  */
        /*  HANDLE APPUNTAMENTO STABS     */
        if(STRING.isNotBlank(caso.NoticeId__c)){
            mapObj.putAll(new Map<String, String>
                {
                    'heraActionsr.0.hertypeDisplayed' => 'Appuntamento',
                    'heraActionsr.0.herstatusDisplayed' => 'Aperto'                    
                }
            );
        }
        if('Rifiutologo'.equalsIgnoreCase(caso.Origin)){
            mapObj.putAll(new Map<String, String>
                {
                    'source' => 'APP_RIF'
                }
            );
        }
        if('Gestione Dotazioni'.equalsIgnoreCase(caso.Type)){
            List<String> materials = mapObj.get('herambienteMateriale').split(';');
            mapObj.put('herambienteMaterialeTcp', materials[0]);
            for(Integer index = 1;index<materials.size();index++){
                mapObj.put('herambienteMateriale'+(index+1)+'Tcp', materials[index]);
            }
            mapObj.remove('herambienteMateriale');
        }
        /*  HANDLE APP DATA     */
    }
}