public with sharing class HDT_TRH_AnagAlignmentEvent extends HDT_TRH_TriggerHandler {
    
    protected override void afterInsert() {
        System.debug('HDT_TRH_AnagAlignmentEvent trigger');
        for (HDT_PEV_AnagAlignment__e event : (List<HDT_PEV_AnagAlignment__e>) Trigger.New) {
            Case c = (Case) JSON.deserialize(event.SerializedCase__c, Case.class);
            try {
                //System.debug('Arricchimento dati su Case: ' + c);
                System.debug('Arricchimento dati su punto: ' + c.PODPDRFormula__c);
                String arricchimentoResponse = HDT_WS_ArricchimentoDatiTemp.submitRequest(c.PODPDRFormula__c, null);
                HDT_UTL_DataEnrichmentPostSales.handleResponse(arricchimentoResponse, c);
            } catch (Exception ex){
                System.debug('Arricchimento dati fallito: line [' + ex.getLineNumber() + ']; ' + ex.getMessage());
            }
    
            System.debug('Inserimento Case');
            HDT_UTL_DatabaseService.insertSObject(c);
            
            System.debug('Invio Case ad Heroku: ' + c.Id);
            c.Phase__c = 'Da Inviare';
            HDT_UTL_DatabaseService.updateSObject(c);
        }
    }

}