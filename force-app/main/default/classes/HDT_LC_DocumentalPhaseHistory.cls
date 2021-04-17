public with sharing class HDT_LC_DocumentalPhaseHistory {
    @AuraEnabled
    public static List<SObject> getDocumentalPhaseHistory(String recordId, String objectApiName){
        String fromQ = '';
        String whereQ = '';
        String fieldsQ = 'Id, OldValue, NewValue, CreatedDate';
        String orderQ = 'CreatedDate Desc';
        String queryString = 'SELECT ';
        switch on objectApiName {
            when 'Case' {
                whereQ = 'CaseId = \''+recordId +'\'';
                fromQ = 'CaseHistory';
            }
            when else {
                whereQ = 'OrderId = \''+recordId +'\'';
                fromQ = 'OrderHistory';
            }
        }
        whereQ += ' AND Field =\'DocumentalPhase__c\'';
        queryString += fieldsQ + ' FROM ' + fromQ + ' WHERE ' + whereQ + ' ORDER BY ' + orderQ;
        System.debug('query ' + queryString);
        return HDT_QR_GenericQuery.getGenericRecords(queryString, fromQ);
    }
}