/**
 * @description       : 
 * @author            : Giacinto Florio
 * @group             : 
 * @last modified on  : 12-10-2022
 * @last modified by  : Giacinto Florio
**/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global inherited sharing class HDT_WS_SegnalazioniTari implements wrts_prcgvr.Interfaces_1_0.IApexCalloutAction {

    private final static String PHASE_OK = 'Inviata a SAP'; 
    private final static String PHASE_KO = 'Inviata a SAP';
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

            System.debug('ResponseMrr --> ' + responseMrr);

            //wrpResponses = hpsmUtl.manipulateResponse(responseMrr);

            System.debug('WRPResponse --> ' + wrpResponses);
            //caseToUpdate = hpsmUtl.handleResponse(wrpResponses, currentCase);

            map<String,String> fieldValueResponse = new map<String,String>();
            List<wrts_prcgvr.MRR_1_0.field> fieldsResponse = responseMrr?.responses?.get(0)?.objects?.get(0)?.fields;
            fieldsResponse=fieldsResponse?.isEmpty()==false? fieldsResponse : new List<wrts_prcgvr.MRR_1_0.field>();
            for(wrts_prcgvr.MRR_1_0.field field : fieldsResponse){                        
                fieldValueResponse.put(field.name,field.value);
            }

            if ( !'OK'.equalsIgnoreCase(fieldValueResponse.get('result'))) {
                // ord.DiscardReason__c = responseService.responses[0].description;
                //ord.Phase__c = 'Comunicazione verso Heroku KO';
                system.debug('KO RICEVUTO');
                caseToUpdate.TecnicalPhase__c=PHASE_KO;
            }else{
                system.debug('OK RICEVUTO');
                if(String.isNotBlank(fieldValueResponse.get('COD_PRAT_UTENTE'))){
                    caseToUpdate.HerokuPracticeCode__c = fieldValueResponse.get('COD_PRAT_UTENTE');
                }else if(String.isNotBlank(responseMrr.responses[0].header.requestId)){
                    caseToUpdate.HerokuPracticeCode__c = responseMrr.responses[0].header.requestId;
                }
                caseToUpdate.TecnicalPhase__c = 'OK'.equalsIgnoreCase(fieldValueResponse.get('result'))? PHASE_OK : PHASE_KO; // ??? MODIFICARE O TOGLIERE
            }

            system.debug('FINAL PRE UPDATE '+caseToUpdate.TecnicalPhase__c+ ' '+caseToUpdate.Phase__c);

            // HRAWRM-1671 (5 Modifiche Flusso di Invio e Annullamento)
            if(currentCase.Type.equalsIgnoreCase('Gestione Rifiuti') /*&& caseToUpdate.StartAppointment__c==null*/ && currentCase.WithdrawalFee__c==false && currentCase.ServicePoint__c!=null){
                Datetime createdDate = currentCase.CreatedDate;
                Date dataUltimoRitiro = Date.newinstance(createdDate.year(), createdDate.month(), createdDate.day());
                System.debug('HDT_WS_SegnalazioniTari check -> ');
                FreeWithdraw__c ritiro = new FreeWithdraw__c(
                    LastFreeWithdrawDate__c = dataUltimoRitiro,
                    ServicePoint__c = currentCase.ServicePoint__c
                );

                System.debug('HDT_WS_SegnalazioniTari ritiro -> ' + ritiro);
                HDT_UTL_DatabaseService.insertSObject(ritiro);
            }
                


            if(!Test.isRunningTest()){
                HDT_UTL_DatabaseService.updateSObject(caseToUpdate);
            }
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



}