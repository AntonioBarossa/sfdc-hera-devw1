public inherited sharing class HDT_UTL_HerokuPostSalesManager {

    private static HDT_QR_HerokuPostSalesManager hpsmQr = new HDT_QR_HerokuPostSalesManager();

    public String getCodeFromPhaseTransition(Case currentCase){
        String code;
        Map<Id, List<wrts_prcgvr__PhaseTransition__c>> result = new Map<Id, List<wrts_prcgvr__PhaseTransition__c>>();
        List<wrts_prcgvr__PhaseTransition__c> ptList = new List<wrts_prcgvr__PhaseTransition__c>();
        wrts_prcgvr.Interfaces_1_0.IPhaseManagerUtils pMUtils = 
            ((wrts_prcgvr.Interfaces_1_0.IPhaseManagerUtils) wrts_prcgvr.VersionManager.newClassInstance('PhaseManagerUtils'));
        result = (Map<Id, List<wrts_prcgvr__PhaseTransition__c>>) 
            pMUtils.getTransitionCalloutsForObjects(new Map<String, Object> {'triggerNew' => new List<Case>{currentCase}});
        ptList = result.get(currentCase.Id);
        code = ptList[0].wrts_prcgvr__CalloutTemplate__c;
        return code;
    }

    public HDT_WRP_HerokuPostSalesProva.HDT_WRP_MultiResponse createFakeResponse(Case currentCase){
        HDT_UserInputFlow__mdt cl = [SELECT FieldsJSON__c 
        FROM HDT_UserInputFlow__mdt 
        WHERE ProcessType__c = 'prova callout' 
        WITH SECURITY_ENFORCED
        LIMIT 1 ];
        String c = cl.FieldsJSON__c;
        HDT_WRP_HerokuPostSalesProva.HDT_WRP_MultiResponse mrrResponse = 
            (HDT_WRP_HerokuPostSalesProva.HDT_WRP_MultiResponse) JSON.deserialize(c,HDT_WRP_HerokuPostSalesProva.HDT_WRP_MultiResponse.class);
        System.debug('Case Phase --> '+currentCase.Phase__c);
        if(currentCase.Phase__c == 'Da Inviare'){
            return mrrResponse;
        } else {
            return null;
        }
    }

    public List<HDT_WRP_HerokuPostSalesManager> manipulateResponse(wrts_prcgvr.MRR_1_0.MultiResponse responseMrr){

        List<HDT_WRP_HerokuPostSalesManager> responseResults = new List<HDT_WRP_HerokuPostSalesManager>();

        String requestType;
        String result;
        String errorMessage;
        String refReq;
        String communicationChannel;
        String reqId;
        String herokuCode;
        String dlCode;
        try{
            responseResults.add(new HDT_WRP_HerokuPostSalesManager(responseMrr.responses[0].objects[0].fields, responseMrr.responses[0].header.requestType));
        }catch(Exception ex){
            System.debug('Error in Heroku Response');
        }
        return responseResults;
    }

    public HDT_WRP_HerokuPostSalesManager manipulateRequest(HDT_WRP_MrrRequest.HDT_WRP_Request request){

        String flowType;
        String phase;
        String recordId;
        String herokuCode;
        String contractCode;
        String contractStatus;
        String dlCode;

        System.debug('UTL_CLASS_Request--> '+request);
        return new HDT_WRP_HerokuPostSalesManager(request.objects[0].fields); 
    }


    public List<Case> handleResponse(List<HDT_WRP_HerokuPostSalesManager> responseResults, Case currentCase){

        String phase;
        String herokuCode = '';
        String dlCode = '';
        String sendDlDate = '';
        String errorMessage = '';
        String comunicationChannel='';
        String responseStatus='';
        Case caseNew = new Case();


        List<Case> caseUpdate = new List<Case>();

        for(HDT_WRP_HerokuPostSalesManager responseResult : responseResults){
            switch on responseResult.responseMap.get('REQUEST_TYPE'){
                when 'CREA_RIC'{
                    herokuCode = responseResult.responseMap.get('requestId');
                    dlCode = responseResult.responseMap.get('COD_PRAT_DISTR');
                    sendDlDate = responseResult.responseMap.get('DT_INVIO_DL');
                    errorMessage = responseResult.responseMap.get('errorMessage');
                    comunicationChannel = responseResult.responseMap.get('comunicationChannel');
                    responseStatus = responseResult.responseMap.get('result');
                    switch on responseStatus{
                        when 'OK'{
                            switch on comunicationChannel{
                                when 'ATOA'{
                                    phase = responseResult.responseMap.get('FASE');
                                } 
                                when else{
                                    phase = 'Comunicazione verso Heroku OK';
                                }
                            }
                        } 
                        when else{
                            phase = 'Comunicazione verso Heroku KO';
                        }
                    }                    
                } when 'ANNULL'{
                    errorMessage = responseResult.responseMap.get('errorMessage');
                    System.debug('SRV_Class_result--> '+responseResult.responseMap.get('result'));
                    switch on responseResult.responseMap.get('result'){
                        when 'OK'{
                            phase = 'Annullamento - Comunicazione verso Heroku OK';
                        } 
                        when else{
                            //FASE NON PRESENTE
                        }
                    }
                } 
                when else {
                    System.debug('Error non existing request');
                    return null;
                }
            }
        }
        if(responseResults.size()<=0){
            phase = 'Comunicazione verso Heroku KO';
            errorMessage = 'Errore nella risposta da Heroku';
        }
        if(currentCase.Phase__c  == 'Da Inviare' 
        || currentCase.Phase__c == 'Preventivo accettato' 
        || currentCase.Phase__c == 'Comunicazione verso Heroku KO'
        || currentCase.Phase__c == 'Annullamento - Da inviare'){

            System.debug('SRV_Class_Phase--> '+phase);
            System.debug('SRV_Class_HerokuPracticeCode--> '+herokuCode);

            caseNew.Id = currentCase.Id;
            caseNew.Phase__c = phase;
            caseNew.HerokuPracticeCode__c = herokuCode;
            caseNew.Description = errorMessage;
            if(dlCode != null && dlCode != ''){
                caseNew.DistributorPracticeCode__c = dlCode;
            }
            if(sendDlDate != null && sendDlDate != ''){
                caseNew.SendToDistributorDate__c = Date.valueOf(sendDlDate);
            }

            caseUpdate.add(caseNew);

        }

        return caseUpdate;

    }

    public List<Case> handleRequest(HDT_WRP_HerokuPostSalesManager reqWrp){
        List<Case> caseUpdate = new List<Case>();
        Case currentCase = new Case();
        String recordId = reqWrp.requestMap.get('RECORD_ID');
        if(String.isBlank(recordId)) return caseUpdate;
        currentCase.Id = reqWrp.requestMap.get('RECORD_ID');
        Case recordCase = hpsmQr.getCaseRecord(reqWrp.requestMap.get('RECORD_ID'));
        Datetime nowDate = Datetime.now();
        String nowDateFormat = nowDate.format('dd/MM/yyyy h:mm a');
        switch on reqWrp.requestMap.get('METHOD'){
            when 'esito_intermedio'{
                if(reqWrp.requestMap.get('FASE') != null && reqWrp.requestMap.get('FASE') != ''){
                    currentCase.Phase__c = reqWrp.requestMap.get('FASE');
                }
                if(reqWrp.requestMap.get('COD_PRAT_DISTR') != null && reqWrp.requestMap.get('COD_PRAT_DISTR') != ''){
                    currentCase.DistributorPracticeCode__c = reqWrp.requestMap.get('COD_PRAT_DISTR');
                }
                if(reqWrp.requestMap.get('DT_INVIO_DL') != null && reqWrp.requestMap.get('DT_INVIO_DL') != ''){
                    currentCase.SendToDistributorDate__c = Date.valueOf(reqWrp.requestMap.get('DT_INVIO_DL'));
                }if(reqWrp.requestMap.get('IMP_PREV_DIST') != null && reqWrp.requestMap.get('IMP_PREV_DIST') != ''){
                    currentCase.Amount__c = Decimal.valueOf(reqWrp.requestMap.get('IMP_PREV_DIST'));
                }
                if(reqWrp.requestMap.get('TESTO_ERRR') != null && reqWrp.requestMap.get('TESTO_ERRR') != ''){
                    String description = recordCase.Description != null?recordCase.Description:'';
                    currentCase.Description = nowDateFormat + ': ' + reqWrp.requestMap.get('TESTO_ERRR') + '\n' + description;
                }
            }
            when 'esito_finale'{
                String currentPhase = recordCase.Phase__c;
                String nextPhase = reqWrp.requestMap.get('FASE');
                String noteSap = reqWrp.requestMap.get('NOTA_HK');
                String odv = reqWrp.requestMap.get('VBELN');
                String currentDescription = recordCase.Description != null?recordCase.Description:'';
                String newDescription = '';
                if(currentPhase.indexOf('KO') > -1 && nextPhase.equalsIgnoreCase('Completata')){
                    //no action needed
                }else{
                    currentCase.Phase__c = nextPhase;
                    handleEntityUpdate(reqWrp);
                }

                if(noteSap != null && noteSap != ''){
                    newDescription = nowDateFormat + ': ' + noteSap + '\n';
                }
                if(odv != null && odv != ''){
                    newDescription =  nowDateFormat + ': ' + odv + '\n' + newDescription;
                }
                if(String.isNotBlank(newDescription)){
                    currentCase.Description = newDescription + '\n' + currentDescription;
                }
            }
        }

        caseUpdate.add(currentCase);

        return caseUpdate;
    }

    public Case handleRequestRichPass(HDT_WRP_HerokuPostSalesManager reqWrp){
        Case currentCase = new Case();
        String tipo = '';
        String sottotipo = '';
        String cluster = '';
        String processType = '';
        String source = '';
        String codiceCliente = '';
        String pod = '';
        String dataDecorrenza = '';
        Contract contract;
        ServicePoint__c sp;
        Account account;
        HDT_QR_HerokuPostSalesManager qrClass = new HDT_QR_HerokuPostSalesManager();
        try {
            tipo = reqWrp.requestMap.get('TIPO_SIEBEL');
            sottotipo = reqWrp.requestMap.get('SOTTOTIPO_SIEBEL');
            cluster = reqWrp.requestMap.get('CLUSTER');
            processType = reqWrp.requestMap.get('PROCESS_TYPE');
            source = reqWrp.requestMap.get('CANALE');
            codiceCliente = reqWrp.requestMap.get('CODICE_CLIENTE');
            pod = reqWrp.requestMap.get('CODICE_PRESA');
            dataDecorrenza = reqWrp.requestMap.get('DATA_DECORRENZA');
            if(String.isNotBlank(pod)){
                if(String.isNotBlank(codiceCliente))
                    account = qrClass.getAccount(codiceCliente);
                else {
                    account = qrClass.getAccountFromSp(pod);
                }
                if(account != null){
                    if(String.isNotBlank(tipo) && String.isNotBlank(sottotipo)){
                        //REQUEST FROM SAP - MOROSITA
                    }else if(String.isNotBlank(cluster) && String.isNotBlank(processType)){
                        //REQUEST FROM HEROKU - SWITCH OUT - ANNULLAMENTO
                        currentCase.Cluster__c = cluster;
                        currentCase.Type = processType;
                        currentCase.Origin = source;
                    }else {
                        throw new HDT_UTL_RichPassException('Non è stato possibile determinare il processo da creare');
                    }
                    if(cluster != null && String.isNotBlank(cluster)){
                        
                    }
                    currentCase.Origin = source;
                    Contact contact = qrClass.getContact(account.Id);
                    currentCase.AccountId = account.Id;
                    currentCase.FiscalCode__c = account.FiscalCode__c;
                    currentCase.VatNumber__c = account.VATNumber__c;
                    currentCase.ContactId = contact?.Id;
                    currentCase.Mobile__c = contact?.MobilePhone;
                    currentCase.Email__c = contact?.Email;
                    sp = qrClass.getServicePoint(pod);
                    if(sp != null){
                        contract = qrClass.getContract(sp.Id);
                        currentCase.Contract__c = contract?.Id;
                        currentCase.ServicePoint__c = sp.Id;
                        currentCase.BillingProfile__c = Contract?.BillingProfile__c;
                    }else {
                        throw new HDT_UTL_RichPassException('Non è stato possibile recuperare il Service Point');
                    }
                    switch on cluster{
                        when 'Disattivazioni'{
                            currentCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_Disattivazioni').getRecordTypeId();
                            if(dataDecorrenza != null){
                                currentCase.SwitchOutDate__c = Date.valueOf(dataDecorrenza);
                                if(contract != null && contract.EndDate !=null) {
                                    Date dataSwitchOut =  Date.valueOf(dataDecorrenza);
                                    if(dataSwitchOut < contract.EndDate){
                                        currentCase.EarlyRecess__c = true;
                                    }
                                }
                            }
                            currentCase.Status = 'In Lavorazione';
                            currentCase.Phase__c = 'In Lavorazione SAP';
                        }when 'Morosità'{
                            currentCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_Morosita').getRecordTypeId();
                        }when else{
                            throw new HDT_UTL_RichPassException('Errore tecnico nella definizione del RecordType');
                        }
                    }
                }else {
                    throw new HDT_UTL_RichPassException('Non è stato possibile recuperare l\'Account di riferimento');
                }
                
            }else {
                throw new HDT_UTL_RichPassException('POD non valorizzato');
            }            
            HDT_UTL_DatabaseService.insertSObject(currentCase);
            if(currentCase.EarlyRecess__c){
                createActivity(currentCase.Id, '', 'Recesso Anticipato');
            }
            dataEnrichment(pod,null,currentCase.Id);
            currentCase = qrClass.getCaseRecord(currentCase.Id);
        } catch (Exception ex) {
            throw ex;
        }
        return currentCase;
    }

    @future(callout=true)
    private static void dataEnrichment(String pod, String contractCode,String caseId){
        Case currentCase = new Case();
        currentCase.Id = caseId;
        String response = HDT_WS_ArricchimentoDatiTemp.submitRequest(pod, contractCode);
        Case updateCase = HDT_UTL_DataEnrichmentPostSales.handleResponse(response, currentCase);
        if (updateCase != null) {
            HDT_UTL_DatabaseService.updateSObject(updateCase);
        }
    }

    @AuraEnabled
    public static String getAsyncJobByJobItem(String recordId){

        wrts_prcgvr__AsyncJob__c asyncJobRec = new wrts_prcgvr__AsyncJob__c();
        String result;

        asyncJobRec = hpsmQr.getAsyncJobByJobItem(recordId);

        if(asyncJobRec != null){
            if(asyncJobRec.wrts_prcgvr__Status__c == 'Completed'){

                result = 'OK';

            }else if(asyncJobRec.wrts_prcgvr__Status__c == 'Queued' && asyncJobRec.wrts_prcgvr__Details__c != null){
                
                result = 'Error';

            } else {

                result = 'KO';

            }
        } else {

            result = 'KO';

        }

        return result;

    }

    private void handleEntityUpdate(HDT_WRP_HerokuPostSalesManager wrapper){
        String contractCode = wrapper.requestMap.get('VERTRAG');
        String contractStatus = wrapper.requestMap.get('VERTRAG_ST');
        Date contractEndDate;
        try{
            contractEndDate = Date.valueOf(wrapper.requestMap.get('DT_FINE_VERT'));
        }catch(Exception e){
            System.debug('UTL_CLASS_ContractEndDate_error--> '+e.getMessage());
        }
        if(contractCode != null){
           handleContractUpdate(contractCode,contractStatus,contractEndDate);
        }
    }

    private void handleContractUpdate(String contractCode,String contractStatus, Date contractEndDate){
        try{
            String queryString = 'SELECT Id, Status FROM Contract WHERE SAPContractCode__c = \''+contractCode+'\'';
            String objectq = 'Contract';
            List<SObject> recordList = HDT_QR_GenericQuery.getGenericRecords(queryString, objectq);
            Contract contracRecord = (Contract) recordList[0];
            contracRecord.Status = contractStatus;
            //contracRecord.EndDate = contractEndDate;
            Boolean result = HDT_UTL_DatabaseService.updateSObject(contracRecord);
        }catch(Exception ex){
            System.debug(LoggingLevel.WARN, ex.getMessage() + ' at line ' + ex.getLineNumber() + ' of HDT_UTL_HerokuPostSalesManager.handleContractUpdate method');
        }
    }
    private static void createActivity(String recordId, String description, String type){
        String queryString = 'Select id,wrts_prcgvr__Assignees__c, wrts_prcgvr__Subject__c, wrts_prcgvr__DueDateField__c,Name from wrts_prcgvr__ActivityTemplate__c  where Name = \''+ type +'\'';
        String objectName = 'wrts_prcgvr__ActivityTemplate__c';
        List<SObject> listRecord = HDT_QR_GenericQuery.getGenericRecords(queryString, objectName);
        wrts_prcgvr__ActivityTemplate__c template = new wrts_prcgvr__ActivityTemplate__c();
        if(listRecord.size()>0){
            template = (wrts_prcgvr__ActivityTemplate__c) listRecord[0];
            wrts_prcgvr__Activity__c activity = new wrts_prcgvr__Activity__c();
            activity.wrts_prcgvr__ActivityTemplate__c = template.Id;
            activity.Case__c = recordId;
            activity.CausalError__c = description;
            activity.wrts_prcgvr__Description__c = description;
            Boolean insertAct = HDT_UTL_DatabaseService.insertSObject(activity);
        }
    }
    public class HDT_UTL_RichPassException extends Exception {}
}