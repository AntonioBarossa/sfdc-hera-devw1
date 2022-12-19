/**​
* @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)​
* @date 13/04/2021
* @description HDT_WS_SalesApexCalloutAction – Callout action for custom behavior of Sales Phase Manager
* @history Inserire Nome Cognome – Data Modifica – Descrizione della modifica​
*/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global inherited sharing class HDT_WS_SalesApexCalloutAction implements wrts_prcgvr.Interfaces_1_0.IApexCalloutAction {

    private static Set<String> methods = new Set<String>{
        'TemporaneaNuovaAttivazioneCreaRich'.toLowerCase(),
        'Annullamento'.toLowerCase(),
        'Ripensamento'.toLowerCase(),
        'SwitchInEECreaRich'.toLowerCase(),
        'SwitchInGasCreaRich'.toLowerCase(),
        'AggScontiBonusEECreaRich'.toLowerCase(),
        'AggScontiBonusGGCreaRich'.toLowerCase(),
        'SubentroEECreaRich'.toLowerCase(),
        'AttivazioneEECreaRich'.toLowerCase(),
        'PrecheckEECreaRich'.toLowerCase(),
        'SubentroGasCreaRich'.toLowerCase(),
        'AttivazioneInDeliberaCreaRich'.toLowerCase(),
        'AttivazioneFuoriDeliberaCreaRich'.toLowerCase(),
        'PrecheckGasCreaRich'.toLowerCase(),
        'AttivazioneConModCreaRich'.toLowerCase(),
        'PreventivoAccettatoSales'.toLowerCase(),
        'PreventivoRifiutatoSales'.toLowerCase(),
        'CambioOffertaGasCreaRich'.toLowerCase(),
        'CambioOffertaEleCreaRich'.toLowerCase(),
        'CambioUsoCreaRich'.toLowerCase(),
        'ConnessioneConAttCreaRich'.toLowerCase(),
        'TempNuovaAttivazionCereaRich'.toLowerCase(),
        'SConVEECreaRich'.toLowerCase(),
        'SConVGasCreaRich'.toLowerCase(),
        'EsecuzioneLavori'.toLowerCase(),
        'ConfPrev'.toLowerCase(),
        'SWRipristinatorioEle'.toLowerCase(),
        'SWRipristinatorioGas'.toLowerCase(),
        'Voltura'.toLowerCase(),
        'SubentroAmbiente'.toLowerCase(),
        'SubentroAmbienteModifica'.toLowerCase(),
        'AttivazAmbiente'.toLowerCase(),
        'CambioTariffaAmbiente'.toLowerCase(),
        'AgevolazioneContestualeAmbiente'.toLowerCase(),
        'AttivazioneAcqua'.toLowerCase(),
        'CambioOffertaAcqua'.toLowerCase(),
        'ConnessioneConAttivazioneAcqua'.toLowerCase(),
        'SubentroAcqua'.toLowerCase(),
        'VolturaAcqua'.toLowerCase()
    };

    @Testvisible
    private static HDT_WS_SalesApexCalloutActionMock mock;

    global Object execute(Object args) {

        Map<String,Object> argsMap = (Map<String,Object>) args;
        SObject action = (SObject) argsMap.get('action');
        SObject obj = (sObject) argsMap.get('sender');
        String method = (String) argsMap.get('method');        
        if(methods.contains(method.toLowerCase())) {
            wrts_prcgvr.MRR_1_0.MultiRequest multirequestObj = getMrrObj(argsMap);
            setHeader(multirequestObj);
            System.debug(multirequestObj.requests[0]);
            Integer count = 0;
            List<Integer> indexOfObjectToRemove = new List<Integer>();
            Map<Integer,Integer> indexOffieldToRemove = new Map<Integer,Integer>();
            Map<String, HDT_CodificaAgevolazione__mdt> codificaAgevolazioni = (method?.containsIgnoreCase('Ambiente') == true)? HDT_CodificaAgevolazione__mdt.getAll() : new Map<String, HDT_CodificaAgevolazione__mdt>();
            /**Rimozione OrderItems non necessaria per Analisi consumi */
            String vasType = (String)obj.get('VASType__c');
            String commercialProduct = (String)obj.get('CommercialProduct__c');
            String commercialProductCode = (String)obj.get('CommercialProductCode__c');
            String commodity = (String)obj.get('CommodityFormula__c');
            if(String.isBlank(vasType) || !vasType.equalsIgnoreCase('VAS Fatturabili'))
            {
                Map<String, wrts_prcgvr.MRR_1_0.Field> fieldsToAdd = new Map<String, wrts_prcgvr.MRR_1_0.Field>();
                wrts_prcgvr.MRR_1_0.WObject processOrder;
                for(wrts_prcgvr.MRR_1_0.WObject w : multirequestObj.requests[0].objects){
                    if(w.id != null && Id.valueOf(w.id, true) == (Id) obj.get('Id') && w.objectType == 'Order'){
                        processOrder = w;

                        for( wrts_prcgvr.MRR_1_0.Field f : w.fields){
                            if( f.name.equalsIgnoreCase('QC') ){
                                Datetime foo = (Datetime)obj.get('SendToDistributorDate__c');
                                String dateFinal = foo.format('yyyy-MM-dd HH:mm:ss');
                                f.value = dateFinal;
                            }
                        }
                    }
                    else if(w.objectType == 'OrderItem'){
                        boolean find = false;
                        Integer k = 0;
                        for( wrts_prcgvr.MRR_1_0.Field f : w.fields){
                            if(f.name.equalsIgnoreCase('Fam_Prod')){
                                if(f.value != null && f.value != '' && f.value== 'Offerta commerciale' ){
                                    find = true;
                                    //indexOffieldToRemove.put(count,k);
                                    break;
                                }
                                else{
                                    indexOffieldToRemove.put(count,k);
                                }
                            }
                            if(f.name.equalsIgnoreCase('AGEVTARI_CODE') && STRING.isNotBlank(f.value) && STRING.isNotBlank(codificaAgevolazioni.get(f.value)?.HerokuTag__c)){
                                String metadataName = f.value?.replaceAll('\\s', '_');
                                fieldsToAdd.put(codificaAgevolazioni.get(metadataName)?.HerokuTag__c, this.createMrrField(codificaAgevolazioni.get(metadataName)?.HerokuTag__c, f.value));//Nome Tag dinamico
                                //f.name = codificaAgevolazioni.get(f.value)?.HerokuTag__c;
                            }
                        }
                        if(!find){
                            indexOfObjectToRemove.add(count);
                        }
                    }

                    count++;
                }
                // for(integer i : indexOffieldToRemove.keyset()){
                //     multirequestObj.requests[0].objects[i].fields.remove(indexOffieldToRemove.get(i));
                // }
                for (integer i = indexOfObjectToRemove.size() - 1 ; i >= 0 ; i--) {
                    multirequestObj.requests[0].objects.remove(indexOfObjectToRemove[i]);
                }
                if(!fieldsToAdd.isEmpty()){
                    processOrder.fields.addAll(fieldsToAdd.values());
                }
                
                //Verificare Se ELE
            }else if ('VAS Fatturabili'.equalsIgnoreCase(vasType) && String.isBlank(commercialProductCode) && 'Analisi Consumi'.equalsIgnoreCase(commercialProduct)
                &&('AggScontiBonusEECreaRich'.equalsIgnoreCase(method) || 'AggScontiBonusGGCreaRich'.equalsIgnoreCase(method)) 
                && 'Energia Elettrica'.equalsIgnoreCase(commodity)){
                this.populateCommercialProductCode((Order)obj, multirequestObj);
            }
        
            try{
                map<String,String> fieldValueResponse = new map<String,String>();
                wrts_prcgvr.MRR_1_0.MultiResponse responseService= makeCallout(multirequestObj, action, getEndpoint(obj));
                //system.debug('Debug response: '+HDT_SRV_BillableVasDeactivation.createLogObj(multirequestObj, responseService, argsMap)?.wrts_prcgvr__Description__c);
                Order ord = new Order();
                ord.id = (id)obj.get('Id');
                ord.AccountId = (id)obj.get('AccountId'); 
                ord.ServicePoint__c = (id)obj.get('ServicePoint__c'); 

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
                    Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_SubentroAmbiente').getRecordTypeId(),
                    Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_ModificaTariffaRimozione').getRecordTypeId(),
                    Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_CambioTariffa').getRecordTypeId(),
                    Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_AttivazioneAmbiente').getRecordTypeId(),
                    Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_AgevolazioniAmbiente').getRecordTypeId(),
                    Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_TemporaneaNuovaAtt').getRecordTypeId(),
                    Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_VolturaConSwitch').getRecordTypeId(),
                    Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_VAS').getRecordTypeId()
                };

                if (responseService.responses[0].objects == null) {
                    if(method.equalsIgnoreCase('Annullamento') || method.equalsIgnoreCase('Ripensamento')){
                        ord.TecnicalPhase__c = method + ' - Comunicazione verso Heroku KO';
                    }
                    else{
                        ord.TecnicalPhase__c = 'Comunicazione verso Heroku KO';
                    }
                    
                    HDT_SRV_Order ordSrv = new HDT_SRV_Order();
                    ordSrv.updateRecord(ord);
                }
                else {

                    wrts_prcgvr.MRR_1_0.WObject objResponse = responseService.responses[0].objects[0];
                    for(wrts_prcgvr.MRR_1_0.field field : objResponse.fields){                        
                        fieldValueResponse.put(field.name,field.value);
                    }
                    if(String.isNotBlank(fieldValueResponse.get('COD_PRAT_UTENTE'))){
                        ord.HerokuPracticeCode__c = fieldValueResponse.get('COD_PRAT_UTENTE');
                    }
                    else if(String.isNotBlank(responseService.responses[0].header.requestId)){
                        ord.HerokuPracticeCode__c = responseService.responses[0].header.requestId;
                    }
                    if(fieldValueResponse.get('result') != null){                        
                        if('OK'.equalsIgnoreCase(fieldValueResponse.get('result'))){
                            ord.DiscardReason__c = '';
                            ord.Description = '';
                            if(fieldValueResponse.get('FASE') != null){
                                if(method.equalsIgnoreCase('Annullamento') || method.equalsIgnoreCase('Ripensamento')){
                                    ord.TecnicalPhase__c = method + ' - Comunicazione verso Heroku OK';
                                    ord.CancellationHerokuPracticeCode__c = responseService.responses[0].header.requestId;
                                }
                                else{                                   
                                    ord.TecnicalPhase__c = fieldValueResponse.get('FASE');
                                    HDT_QR_Order orderQr = new HDT_QR_Order();
                                    Order ordRetrieved = orderQr.getOrderByIdForSalesCallout(ord.id)[0];

                                    switch on fieldValueResponse.get('FASE') {
                                        when 'Ammissibilità KO' {
                                            ord.DiscardReason__c = HDT_UTL_Accents.removeDiacritics(fieldValueResponse.get('DES_ERR_AEEG'));
                                            ord.CausalCode__c = fieldValueResponse.get('CODERR');
                                            ord.DistributorPracticeCode__c = fieldValueResponse.get('COD_PRAT_DISTR');
                                            ord.Description = fieldValueResponse.get('ANNOTAZIONI');
                                            if((ord.CausalCode__c == '032' || ord.CausalCode__c == '033') && (ordRetrieved.ProcessType__c == 'Subentro Gas'  || ordRetrieved.ProcessType__c == 'Prima Attivazione In delibera' || ordRetrieved.ProcessType__c == 'Prima Attivazione Fuori delibera')){
                                                ord.TecnicalPhase__c = 'Annullato';
                                            }
                                        }
                                        when 'Ammissibilità OK' {
                                            ord.DistributorPracticeCode__c = fieldValueResponse.get('COD_PRAT_DISTR');
                                            if( fieldValueResponse.get('DES_ERR_AEEG') != null) {
                                                ord.DiscardReason__c = HDT_UTL_Accents.removeDiacritics(fieldValueResponse.get('DES_ERR_AEEG'));
                                                ord.CausalCode__c = fieldValueResponse.get('CODERR_AEEG');
                                            }
                                            else {
                                                ord.CausalCode__c = fieldValueResponse.get('COD_FLUSSO');
                                            }
                                            if (fieldValueResponse.get('IMP_PREV_DIST') != null) {
                                                ord.EstimateAmount__c = Decimal.valueOf(fieldValueResponse.get('IMP_PREV_DIST'));
                                            }
                                            if(ord.CausalCode__c == '034' && (ordRetrieved.ProcessType__c == 'Subentro Gas' || ordRetrieved.ProcessType__c == 'Prima Attivazione In delibera' || ordRetrieved.ProcessType__c == 'Prima Attivazione Fuori delibera')){
                                                ord.TecnicalPhase__c = 'Annullato';
                                            }
                                        }
                                        when 'Esito KO da DL' {
                                            ord.DiscardReason__c = HDT_UTL_Accents.removeDiacritics(fieldValueResponse.get('TESTO_ERRR'));
                                            ord.DistributorPracticeCode__c = fieldValueResponse.get('COD_PRAT_DISTR');
                                            ord.CausalCode__c = fieldValueResponse.get('COD_FLUSSO');
                                        }
                                        when 'Esito OK da DL' {
                                            ord.DistributorPracticeCode__c = fieldValueResponse.get('COD_PRAT_DISTR');
                                            ord.SapContractActivationDate__c = fieldValueResponse.get('DT_INIZIO_VERT') != null ? Date.valueOf(fieldValueResponse.get('DT_INIZIO_VERT')) : null;
                                            ord.CausalCode__c = fieldValueResponse.get('COD_FLUSSO');
                                        }
                                        when 'Amm. Precheck KO SII' {
                                            ord.PrecheckReasonSII__c = String.isBlank(fieldValueResponse.get('DES_ERR_AEEG')) ? 
                                                                                        fieldValueResponse.get('TESTO_ERRR') : 
                                                                                        fieldValueResponse.get('DES_ERR_AEEG');
                                            ord.CausalCode__c = String.isBlank(fieldValueResponse.get('CODERR_AEEG')) ? 
                                                                                        fieldValueResponse.get('CODERR_ES') : 
                                                                                        fieldValueResponse.get('CODERR_AEEG');
                                            ord.DistributorPracticeCode__c = fieldValueResponse.get('COD_PRAT_DISTR');
                                            ord.DiscardReason__c = (String.isNotBlank(ord.PrecheckReasonSII__c) && String.isNotBlank(ord.CausalCode__c))? ord.CausalCode__c+' - '+ord.PrecheckReasonSII__c 
                                                : (String.isBlank(ord.CausalCode__c))? ord.PrecheckReasonSII__c : ord.CausalCode__c;
                                            if(fieldValueResponse.get('CODERR_ES') == '003' || fieldValueResponse.get('CODERR_ES') == '103'){
                                                ord.IsTechnicalTransfer__c = true;
                                            }
                                        }
                                        when 'Amm. Precheck OK SII' {
                                            ord.DistributorPracticeCode__c = fieldValueResponse.get('COD_PRAT_DISTR');
                                            ord.RemiCode__c = fieldValueResponse.get('EXT_CABINA_REMI');
                                            //ord.VATNumberUdb__c = fieldValueResponse.get('EXT_PIVA_DISTR');
                                            if (ordRetrieved.PrecheckResultSII__c == null || ordRetrieved.PrecheckResultSII__c == '') {
                                                ord.PrecheckResultSII__c = 'OK';
                                            }
                                            ord.PreviousCompany__c = fieldValueResponse.get('Z_RAGSOC_CC');
                                        }
                                        when 'Esito KO da SII' {
                                            ord.PrecheckReasonSII__c = HDT_UTL_Accents.removeDiacritics(fieldValueResponse.get('TESTO_ERRR'));
                                            ord.DistributorPracticeCode__c = fieldValueResponse.get('COD_PRAT_DISTR');
			                                ord.CausalCode__c = fieldValueResponse.get('COD_FLUSSO');
                                        }
                                        when 'Esito OK da SII' {
                                            ord.DistributorPracticeCode__c = fieldValueResponse.get('COD_PRAT_DISTR');
			                                ord.CausalCode__c = fieldValueResponse.get('COD_FLUSSO');
                                        }
                                        when 'Errore lavorazione SAP' {
                                            ord.DiscardReason__c = HDT_UTL_Accents.removeDiacritics(fieldValueResponse.get('NOTE_ERR'));
                                        }
                                        when 'Completata' {
                                            ord.Description = fieldValueResponse.get('NOTA_HK');
                                            ord.SAPImplantCode__c = fieldValueResponse.get('ANLAGE');
                                            ord.OrderODV__c = fieldValueResponse.get('VBELN');
                                            ord.SapContractCode__c = fieldValueResponse.get('VERTRAG');    
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
                            }
                            else if(method.equalsIgnoreCase('Annullamento') || method.equalsIgnoreCase('Ripensamento')){
                                ord.TecnicalPhase__c = method + ' - Comunicazione verso Heroku OK';
                                ord.CancellationHerokuPracticeCode__c = responseService.responses[0].header.requestId;
                            }
                            else if( recordTypeIdsNoPhase.contains((ID) obj.get('RecordTypeId'))){
                                ord.HerokuPracticeCode__c = responseService.responses[0].header.requestId;
                                ord.TecnicalPhase__c = 'Comunicazione verso Heroku OK';
                            }
                        }
                        else{
                            ord.DiscardReason__c = fieldValueResponse.get('errorMessage');

                            if(method.equalsIgnoreCase('Annullamento') || method.equalsIgnoreCase('Ripensamento')){
                                ord.TecnicalPhase__c = method + ' - Comunicazione verso Heroku KO';
                            }
                            else{
                                ord.TecnicalPhase__c = 'Comunicazione verso Heroku KO';
                            }
                            ord.description = fieldValueResponse.get('errorMessage');
                            if(fieldValueResponse.get('errorMessage').contains('Venditore')){
                                wrts_prcgvr__Activity__c act = new wrts_prcgvr__Activity__c();
                                act.Type__c = 'Caricamento Manuale Siebel';
                                act.DiscardCategory__c = 'Manuale';
                                act.RecordTypeId = Schema.getGlobalDescribe().get('wrts_prcgvr__Activity__c').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_RT_Scarto').getRecordTypeId();
                                act.Order__c = ord.Id;
                                act.Account__c = ord.AccountId;
                                act.ServicePoint__c = ord.ServicePoint__c;
                                act.wrts_prcgvr__Status__c = 'Aperta';
                                HDT_UTL_DatabaseService.insertSObject(act);

                            }
                        }
                        HDT_SRV_Order ordSrv = new HDT_SRV_Order();
                        ordSrv.updateRecord(ord);

                        Map<String,String> utilityMap = new Map<String, String>();
                        
                        String errdesc = '';
                        if(String.isNotBlank(fieldValueResponse.get('NOTE_ERR'))){
                            errdesc += HDT_UTL_Accents.removeDiacritics(fieldValueResponse.get('NOTE_ERR')) + '\n';
                        }
                        if(String.isNotBlank(fieldValueResponse.get('DES_ERR_AEEG'))){
                            errdesc += HDT_UTL_Accents.removeDiacritics(fieldValueResponse.get('DES_ERR_AEEG')) + '\n';
                        }
                        if(String.isNotBlank(fieldValueResponse.get('TESTO_ERRR'))){
                            errdesc += HDT_UTL_Accents.removeDiacritics(fieldValueResponse.get('TESTO_ERRR')) + '\n';
                        }
                        if(String.isNotBlank(fieldValueResponse.get('ANNOTAZIONI'))){
                            errdesc += HDT_UTL_Accents.removeDiacritics(fieldValueResponse.get('ANNOTAZIONI'));
                        }

                        utilityMap.put('NOTE_ERR', errdesc);
                        utilityMap.put('DISCARD_MESSAGE', errdesc);
                        utilityMap.put('DATA_ELABORAZIONE', String.isNotBlank(fieldValueResponse.get('DATA_ELABORAZIONE')) ? fieldValueResponse.get('DATA_ELABORAZIONE') :  
                            String.isNotBlank(fieldValueResponse.get('DATA_EVENTO')) ? fieldValueResponse.get('DATA_EVENTO') : '');
                        utilityMap.put('CMP', String.isNotBlank(fieldValueResponse.get('CMP')) ? fieldValueResponse.get('CMP') : '');
                        utilityMap.put('UTENZA', String.isNotBlank(fieldValueResponse.get('UTENZA')) ? fieldValueResponse.get('UTENZA') : '');
                        utilityMap.put('FASE', String.isNotBlank(fieldValueResponse.get('FASE')) ? fieldValueResponse.get('FASE') : '');
                        utilityMap.put('RECORD_ID', ord.id);
                        utilityMap.put('OBJECT_TYPE', 'Order');

                        HDT_UTL_Scarti.handleHerokuResponse(ord.Id,fieldValueResponse.get('ATTIVITA'), fieldValueResponse.get('FASE'), utilityMap);
                        HDT_UTL_Scarti.discardManagement(utilityMap);
                    }
                }

            }
            catch(Exception e ) {
                wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse response = new wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse();
                response.success = false;
                response.message = 'KO';
                return response;
            }
        }

        wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse response = new wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse();
        response.success = true;
        response.message = 'OK';
        return response;
    }

    public wrts_prcgvr.MRR_1_0.MultiRequest getMrrObj(Map<String,Object> argsMap){

        SObject transition = (SObject) argsMap.get('transition');
        SObject obj = (sObject) argsMap.get('sender');
        String idTemplate = (String)transition.get('wrts_prcgvr__CalloutTemplate__c');
        wrts_prcgvr__CalloutTemplate__c tm = [select id, wrts_prcgvr__Code__c, wrts_prcgvr__ConfigurationFile__c, wrts_prcgvr__IncludeNullFields__c,wrts_prcgvr__ObjectType__c, wrts_prcgvr__Structure__c from wrts_prcgvr__CalloutTemplate__c where wrts_prcgvr__Code__c = :idTemplate][0];
        Map<String,String> parameters = (Map<String,String>)argsMap.get('parameters');

        

        Map<String,Object> inputTemplateFunction = new Map<String,Object>();
        inputTemplateFunction.put('sender',obj);
        inputTemplateFunction.put('template',tm);
        inputTemplateFunction.put('parameters',parameters);

        wrts_prcgvr.Interfaces_1_0.ICalloutTemplateMng templateEngine = (wrts_prcgvr.Interfaces_1_0.ICalloutTemplateMng) wrts_prcgvr.VersionManager.newClassInstance('CalloutTemplateMng');
        Object objTemp = templateEngine.getTemplate(inputTemplateFunction);
        Map<String,Object> templateReturn = (Map<String,Object>)templateEngine.applyTemplate(objTemp);
        return (wrts_prcgvr.MRR_1_0.MultiRequest)templateReturn.get('multirequest');        
    }

    public void setHeader(wrts_prcgvr.MRR_1_0.MultiRequest multirequestObj){
        wrts_prcgvr.MRR_1_0.field headerAddValue = new  wrts_prcgvr.MRR_1_0.field();
        headerAddValue.fieldType = 'STRING';
        headerAddValue.name = 'PROCESS_CATEGORY';
        headerAddValue.value = 'sales';
        list<wrts_prcgvr.MRR_1_0.field> headerAttributetoAdd = new list<wrts_prcgvr.MRR_1_0.field>{headerAddValue};
        multirequestObj.requests[0].header.fields = headerAttributetoAdd;
    }

    public wrts_prcgvr.MRR_1_0.MultiResponse makeCallout(wrts_prcgvr.MRR_1_0.MultiRequest multirequestObj, SObject action, String endpoint){
        Map<String,Object> inputClientFunction = new Map<String,Object>();
        inputClientFunction.put('endpoint',endpoint);
        inputClientFunction.put('timeout',60000);
        inputClientFunction.put('payload',multirequestObj);
        inputClientFunction.put('clientType','REST');
        inputClientFunction.put('contentType','application/json');
        wrts_prcgvr.MRR_1_0.MultiResponse responseServiceTemp;
        wrts_prcgvr.Interfaces_1_0.ICalloutClient client = (wrts_prcgvr.Interfaces_1_0.ICalloutClient) wrts_prcgvr.VersionManager.newClassInstance ('CalloutClient');
        if (Test.isRunningTest()){
            responseServiceTemp = (wrts_prcgvr.MRR_1_0.MultiResponse)mock.respond(action);
        }else{
            responseServiceTemp = (wrts_prcgvr.MRR_1_0.MultiResponse) client.send(inputClientFunction);
        }
        return responseServiceTemp;
    }

    public String getEndpoint(SObject sender){
        wrts_prcgvr.Interfaces_1_0.IEndpointRulesIntegration endpointUtils = ( wrts_prcgvr.Interfaces_1_0.IEndpointRulesIntegration)  wrts_prcgvr.VersionManager.newClassInstance('EndpointRulesIntegration');
        String endpoint = endpointUtils.getEndpoint(sender);
        return endpoint;
    }
    
    @TestVisible
    private void populateCommercialProductCode(Order ord,wrts_prcgvr.MRR_1_0.MultiRequest mrrList){
        Id contractId = ord.ContractReference__c;
        Id servicePointId = ord.ServicePoint__c;
        Id parentOrderId = ord.ParentOrder__c;
        Id orderId = ord.Id;
        String commercialProductCode = '';
        String commercialVersion = ''; 
        HDT_QR_Quote quoteQuery = new HDT_QR_Quote();
        try{
            if(String.isNotBlank(contractId) && quoteQuery.getQuoteType(orderId).equalsIgnoreCase('Amendment')){
                HDT_QR_Contract qrContract = new HDT_QR_Contract();
                SBQQ__Subscription__c subscription = qrContract.getSubscriptionFromContract(contractId);
                if(subscription != null){
                    commercialProductCode = subscription.ProductCode__c;
                    commercialVersion = subscription.VersionFormula__c;
                }
            }else if(String.isNotBlank(servicePointId) && String.isNotBlank(parentOrderId)) {
                HDT_QR_OrderItem qrOrderItems = new HDT_QR_OrderItem();
                OrderItem orderItem = qrOrderItems.getOfferActivationItem(parentOrderId,servicePointId);
                if(orderItem != null){
                    commercialProductCode = orderItem.Product2.ProductCode;
                    commercialVersion = orderItem.Product2.Version__c;            
                }
            }
        }catch(Exception e){
            commercialProductCode = '';
            commercialVersion = '';
        }
        
        if (String.isBlank(commercialProductCode) && String.isBlank(commercialVersion)){
            return;
        }
        Boolean changeProfilo = false;
        Boolean changeOfferta = false;
        for(wrts_prcgvr.MRR_1_0.WObject obj : mrrList.requests[0].objects){
            if(obj.objectType!= null && obj.objectType.equalsIgnoreCase('Order')){
                for(wrts_prcgvr.MRR_1_0.Field f : obj.fields){
                    if(f.name.equalsIgnoreCase('OFFERTA')){
                        f.value = commercialProductCode;
                        changeOfferta = true;   
                    }else if (f.name.equalsIgnoreCase('PROFILO')){
                        f.value = commercialVersion;
                        changeProfilo = true;
                    }
                    if (changeOfferta && changeProfilo){
                        break;
                    }
                } 
                if (!changeOfferta){
                    wrts_prcgvr.MRR_1_0.Field offerta = new wrts_prcgvr.MRR_1_0.Field();
                    offerta.name = 'OFFERTA';
                    offerta.fieldType = 'STRING';
                    offerta.value = commercialProductCode;
                    obj.fields.add(offerta);
                }
                if (!changeProfilo){
                    wrts_prcgvr.MRR_1_0.Field profilo = new wrts_prcgvr.MRR_1_0.Field();
                    profilo.name = 'PROFILO';
                    profilo.fieldType = 'STRING';
                    profilo.value = commercialVersion;
                    obj.fields.add(profilo);
                }           
                break;
            }
        }
    }

    private wrts_prcgvr.MRR_1_0.Field createMrrField(String name, Object Value){
        return this.createMrrField(name, value, 'STRING');
    }

    private wrts_prcgvr.MRR_1_0.Field createMrrField(String name, Object value, String type){
        wrts_prcgvr.MRR_1_0.Field field = new wrts_prcgvr.MRR_1_0.Field();
        field.name = name;
        field.fieldType = type;
        field.value = STRING.valueOf(value);
        return field;
    }
}