public inherited sharing class HDT_QR_SolManager {
    
    public String getSolLogin(String solContactId) {

        if (solContactId == null) {
            System.debug('HDT_QR_SolManager: null solContactId in input');
            return '';
        }

        HDT_QR_Contact contactQueryHandler = new HDT_QR_Contact();
        Contact solContact = contactQueryHandler.getRecordById(solContactId);
        Id individualId = solContact.IndividualId;

        if (individualId == null) {
            System.debug('HDT_QR_SolManager: No InvididualId set for contact with Id: ' + solContactId);
            return '';        
        }

        List<ContactPointEmail> emails = [
            SELECT
            EmailAddress
            FROM ContactPointEmail
            WHERE ParentId = :individualId
            AND Type__c = 'E-mail SOL'
            WITH SECURITY_ENFORCED
        ];

        if (emails.isEmpty()) {
            System.debug('HDT_QR_SolManager: No SOL login email found for contact with id: ' + solContactId);
            return '';
        }

        return emails[0].EmailAddress;
    }

    public List<ContactPointEmail> getSolLogins(Set<Id> individualIds) {
        return [
            SELECT 
            Id,
            EmailAddress,
            ParentId 
            FROM ContactPointEmail 
            WHERE ParentId IN :individualIds 
            AND Type__c = 'E-mail SOL'
            WITH SECURITY_ENFORCED
        ];
    }

}