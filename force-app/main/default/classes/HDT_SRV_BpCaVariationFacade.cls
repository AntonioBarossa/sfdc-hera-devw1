@SuppressWarnings('PMD.AvoidDebugStatements, PMD.AvoidGlobalModifier')
global with sharing class HDT_SRV_BpCaVariationFacade implements wrts_prcgvr.Interfaces_1_0.IApexCalloutAction {

    global Object execute(Object args) {

        wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse response = new wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse();
        response.success = true;
        response.message = 'OK';
        /*
            @Author: Davide Viola - 19/10/2021
            Description: PMD -> Commentate variabili non utilizzate.
        */
        /*Map<String,Object> arg = new Map<String,Object>();
        Case currentCase = new Case();
        String method = (String) argsMap.get('method');
        */
        //List<Case> caseToUpdate = new List<Case>();
        String recordId;
        Map<String,Object> argsMap = (Map<String,Object>) args;
        SObject obj = (SObject) argsMap.get('sender');
        Map<String,String> parameters = (Map<String,String>)argsMap.get('parameters');
        Boolean okFromSap = true;
        try{
            recordId = (String) obj.get('Id');
            HDT_WRP_GenericSapIntegration sapIntegration = new HDT_WRP_GenericSapIntegration();
            sapIntegration = submitRequest(recordId,parameters.get('requestType'));

            Map<String,Object> body = (Map<String,Object>) JSON.deserializeUntyped(sapIntegration.responseBody);
            System.debug(LoggingLevel.DEBUG, 'responseBody deserialized: ' + body);
            Map<String,Object> data = (Map<String,Object>) body.get('data');
            if((sapIntegration.responseCode != 200 && sapIntegration.responseCode != 201) || (data != null && data.get('commenti') != null)){
                if (data != null) {
                    String tipoAttivita = (String) data.get('tipoAttivita');
                    if (tipoAttivita != null && !tipoAttivita.equals('Pratica gestita')){ // ==> tipoAttivita = Errore cons. eBSM ==> riportiamo l'errore nell'activity.
                        System.debug(LoggingLevel.DEBUG, 'Creazione activity Errore Lavorazione SAP');
                        HDT_UTL_Case.createActivity(recordId,(String)data.get('commenti'),'Esito KO da SAP','Esito KO da SAP');
                        okFromSap = false;
                        /*
                        response.success = false;
                        response.message = 'KO';
                        */
                    } else {
                        System.debug(LoggingLevel.DEBUG, 'Response OK: commento da SAP: ' + (String)data.get('commenti'));
                        response.success = true;
                        response.message = 'OK';
                    }
                }
            } else {
                System.debug(LoggingLevel.DEBUG, 'Response OK');
                response.success = true;
                response.message = 'OK';
            }

        } catch (Exception ex) {
            System.debug(LoggingLevel.DEBUG, 'execute - Exception TypeName: ' + ex.getTypeName());
            System.debug(LoggingLevel.DEBUG, 'execute - Exception Message: ' + ex.getMessage());
            System.debug(LoggingLevel.DEBUG, 'execute - Exception StackTraceString: ' + ex.getStackTraceString());
        }

        Case caseToUpdate = new Case();
        caseToUpdate.Id = recordId;
        caseToUpdate.SendDate__c = Date.today();
        caseToUpdate.TecnicalPhase__c = okFromSap ? 'Esito OK da SAP' : 'Errore Lavorazione SAP';
        if ('Errore Lavorazione SAP'.equalsIgnoreCase(caseToUpdate.TecnicalPhase__c)){
            caseToUpdate.distributorflowcode__c = 'KO';
        }

        // String serializedCase = JSON.serialize(caseToUpdate);
        // updateFuture(serializedCase);
        HDT_UTL_DatabaseService.updateSObject(caseToUpdate);

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
            System.debug(LoggingLevel.DEBUG, 'submitRequest - Exception TypeName: ' + ex.getTypeName());
            System.debug(LoggingLevel.DEBUG, 'submitRequest - Exception Message: ' + ex.getMessage());
            System.debug(LoggingLevel.DEBUG, 'submitRequest - Exception StackTraceString: ' + ex.getStackTraceString());
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
                    //HDT_UTL_Case.createActivity(inputs[0].recordId,(String)data.get('commenti'),'Esito KO da SAP','Esito KO da SAP');
                    output.commenti = (String) data.get('commenti') != null ? (String) data.get('commenti') : '';
                }
                output.outcome = false;
            } else {
                output.outcome = true;
            }    
        } catch (Exception ex) {
            output.outcome = false;
        }
        outputList.add(output);
        return outputList;
    }

    @Future
    private static void updateFuture(String inputString) {
        Case c = (Case) JSON.deserialize(inputString, Case.class);
        HDT_UTL_DatabaseService.updateSObject(c);
    }

    public class HDT_WRP_InputBpCaFlow{
        @InvocableVariable
        public String recordId;
    }
    
    public class HDT_WRP_OutputBpCaFlow{
        @InvocableVariable
        public Boolean outcome;
        @InvocableVariable
        public String commenti;
    }

}
