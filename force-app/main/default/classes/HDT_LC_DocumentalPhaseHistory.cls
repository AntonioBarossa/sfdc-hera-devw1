public with sharing class HDT_LC_DocumentalPhaseHistory {
    @AuraEnabled
    public static List<SObject> getDocumentalPhaseHistory(String recordId, String objectApiName){
        String fromString = '';
        String whereString = '';
        String fieldsString = 'Id, OldValue, NewValue, CreatedDate';
        String orderString = 'CreatedDate Desc';
        String queryString = 'SELECT ';
        switch on objectApiName {
            when 'Case' {
                whereString = 'CaseId = \''+recordId +'\'';
                fromString = 'CaseHistory';
            }
            when else {
                whereString = 'OrderId = \''+recordId +'\'';
                fromString = 'OrderHistory';
            }
        }
        whereString += ' AND Field =\'DocumentalPhase__c\'';
        queryString += fieldsString + ' FROM ' + fromString + ' WHERE ' + whereString + ' ORDER BY ' + orderString;
        System.debug('query ' + queryString);
        return HDT_QR_GenericQuery.getGenericRecords(queryString, fromString);
    }

    @AuraEnabled
    public static String getParentOrderId(String orderId){
        
        Order parentOrder = HDT_QR_DocumentalConfiguration.getParentOrder(orderId);
        if (parentOrder != null) {
            return parentOrder.ParentOrder__c;
        }

        return null;
    }
}