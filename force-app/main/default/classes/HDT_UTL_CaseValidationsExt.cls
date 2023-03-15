public with sharing class HDT_UTL_CaseValidationsExt implements HDT_UTL_CaseValidationInterface 
{
    HDT_QR_CaseValidations qrClass = new HDT_QR_CaseValidations();

    @SuppressWarnings('PMD.AvoidDebugStatements')
    public String validate(String fields, String recordId)
    {
        /* Output */
        String r = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK', 'Success'));
        /* Current Instance of the Case */
        Case c = qrClass.getCaseById(recordId);

        if(c.Type.equalsIgnoreCase('Piano Rateizzazione'))
        {
            r = validatePianoRata(c);
        }

        return r;
    }

    private string validatePianoRata(Case c)
    {
        if(c.DepositPaymentMode__c != null && c.DepositPaymentMode__c.containsIgnoreCase('Bonifico') && (qrClass.getDocumentByCaseId(c.Id)).size() < 1)
        {
            return  JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Per modalità pagamento acconto "Bonifico" è necessario inserire allegati'));
        }
        return JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK', 'Success'));
    }
}
