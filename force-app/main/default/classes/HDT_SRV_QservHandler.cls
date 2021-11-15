@SuppressWarnings('PMD.AvoidDebugStatements')
public with sharing class HDT_SRV_QservHandler {
    
    public static Map<String, Object> handler(SObject sobj){

        System.debug(LoggingLevel.DEBUG, 'Received sObject: ' + sobj);

        Map<String, Object> transcodeMap = new Map<String, Object>();

        try {

            String body = HDT_UTL_CreateGenericRequestBody.createBodyRequest(sobj);
            HttpResponse response = makePostCallout(body);
            HDT_WRP_MrrResponse deserializedResponse = (HDT_WRP_MrrResponse) JSON.deserialize(response.getBody(), HDT_WRP_MrrResponse.class);

            System.debug(LoggingLevel.DEBUG, 'RESPONSE: ' + deserializedResponse);

            if(deserializedResponse != null){

                List<HDT_QServicesTranscode__mdt> transcodeConfigList = [SELECT HerokuField__c, SfdcField__c FROM HDT_QServicesTranscode__mdt WHERE ObjectName__c =: String.valueof(sobj.getSObjectType().getDescribe().getName()) WITH SECURITY_ENFORCED];

                if (transcodeConfigList.size() > 0) {
                    for(HDT_WRP_MrrResponse.HDT_WRP_Field field : deserializedResponse.responses.get(0).objects.get(0).fields){ 
                        for (HDT_QServicesTranscode__mdt transcodeConfig : transcodeConfigList){

                            if ('FASE'.equals(field.name) && field.value.containsIgnoreCase('KO')){
                                transcodeMap.put('ESITO', false);
                            }else if ('FASE'.equals(field.name) && field.value.containsIgnoreCase('OK')){
                                transcodeMap.put('ESITO', true);
                            }else if ('DES_ERR_AEEG'.equals(field.name)){
                                transcodeMap.put('DES_ERR_AEEG', field.value);
                            }

                            if (field.name == transcodeConfig.HerokuField__c){
                                sobj.put(transcodeConfig.SfdcField__c, field.value);
                            }
                        }
                    }
                }

                HDT_UTL_DatabaseService.updateSObject(sobj);
            }
        } catch (Exception e) {
            throw e;
        }

        System.debug(LoggingLevel.DEBUG, 'transcodeMap: ' + transcodeMap);
        return transcodeMap;
    }

    public static HttpResponse makePostCallout(String body) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:Heroku');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setBody(body);
        HttpResponse response = http.send(request);
        // Parse the JSON response
        if(response.getStatusCode() != 200) {
            System.debug(LoggingLevel.DEBUG, 'The status code returned was not expected: ' +
                response.getStatusCode() + ' ' + response.getStatus());
        } else {
            System.debug(LoggingLevel.DEBUG, 'RESPONSE BODY: ' + JSON.serialize(response.getBody()));
        }
        
        return response;
    } 
    
    @InvocableMethod(label='Q02 Flow Request Handler' callout = true)
    public static List<String> flowRequestHandler(List<HDT_SRV_FlowInputRequest> inputs){

        List<String> desRespList = new List<String>();
        try {

            String body = HDT_UTL_CreateGenericRequestBody.createBodyRequest(inputs[0].currentCase);
            HttpResponse response = makePostCallout(body);
            HDT_WRP_MrrResponse deserializedResponse = (HDT_WRP_MrrResponse) JSON.deserialize(response.getBody(), HDT_WRP_MrrResponse.class);
    
            System.debug(LoggingLevel.DEBUG, 'DES RESP: ' + JSON.serialize(deserializedResponse));
            desRespList.add(JSON.serialize(deserializedResponse));
            
        } catch (Exception e) {
            throw e;
        }

        return desRespList;
    }

    public class HDT_SRV_FlowInputRequest{

        @InvocableVariable
        public Case currentCase;

    }
}
