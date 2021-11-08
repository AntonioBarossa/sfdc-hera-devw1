/**
 * @author Andrei Necsulescu (andrei.necsulescu@webresults.it)
 * @date 10/08/2021
 * @description HDT_LC_SendCertificationRequest - Controller class for hdtSendCertificationRequest
 * @history Inserire Nome Cognome – Data Modifica – Descrizione della modifica
 */

public with sharing class HDT_LC_SendCertificationRequest {

    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();
    private static HDT_QR_Account accountQr = new HDT_QR_Account();
    private static HDT_QR_Lead leadQr = new HDT_QR_Lead();
    private static HDT_QR_Contact contactQr = new HDT_QR_Contact();
    
    @AuraEnabled
    public static Map<String, Object> initialize(String objectapiname, String recordId){

        Map<String, Object> result = new Map<String, Object>();

        try {

            Boolean needsUpdate = false;
            
            String fields = 'Id, Status__c, SendToMarketingCloud__c, Contact__c, ParentId ';

            sObject contactPointRecord = HDT_QR_ContactPoint.getContactPointByIdAndObjectType(objectapiname, recordId, fields);

            if (contactPointRecord.get('Status__c') == constants.CONTACTPOINT_STATUS_VERIFICATO ) {

                result.put('error', true);
                result.put('errorMessage', Label.ContactPointAlreadyCertified);

            } else if ((Boolean) contactPointRecord.get('SendToMarketingCloud__c')) {

                result.put('error', true);
                result.put('errorMessage', Label.CertificationAlreadyInProgress);

            } else {
                
                Id parentId = (String) contactPointRecord.get('ParentId');

                if (String.isNotEmpty(parentId)) {

                    switch on ((Id) parentId).getSobjectType().getDescribe().getName() {

                        when 'Individual' {

                            if (!leadQr.getRecordByIndividual(parentId, 'Id, IndividualId').isEmpty()) {
                                
                                result.put('error', true);
                                result.put('errorMessage', Label.LeadCantBeCertified);

                            } else {

                                List<Contact> contacts = contactQr.getRecordByIndividual(parentId, 'Id, IndividualId, Account.CustomerAccountStatus__c');

                                if (!contacts.isEmpty() && contacts.get(0).Account.CustomerAccountStatus__c != constants.ACCOUNT_CUSTOMER_ACCOUNT_STATUS_CUSTOMER) {
                                    
                                    result.put('error', true);
                                    result.put('errorMessage', Label.AccountCantBeCertified);

                                } else {
                                    
                                    needsUpdate = true;

                                }

                            }                            

                        }
                        when 'Account' {
                            
                            Account parentAccount = accountQr.getRecordById(parentId, 'Id, CustomerAccountStatus__c');
                            
                            if (parentAccount.CustomerAccountStatus__c != constants.ACCOUNT_CUSTOMER_ACCOUNT_STATUS_CUSTOMER) {
                                
                                result.put('error', true);
                                result.put('errorMessage', Label.AccountCantBeCertified);

                            } else {

                                needsUpdate = true;

                            }

                        }
                        when else {

                            needsUpdate = true;

                        }
                    }
                    
                } else {
                    
                    needsUpdate = true;

                }
            }

            if (needsUpdate) {

                contactPointRecord.put('SendToMarketingCloud__c', true);
                
                switch on objectapiname {
                    when 'ContactPointEmail' {                        

                        HDT_SRV_ContactPointEmail.updateRecord(new List<ContactPointEmail>{(ContactPointEmail) contactPointRecord});
                        result.put('error', false);
                        result.put('resultMessage', Label.SuccessfulCertificationRequest);

                    }
                    when 'ContactPointPhone' {

                        HDT_SRV_ContactPointPhone.updateRecord(new List<ContactPointPhone>{(ContactPointPhone) contactPointRecord});
                        result.put('error', false);
                        result.put('resultMessage', Label.SuccessfulCertificationRequest);

                    }
                    when else {

                        result.put('error', true);
                        result.put('errorMessage', Label.ObjectNotAllowedForCertification);

                    }
                }

            }

            return result;


        } catch (Exception ex) {
            
            result.put('error', true);
            result.put('errorMessage', ex.getMessage());
            result.put('errorStackTrace', ex.getStackTraceString());

            return result;
        }
    }
}