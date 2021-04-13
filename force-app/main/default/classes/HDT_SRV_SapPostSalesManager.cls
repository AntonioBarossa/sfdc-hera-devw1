public inherited sharing class HDT_SRV_SapPostSalesManager {

    public void submitRequest(String recordId, String caseType){

        HDT_UTL_SapIntegrationInterface support = HDT_UTL_SapIntegrationAdapterFactory.getInstance('HDT_WS_GenericSapIntegrationAdapter');
        HDT_WRP_GenericSapIntegration sapIntegration = new HDT_WRP_GenericSapIntegration();
        sapIntegration.recordId = recordId;
        sapIntegration.requestType = caseType.replace(' ','');
        sapIntegration = support.submitRequest(sapIntegration);
        handleResponse(sapIntegration);

    }

    private void handleResponse(HDT_WRP_GenericSapIntegration sapIntegration){

        System.debug('Response Code--> '+sapIntegration.responseCode);
        System.debug('Response Status--> '+sapIntegration.responseStatus);
        System.debug('Response Body--> '+sapIntegration.responseBody);

    }
}
