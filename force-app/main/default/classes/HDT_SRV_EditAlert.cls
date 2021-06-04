global with sharing class HDT_SRV_EditAlert implements wrts_prcgvr.Interfaces_1_0.IApexCalloutAction {

    global Object execute(Object args) {

        System.debug('HDT_SRV_EditAlert callout action');
        wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse response = new wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse();
        Map<String,Object> arg = new Map<String,Object>();
        List<Case> caseToUpdate = new List<Case>();
        Case currentCase = new Case();
        String recordId;
        Map<String,Object> argsMap = (Map<String,Object>) args;
        //String method = (String) argsMap.get('method');
        SObject obj = (SObject) argsMap.get('sender');
        //Map<String,String> parameters = (Map<String,String>)argsMap.get('parameters');

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
        sapIntegration.requestType = 'ModificaAlert';
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

            Map<String, Object> responseBodyMap = (Map<String, Object>) JSON.deserializeUntyped(sapIntegration.responseBody);
            if (responseBodyMap != null) {
                String responseOutcome = (String) responseBodyMap.get('note');
                System.debug('Esito WS Modifica Alert: ' + responseOutcome);

                if (responseOutcome != 'KO') {
                    Case caseToUpdate = new Case();
                    caseToUpdate.Id = sapIntegration.recordId;
                    caseToUpdate.Phase__c = 'Esito OK da SAP';
                    caseToUpdate.SendDate__c = Date.today();
                    String serializedCase = JSON.serialize(caseToUpdate);
                    updateFuture(serializedCase);
                }
            }
        }
    }

    @Future
    private static void updateFuture(String inputString) {

        Case c = (Case) JSON.deserialize(inputString, Case.class);

        HDT_UTL_DatabaseService.updateSObject(c);

    }
}
