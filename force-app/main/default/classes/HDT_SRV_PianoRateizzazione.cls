public inherited sharing class HDT_SRV_PianoRateizzazione {
    public void submitRequest(Id recordId){

        HDT_UTL_SapIntegrationInterface support = HDT_UTL_SapIntegrationAdapterFactory.getInstance('HDT_WS_GenericSapIntegrationAdapter');
        HDT_WRP_GenericSapIntegration sapIntegration = new HDT_WRP_GenericSapIntegration();
        sapIntegration.recordId = recordId;
        sapIntegration.requestType = 'PianoRateizzazione';
        sapIntegration = support.submitRequest(sapIntegration);
    }

    private void manageResponse(HDT_WRP_GenericSapIntegration sapIntegration){
        Case caseToUpdate = new Case();
        caseToUpdate.Id = sapIntegration.recordId;
        if(sapIntegration.responseCode != 201){
            caseToUpdate.Phase__c = 'Comunicazione Heroku KO';
        }else {
            caseToUpdate.Phase__c = 'Comunicazione Heroku OK';
        }
        update caseToUpdate;
        
    }
}