/**​
* @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)​
* @date 13/04/2021
* @description HDT_WS_SalesApexCalloutAction – Callout action for custom behavior of Sales Phase Manager
* @history Inserire Nome Cognome – Data Modifica – Descrizione della modifica​
*/
global inherited sharing class HDT_WS_SalesApexCalloutAction implements wrts_prcgvr.Interfaces_1_0.IApexCalloutAction {

    @Testvisible
    private static HDT_WS_SalesApexCalloutActionMock mock;

    public Object execute(Object args) {
        Map<String,Object> argsMap = (Map<String,Object>) args;
        SObject transition = (SObject) argsMap.get('transition'); //phase transition
        String idTemplate = (String)transition.get('wrts_prcgvr__CalloutTemplate__c');
        wrts_prcgvr__CalloutTemplate__c tm = [select id, wrts_prcgvr__Code__c, wrts_prcgvr__ConfigurationFile__c, wrts_prcgvr__IncludeNullFields__c,wrts_prcgvr__ObjectType__c, wrts_prcgvr__Structure__c from wrts_prcgvr__CalloutTemplate__c where wrts_prcgvr__Code__c = :idTemplate][0];
        SObject action = (SObject) argsMap.get('action'); //phase transition detail
        String method = (String) argsMap.get('method');
        SObject obj = (sObject) argsMap.get('sender');
        wrts_prcgvr.MRR_1_0.field headerAddValue = new  wrts_prcgvr.MRR_1_0.field();
        headerAddValue.fieldType = 'STRING';
        headerAddValue.name = 'PROCESS_CATEGORY';
        headerAddValue.value = 'sales';
        list<wrts_prcgvr.MRR_1_0.field> headerAttributetoAdd = new list<wrts_prcgvr.MRR_1_0.field>{headerAddValue};
        //Object templateMap = argsMap.get('templateMap');
        Map<String,String> parameters = (Map<String,String>)argsMap.get('parameters');

        //custom logic ...

        system.debug(json.serialize(transition));
       
        System.debug('********INPUTFIELD:' + argsMap);
        
        System.debug('********tem:' + idTemplate);
        System.debug('********TM:' + tm);
        System.debug('********sender:' + obj);
        //INIZIO SVILUPPI EVERIS
        System.debug('********method:' +method);
        //FINE SVILUPPI EVERIS
        // Aggiungere if basato su Method e parte static nell header struttura ad oggetto
        
        if( 'TemporaneaNuovaAttivazioneCreaRich'.equalsIgnoreCase(method) || 'Annullamento'.equalsIgnoreCase(method) || 'Ripensamento'.equalsIgnoreCase(method) || 'SwitchInEECreaRich'.equalsIgnoreCase(method) || 'SwitchInGasCreaRich'.equalsIgnoreCase(method) || 'AggScontiBonusEECreaRich'.equalsIgnoreCase(method) || 'AggScontiBonusGGCreaRich'.equalsIgnoreCase(method) || 'SubentroEECreaRich'.equalsIgnoreCase(method) || 'AttivazioneEECreaRich'.equalsIgnoreCase(method) || 'PrecheckEECreaRich'.equalsIgnoreCase(method) || 'SubentroGasCreaRich'.equalsIgnoreCase(method) || 'AttivazioneInDeliberaCreaRich'.equalsIgnoreCase(method) || 'AttivazioneFuoriDeliberaCreaRich'.equalsIgnoreCase(method) || 'PrecheckGasCreaRich'.equalsIgnoreCase(method) || 'AttivazioneConModCreaRich'.equalsIgnoreCase(method) || 'PreventivoAccettatoSales'.equalsIgnoreCase(method) || 'PreventivoRifiutatoSales'.equalsIgnoreCase(method) || 'CambioOffertaGasCreaRich'.equalsIgnoreCase(method) || 'CambioOffertaEleCreaRich'.equalsIgnoreCase(method) || 'CambioUsoCreaRich'.equalsIgnoreCase(method) || 'ConnessioneConAttCreaRich'.equalsIgnoreCase(method) || 'TempNuovaAttivazionCereaRich'.equalsIgnoreCase(method) || 'SConVEECreaRich'.equalsIgnoreCase(method) || 'SConVGasCreaRich'.equalsIgnoreCase(method) || 'EsecuzioneLavori'.equalsIgnoreCase(method) || 'ConfPrev'.equalsIgnoreCase(method) || 'SWRipristinatorioEle'.equalsIgnoreCase(method) || 'SWRipristinatorioGas'.equalsIgnoreCase(method) || /*Everis: Aggiunto metodo Voltura*/ 'Voltura'.equalsIgnoreCase(method)) {
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
            system.debug('*********OBJTEMP:' + ((Map<String,Object>)objTemp).get('templateObject'));
            system.debug('*********inputTemplateFunction:' + inputTemplateFunction);
            Map<String,Object> templateReturn = (Map<String,Object>)templateEngine.applyTemplate(objTemp);
            wrts_prcgvr.MRR_1_0.MultiRequest multirequestObj = (wrts_prcgvr.MRR_1_0.MultiRequest)templateReturn.get('multirequest');
            multirequestObj.requests[0].header.fields = headerAttributetoAdd;
        
            System.debug('********MRRequest:' + multirequestObj);
            Integer count = 0;
            List<Integer> indexOfObjectToRemove = new List<Integer>();
            Map<Integer,Integer> indexOffieldToRemove = new Map<Integer,Integer>();
            for(wrts_prcgvr.MRR_1_0.WObject w : multirequestObj.requests[0].objects){
                system.debug('obj '+w.objectType);
                if(w.objectType == 'OrderItem'){
                    boolean find = false;
                    Integer k = 0;
                    for( wrts_prcgvr.MRR_1_0.Field f : w.fields){
                        System.debug('************Enterfield:' + f.name);
                        if(f.name == 'Fam_Prod'){
                            if(f.value != null && f.value != '' && f.value== 'Offerta commerciale' ){
                                find = true;
                                System.debug('************EnterFIND');
                                indexOffieldToRemove.put(count,k);
                                break;
                            }
                            else{
                                indexOffieldToRemove.put(count,k);
                            }
                        }
                    }
                    if(!find){
                        System.debug('************EnterRemove');
                        indexOfObjectToRemove.add(count);
                    }
                }
                count++;
            }
            for(integer i : indexOffieldToRemove.keyset())
            {
                multirequestObj.requests[0].objects[i].fields.remove(indexOffieldToRemove.get(i));
            }
            for(integer i : indexOfObjectToRemove)
            {
                multirequestObj.requests[0].objects.remove(i);
            }

            ///////////// instanzio e effettuo la chiamata con la request
            Map<String,Object> inputClientFunction = new Map<String,Object>();
            inputClientFunction.put('endpoint',endpoint);
            inputClientFunction.put('timeout',60000);
            inputClientFunction.put('payload',multirequestObj);
            inputClientFunction.put('clientType','REST');
            inputClientFunction.put('contentType','application/json');
            wrts_prcgvr.Interfaces_1_0.ICalloutClient client = (wrts_prcgvr.Interfaces_1_0.ICalloutClient) wrts_prcgvr.VersionManager.newClassInstance ('CalloutClient');
        
            try{

                map<String,String> fieldValueResponse = new map<String,String>();
                wrts_prcgvr.MRR_1_0.MultiResponse responseService;
                if (Test.isRunningTest()){
                     wrts_prcgvr.MRR_1_0.MultiResponse responseServiceTemp = (wrts_prcgvr.MRR_1_0.MultiResponse)mock.respond(action);
                     responseService = responseServiceTemp;
                }else{
                     wrts_prcgvr.MRR_1_0.MultiResponse responseServiceTemp = (wrts_prcgvr.MRR_1_0.MultiResponse)client.send(inputClientFunction);
                     responseService = responseServiceTemp;
                } 

                System.debug('********MRRequest:' + responseService);
                //System.debug('********description:' + responseService.responses[0].description);
                //System.debug('********objects:' + responseService.responses[0].objects);            
                //for()
             //   responseService.responses[0].objects[0].objects[0].objectType == 'OrderItem'
             //   responseService.responses[0].objects[0].objects[0].fields[0].name = 'TEMPLATENAME'
             //   responseService.responses[0].objects[0].objects[0].remove().fields[0].name = 'TEMPLATENAME'
               System.debug('************Before');
                
                Order ord = new Order();
                ord.id = (id)obj.get('Id');

                Set<Id> recordTypeIdsNoPhase = new Set<Id>{
                    Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_ScontiBonus').getRecordTypeId(),
                    Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_Attivazione').getRecordTypeId(),
                    Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_AttivazioneConModifica').getRecordTypeId(),
                    Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_CambioOfferta').getRecordTypeId(),
                    Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_CambioUso').getRecordTypeId(),
                    Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_ConnessioneConAttivazione').getRecordTypeId(),
                    Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_Subentro').getRecordTypeId(),
                    Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_SwitchIn').getRecordTypeId(),
                    Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_SwitchInVolturaTecnica').getRecordTypeId(),
                    Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_TemporaneaNuovaAtt').getRecordTypeId(),
                    Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_VolturaConSwitch').getRecordTypeId()
                };


                if (responseService.responses[0].objects == null) {
                    // ord.DiscardReason__c = responseService.responses[0].description;
                    //ord.Phase__c = 'Comunicazione verso Heroku KO';
                    if(method.equalsIgnoreCase('Annullamento') || method.equalsIgnoreCase('Ripensamento')){
                        ord.TecnicalPhase__c = method + ' - Comunicazione verso Heroku KO';
                    }else{
                        ord.TecnicalPhase__c = 'Comunicazione verso Heroku KO';
                    }
                    
                    HDT_SRV_Order ordSrv = new HDT_SRV_Order();
                    ordSrv.updateRecord(ord);
                } else {

                    wrts_prcgvr.MRR_1_0.WObject objResponse = responseService.responses[0].objects[0];
                    for(wrts_prcgvr.MRR_1_0.field field : objResponse.fields){
                        
                        fieldValueResponse.put(field.name,field.value);
                    }
                    if(String.isNotBlank(fieldValueResponse.get('COD_PRAT_UTENTE'))){
                        ord.HerokuPracticeCode__c = fieldValueResponse.get('COD_PRAT_UTENTE');
                    }else if(String.isNotBlank(responseService.responses[0].header.requestId)){
                        ord.HerokuPracticeCode__c = responseService.responses[0].header.requestId;
                    }
                    if(fieldValueResponse.get('result') != null){
                        
                        if('OK'.equalsIgnoreCase(fieldValueResponse.get('result'))){
                            System.debug('********INSIDE RESULT OK');
                            if(fieldValueResponse.get('FASE') != null){
                                System.debug('********INSIDE FASE NOT NULL');
                                //ord.Phase__c = fieldValueResponse.get('FASE');
                                if(method.equalsIgnoreCase('Annullamento') || method.equalsIgnoreCase('Ripensamento')){
                                    ord.TecnicalPhase__c = method + ' - Comunicazione verso Heroku OK';
                                    ord.CancellationHerokuPracticeCode__c = responseService.responses[0].header.requestId;
                                }else{
                                   
                                    ord.TecnicalPhase__c = fieldValueResponse.get('FASE');
                                    //ord.HerokuPracticeCode__c = fieldValueResponse.get('requestId');//Comment bug 462

                                    HDT_QR_Order orderQr = new HDT_QR_Order();
                                    Order ordRetrieved = orderQr.getOrderByIdForSalesCallout(ord.id)[0];

                                    switch on fieldValueResponse.get('FASE') {
                                        when 'Ammissibilità KO' {
                                            ord.DiscardReason__c = fieldValueResponse.get('DES_ERR_AEEG');
                                            ord.CausalCode__c = fieldValueResponse.get('CODERR');
                                            //ord.HerokuPracticeCode__c = fieldValueResponse.get('COD_PRAT_UTENTE');
                                            ord.DistributorPracticeCode__c = fieldValueResponse.get('COD_PRAT_DISTR');
                                            ord.Description = fieldValueResponse.get('ANNOTAZIONI');

                                             if((ord.CausalCode__c == '032' || ord.CausalCode__c == '033')
                                                 && (ordRetrieved.ProcessType__c == 'Subentro Gas' 
                                                     || ordRetrieved.ProcessType__c == 'Prima Attivazione In delibera'
                                                     || ordRetrieved.ProcessType__c == 'Prima Attivazione Fuori delibera'
                                             )){
                                                 ord.TecnicalPhase__c = 'Annullato';
                                             }
                                        }
                                        when 'Ammissibilità OK' {
                                            //ord.HerokuPracticeCode__c = fieldValueResponse.get('COD_PRAT_UTENTE');
                                            ord.DistributorPracticeCode__c = fieldValueResponse.get('COD_PRAT_DISTR');
                                            if( fieldValueResponse.get('DES_ERR_AEEG') != null) {
                                                ord.DiscardReason__c = fieldValueResponse.get('DES_ERR_AEEG');
                                                ord.CausalCode__c = fieldValueResponse.get('CODERR_AEEG');
                                            } else {
                                                ord.CausalCode__c = fieldValueResponse.get('COD_FLUSSO');
                                            }

                                            if (fieldValueResponse.get('IMP_PREV_DIST') != null) {
                                                ord.EstimateAmount__c = Decimal.valueOf(fieldValueResponse.get('IMP_PREV_DIST'));
                                            }

                                             if(ord.CausalCode__c == '034' 
                                                 && (ordRetrieved.ProcessType__c == 'Subentro Gas' 
                                                     || ordRetrieved.ProcessType__c == 'Prima Attivazione In delibera'
                                                     || ordRetrieved.ProcessType__c == 'Prima Attivazione Fuori delibera'
                                             )){
                                                 ord.TecnicalPhase__c = 'Annullato';
                                             }
                                        }
                                        when 'Esito KO da DL' {
                                            ord.ReasonDL__c = fieldValueResponse.get('TESTO_ERRR');
                                            //ord.HerokuPracticeCode__c = fieldValueResponse.get('COD_PRAT_UTENTE');
                                            ord.DistributorPracticeCode__c = fieldValueResponse.get('COD_PRAT_DISTR');
                                            ord.CausalCode__c = fieldValueResponse.get('COD_FLUSSO');
                                        }
                                        when 'Esito OK da DL' {
                                            ord.DistributorPracticeCode__c = fieldValueResponse.get('COD_PRAT_DISTR');
                                            ord.SapContractActivationDate__c = fieldValueResponse.get('DT_INIZIO_VERT') != null ? Date.valueOf(fieldValueResponse.get('DT_INIZIO_VERT')) : null;
                                            //ord.HerokuPracticeCode__c = fieldValueResponse.get('COD_PRAT_UTENTE');
                                            ord.CausalCode__c = fieldValueResponse.get('COD_FLUSSO');
                                        }
                                        when 'Amm. Precheck KO SII' {
                                            ord.PrecheckReasonSII__c = fieldValueResponse.get('DES_ERR_ES');
                                            ord.CausalCode__c = fieldValueResponse.get('CODERR_ES');
                                            ord.DistributorPracticeCode__c = fieldValueResponse.get('COD_PRAT_DISTR');
                                            //ord.HerokuPracticeCode__c = fieldValueResponse.get('COD_PRAT_UTENTE');

                                            if(fieldValueResponse.get('CODERR_ES') == '003' || fieldValueResponse.get('CODERR_ES') == '103'){
                                                ord.IsTechnicalTransfer__c = true;
                                            }
                                        }
                                        when 'Amm. Precheck OK SII' {
                                            ord.DistributorPracticeCode__c = fieldValueResponse.get('COD_PRAT_DISTR');
                                            //ord.HerokuPracticeCode__c = fieldValueResponse.get('COD_PRAT_UTENTE');
                                            ord.RemiCode__c = fieldValueResponse.get('EXT_CABINA_REMI');
                                            ord.VATNumberUdb__c = fieldValueResponse.get('EXT_PIVA_DISTR');
                                            if (ordRetrieved.PrecheckResultSII__c == null || ordRetrieved.PrecheckResultSII__c == '') {
                                                ord.PrecheckResultSII__c = 'OK';
                                            }
                                            ord.PreviousCompany__c = fieldValueResponse.get('Z_RAGSOC_CC');
                                        }
                                        when 'Esito KO da SII' {
                                            ord.PrecheckReasonSII__c = fieldValueResponse.get('TESTO_ERRR');
                                            ord.DistributorPracticeCode__c = fieldValueResponse.get('COD_PRAT_DISTR');
                                            //ord.HerokuPracticeCode__c = fieldValueResponse.get('COD_PRAT_UTENTE');
			                                ord.CausalCode__c = fieldValueResponse.get('COD_FLUSSO');
                                        }
                                        when 'Esito OK da SII' {
                                            ord.DistributorPracticeCode__c = fieldValueResponse.get('COD_PRAT_DISTR');
                                            //ord.HerokuPracticeCode__c = fieldValueResponse.get('COD_PRAT_UTENTE');
			                                ord.CausalCode__c = fieldValueResponse.get('COD_FLUSSO');
                                        }
                                        when 'Errore lavorazione SAP' {
                                            ord.DiscardReason__c = fieldValueResponse.get('NOTE_ERR');
                                            //ord.HerokuPracticeCode__c = fieldValueResponse.get('COD_PRAT_UTENTE');
                                        }
                                        when 'Completata' {
                                            ord.Description = fieldValueResponse.get('NOTA_HK');
                                            ord.SAPImplantCode__c = fieldValueResponse.get('ANLAGE');
                                            ord.OrderODV__c = fieldValueResponse.get('VBELN');
                                            ord.SapContractCode__c = fieldValueResponse.get('VERTRAG');
                                            //ord.HerokuPracticeCode__c = fieldValueResponse.get('COD_PRAT_UTENTE');
    
                                            if(fieldValueResponse.get('VKONT') != null) {
                                                ord.ContractAccountCode__c = fieldValueResponse.get('VKONT');
    
                                                BillingProfile__c billingProfile = new BillingProfile__c();
                                                billingProfile.Id = ordRetrieved.BillingProfile__c;
                                                billingProfile.ContractAccountCode__c = fieldValueResponse.get('VKONT');
    
                                                HDT_SRV_BillingProfile billingProfileSrv = new HDT_SRV_BillingProfile();
                                                billingProfileSrv.updateRecord(billingProfile);
                                            }
                                        }
                                    }
                                }
                                System.debug('********AFTER UPDATE');
                            }else if(method.equalsIgnoreCase('Annullamento') || method.equalsIgnoreCase('Ripensamento')){
                                ord.TecnicalPhase__c = method + ' - Comunicazione verso Heroku OK';
                                ord.CancellationHerokuPracticeCode__c = responseService.responses[0].header.requestId;
                            }
                            //else if( (ID) obj.get('RecordTypeId') == Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_ScontiBonus').getRecordTypeId()){
                            else if( recordTypeIdsNoPhase.contains((ID) obj.get('RecordTypeId'))){
                                //BonusESconti
                                ord.HerokuPracticeCode__c = responseService.responses[0].header.requestId;
                                ord.TecnicalPhase__c = 'Comunicazione verso Heroku OK';
                            }
                        }
                        else{
                            //INIZIO SVILUPPI EVERIS
                            System.debug('Ricevuto KO Start');
                            ord.DiscardReason__c = fieldValueResponse.get('errorMessage');
                            //ord.Phase__c = 'Comunicazione verso Heroku KO';
                            if(method.equalsIgnoreCase('Annullamento') || method.equalsIgnoreCase('Ripensamento')){
                                ord.TecnicalPhase__c = method + ' - Comunicazione verso Heroku KO';
                            }else{
                                ord.TecnicalPhase__c = 'Comunicazione verso Heroku KO';
                            }
                            ord.description = fieldValueResponse.get('errorMessage');
                            System.debug('Ricevuto KO End');
                            //FINE SVILUPPI EVERIS
                        }
                        HDT_SRV_Order ordSrv = new HDT_SRV_Order();
                        System.debug('Phase aggiorntata--> '+ord);
                        ordSrv.updateRecord(ord);
                    }
                }

            } catch(Exception e ) {
                System.debug('ERRORE RESPONSE 500');
                system.debug(e);
            }
        }
        
       wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse response = new wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse();
        response.success = true;
        response.message = 'OK';
        return response;
  		//return responseService;
    }
}