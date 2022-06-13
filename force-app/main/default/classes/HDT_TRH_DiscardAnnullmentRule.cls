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
            if (String.isNotBlank(rule.ControllingValue__c)){
                String key = HDT_UTL_Accents.removeDiacritics(rule.ControllingValue__c);
                if (!key.contains(' ') && !'Alta'.equalsIgnoreCase(rule.DiscardNoteReliability__c)){
                    rule.addError('Il campo Valore Controllante può essere formato da una sola parola, soltanto se l\'Affidabilità Nota Scarto è Alta.');
                }else{
                    rule.ControllingValue__c = key;
                }
            }
        }

    }

}
