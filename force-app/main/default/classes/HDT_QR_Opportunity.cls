public with sharing class HDT_QR_Opportunity {
    
    /**
     * Counts all records
     * @param String Sale__c.Id
     * @return Integer
     */
    public Integer countRecordsBySale(String saleId){
        return [SELECT count() FROM Opportunity WHERE Vendita__c = :saleId WITH SECURITY_ENFORCED];
    }
}
