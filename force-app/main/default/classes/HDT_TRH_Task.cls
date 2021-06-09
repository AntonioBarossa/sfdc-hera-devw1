public inherited sharing class HDT_TRH_Task extends HDT_TRH_TriggerHandler {

    protected override void beforeInsert() {
        //System.debug('HDT_TRH_Task before insert validation.');
        doValidation();
    }

    // protected override void beforeUpdate() {
    // }

    protected override void afterInsert() {
        // Il campo WhoId non può essere sbiancato in before insert, quindi dobbiamo farlo in after.
        // removeWhoId();  // NOT WORKING
    }

    private void doValidation() {

        Set<Id> contactIds = new Set<Id>();

        for (Task t : (List<Task>) Trigger.new) {

            // Sostituiamo gli UserTags solo in before.
            if (Trigger.isBefore) {
                replaceUserTags(t);
            }

            if (t.IsSms__c == True) {
                // TODO: rendere parametrica la lunghezza.
                if (t.Description.length() > 320) {
                    t.addError('È necessario inserire un testo inferiore a 320 caratteri.');
                }
                
                if (t.WhoId == null && t.PhoneNumber__c == null) {
                    t.addError('È necessario inserire un Contatto oppure un numero di telefono alternativo.');
                }
                
                if (t.WhoId != null) {
                    contactIds.add(t.WhoId);
                }

                if (t.PhoneNumber__c != null) {
                    String validateOutcome = HDT_UTL_PhoneNumbers.validateMobileNumber(t.PhoneNumber__c);
                    if (!String.isEmpty(validateOutcome)) {
                        t.addError(validateOutcome);
                    }
                }

            } else if (t.IsPec__c == True) {
                if (t.WhoId == null && t.PecAddress__c == null) {
                    t.addError('È necessario inserire un Contatto oppure un indirizzo PEC alternativo.');
                } else if (t.WhoId != null && t.PecAddress__c == null) {
                    // Salviamo il WhoId per recuperare la PEC dal Contact.
                    contactIds.add(t.WhoId);
                }
            }

            System.debug('Task after validation: ' + t);
        }

        List<Contact> contacts = new List<Contact>();
        if (!contactIds.isEmpty()) {
            HDT_QR_Contact queryHandler = new HDT_QR_Contact();
            contacts = queryHandler.getRecordsByIds(contactIds);
        }

        for (Contact c : contacts) {
            System.debug('PEC = ' + c.CertifiedEmail__c);
        }

        Map<Id, Contact> contactsMap = new Map<Id, Contact>(contacts);
        for (Task t : (List<Task>) Trigger.new) {
            if (t.IsSms__c == True) {
                if (t.WhoId != null) {
                    t.CompanyOwner__c = contactsMap.get(t.WhoId).CompanyOwner__c;
                } else {
                    t.CompanyOwner__c = 'HERA COMM'; // Default.
                }

                if (t.PhoneNumber__c != null) {
                    t.PhoneNumber__c = HDT_UTL_PhoneNumbers.withInternationPrefix(t.PhoneNumber__c);
                } else if (t.WhoId != null) {
                    String contactPhone = HDT_UTL_PhoneNumbers.withoutInternationPrefix(contactsMap.get(t.WhoId).MobilePhone);
                    String validateOutcome = HDT_UTL_PhoneNumbers.validateMobileNumber(contactPhone);
                    if (!String.isEmpty(validateOutcome)) {
                        t.addError(validateOutcome + ' Si prega di effettuare una Modifica Anagrafica per correggere il numero di telefono del cliente: ' + contactPhone);
                    } else {
                        t.PhoneNumber__c = HDT_UTL_PhoneNumbers.withInternationPrefix(contactPhone);
                    }
                }

            } else if (t.IsPec__c == True) {
                t.DoxeePecTemplateCode__c = doxeeTemplateCode(t.DoxeePecTemplate__c);

                if (t.PecAddress__c == null && t.WhoId != null) {
                    t.PecAddress__c = contactsMap.get(t.WhoId).CertifiedEmail__c;
                }
            }
        }

    }

    /**
     * Sostituisce gli UserTag presenti nel testo del Task in input.
     * Marketing Cloud inserisce le stringhe "UserTagN" senza nessun carattere speciale (parentesi o altro).
     */
    private void replaceUserTags(Task t) {

        if (t.Description  != null && t.Description .contains('UserTag')) {
            String userTag1 = t.UserTag1__c != null ? t.UserTag1__c : '';
            String userTag2 = t.UserTag2__c != null ? t.UserTag2__c : '';
            String userTag3 = t.UserTag3__c != null ? t.UserTag3__c : '';
            String userTag4 = t.UserTag4__c != null ? t.UserTag4__c : '';
            String userTag5 = t.UserTag5__c != null ? t.UserTag5__c : '';

            String replacedText = t.Description.replace('UserTag1', userTag1);
            replacedText = replacedText.replace('UserTag2', userTag2);
            replacedText = replacedText.replace('UserTag3', userTag3);
            replacedText = replacedText.replace('UserTag4', userTag4);
            replacedText = replacedText.replace('UserTag5', userTag5);

            t.Description  = replacedText;
        }
    }

    // Rimuove il WhoId, qualora presente, se l'operatore ha inserito un destinatario alternativo (cellulare o PEC).
    // DA FIXARE - al momento rimuovere sempre il WhoId, invece dovrebbe toglierlo solo se il numero alternativo è diverso dal numero del Contact.
    private void removeWhoId() {

        Set<Id> taskIds = new Set<Id>();
        for (Task t : (List<Task>) Trigger.new) {
            if (t.IsSms__c == True && t.WhoId != null && t.PhoneNumber__c != null) {
                taskIds.add(t.Id);
            } else if (t.IsPec__c == True && t.WhoId != null && t.PecAddress__c != null) {
                taskIds.add(t.Id);
            }
        }

        HDT_QR_Task queryHandler = new HDT_QR_Task();
        List<Task> tasksToUpdate = queryHandler.getRecordsByIds(taskIds);
        for (Task t : tasksToUpdate) {
            t.WhoId = null;
        }

        if (!tasksToUpdate.isEmpty()) {
            HDT_UTL_DatabaseService.updateSObject(tasksToUpdate);
        }

    }

    private Integer doxeeTemplateCode(String doxeeTemplate) {

        switch on doxeeTemplate {
            when 'Comunicazione Forte Consumo (23)' {
                return 23;
            }
            when 'Comunicazione Fuga Accertata (24)' {
                return 24;
            }
            when 'Comunicazione Fuga Presunta (25)' {
                return 25;
            }
            when 'Ultimo Avviso (26)' {
                return 26;
            }
        }

        return 0;

    }

}
