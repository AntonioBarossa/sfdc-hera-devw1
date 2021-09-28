global with sharing class HDT_SRV_SelfReadingsFacade implements wrts_prcgvr.Interfaces_1_0.IApexCalloutAction {

    global Object execute(Object args) {

        wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse response = new wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse();
        Map<String,Object> arg = new Map<String,Object>();
        String recordId;
        Map<String,Object> argsMap = (Map<String,Object>) args;
        String method = (String) argsMap.get('method');//NOTA: PARAMETRO NON UTILIZZATO
        SObject obj = (SObject) argsMap.get('sender');
        Map<String,String> parameters = (Map<String,String>)argsMap.get('parameters');

        try {
            recordId = (String) obj.get('Id');
            String requestType = parameters.get('requestType');

            if (requestType == 'CheckAutolettura') {

                HDT_WRP_GenericSapIntegration sapIntegrationCheckAutoletture = new HDT_WRP_GenericSapIntegration();
                sapIntegrationCheckAutoletture = submitRequest(recordId, requestType);

                HDT_SRV_SelfReadings.HDT_WRP_SelfReadingResponse responseCheckAutoletture = HDT_SRV_SelfReadings.handleResponse(sapIntegrationCheckAutoletture, '');
                // Facciamo partire la seconda callout direttamente da qui, poichè PClick non supporta due callout action consecutive in seguito a due update di fase.
                if (responseCheckAutoletture.isResponseOk) {
                    System.debug('CheckAutolettura OK, next step: InvioLetture');
                    HDT_WRP_GenericSapIntegration sapIntegrationInvioLetture = new HDT_WRP_GenericSapIntegration();
                    sapIntegrationInvioLetture = submitRequest(recordId, 'InvioLetture');
                    HDT_SRV_SelfReadings.HDT_WRP_SelfReadingResponse responseInvioLetture = HDT_SRV_SelfReadings.handleResponse(sapIntegrationInvioLetture, responseCheckAutoletture.checkAutoletturaDescription);
                } else {
                    System.debug('CheckAutolettura KO');
                }
            } else if (requestType == 'InvioLettureForzato') {
                HDT_WRP_GenericSapIntegration sapIntegration = new HDT_WRP_GenericSapIntegration();
                sapIntegration = submitRequest(recordId, requestType);
                HDT_SRV_SelfReadings.HDT_WRP_SelfReadingResponse responseInvioLetture = HDT_SRV_SelfReadings.handleResponse(sapIntegration, '');
            }

            response.success = True;
            response.message = 'OK';

        } catch(Exception ex){
            response.success = false;
            response.message = 'KO';
            System.debug('HDT_SRV_SelfReadingsFacade: exception at line [' + ex.getLineNumber() + ']; ' + ex.getMessage());
        }

        return response;
    }
    
    @testVisible
    private static HDT_WRP_GenericSapIntegration submitRequest(String recordId, String requestType) {
       
        HDT_UTL_SapIntegrationInterface support = HDT_UTL_SapIntegrationAdapterFactory.getInstance('HDT_WS_SelfReadingsIntegrationAdapter');
        HDT_WRP_GenericSapIntegration sapIntegration = new HDT_WRP_GenericSapIntegration();
        try {
            sapIntegration.recordId = recordId;
            sapIntegration.requestType = requestType;
            sapIntegration = support.submitRequest(sapIntegration);
        } catch (Exception ex) {
            System.debug('HDT_SRV_SelfReadingsFacade: exception at line [' + ex.getLineNumber() + ']; ' + ex.getMessage());
            System.debug('HDT_SRV_SelfReadingsFacade: exception stack trace string:' + ex.getStackTraceString() );
            
        }
        return sapIntegration;
        
    }
}
