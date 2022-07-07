@SuppressWarnings('PMD.AvoidDebugStatements')
public with sharing class HDT_TRH_DiscardAnnullmentRule extends HDT_TRH_TriggerHandler {
    
    protected override void beforeInsert() {
        validateDiscardText(false);
    }

    protected override void beforeUpdate() {
        validateDiscardText(true);
    }

    /**
     * Validazione e normalizzazione del testo inserito come nota dello scarto.
     */
    private void validateDiscardText(Boolean isUpdate) {
        for (DiscardAnnullmentRule__c rule : (List<DiscardAnnullmentRule__c>) Trigger.new) {
            if (String.isNotBlank(rule.ControllingValue__c)){
                DiscardAnnullmentRule__c oldRule = isUpdate? (DiscardAnnullmentRule__c)Trigger.oldMap.get(rule.Id) : null;
                String key = setKey(rule.ControllingValue__c,oldRule?.ControllingValue__c);
                /* 
                ea: elimata dopo richiesta del business
                if (!key.contains(' ') && !'Alta'.equalsIgnoreCase(rule.DiscardNoteReliability__c)){
                    rule.addError('Il campo Valore Controllante può essere formato da una sola parola, soltanto se l\'Affidabilità Nota Scarto è Alta.');
                }else{
                    rule.ControllingValue__c = key;
                } */
                rule.ControllingValue__c = key;
            }
        }

    }

    private String setKey(String value,String oldValue){
        if (!value.equalsIgnoreCase(oldValue)){
            return HDT_UTL_Accents.removeDiacritics(value);
        }
        return value;
    }

}
