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
            if (String.isNotBlank(rule.DiscardNote__c) && String.isNotBlank(rule.ControllingValue__c)){
                String key = HDT_UTL_Accents.removeDiacritics(rule.ControllingValue__c);
                String discardNote = HDT_UTL_Accents.removeDiacritics(rule.DiscardNote__c);
                List<String> keyWords = key.split(' ');
                List<String> discardNoteWords = discardNote.split(' ');
                if (!discardNote.containsIgnoreCase(key)){
                    rule.addError('Il campo Valore Controllante deve essere una parola/frase contenuta nel campo Nota Scarto.');
                }else if (discardNoteWords.size() == 1 && !'Alta'.equalsIgnoreCase(rule.DiscardNoteReliability__c)){
                    rule.addError('Il campo Nota Scarto può essere una sola parola, soltanto se l\'Affidabilità Nota Scarto è Alta.');
                }/* else if (keyWords.size() == 1 && !'Alta'.equalsIgnoreCase(rule.DiscardNoteReliability__c)){
                    rule.addError('Il campo Valore Controllante può essere formato da una sola parola, soltanto se l\'Affidabilità Nota Scarto è Alta.');
                } */else{
                    rule.DiscardNote__c = discardNote;
                    rule.ControllingValue__c = key;
                    //Una volta importata la tabella, cancellare questo codice e decommentare l'altro.
                    if (keyWords.size() == 1 && !'Alta'.equalsIgnoreCase(rule.DiscardNoteReliability__c)){
                        Integer indexWord = -1;
                        for(Integer i = 0; i < discardNoteWords.size();i++){
                            if (key.equalsIgnoreCase(discardNoteWords.get(i))){
                                indexWord = i;
                                break;
                            }
                        }
                        String newKey = '';
                        if (indexWord == 0){
                            newKey = discardNoteWords.get(indexWord)+' '+discardNoteWords.get(indexWord+1);
                            if (discardNoteWords.get(indexWord+1).length() <= 2 && (indexWord+1) < discardNoteWords.size()-1){
                                newKey += ' '+discardNoteWords.get(indexWord+2);
                            }
                        }else if (indexWord == discardNoteWords.size()-1){
                            newKey = discardNoteWords.get(indexWord-1)+' '+discardNoteWords.get(indexWord);
                            if (discardNoteWords.get(indexWord-1).length() <= 2 && (indexWord-1) > 0){
                                newKey = discardNoteWords.get(indexWord-2)+' '+newKey;
                            }
                        }else if (indexWord > 0 && indexWord < discardNoteWords.size()){
                            newKey = discardNoteWords.get(indexWord-1) +' '+discardNoteWords.get(indexWord)+' '+discardNoteWords.get(indexWord+1);
                        }
                        else{
                            rule.addError('Qualcosa non va con il valore controllante! Il sistema non riesce a trovarlo nel campo Note Scarto.');
                        }
                        rule.ControllingValue__c = newKey;
                        if (newKey.equalsIgnoreCase(discardNote)){
                            rule.DiscardNoteReliability__c = 'Alta';
                        }
                    }
                    //Fine del codice da cancellare.
                }

            }
            /* if (String.isNotBlank(rule.ControllingValue__c)) {

                if (!rule.ControllingValue__c.contains(' ')) {
                    rule.addError('La nota dello scarto deve contenere almeno due parole.');
                } else {
                    rule.ControllingValue__c = HDT_UTL_Accents.removeDiacritics(rule.ControllingValue__c);
                }
            } */
        }

    }

}
