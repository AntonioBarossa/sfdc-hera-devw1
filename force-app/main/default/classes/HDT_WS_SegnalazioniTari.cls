@SuppressWarnings('PMD.AvoidGlobalModifier')
global inherited sharing class HDT_WS_SegnalazioniTari implements wrts_prcgvr.Interfaces_1_0.IApexCalloutAction {

    private final static String PHASE_OK = 'Completata';
    private final static String PHASE_KO = 'Da Inviare';
    private static HDT_QR_HerokuPostSalesManager hpsmQr = new HDT_QR_HerokuPostSalesManager();
    private static HDT_UTL_HerokuPostSalesManager hpsmUtl = new HDT_UTL_HerokuPostSalesManager();

    global HDT_WS_SegnalazioniTari() {
        return;
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
                endpoint
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
            //MOCK CALLOUT
            //responseMrr = (wrts_prcgvr.MRR_1_0.MultiResponse) client.send(arg);
            //insert HDT_SRV_BillableVasDeactivation.createLogObj(mrrList, responseMrr, argsMap);
        } catch (Exception ex) {
            //Error Handling
            System.debug(ex.getMessage());
        }

        System.debug('ResponseMrr --> ' + responseMrr);

        //wrpResponses = hpsmUtl.manipulateResponse(responseMrr);

        System.debug('WRPResponse --> ' + wrpResponses);
        //caseToUpdate = hpsmUtl.handleResponse(wrpResponses, currentCase);

        if ( !(responseMrr?.responses?.size()>0) || responseMrr?.responses[0]?.objects == null) {
            // ord.DiscardReason__c = responseService.responses[0].description;
            //ord.Phase__c = 'Comunicazione verso Heroku KO';
            system.debug('KO RICEVUTO');
            caseToUpdate.TecnicalPhase__c=PHASE_KO;
        }else{
            system.debug('OK RICEVUTO');
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
            caseToUpdate.TecnicalPhase__c = 'OK'.equalsIgnoreCase(fieldValueResponse.get('result'))? PHASE_OK : PHASE_KO;
        }

        system.debug('FINAL PRE UPDATE '+caseToUpdate.TecnicalPhase__c+ ' '+caseToUpdate.Phase__c);

        //OK PREDEFINITO DA SMOCKARE
        if(caseToUpdate.StartAppointment__c==null){
            caseToUpdate.TecnicalPhase__c= PHASE_OK;
        }else if(currentCase.Type.equalsIgnoreCase('Gestione rifiuti')){
            caseToUpdate.TecnicalPhase__c= 'Inviata a SAP';
        }

        if(!Test.isRunningTest()){
            HDT_UTL_DatabaseService.updateSObject(caseToUpdate);
        }

        response.success = true;
        response.message = 'OK';
        return response;
    }



}