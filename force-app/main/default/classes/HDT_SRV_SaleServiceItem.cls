public with sharing class HDT_SRV_SaleServiceItem {
    
    private static HDT_UTL_HelperMethods helperMethods = new HDT_UTL_HelperMethods();

    /**
     * Create SaleServiceItem__c record
     * @param SaleServiceItem__c saleServiceItem
     * @return SaleServiceItem__c saleServiceItem
     */
    public SaleServiceItem__c createRecord(SaleServiceItem__c saleServiceItem){
        
        List<String> fields = helperMethods.getObjAttrList(saleServiceItem);

        HDT_UTL_SecurityAccess securityAccess = new HDT_UTL_SecurityAccess('SaleServiceItem__c', String.join(fields, ','), 'create');
        securityAccess.checkSecurityAccess();

        insert saleServiceItem;

        return saleServiceItem;
    }
}
