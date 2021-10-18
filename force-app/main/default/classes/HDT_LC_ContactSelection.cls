public with sharing class HDT_LC_ContactSelection {

    @AuraEnabled(cacheable = false)
    public static String getListRecords(String accountId){
        String recordListString;
        try{
            System.debug(LoggingLevel.DEBUG,'HDT_LC_ContactSelection: accountId: ' + accountId);

            List<List<sObject>> recordList = new List<List<sObject>>();
            Map<Id, String> rolesMap = new Map<Id, String>();

            // TODO: capire se escludere contatti particolari, es. contatti SOL o Amministratore Condominio
            HDT_QR_AccountContactRelation acrQueryHandler = new HDT_QR_AccountContactRelation();
            List<AccountContactRelation> relationList = acrQueryHandler.getContactsByAccountWithRoles(accountId);
            Set<Id> contactIds = new Set<Id>();
            for (AccountContactRelation acr : relationList) {
                System.debug(LoggingLevel.DEBUG,'HDT_LC_ContactSelection: ACR: ' + acr);
                contactIds.add(acr.ContactId);
                rolesMap.put(acr.ContactId, acr.Roles);
            }

            List<AccountContactRelation> primaryRelations = acrQueryHandler.getPrimaryRelationsByContacts(contactIds);
            for (AccountContactRelation acr : primaryRelations) {
                // Rimuoviamo i contatti che sono Titolari per altri Account.
                // Per modificare questi contatti il processo va innescato dall'Account per cui sono titolari.
                if (acr.AccountId != accountId) {
                    contactIds.remove(acr.ContactId);
                    rolesMap.remove(acr.ContactId);
                }
            }

            HDT_QR_Contact contactQueryHandler = new HDT_QR_Contact();
            List<Contact> contacts = contactQueryHandler.getRecordsByIds(contactIds);

            JSONGenerator gen = JSON.createGenerator(false);
            gen.writeStartArray();
            for (Contact contact : contacts) {
                gen.writeStartObject();
                gen.writeStringField('Id', contact.Id);
                writeIfNotNull(gen, 'Name', contact.Name);
                writeIfNotNull(gen, 'Phone', contact.Phone);
                writeIfNotNull(gen, 'MobilePhone', contact.MobilePhone);
                writeIfNotNull(gen, 'Email', contact.Email);
                writeIfNotNull(gen, 'Fax', contact.Fax);
                writeIfNotNull(gen, 'CertifiedEmail__c', contact.CertifiedEmail__c);
                writeIfNotNull(gen, 'Roles', rolesMap.get(contact.Id));
                gen.writeEndObject();
            }

            gen.writeEndArray();
            recordListString = gen.getAsString();
            System.debug(LoggingLevel.DEBUG,'HDT_LC_ContactSelection: recordListString: ' + recordListString);

        }catch(Exception e){
            System.debug(LoggingLevel.DEBUG,e.getMessage());
        }
        return recordListString;
    }

    @AuraEnabled(cacheable = false)
    public static String getAdministrators(String accountId, String soslSearchTerm){
        String recordListString;
        try{
            System.debug(LoggingLevel.DEBUG,'HDT_LC_ContactSelection: accountId: ' + accountId + ' soslSearchTerm: ' + soslSearchTerm);

            List<List<sObject>> recordList = new List<List<sObject>>();

            HDT_QR_AccountContactRelation acrQueryHandler = new HDT_QR_AccountContactRelation();
            List<AccountContactRelation> relationList = acrQueryHandler.getAdministratorRelations();
            Set<Id> contactIds = new Set<Id>();
            Id accountAdministratorId = null;
            for (AccountContactRelation acr : relationList) {
                System.debug(LoggingLevel.DEBUG,'HDT_LC_ContactSelection: ACR: ' + acr);
                if (acr.AccountId == accountId) {
                    // Memorizziamo l'Id dell'amministratore che gestisce l'Account in modo da poterlo togliere dopo.
                    accountAdministratorId = acr.ContactId;
                }
                contactIds.add(acr.ContactId);
            }

            // Rimuoviamo l'Id dell'amministratore attuale dell'Account.
            if (accountAdministratorId != null) {
                contactIds.remove(accountAdministratorId);
            }

            if (contactIds.isEmpty()) {
                System.debug(LoggingLevel.DEBUG,'HDT_LC_ContactSelection: nessun amministratore di condominio a sistema');
                return '';
            }

            List<Id> idsList = new List<Id>();
            idsList.addAll(contactIds);
            HDT_QR_GenericRecordSelection soslHandler = new HDT_QR_GenericRecordSelection();
            String fields = 'Name,Phone,MobilePhone,Email,Fax,CertifiedEmail__c,MailingAddressFormula__c,FirstName,LastName,FiscalCode__c,ContactCode__c';
            String filters = 'Id IN (\'' + idsList[0] + '\'';
            for (Integer i = 1; i < idsList.size(); i++) {
                filters += ',\'' + idsList[i] + '\'';
            }
            filters += ')';
            if (String.isBlank(soslSearchTerm)) {
                System.debug(LoggingLevel.DEBUG,'HDT_LC_ContactSelection: default search term = 1900*');
                soslSearchTerm = '1900*'; // tutti i codici contatto SAP iniziano con 1900*
            }

            List<List<SObject>> contacts = soslHandler.executeQuery(fields, filters, '', soslSearchTerm, 'Contact');
            if (contacts[0].size() == 0) { //Davide Viola - 05/10/2021 Modificata la condizione da contacts.isEmpty() a contacts[0].size() == 0.
                System.debug(LoggingLevel.DEBUG,'HDT_LC_ContactSelection: nessun amministratore di condominio trovato con il filtro: ' + soslSearchTerm);
                return '';
            }

            JSONGenerator gen = JSON.createGenerator(false);
            gen.writeStartArray();
            for (SObject obj : contacts[0]) {
                Contact contact = (Contact) obj;
                gen.writeStartObject();
                gen.writeStringField('Id', contact.Id);
                writeIfNotNull(gen, 'Name', contact.Name);
                writeIfNotNull(gen, 'Phone', contact.Phone);
                writeIfNotNull(gen, 'MobilePhone', contact.MobilePhone);
                writeIfNotNull(gen, 'Email', contact.Email);
                writeIfNotNull(gen, 'ContactCode__c', contact.ContactCode__c);
                writeIfNotNull(gen, 'Fax', contact.Fax);
                writeIfNotNull(gen, 'FiscalCode__c', contact.FiscalCode__c);
                writeIfNotNull(gen, 'CertifiedEmail__c', contact.CertifiedEmail__c);
                writeIfNotNull(gen, 'MailingAddressFormula__c', contact.MailingAddressFormula__c);
                gen.writeEndObject();
            }

            gen.writeEndArray();
            recordListString = gen.getAsString();
            System.debug(LoggingLevel.DEBUG,'HDT_LC_ContactSelection: recordListString: ' + recordListString);

        }catch(Exception e){
            System.debug(LoggingLevel.DEBUG,e.getMessage());
        }
        return recordListString;
    }

    @AuraEnabled(cacheable = false)
    public static String getSolContacts(String accountId){
        String recordListString;
        try{
            System.debug(LoggingLevel.DEBUG,'HDT_LC_ContactSelection: accountId: ' + accountId);

            List<List<sObject>> recordList = new List<List<sObject>>();
            Map<Id, String> rolesMap = new Map<Id, String>();

            HDT_QR_AccountContactRelation acrQueryHandler = new HDT_QR_AccountContactRelation();
            List<AccountContactRelation> relationList = acrQueryHandler.getSolContactRelations(accountId);
            Set<Id> contactIds = new Set<Id>();
            for (AccountContactRelation acr : relationList) {
                System.debug(LoggingLevel.DEBUG,'HDT_LC_ContactSelection: ACR: ' + acr);
                contactIds.add(acr.ContactId);
                rolesMap.put(acr.ContactId, acr.Roles);
            }

            HDT_QR_Contact contactQueryHandler = new HDT_QR_Contact();
            List<Contact> contacts = contactQueryHandler.getRecordsByIds(contactIds);
            Set<Id> individualIds = new Set<Id>();
            for (Contact c : contacts) {
                individualIds.add(c.IndividualId);
            }

            HDT_QR_SolManager solManagerQuery = new HDT_QR_SolManager();
            List<ContactPointEmail> logins = solManagerQuery.getSolLogins(individualIds);
            System.debug(LoggingLevel.DEBUG,'# LOGIN SOL: ' + logins.size());
            Map<Id, String> loginsMap = new Map<Id, String>();
            for (ContactPointEmail login : logins) {
                loginsMap.put(login.ParentId, login.EmailAddress);
            }

            JSONGenerator gen = JSON.createGenerator(false);
            gen.writeStartArray();
            for (Contact contact : contacts) {
                gen.writeStartObject();
                gen.writeStringField('Id', contact.Id);
                writeIfNotNull(gen, 'Name', contact.Name);
                writeIfNotNull(gen, 'Phone', contact.Phone);
                writeIfNotNull(gen, 'MobilePhone', contact.MobilePhone);
                writeIfNotNull(gen, 'Email', contact.Email);
                writeIfNotNull(gen, 'Fax', contact.Fax);
                writeIfNotNull(gen, 'CertifiedEmail__c', contact.CertifiedEmail__c);
                writeIfNotNull(gen, 'MailingAddressFormula__c', contact.MailingAddressFormula__c);
                writeIfNotNull(gen, 'SolLogin', loginsMap.get(contact.IndividualId));
                writeIfNotNull(gen, 'Roles', rolesMap.get(contact.Id));
                gen.writeEndObject();
            }

            gen.writeEndArray();
            recordListString = gen.getAsString();
            System.debug(LoggingLevel.DEBUG,'HDT_LC_ContactSelection: recordListString: ' + recordListString);

        }catch(Exception e){
            System.debug(LoggingLevel.DEBUG,e.getMessage());
        }
        return recordListString;
    }

    private static void writeIfNotNull(JSONGenerator generator, String key, String value) {
        if (value != null) {
            generator.writeStringField(key, value);
        }
    }
}
