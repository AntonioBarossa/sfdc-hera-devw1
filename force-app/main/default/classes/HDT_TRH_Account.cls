public with sharing class HDT_TRH_Account extends HDT_TRH_TriggerHandler {
    
   public override void beforeInsert(){
        HDT_UTL_CompanyOwner.feedCompanOwner(trigger.new);
    }

    protected override void beforeUpdate() {
        checkAccountName();
    }

    /**
     * Verifica che il Name degli Account residenziali/aziende rimanga la concatenazione di FirstName + LastName.
     */
    private void checkAccountName() {

        HDT_QR_RecordType queryHandler = new HDT_QR_RecordType();
        Id rtResidenziale = queryHandler.getRecordTypeIdByName('HDT_RT_Residenziale');
        Id rtBusiness = queryHandler.getRecordTypeIdByName('HDT_RT_Business');

        for (Account acc : (List<Account>) Trigger.new) {

            if (acc.RecordTypeId != rtResidenziale && acc.RecordTypeId != rtBusiness) {
                continue;
            }

            String expectedNewName = String.isBlank(acc.FirstName__c) ? acc.LastName__c : acc.FirstName__c + ' ' + acc.LastName__c;

            if (!acc.Name.equals(expectedNewName)) {
                acc.addError('Il Nome del Cliente deve essere equivalente a \'Nome Cognome\' per clienti Residenziali o \'Cognome/Ragione sociale\' per clienti Aziende.');
            }
        }

    }

}
