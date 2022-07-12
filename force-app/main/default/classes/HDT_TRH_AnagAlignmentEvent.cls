public with sharing class HDT_TRH_AnagAlignmentEvent extends HDT_TRH_TriggerHandler {
    
    /*
    * @Author: Salvatore A. Sarà 21/10/2021
    * Risoluzione "Debug Should Use Logging Level"
    * Risoluzione "Avoid debug statements since they impact on performance"
    */
    @SuppressWarnings('PMD.AvoidDebugStatements')
    protected override void afterInsert() {
        System.debug(LoggingLevel.DEBUG, 'HDT_TRH_AnagAlignmentEvent trigger');
        List<Case> anagAlignCases = new List<Case>();
        for (HDT_PEV_AnagAlignment__e event : (List<HDT_PEV_AnagAlignment__e>) Trigger.New) {
            Case anagAlignCase = (Case) JSON.deserialize(event.SerializedCase__c, Case.class);
            anagAlignCases.add(anagAlignCase);
        }

        System.debug(LoggingLevel.DEBUG, '# Case di allineamento anagrafica da creare: ' + anagAlignCases.size());
        HDT_UTL_DatabaseService.insertSObject(anagAlignCases);

        List<ServiceRequest__c> serviceRequestList = HDT_UTL_Case.createServiceRequestFromCases(anagAlignCases);
        HDT_UTL_DatabaseService.insertSObject(serviceRequestList);

        for (Case anagAlignCase : anagAlignCases) {
            anagAlignCase.Phase__c = 'Da Inviare';
        }
        
        System.debug(LoggingLevel.DEBUG, 'Invio Case ad Heroku');
        HDT_UTL_DatabaseService.updateSObject(anagAlignCases);
    }

}