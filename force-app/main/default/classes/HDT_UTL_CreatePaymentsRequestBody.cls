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

        caseToUpdate.Id = recordId;

        if(response != null){

            switch on response.getStatusCode(){

                when 200{

                    HDT_WRP_SuccessResponse successResponse = 
                        (HDT_WRP_SuccessResponse) JSON.deserialize(response.getBody(), HDT_WRP_SuccessResponse.class);

                    System.debug('WS_ReminderBlock successResponse--> ' + successResponse);
                    if(process == 'Comunicazione Pagamento'
                    || process == 'Piano Rateizzazione'
                    || process == 'Paperless'){
                        caseToUpdate.Phase__c = 'Inviata a SAP';
                    }

                }
                when else{

                    HDT_WRP_ErrorResponse errorResponse = 
                        (HDT_WRP_ErrorResponse) JSON.deserialize(response.getBody(), HDT_WRP_ErrorResponse.class);

                    System.debug('WS_ReminderBlock errorResponse--> ' + errorResponse);
                    if(process == 'Comunicazione Pagamento'
                    || process == 'Piano Rateizzazione'
                    || process == 'Paperless'){
                        caseToUpdate.Phase__c = 'Non Inviata a SAP';
                    }
                    if(caseToUpdate != null){
                        caseToUpdate.Description += '[' + System.Now().format() + ']: ' + errorResponse.errorDetails[0].message +'\n';
                    }else{
                        caseToUpdate.Description  = '[' + System.Now().format() + ']: ' + errorResponse.errorDetails[0].message +'\n';
                    }

                }

            }

        } else {

            caseToUpdate.Phase__c = 'Non Inviata a SAP';

        }

        updateFuture(JSON.serialize(caseToUpdate));

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

    public class HDT_WRP_SuccessResponse{

        public String status;
        public String correlationId;
        public String timestamp;

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
