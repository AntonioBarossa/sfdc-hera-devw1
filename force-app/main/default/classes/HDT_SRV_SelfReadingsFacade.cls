@SuppressWarnings('PMD.AvoidDebugStatements, PMD.AvoidGlobalModifier')
global with sharing class HDT_SRV_SelfReadingsFacade implements wrts_prcgvr.Interfaces_1_0.IApexCalloutAction {

    global Object execute(Object args) {

        wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse response = new wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse();
        /*
            @Author: Davide Viola - 20/10/2021
            Description: PMD -> Commentate variabili non utilizzate.
        */
        /*Map<String,Object> arg = new Map<String,Object>();
        String method = (String) argsMap.get('method');//NOTA: PARAMETRO NON UTILIZZATO*/
        String recordId;
        Map<String,Object> argsMap = (Map<String,Object>) args;
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
                    System.debug(LoggingLevel.DEBUG, 'CheckAutolettura OK, next step: InvioLetture');
                    HDT_WRP_GenericSapIntegration sapIntegrationInvioLetture = new HDT_WRP_GenericSapIntegration();
                    sapIntegrationInvioLetture = submitRequest(recordId, 'InvioLetture');
                    HDT_SRV_SelfReadings.handleResponse(sapIntegrationInvioLetture, responseCheckAutoletture.checkAutoletturaDescription);
                } else {
                    System.debug(LoggingLevel.DEBUG, 'CheckAutolettura KO');
                }
            } else if (requestType == 'InvioLettureForzato') {
                HDT_WRP_GenericSapIntegration sapIntegration = new HDT_WRP_GenericSapIntegration();
                sapIntegration = submitRequest(recordId, requestType);
                /*
                    @Author: Davide Viola - 20/10/2021
                    Description: PMD -> Commentata variabile non utilizzata.
                */
                HDT_SRV_SelfReadings.HDT_WRP_SelfReadingResponse responseInvioLetture = HDT_SRV_SelfReadings.handleResponse(sapIntegration, '');
                Boolean discardRework = argsMap.containsKey('discardRework') ? (Boolean)argsMap.get('discardRework') : false;
                if (System.isQueueable() && discardRework && !responseInvioLetture.isResponseOk){
                    List<Case> cList = HDT_QR_GenericQuery.getGenericRecords('Id,Phase__c', 'Case', 'Id = \''+recordId+'\' AND Phase__c IN (\'Esito KO pre-MDM\',\'Esito KO da SAP\')');
                    if (!cList.isEmpty()){
                        HDT_UTL_Scarti.createActivity(cList[0].Id, cList[0].Phase__c,responseInvioLetture.checkAutoletturaDescription);
                    }
                }
            }

            response.success = True;
            response.message = 'OK';

        } catch(Exception ex){
            response.success = false;
            response.message = 'KO';
            System.debug(LoggingLevel.DEBUG, 'HDT_SRV_SelfReadingsFacade: exception at line [' + ex.getLineNumber() + ']; ' + ex.getMessage());
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
            System.debug(LoggingLevel.DEBUG, 'HDT_SRV_SelfReadingsFacade: exception at line [' + ex.getLineNumber() + ']; ' + ex.getMessage());
            System.debug(LoggingLevel.DEBUG, 'HDT_SRV_SelfReadingsFacade: exception stack trace string:' + ex.getStackTraceString() );
            
        }
        return sapIntegration;
        
    }
}
