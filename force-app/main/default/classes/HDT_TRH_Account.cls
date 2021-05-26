public with sharing class HDT_TRH_Account extends HDT_TRH_TriggerHandler {

    protected override void beforeUpdate() {
        checkAccountName();
    }

    /**
     * Verifica che il Name dell'Account rimanga la concatenazione di FirstName + LastName.
     */
    private void checkAccountName() {

        for (Account acc : (List<Account>) Trigger.new) {

            String expectedNewName = String.isBlank(acc.FirstName__c) ? acc.LastName__c : acc.FirstName__c + ' ' + acc.LastName__c;

            if (!acc.Name.equals(expectedNewName)) {
                acc.addError('Il Nome del Cliente deve essere equivalente a \'Nome Cognome\' per clienti Residenziali o \'Cognome/Ragione sociale\' per clienti Aziende.');
            }
        }

    }

}