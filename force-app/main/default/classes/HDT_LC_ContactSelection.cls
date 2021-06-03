public with sharing class HDT_LC_ContactSelection {

    @AuraEnabled(cacheable = false)
    public static String getListRecords(String accountId){
        String recordListString;
        try{
            System.debug('HDT_LC_ContactSelection: accountId: ' + accountId);

            List<List<sObject>> recordList = new List<List<sObject>>();
            Map<Id, String> rolesMap = new Map<Id, String>();

            // TODO: capire se escludere contatti particolari, es. contatti SOL o Amministratore Condominio
            HDT_QR_AccountContactRelation acrQueryHandler = new HDT_QR_AccountContactRelation();
            List<AccountContactRelation> relationList = acrQueryHandler.getContactsByAccountWithRoles(accountId);
            Set<Id> contactIds = new Set<Id>();
            for (AccountContactRelation acr : relationList) {
                System.debug('HDT_LC_ContactSelection: ACR: ' + acr);
                contactIds.add(acr.ContactId);
                rolesMap.put(acr.ContactId, acr.Roles);
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
            System.debug('HDT_LC_ContactSelection: recordListString: ' + recordListString);

        }catch(Exception e){
            System.debug(e.getMessage());
        }
        return recordListString;
    }

    @AuraEnabled(cacheable = false)
    public static String getAdministrators(String accountId){
        String recordListString;
        try{
            System.debug('HDT_LC_ContactSelection: accountId: ' + accountId);

            List<List<sObject>> recordList = new List<List<sObject>>();
            Map<Id, String> rolesMap = new Map<Id, String>();

            HDT_QR_AccountContactRelation acrQueryHandler = new HDT_QR_AccountContactRelation();
            List<AccountContactRelation> relationList = acrQueryHandler.getAdministratorRelations();
            Set<Id> contactIds = new Set<Id>();
            Id accountAdministratorId = null;
            for (AccountContactRelation acr : relationList) {
                System.debug('HDT_LC_ContactSelection: ACR: ' + acr);
                if (acr.AccountId == accountId) {
                    // Memorizziamo l'Id dell'amministratore che gestisce l'Account in modo da poterlo togliere dopo.
                    accountAdministratorId = acr.ContactId;
                }
                contactIds.add(acr.ContactId);
                rolesMap.put(acr.ContactId, acr.Roles);
            }

            // Rimuoviamo l'Id dell'amministratore attuale dell'Account.
            if (accountAdministratorId != null) {
                contactIds.remove(accountAdministratorId);
                rolesMap.remove(accountAdministratorId);
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
                writeIfNotNull(gen, 'MailingAddressFormula__c', contact.MailingAddressFormula__c);
                writeIfNotNull(gen, 'Roles', rolesMap.get(contact.Id));
                gen.writeEndObject();
            }

            gen.writeEndArray();
            recordListString = gen.getAsString();
            System.debug('HDT_LC_ContactSelection: recordListString: ' + recordListString);

        }catch(Exception e){
            System.debug(e.getMessage());
        }
        return recordListString;
    }

    @AuraEnabled(cacheable = false)
    public static String getSolContacts(String accountId){
        String recordListString;
        try{
            System.debug('HDT_LC_ContactSelection: accountId: ' + accountId);

            List<List<sObject>> recordList = new List<List<sObject>>();
            Map<Id, String> rolesMap = new Map<Id, String>();

            HDT_QR_AccountContactRelation acrQueryHandler = new HDT_QR_AccountContactRelation();
            List<AccountContactRelation> relationList = acrQueryHandler.getSolContactRelations(accountId);
            Set<Id> contactIds = new Set<Id>();
            for (AccountContactRelation acr : relationList) {
                System.debug('HDT_LC_ContactSelection: ACR: ' + acr);
                contactIds.add(acr.ContactId);
                rolesMap.put(acr.ContactId, acr.Roles);
            }

            HDT_QR_Contact contactQueryHandler = new HDT_QR_Contact();
            List<Contact> contacts = contactQueryHandler.getRecordsByIds(contactIds);
            Set<Id> individualIds = new Set<Id>();
            for (Contact c : contacts) {
                individualIds.add(c.IndividualId);
            }


            //String query = 'SELECT Id,EmailAddress,ParentId FROM ContactPointEmail WHERE ParentId IN :contactIds AND Type__c = \'E-mail SOL\'';
            List<ContactPointEmail> logins = [SELECT Id,EmailAddress,ParentId FROM ContactPointEmail WHERE ParentId IN :individualIds AND Type__c = 'E-mail SOL'];
            System.debug('# LOGIN SOL: ' + logins.size());
            Map<Id, String> loginsMap = new Map<Id, String>();
            for (ContactPointEmail login : logins) {
                System.debug('LOGIN SOL: ' + login);
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
            System.debug('HDT_LC_ContactSelection: recordListString: ' + recordListString);

        }catch(Exception e){
            System.debug(e.getMessage());
        }
        return recordListString;
    }

    private static void writeIfNotNull(JSONGenerator generator, String key, String value) {
        if (value != null) {
            generator.writeStringField(key, value);
        }
    }
}
