public inherited sharing class HDT_UTL_ContactPointManagement {

    
    @InvocableMethod 
    public static void updateContactPoint(List<HDT_UTL_ContactPointManagementFlowInputs> flowInputs) {
        try {

            if (flowInputs.isEmpty()) {
                return;
            }

            String contactId = flowInputs[0].contactId;
            if (String.isBlank(contactId)) {
                System.debug('HDT_UTL_ContactPointManagement: no contact ID in input.');
            }

            String newPhone = flowInputs[0].newPhone;
            String newMobilePhone = flowInputs[0].newMobilePhone;
            String newEmail = flowInputs[0].newEmail;

            Contact currentContact = [SELECT Id, IndividualId, Email, Phone, MobilePhone FROM Contact WHERE Id =: contactId];

            // Disattivazione ContactPointEmail
            if (String.isNotBlank(currentContact.Email) && String.isBlank(newEmail)) {

            }

            // Aggiornamento Email
            if (String.isNotBlank(currentContact.Email) && String.isNotBlank(newEmail) && !newEmail.equals(currentContact.Email)) {

                List<Individual> individuals = [SELECT Id, (SELECT Id, EmailAddress FROM ContactPointEmails WHERE EmailAddress =: newEmail) FROM Individual WHERE Id =: currentContact.IndividualId];
                // TODO: handle empty variable individuals
                List<ContactPointEmail> emails = individuals[0].ContactPointEmails;
                if (emails.isEmpty()) {
                    System.debug('HDT_UTL_ContactPointManagement: creating new ContactPointEmail for email: ' + newEmail);

                    ContactPointEmail newCpe = new ContactPointEmail();
                    newCPE.ParentId = currentContact.IndividualId;
                    newCPE.EmailAddress = newEmail;
                    insert newCpe;

                } else {
                    // TODO
                }
                
                //System.debug('HDT_UTL_ContactPointManagement: daje ' + i[0].getSObjects('ContactPointEmails'));

            }


            System.debug('HDT_UTL_ContactPointManagement: individual ID:' + currentContact.IndividualId);

        } catch (Exception e) {
            System.debug('HDT_UTL_ContactPointManagement: ' + e.getMessage());
        }
    }

    public class HDT_UTL_ContactPointManagementFlowInputs {

        @InvocableVariable
        public String contactId;

        @InvocableVariable
        public String newPhone;

        @InvocableVariable
        public String newMobilePhone;

        @InvocableVariable
        public String newEmail;
    }
}
