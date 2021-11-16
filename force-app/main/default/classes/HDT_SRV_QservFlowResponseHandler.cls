@SuppressWarnings('PMD.AvoidDebugStatements')
public with sharing class HDT_SRV_QservFlowResponseHandler {

    @InvocableMethod(label='Q02 Flow Response Handler' callout = true)
    public static void flowResponseHandler(List<HDT_SRV_FlowInputResponse> inputs){

        Boolean makeUpdate = true;
        Case caseToUpdate = inputs[0].currentCase;
        System.debug(LoggingLevel.DEBUG, JSON.serialize('Serialized Case: ' + caseToUpdate));
        HDT_WRP_MrrResponse deserializedResponse = (HDT_WRP_MrrResponse) JSON.deserialize(inputs[0].deserializedResponse, HDT_WRP_MrrResponse.class);

        try{

            System.debug(LoggingLevel.DEBUG, 'RESPONSE: ' + deserializedResponse);

            if(deserializedResponse != null){

                List<HDT_QServicesTranscode__mdt> transcodeConfigList = [SELECT HerokuField__c, SfdcField__c FROM HDT_QServicesTranscode__mdt WHERE ObjectName__c =: String.valueof(caseToUpdate.getSObjectType().getDescribe().getName()) WITH SECURITY_ENFORCED];

                if (transcodeConfigList.size() > 0) {
                    for(HDT_WRP_MrrResponse.HDT_WRP_Field field : deserializedResponse.responses.get(0).objects.get(0).fields){ 

                        if ('FASE'.equals(field.name) && field.value.containsIgnoreCase('KO')){
                            System.debug(LoggingLevel.DEBUG, 'FASE KO');
                            makeUpdate = false;
                            break;
                        }

                        for (HDT_QServicesTranscode__mdt transcodeConfig : transcodeConfigList){
                            if (field.name == transcodeConfig.HerokuField__c){
                                caseToUpdate.put(transcodeConfig.SfdcField__c, field.value);
                            }
                        }
                    }
                }

                System.debug(LoggingLevel.DEBUG, 'makeUpdate: ' + makeUpdate);
                if (makeUpdate){
                    System.debug(LoggingLevel.DEBUG, 'Make case update');
                    HDT_UTL_DatabaseService.updateSObject(caseToUpdate); //aggiorno il case con i valori ricevuti in response dalla chiamata al servizio
                }
            }
        } catch (Exception e) {
            throw e;
        }
    }

    public class HDT_SRV_FlowInputResponse{

        @InvocableVariable
        public String deserializedResponse;
        @InvocableVariable
        public Case currentCase;

    }
}
