public with sharing class HDT_LC_DocusignQrCode {
    @AuraEnabled
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
    }
}