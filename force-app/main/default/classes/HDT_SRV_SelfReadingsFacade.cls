global with sharing class HDT_SRV_SelfReadingsFacade implements wrts_prcgvr.Interfaces_1_0.IApexCalloutAction {

    global Object execute(Object args) {

        wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse response = new wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse();
        Map<String,Object> arg = new Map<String,Object>();
        //List<Case> caseToUpdate = new List<Case>();
        Case currentCase = new Case();
        String recordId;
        Map<String,Object> argsMap = (Map<String,Object>) args;
        String method = (String) argsMap.get('method');
        SObject obj = (SObject) argsMap.get('sender');
        Map<String,String> parameters = (Map<String,String>)argsMap.get('parameters');

        try {
            recordId = (String) obj.get('Id');
            HDT_WRP_GenericSapIntegration sapIntegration = new HDT_WRP_GenericSapIntegration();
            sapIntegration = submitRequest(recordId,parameters.get('requestType'));

            Boolean responseOk = HDT_SRV_SelfReadings.handleResponse(sapIntegration);
            response.success = responseOk;
            response.message = responseOk ? 'OK' : 'KO';

        } catch(Exception ex){
            System.debug('HDT_SRV_SelfReadingsFacade: exception ' + ex.getMessage());
        }

        return response;
    }

    private static HDT_WRP_GenericSapIntegration submitRequest(String recordId,String requestType) {
       
        HDT_UTL_SapIntegrationInterface support = HDT_UTL_SapIntegrationAdapterFactory.getInstance('HDT_WS_SelfReadingsIntegrationAdapter');
        HDT_WRP_GenericSapIntegration sapIntegration = new HDT_WRP_GenericSapIntegration();
        try {
            sapIntegration.recordId = recordId;
            sapIntegration.requestType = requestType;
            sapIntegration = support.submitRequest(sapIntegration);
        } catch (Exception ex) {
            System.debug('HDT_SRV_SelfReadingsFacade: exception at line ' + ex.getLineNumber());
            System.debug(ex.getMessage()); 
        }
        return sapIntegration;
        
    }
}
