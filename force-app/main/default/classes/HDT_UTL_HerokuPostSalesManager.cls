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

        for(wrts_prcgvr.MRR_1_0.Response response : responseMrr.responses){

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
                        when else{

                            //blank code

                        }

                    }

                }

            }

            responseResults.add(
                new HDT_WRP_HerokuPostSalesManager(requestType,result,errorMessage,refReq,communicationChannel,reqId,herokuCode));

        }

        return responseResults;

    }

    public HDT_WRP_HerokuPostSalesManager manipulateRequest(HDT_WRP_MrrRequest.HDT_WRP_Request request){

        String flowType;
        String phase;
        String recordId;
        String herokuCode;

        System.debug('UTL_CLASS_Request--> '+request);

        for(HDT_WRP_MrrRequest.HDT_WRP_Field field : request.objects[0].fields){

            switch on field.name{

                when 'FLOW_TYPE'{

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

            }

        }
        
        return new HDT_WRP_HerokuPostSalesManager(flowType, phase, recordId,herokuCode);

    }


    public List<Case> handleResponse(List<HDT_WRP_HerokuPostSalesManager> responseResults, Case currentCase){

        String phase;
        String herokuCode;

        List<Case> caseUpdate = new List<Case>();

        for(HDT_WRP_HerokuPostSalesManager responseResult : responseResults){

            switch on responseResult.responseMap.get('requestType'){

                when 'CREA_RIC'{

                    //if(responseResult.responseMap.get('refReq') == String.valueOf(currentCase.CaseNumber)){

                    herokuCode = responseResult.responseMap.get('reqId');
                    System.debug('SRV_Class_result--> '+responseResult.responseMap.get('result'));

                    switch on responseResult.responseMap.get('result'){

                        when 'OK'{

                            phase = 'Comunicazione verso Heroku OK';

                        } 
                        when else{

                            phase = 'Comunicazione verso Heroku KO';
                        }

                    }

                    //}

                } when else {

                    System.debug('Error non existing request');

                    return null;

                }

            }

        }

        if(currentCase.Phase__c  == 'Da Inviare'){

            System.debug('SRV_Class_Phase--> '+phase);
            System.debug('SRV_Class_HerokuPracticeCode--> '+herokuCode);

            currentCase.Phase__c = phase;
            currentCase.HerokuPracticeCode__c = herokuCode;

            caseUpdate.add(currentCase);

        }

        return caseUpdate;

    }

    public List<case> handleRequest(HDT_WRP_HerokuPostSalesManager reqWrp){

        List<Case> caseUpdate = new List<Case>();
        Case currentCase = new Case();

        currentCase = hpsmQr.getCurrentCaseById(reqWrp.requestMap.get('recordId'));
        
        switch on reqWrp.requestMap.get('flowType'){

            when 'esito_intermedio'{

                currentCase.Phase__c = reqWrp.requestMap.get('phase');

            }
            when 'esito_finale'{

                currentCase.Phase__c = reqWrp.requestMap.get('phase');
                //handleFinalOutcome


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





}
