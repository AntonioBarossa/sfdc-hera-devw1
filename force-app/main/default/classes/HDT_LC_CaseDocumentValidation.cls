public inherited sharing class HDT_LC_CaseDocumentValidation {

    private static HDT_QR_Case caseQr = new HDT_QR_Case();
	private static HDT_SRV_Case caseSrv = new HDT_SRV_Case();
    
    @AuraEnabled
    public static Boolean isValidPhase(String recordId){
        Case currentCase = caseQr.getRecordById(recordId);
        return true;
        //return ('In Attesa Validazione'.equalsIgnoreCase(currentCase.Phase__c));
    }
    
    @AuraEnabled
    public static void saveValidation(String caseId, Boolean allValidated){
        Case currentCase = new Case();
        String phase;

        currentCase.Id = caseId;

        if(allValidated){
            if(currentCase.Subprocess__c == 'Accise - Energia Elettrica'){
                phase = 'Elaborazione Manuale';
            } else {
                phase = 'Da Inviare';
            }
            currentCase.Phase__c = phase;
            currentCase.CompletedDocumentationDate__c = System.today();
        } else {

            currentCase.Phase__c = 'In attesa Documentazione';

        }

        HDT_UTL_DatabaseService.updateSObject(currentCase);

    }
}