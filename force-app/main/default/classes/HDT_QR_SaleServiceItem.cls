public with sharing class HDT_QR_SaleServiceItem {
    
    /**
     * Check for SaleServiceItem record that has a ServicePoint__c with this city and record type
     * @param Sale__c sale
     * @param String ServicePoint__r.SupplyCity__c
     * @param String ServicePoint__r.RecordType.Name
     * @return List<SaleServiceItem__c>
     */
    public List<SaleServiceItem__c> queryExsistingCityAndType(Sale__c sale, String city, String type){

        String fieldsToCheck = 'Opportunity__c,Quote__c,ServicePoint__c,ServicePoint__r.SupplyCity__c,ServicePoint__r.RecordType.Name,Opportunity__r.Vendita__c';
        HDT_UTL_SecurityAccess securityAccess = new HDT_UTL_SecurityAccess('SaleServiceItem__c', fieldsToCheck, 'read');
        securityAccess.checkSecurityAccess();

        String saleId = sale.Id;

        return [SELECT Id,
        Opportunity__c,
        Quote__c,
        ServicePoint__c,
        ServicePoint__r.SupplyCity__c,
        ServicePoint__r.RecordType.Name,
        Opportunity__r.Vendita__c
        FROM SaleServiceItem__c
        WHERE Opportunity__r.Vendita__c = :saleId
        AND ServicePoint__r.SupplyCity__c = :city
        AND ServicePoint__r.RecordType.Name = :type
        WITH SECURITY_ENFORCED];
    }

    /**
     * Get records filtered by Opportunity__r.Vendita__c
     * @param String saleId
     * @return List<SaleServiceItem__c>
     */
    public List<SaleServiceItem__c> getRecordsBySaleId(String saleId){
        String fieldsToCheck = 'Opportunity__c,Opportunity__r.Vendita__c,Opportunity__r.Name,Quote__c,ServicePoint__c,ServicePoint__r.ServicePointCode__c,ServicePoint__r.RecordType.Name,ServicePoint__r.SupplyCity__c';
        HDT_UTL_SecurityAccess securityAccess = new HDT_UTL_SecurityAccess('SaleServiceItem__c', fieldsToCheck, 'read');
        securityAccess.checkSecurityAccess();

        return [SELECT 
        Id,
        Opportunity__c,
        Opportunity__r.Vendita__c,
        Opportunity__r.Name,
        Quote__c,
        ServicePoint__c,
        ServicePoint__r.ServicePointCode__c,
        ServicePoint__r.RecordType.Name,
        ServicePoint__r.SupplyCity__c
        FROM SaleServiceItem__c
        WHERE Opportunity__r.Vendita__c = :saleId
        WITH SECURITY_ENFORCED
        ORDER BY CreatedDate ASC
        ];
    }
}
