public inherited sharing class HDT_UTL_CreatePaymentsRequestBody {

    public String createBodyRequest(List<HDT_UTL_WrapperInput> inputs){

        JSONGenerator gen = JSON.createGenerator(true);
        String pretty;

        gen.writeStartObject();

        for(HDT_UTL_WrapperInput input: inputs){

            if(input.isParent){

                for(Map<String, Object> configMap : input.configMapList){

                    writeBody(configMap, gen);

                }
            
            }else if(input.isChild){

                gen.writeFieldName(input.childObjName);
                gen.writeStartArray();
                for(Map<String, Object> configMap : input.configMapList){
                    gen.writeStartObject();
                    writeBody(configMap, gen);
                    gen.writeEndObject();
                }
                gen.writeEndArray();
                
            }

        }

        gen.writeEndObject();

        return gen.getAsString();

    }

    private void writeBody(Map<String, Object> configMap, JSONGenerator gen){

        for(String mapKey : configMap.keySet()){

            if(configMap.get(mapKey) != null){

                if(configMap.get(mapKey) instanceof String){

                    gen.writeStringField(mapKey, (String) configMap.get(mapKey));

                } else if(configMap.get(mapKey) instanceof Integer){

                    gen.writeNumberField(mapKey, (Integer) configMap.get(mapKey));

                }else if(configMap.get(mapKey) instanceof Decimal){

                    gen.writeNumberField(mapKey, (Decimal) configMap.get(mapKey));

                } else if(configMap.get(mapKey) instanceof Date){

                    gen.writeStringField(mapKey, ((Date) configMap.get(mapKey)).format());

                } else if(configMap.get(mapKey) instanceof Boolean){

                    gen.writeBooleanField(mapKey, (Boolean) configMap.get(mapKey));

                }

            }else{

                gen.writeNullField(mapKey);

            }
        }

        return;

    }


    public void handleResponse(String recordId, String process, HttpResponse response){

        Case caseToUpdate = new Case();
        String phase; 

        caseToUpdate.Id = recordId;

        if(response != null){

            HDT_WRP_MinWrapper minWrapper = (HDT_WRP_MinWrapper) JSON.deserialize(response.getBody(), HDT_WRP_MinWrapper.class);

            switch on minWrapper.status{

                when 'success'{

                    HDT_WRP_SuccessResponse successResponse = 
                        (HDT_WRP_SuccessResponse) JSON.deserialize(response.getBody(), HDT_WRP_SuccessResponse.class);

                    System.debug('WS_Payments successResponse--> ' + successResponse);

                    phase = handleSuccessResponse(successResponse, recordId, process);

                    if(phase != null){

                        caseToUpdate.Phase__c = phase;

                    }

                    // if(process == 'Comunicazione Pagamento'
                    // || process == 'Piano Rateizzazione'
                    // || process == 'Paperless'){
                    //     caseToUpdate.Phase__c = 'Inviata a SAP';
                    // }
                    
                }   
                when else{ 

                    HDT_WRP_ErrorResponse errorResponse = 
                        (HDT_WRP_ErrorResponse) JSON.deserialize(response.getBody(), HDT_WRP_ErrorResponse.class);

                    System.debug('WS_Payments errorResponse--> ' + errorResponse);
                    if(process == 'Comunicazione Pagamento'
                    || process == 'Piano Rateizzazione'
                    || process == 'Paperless'){
                        caseToUpdate.Phase__c = 'Esito KO da SAP';
                    }
                    createActivity(recordId, errorResponse.errorDetails[0].message, 'Esito KO da SAP');
                    // if(caseToUpdate.Description != null){
                    //     caseToUpdate.Description += '[' + System.Now().format() + ']: ' + errorResponse.errorDetails[0].message +'\n';
                    // }else{
                    //     caseToUpdate.Description  = '[' + System.Now().format() + ']: ' + errorResponse.errorDetails[0].message +'\n';
                    // }

                }

            }

        } else {

            caseToUpdate.Phase__c = 'Esito KO da SAP';
            createActivity(recordId, 'Comunicazione con SAP fallita', 'Esito KO da SAP');

        }

        updateFuture(JSON.serialize(caseToUpdate));

    }

    public String handleSuccessResponse(HDT_WRP_SuccessResponse response, String recordId, String process){

        String phase = null;

        phase = handlePhaseChange(response, recordId, process, 
            process ==   'Piano Rateizzazione' 
                ? 'Pratica avviata' //successCondition
            : process == 'Comunicazione Pagamento'
                ? '' //successCondition
            : process == 'Paperless' 
                ? '' //successCondition
            : null);

        return phase;

    }

    private String handlePhaseChange(HDT_WRP_SuccessResponse response, String recordId, String process,String condition){
        
        String phase = null;
        String successPhase = 'Esito OK da SAP';
        String failedPhase = 'Esito KO da SAP';

        if(condition != null){

            if(response.data.tipoAttivita.containsIgnoreCase(condition)){

                phase = successPhase;

            } else {

                phase = failedPhase;
                createActivity(recordId, response.data.note, 'Esito KO da SAP');

            }

        }

        return phase;

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

    @Future
    private static void updateFuture(String inputString){

        Case c = (Case) JSON.deserialize(inputString, Case.class);

        HDT_UTL_DatabaseService.updateSObject(c);

    }


    public class HDT_UTL_WrapperInput{

        public Boolean isParent;
        public Boolean isChild;
        public String childObjName;
        public List<Map<String, Object>> configMapList;

    }

    public class HDT_WRP_MinWrapper{

        public String status;
        public String correlationId;
        public String timestamp;

    }

    public class HDT_WRP_SuccessResponse{

        public String status;
        public String correlationId;
        public String timestamp;
        public HDT_WRP_Data data;

    }

    public class HDT_WRP_Data{

        public string rdsRdo;
        public string tipoAttivita;
        public string note;

    }

    public class HDT_WRP_ErrorResponse{

        public String status;
        public String correlationId;
        public String timestamp;
        public List<HDT_WRP_Error> errorDetails;
    }


    public class HDT_WRP_Error{

        public string code;
        public string message;
        public string additionalInfo;

    }


}
