public with sharing class HDT_SRV_GenericSolHandler {
    public static void checkCompatibility(String caseId,String phase){
        HDT_QR_HerokuPostSalesManager qrClass = new HDT_QR_HerokuPostSalesManager();
        Case currentCase = qrClass.getCaseRecord(caseId);
        //CompatibilityCheck
        String compatibility = '';
        //checkCompatibility Method Call
        try
        {
            compatibility = HDT_UTL_MatrixCompatibility.checkCompatibilityPostSales(currentCase);
        }
        catch(Exception e)
        {
            System.debug('Errore Compatibilita ' + e.getMessage());
        }
        //Check Compatibility Output
        if(String.isEmpty(compatibility))
        {
            if(String.isNotBlank(phase)){
                currentCase.Phase__c = phase;
            }
            System.debug('Compatibilita superata con successo ' + compatibility);
        }
        else
        {
            System.debug('Compatibilita non superata ' + compatibility);
            currentCase.Phase__c = 'Bozza Annullata';
            currentCase.Status = 'Closed';
            currentCase.CancellationReason__c = 'Processo incompatibile';
        }
        HDT_UTL_DatabaseService.updateSObject(currentCase);
    }

    public static void dataEnrichment(String caseId){
        HDT_QR_HerokuPostSalesManager qrClass = new HDT_QR_HerokuPostSalesManager();
        Case currentCase = qrClass.getCaseRecord(caseId);
        String pod = currentCase.PODPDRFormula__c;
        String contractCode = currentCase.ContractCode__c;
        String serializedResponse = HDT_WS_ArricchimentoDatiTemp.submitRequest(pod, contractCode);
        currentCase = HDT_UTL_DataEnrichmentPostSales.handleResponse(serializedResponse, currentCase);
    }
}
