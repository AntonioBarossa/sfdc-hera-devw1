global with sharing class HDT_SRV_ModificaLayoutFattura implements wrts_prcgvr.Interfaces_1_0.IApexCalloutAction {

    global Object execute(Object args) {

        System.debug('HDT_SRV_ModificaLayoutFattura callout action');
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
            sapIntegration = submitRequest(recordId);
            manageResponse(sapIntegration);
        }catch(Exception ex){
            System.debug(ex.getMessage());
        }

        response.success = true;
        response.message = 'OK';
        return response;
     
    }

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

    private static void manageResponse(HDT_WRP_GenericSapIntegration sapIntegration){

        if (sapIntegration.responseCode == 200) {

            // TODO: parse response in sapIntegration.responseBody e update Phase sul case

            // Case caseToUpdate = new Case();
            // caseToUpdate.Id = sapIntegration.recordId;
            // caseToUpdate.Phase__c = 'Inviata a SAP';
            // HDT_UTL_DatabaseService.updateSObject(caseToUpdate);
            
        }
    }
}
