/**@frpanico 15/10/2021
 * Per implementare interfaccia di PClick il modifier deve essere global
 */
@SuppressWarnings('PMD.AvoidGlobalModifier, PMD.AvoidDebugStatements')
global with sharing class HDT_SRV_ModificaLayoutFattura implements wrts_prcgvr.Interfaces_1_0.IApexCalloutAction {
    
    global Object execute(Object args) {

        System.debug(LoggingLevel.DEBUG, 'HDT_SRV_ModificaLayoutFattura callout action');
        wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse responsePclick = new wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse();
        //Map<String,Object> arg = new Map<String,Object>();
        //List<Case> caseToUpdate = new List<Case>();
        Case currentCase = new Case();
        Map<String,Object> argsMap = (Map<String,Object>) args;
        String method = (String) argsMap.get('method');
        SObject obj = (SObject) argsMap.get('sender');
        //Map<String,String> parameters = (Map<String,String>)argsMap.get('parameters');

        HttpRequest request = new HttpRequest();
        Http http = new Http();
        HttpResponse response = new HttpResponse();
        //String result;
        String recordId;
        // String depositMode;
        // String process;
        String requestBody;
        HDT_WRP_RequestBody bodyWrp = new HDT_WRP_RequestBody();
        HDT_WRP_Position positions = new HDT_WRP_Position();
        String endpoint = 'Callout:' + method;

        recordId = (String) obj.get('Id');
        currentCase.Id = recordId;
        bodyWrp.rds = (String) obj.get('CaseNumber');
        
        System.debug(LoggingLevel.DEBUG, 'contratti -> ' +(String) obj.get('ContractCode__c'));
        positions.contratti = (String) obj.get('ContractCode__c');
        
        System.debug(LoggingLevel.DEBUG, 'dettaglioBolletta -> ' + (Boolean) obj.get('ElementDetail__c'));
        positions.dettaglioBolletta = (Boolean) obj.get('ElementDetail__c') ? 'Y' : 'N';
        
        bodyWrp.posizioni = positions;
        requestBody = JSON.serialize(bodyWrp);
        
        try{
            request.setEndpoint(endpoint);
            request.setMethod('POST');
            request.setBody(requestBody);
            request.setTimeout(120000);
            request.setHeader('Accept','application/json');
            request.setHeader('Content-Type','application/json');

            response = http.send(request);

        } catch (Exception e){
            System.debug(LoggingLevel.DEBUG, 'execute - Exception TypeName: ' + e.getTypeName());
            System.debug(LoggingLevel.DEBUG, 'execute - Exception Message: ' + e.getMessage());
            System.debug(LoggingLevel.DEBUG, 'execute - Exception StackTraceString: ' + e.getStackTraceString());
            response = null;
            
        }
        System.debug(LoggingLevel.DEBUG, 'response -> ' + response);

        if(response != null){
            currentCase = manageResponse(response, recordId);
        }else{
            currentCase.TecnicalPhase__c = 'Errore Lavorazione SAP';
            currentCase.distributorflowcode__c = 'KO';
        }
        HDT_UTL_DatabaseService.updateSObject(currentCase);

        /*try{
            recordId = (String) obj.get('Id');
            HDT_WRP_GenericSapIntegration sapIntegration = new HDT_WRP_GenericSapIntegration();
            sapIntegration = submitRequest(recordId);
            manageResponse(sapIntegration);
        }catch(Exception ex){
            System.debug(ex.getMessage());
        }*/

        responsePclick.success = true;
        responsePclick.message = 'OK';
        return responsePclick;
     
    }

    /*
    private static HDT_WRP_GenericSapIntegration submitRequest(Id recordId){

        HDT_UTL_SapIntegrationInterface support = HDT_UTL_SapIntegrationAdapterFactory.getInstance('HDT_WS_GenericSapIntegrationAdapter');
        HDT_WRP_GenericSapIntegration sapIntegration = new HDT_WRP_GenericSapIntegration();
        sapIntegration.recordId = recordId;
        sapIntegration.requestType = 'ModificaLayoutFattura';
        sapIntegration = support.submitRequest(sapIntegration);

        try {
            sapIntegration = support.submitRequest(sapIntegration);
        } catch (Exception ex) {
            System.debug(ex.getMessage()); 
        }
        return sapIntegration;
    }
    */

    private static Case manageResponse(HttpResponse response, String caseId){
        Case caseToUpdate = new Case();
        caseToUpdate.Id = caseId;
        HDT_WRP_SuccessResponse responseBody = (HDT_WRP_SuccessResponse) JSON.deserialize(response.getBody(), HDT_WRP_SuccessResponse.class);
        if(responseBody.data != null){

            if(responseBody.data.attivita == 'Esito OK da SAP'){
                caseToUpdate.TecnicalPhase__c = 'Completata';
            } else {
                caseToUpdate.TecnicalPhase__c = 'Errore Lavorazione SAP';
                caseToUpdate.distributorflowcode__c = 'KO';
            }

        } else {
            caseToUpdate.TecnicalPhase__c = 'Errore Lavorazione SAP';
            caseToUpdate.distributorflowcode__c = 'KO';
        }
        return caseToUpdate;
    }


        /*Case caseToUpdate = new Case();

        caseToUpdate.Id = sapIntegration.recordId;

        if (sapIntegration.responseCode == 200) {


            HDT_WRP_ModificaLayoutFattura.HDT_WRP_Response responseBody = 
                (HDT_WRP_ModificaLayoutFattura.HDT_WRP_Response) JSON.deserialize(sapIntegration.responseBody, HDT_WRP_ModificaLayoutFattura.HDT_WRP_Response.class);

            if(responseBody.data.attivita == 'Esito OK da SAP'){

                caseToUpdate.Phase__c = 'Completata';

            }else{


                caseToUpdate.description = responsebody.data.attivita + ' ' +responseBody.data.note;
                caseToUpdate.Phase__c = 'Errore Lavorazione SAP';

            }

            // TODO: parse response in sapIntegration.responseBody e update Phase sul case

            // Case caseToUpdate = new Case();
            // caseToUpdate.Id = sapIntegration.recordId;
            // caseToUpdate.Phase__c = 'Inviata a SAP';
            // HDT_UTL_DatabaseService.updateSObject(caseToUpdate);
            
            HDT_UTL_DatabaseService.updateSObject(caseToUpdate);

        } else {
            caseToUpdate.Phase__c = 'Errore Lavorazione SAP';
            caseToUpdate.Description = 'Errore comunicazione con SAP';
        }
    }*/

    public class HDT_WRP_RequestBody{
        String rds;
        HDT_WRP_Position posizioni;
    }
    public class HDT_WRP_Position{
        String contratti;
        String dettaglioBolletta;
    }
    public class HDT_WRP_SuccessResponse{
        public String status;
        public String correlationId;
        public String timestamp;
        public HDT_WRP_Data data;

    }   
    public class HDT_WRP_Data{
        public String rds;
        public String attivita;
    }

}