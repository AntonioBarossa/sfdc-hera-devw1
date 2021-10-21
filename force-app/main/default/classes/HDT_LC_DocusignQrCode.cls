/*
* @Author: Salvatore A. Sarà 20/10/2021
* Risoluzione "Debug Should Use Logging Level"
* Risoluzione "Avoid debug statements since they impact on performance"
*/
@SuppressWarnings('PMD.AvoidDebugStatements')
public with sharing class HDT_LC_DocusignQrCode {
    /*@AuraEnabled
    public static String getDocusignUrl(String recordId, String objectApiName){
        String fromString = '';
        String whereString = '';
        String fieldsString = 'Id, DocusignURL__c';
        String queryString = 'SELECT ';
        switch on objectApiName {
            when 'Case' {
                whereString = 'Id = \''+recordId +'\'';
                fromString = 'Case';
            }
            when else {
                whereString = 'Id = \''+recordId +'\'';
                fromString = 'Order';
            }
        }
        queryString += fieldsString + ' FROM ' + fromString + ' WHERE ' + whereString;
        System.debug('query ' + queryString);

        List<SObject> objects = HDT_QR_GenericQuery.getGenericRecords(queryString, fromString);

        if (!objects.isEmpty()) {
            return (String) objects[0].get('DocusignURL__c');
        }

        return null;
    }*/

    @AuraEnabled
    public static String getObject(String recordId, String objectApiName){
        String fromString = '';
        String whereString = '';
        String fieldsString = 'Id,DocusignURL__c';
        String queryString = 'SELECT ';
        switch on objectApiName {
            when 'Case' {
                fieldsString += ',SendMode__c,SignMode__c,Email__c,PhoneNumber__c';
                whereString = 'Id = \''+recordId +'\'';
                fromString = 'Case';
            }
            when else {
                fieldsString += ',DocSendingMethod__c,SignatureMethod__c,ShippingMail__c,PhoneNumber__c';
                whereString = 'Id = \''+recordId +'\'';
                fromString = 'Order';
            }
        }
        queryString += fieldsString + ' FROM ' + fromString + ' WHERE ' + whereString;
        System.debug(LoggingLevel.DEBUG, 'query ' + queryString);

        List<SObject> objects = HDT_QR_GenericQuery.getGenericRecords(queryString, fromString);

        if (!objects.isEmpty()) {
            return JSON.serialize(objects[0]);
        }

        return null;
    }
}