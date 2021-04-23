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
            currentCase = (Case) obj;
            HDT_UTL_SapIntegrationInterface support = HDT_UTL_SapIntegrationAdapterFactory.getInstance('HDT_WS_BpCaVariationIntegrationAdapter');
            HDT_WRP_GenericSapIntegration sapIntegration = new HDT_WRP_GenericSapIntegration();
            sapIntegration.recordId = recordId;
            sapIntegration.requestType = parameters.get('requestType');
            sapIntegration = support.submitRequest(sapIntegration);
        }catch(Exception ex){
            System.debug(ex.getMessage());
        }
        response.success = true;
        response.message = 'OK';
        return response;
     
    }
}
