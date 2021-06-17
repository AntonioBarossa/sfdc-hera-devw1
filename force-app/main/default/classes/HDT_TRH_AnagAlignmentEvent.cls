public with sharing class HDT_TRH_AnagAlignmentEvent extends HDT_TRH_TriggerHandler {
    
    protected override void afterInsert() {
        System.debug('HDT_TRH_AnagAlignmentEvent trigger');
        List<Case> anagAlignCases = new List<Case>();
        for (HDT_PEV_AnagAlignment__e event : (List<HDT_PEV_AnagAlignment__e>) Trigger.New) {
            Case anagAlignCase = (Case) JSON.deserialize(event.SerializedCase__c, Case.class);
            try {
                System.debug('Arricchimento dati su punto: ' + anagAlignCase.PODPDRFormula__c);
                String arricchimentoResponse = HDT_WS_ArricchimentoDatiTemp.submitRequest(anagAlignCase.PODPDRFormula__c, null);
                HDT_UTL_DataEnrichmentPostSales.handleResponse(arricchimentoResponse, anagAlignCase);
            } catch (Exception ex){
                System.debug('Arricchimento dati fallito: line [' + ex.getLineNumber() + ']; ' + ex.getMessage());
            }

            anagAlignCases.add(anagAlignCase);
        }

        System.debug('# Case di allineamento anagrafica da creare: ' + anagAlignCases.size());
        HDT_UTL_DatabaseService.insertSObject(anagAlignCases);

        for (Case anagAlignCase : anagAlignCases) {
            anagAlignCase.Phase__c = 'Da Inviare';
        }
        
        System.debug('Invio Case ad Heroku');
        HDT_UTL_DatabaseService.updateSObject(anagAlignCases);
    }

}