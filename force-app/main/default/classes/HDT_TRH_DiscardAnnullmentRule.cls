@SuppressWarnings('PMD.AvoidDebugStatements')
public with sharing class HDT_TRH_DiscardAnnullmentRule extends HDT_TRH_TriggerHandler {
    
    protected override void beforeInsert() {
        validateDiscardText();
    }

    protected override void beforeUpdate() {
        validateDiscardText();
    }

    /**
     * Validazione e normalizzazione del testo inserito come nota dello scarto.
     */
    private void validateDiscardText() {

        for (DiscardAnnullmentRule__c rule : (List<DiscardAnnullmentRule__c>) Trigger.new) {
            if (String.isNotBlank(rule.ControllingValue__c)) {

                if (!rule.ControllingValue__c.contains(' ')) {
                    rule.addError('La nota dello scarto deve contenere almeno due parole.');
                } else {
                    rule.ControllingValue__c = HDT_UTL_Accents.removeDiacritics(rule.ControllingValue__c);
                }
            }
        }

    }

}
