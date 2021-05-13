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
        responseResults.add(new HDT_WRP_HerokuPostSalesManager(responseMrr.responses[0].objects[0].fields, responseMrr.responses[0].header.requestType));
        return responseResults;
        /*for(wrts_prcgvr.MRR_1_0.Response response : responseMrr.responses){
            requestType = response.header.requestType;
            for(wrts_prcgvr.MRR_1_0.WObject wobject : response.objects){
                for(wrts_prcgvr.MRR_1_0.Field fld : wobject.fields){
                    switch on fld.name{
                        when 'result'{

                            result = fld.value;

                        }
                        when 'requestId'{

                            reqId = fld.value;

                        }
                        when 'errorMessage'{

                            errorMessage = fld.value;

                        }
                        when 'rifRich'{

                            refReq = fld.value;

                        }
                        when 'communicationChannel'{

                            communicationChannel = fld.value;

                        }
                        when 'COD_PRAT_UTENTE'{
                            
                            herokuCode = fld.value;    

                        }
                        when 'COD_PRAT_DISTR'{
                            dlCode = fld.value;
                        }
                        when 'COD_PRAT_DISTR'{
                            dlCode = fld.value;
                        }
                        when else{

                            //blank code

                        }

                    }

                }

            }

            responseResults.add(
                new HDT_WRP_HerokuPostSalesManager(requestType,result,errorMessage,refReq,communicationChannel,reqId,herokuCode,dlCode));
        }*/

        

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
       /* for(HDT_WRP_MrrRequest.HDT_WRP_Field field : request.objects[0].fields){

            switch on field.name{

                when 'FLOW_TYPE'{

                    flowType = field.value;

                }when 'METHOD'{

                    flowType = field.value;

                }
                when 'COD_PRAT_UTENTE'{

                    herokuCode = field.value;

                }
                when 'RECORD_ID'{

                    recordId = field.value;

                }
                when 'FASE'{

                    phase = field.value;

                }
                when 'VERTRAG'{

                    contractCode = field.value;

                }
                when 'VERTRAG_ST '{

                    contractStatus = field.value;

                }when 'COD_PRAT_DISTR'{
                    dlCode = fld.value;
                }

            }

        }
        
        return new HDT_WRP_HerokuPostSalesManager(flowType, phase, recordId,herokuCode,contractCode,contractStatus,dlCode);*/
    }


    public List<Case> handleResponse(List<HDT_WRP_HerokuPostSalesManager> responseResults, Case currentCase){

        String phase;
        String herokuCode;
        String dlCode;
        String sendDlDate;
        String errorMessage;

        Case caseNew = new Case();


        List<Case> caseUpdate = new List<Case>();

        for(HDT_WRP_HerokuPostSalesManager responseResult : responseResults){
            switch on responseResult.responseMap.get('REQUEST_TYPE'){
                when 'CREA_RIC'{
                    herokuCode = responseResult.responseMap.get('requestId');
                    dlCode = responseResult.responseMap.get('COD_PRAT_DISTR');
                    sendDlDate = responseResult.responseMap.get('DT_INVIO_DL');
                    errorMessage = responseResult.responseMap.get('errorMessage');
                    System.debug('SRV_Class_result--> '+responseResult.responseMap.get('result'));
                    switch on responseResult.responseMap.get('result'){
                        when 'OK'{
                            phase = 'Comunicazione verso Heroku OK';
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

    public List<case> handleRequest(HDT_WRP_HerokuPostSalesManager reqWrp){
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
                if(currentPhase.indexOf('KO') > -1 && nextPhase.equalsIgnoreCase('Completata')){
                    if(noteSap != null && noteSap != ''){
                        String description = recordCase.Description != null?recordCase.Description:'';
                        currentCase.Description = nowDateFormat + ': ' + noteSap + '\n' + description;
                    }
                }else{
                    currentCase.Phase__c = nextPhase;
                    handleEntityUpdate(reqWrp);
                }
            }
        }

        caseUpdate.add(currentCase);

        return caseUpdate;
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
}