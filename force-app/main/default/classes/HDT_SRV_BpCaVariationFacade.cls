global with sharing class HDT_SRV_BpCaVariationFacade implements wrts_prcgvr.Interfaces_1_0.IApexCalloutAction {

    global Object execute(Object args) {

        wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse response = new wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse();
        Map<String,Object> arg = new Map<String,Object>();
        List<Case> caseToUpdate = new List<Case>();
        Case currentCase = new Case();
        String recordId;
        Map<String,Object> argsMap = (Map<String,Object>) args;
        String method = (String) argsMap.get('method');
        SObject obj = (SObject) argsMap.get('sender');
        Map<String,String> parameters = (Map<String,String>)argsMap.get('parameters');

        try{
            recordId = (String) obj.get('Id');
            HDT_WRP_GenericSapIntegration sapIntegration = new HDT_WRP_GenericSapIntegration();
            sapIntegration = submitRequest(recordId,parameters.get('requestType'));

            Map<String,Object> body = (Map<String,Object>) JSON.deserializeUntyped(sapIntegration.responseBody);
            System.debug('responseBody deserialized: ' + body);
            Map<String,Object> data = (Map<String,Object>) body.get('data');
            if((sapIntegration.responseCode != 200 && sapIntegration.responseCode != 201) || (data != null && data.get('commenti') != null)){
                if (data != null) {
                    String tipoAttivita = (String) data.get('tipoAttivita');
                    if (!tipoAttivita.equals('Pratica gestita')){ // ==> tipoAttivita = Errore cons. eBSM ==> riportiamo l'errore nell'activity.
                        System.debug('Creazione activity Errore Lavorazione SAP');
                        HDT_SRV_BpCaVariation.createActivity(recordId,(String)data.get('commenti'),'Errore Lavorazione SAP');
                        response.success = false;
                        response.message = 'KO';
                    } else {
                        System.debug('Response OK: commento da SAP: ' + (String)data.get('commenti'));
                        response.success = true;
                        response.message = 'OK';
                    }
                }
            }else {
                System.debug('Response OK');
                response.success = true;
                response.message = 'OK';
            }

        }catch(Exception ex){
            System.debug(ex.getMessage());
        }

        return response;
    }

    private static HDT_WRP_GenericSapIntegration submitRequest(String recordId,String requestType){
       
        HDT_UTL_SapIntegrationInterface support = HDT_UTL_SapIntegrationAdapterFactory.getInstance('HDT_WS_BpCaVariationIntegrationAdapter');
        HDT_WRP_GenericSapIntegration sapIntegration = new HDT_WRP_GenericSapIntegration();
        try {
            sapIntegration.recordId = recordId;
            sapIntegration.requestType = requestType;
            sapIntegration = support.submitRequest(sapIntegration);
        } catch (Exception ex) {
            System.debug(ex.getMessage()); 
        }
        return sapIntegration;
        
    }
    @InvocableMethod
    public static List<HDT_WRP_OutputBpCaFlow> executeFromFlow(List<HDT_WRP_InputBpCaFlow> inputs){
        HDT_WRP_OutputBpCaFlow output = new HDT_WRP_OutputBpCaFlow();
        List<HDT_WRP_OutputBpCaFlow> outputList = new List<HDT_WRP_OutputBpCaFlow>();
        HDT_WRP_GenericSapIntegration sapIntegration = new HDT_WRP_GenericSapIntegration();
        try {
            sapIntegration = submitRequest(inputs[0].recordId, 'MA3Disattivazioni');
            Map<String,Object> body = (Map<String,Object>) JSON.deserializeUntyped(sapIntegration.responseBody);
            Map<String,Object> data = (Map<String,Object>) body.get('data');
            if((sapIntegration.responseCode != 200 && sapIntegration.responseCode != 201) || (data != null && data.get('commenti') != null)){
                if (data != null) {
                    HDT_SRV_BpCaVariation.createActivity(inputs[0].recordId,(String)data.get('commenti'),'Errore Lavorazione SAP');
                }
                output.outcome = false;
            }else {
                output.outcome = true;
            }    
        } catch (Exception ex) {
            output.outcome = false;
        }
        outputList.add(output);
        return outputList;
    }

    public class HDT_WRP_InputBpCaFlow{
        @InvocableVariable
        public String recordId;

    }
    public class HDT_WRP_OutputBpCaFlow{
        @InvocableVariable
        public Boolean outcome;

    }

}
