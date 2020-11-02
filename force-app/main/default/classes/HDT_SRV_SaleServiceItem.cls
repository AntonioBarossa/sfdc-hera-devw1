public with sharing class HDT_SRV_SaleServiceItem {
    
    private static HDT_UTL_HelperMethods helperMethods = new HDT_UTL_HelperMethods();
    private static HDT_SRV_Opportunity opportunityService = new HDT_SRV_Opportunity();
    private static HDT_SRV_Quote quoteService = new HDT_SRV_Quote();
    private static HDT_QR_SaleServiceItem saleServiceItemQuery = new HDT_QR_SaleServiceItem();
    private static HDT_QR_ServicePoint servicePointQuery = new HDT_QR_ServicePoint();

    /**
     * Create SaleServiceItem__c record
     * @param ServicePoint__c servicePoint
     * @param Sale__c sale
     * @return SaleServiceItem__c saleServiceItem
     */
    public SaleServiceItem__c createRecord(ServicePoint__c servicePoint, Sale__c sale){

        List<ServicePoint__c> existingServicePoint = servicePointQuery.getRecordById(servicePoint.Id, 'ServicePointCode__c,RecordType.Name');

        String recordTypeName = existingServicePoint[0].RecordType.Name;
        String supplyCity = servicePoint.SupplyCity__c;

        List<SaleServiceItem__c> existingSaleServiceItems = saleServiceItemQuery.queryExsistingCityAndType(sale, supplyCity, recordTypeName);

        SaleServiceItem__c newSaleServiceItem = new SaleServiceItem__c();

        if (!existingSaleServiceItems.isEmpty()) {

            if (isServicePointConfirmed(existingSaleServiceItems, servicePoint.Id)) {
                throw new AuraHandledException('Service Point '+ servicePoint.ServicePointCode__c +' già confermato ');
            }

            newSaleServiceItem = new SaleServiceItem__c(
                Opportunity__c = existingSaleServiceItems[0].Opportunity__c,
                Quote__c = existingSaleServiceItems[0].Quote__c,
                ServicePoint__c = servicePoint.Id
            );
        } else {
            Opportunity newOpportunity = opportunityService.createRecord(new Opportunity(
                Vendita__c = sale.Id,
                Name = opportunityService.generateName(sale),
                CloseDate = Date.today().addDays(30),
                StageName = 'Proposal',
                AccountId = sale.Account__c
            ));

            SBQQ__Quote__c newQuote = quoteService.createRecord(new SBQQ__Quote__c(
                Vendita__c = sale.Id,
                SBQQ__Account__c = sale.Account__c
            ));

            newSaleServiceItem = new SaleServiceItem__c(
                Opportunity__c = newOpportunity.Id,
                Quote__c = newQuote.Id,
                ServicePoint__c = servicePoint.Id
            );
        }

        List<String> fields = helperMethods.getObjAttrList(newSaleServiceItem);

        HDT_UTL_SecurityAccess securityAccess = new HDT_UTL_SecurityAccess('SaleServiceItem__c', String.join(fields, ','), 'create');
        securityAccess.checkSecurityAccess();

        insert newSaleServiceItem;

        return newSaleServiceItem;
    }
    
    /**
     * Check if Service Point is already confirmed for current Sale__c and Opportunity
     * @param List<SaleServiceItem__c> saleServiceItems
     * @param String servicePointId
     * @return Boolean
     */
    private Boolean isServicePointConfirmed(List<SaleServiceItem__c> saleServiceItems, String servicePointId){
        for (SaleServiceItem__c item : saleServiceItems) {
            if (item.ServicePoint__c == servicePointId) {
                return true;
            }
        }

        return false;
    }
}
