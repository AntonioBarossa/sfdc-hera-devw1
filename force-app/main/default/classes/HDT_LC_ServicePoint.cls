public with sharing class HDT_LC_ServicePoint {

    private static HDT_SRV_ServicePoint serviceSP = new HDT_SRV_ServicePoint();
    private static HDT_SRV_Opportunity opportunityService = new HDT_SRV_Opportunity();
    private static HDT_SRV_Quote quoteService = new HDT_SRV_Quote();
    private static HDT_SRV_SaleServiceItem saleServiceItemService = new HDT_SRV_SaleServiceItem();
    private static HDT_QR_SaleServiceItem saleServiceItemQuery = new HDT_QR_SaleServiceItem();

    public static List<String> getObjAttrList(ServicePoint__c obj){

        Map<String,Object> objMap = obj.getPopulatedFieldsAsMap();

        List<String> fields = new List<String>();
        for (String field: objMap.keySet()) {
            if (! (field.equalsIgnoreCase('Id') || field.equalsIgnoreCase('attributes'))){
                fields.add(field); 
            } 
        }

        return fields;
    }

    public static List<ServicePoint__c> getServicePointById(Id id, String fields) {
        
        HDT_UTL_SecurityAccess securityAccess = new HDT_UTL_SecurityAccess('ServicePoint__c', fields, 'read');
        securityAccess.checkSecurityAccess();

        String stringId = String.escapeSingleQuotes(id);
        String stringFields = String.escapeSingleQuotes(fields);

        String query = 'SELECT '+ stringFields +
                ' FROM ServicePoint__c WHERE Id = :stringId LIMIT 1';
        List<ServicePoint__c> servicePoints = Database.query(query);

        return servicePoints;
    }

    @AuraEnabled
    public static List<ServicePoint__c> getServicePoint(String code, String fields) {
        
        HDT_UTL_SecurityAccess securityAccess = new HDT_UTL_SecurityAccess('ServicePoint__c', fields, 'read');
        securityAccess.checkSecurityAccess();

        String stringCode = String.escapeSingleQuotes(code.trim());
        String stringFields = String.escapeSingleQuotes(fields);

        String query = 'SELECT '+ stringFields +
                ' FROM ServicePoint__c WHERE ServicePointCode__c = :stringCode LIMIT 1';
        List<ServicePoint__c> servicePoints = Database.query(query);
        return servicePoints;
    }

    @AuraEnabled
    public static ServicePoint__c createServicePoint(ServicePoint__c servicePoint) {

        List<ServicePoint__c> existingServicePoint = getServicePoint(servicePoint.ServicePointCode__c, 'ServicePointCode__c');

        if (!existingServicePoint.isEmpty()) {
            throw new AuraHandledException('Codice POD/PDR duplicato');
        } else {

            List<String> fields = getObjAttrList(servicePoint);
            
            HDT_UTL_SecurityAccess securityAccess = new HDT_UTL_SecurityAccess('ServicePoint__c', String.join(fields, ','), 'create');
            securityAccess.checkSecurityAccess();

            insert servicePoint;
            return servicePoint;
        }
    }

    @AuraEnabled
    public static ServicePoint__c confirmServicePoint(ServicePoint__c servicePoint, Sale__c sale){

        List<ServicePoint__c> existingServicePoint = getServicePointById(servicePoint.Id, 'ServicePointCode__c,RecordType.Name');

        if (existingServicePoint[0].ServicePointCode__c != servicePoint.ServicePointCode__c) {
            throw new AuraHandledException('Codice POD/PDR e stato cambiato');
        } else {

            serviceSP.updateRecord(servicePoint);

            String recordTypeName = existingServicePoint[0].RecordType.Name;
            String supplyCity = servicePoint.SupplyCity__c;

            List<SaleServiceItem__c> existingSaleServiceItems = saleServiceItemQuery.queryExsistingCityAndType(supplyCity, recordTypeName);

            if (!existingSaleServiceItems.isEmpty()) {
                SaleServiceItem__c newSaleServiceItem = saleServiceItemService.createRecord(new SaleServiceItem__c(
                    Opportunity__c = existingSaleServiceItems[0].Opportunity__c,
                    Quote__c = existingSaleServiceItems[0].Quote__c,
                    ServicePoint__c = servicePoint.Id
                ));
            } else {
                Opportunity newOpportunity = opportunityService.createRecord(new Opportunity(
                    Vendita__c = sale.Id,
                    Name = 'Test Confirm',
                    CloseDate = Date.today(),
                    StageName = 'Proposal'
                ));

                SBQQ__Quote__c newQuote = quoteService.createRecord(new SBQQ__Quote__c(
                    Vendita__c = sale.Id
                ));

                SaleServiceItem__c newSaleServiceItem = saleServiceItemService.createRecord(new SaleServiceItem__c(
                    Opportunity__c = newOpportunity.Id,
                    Quote__c = newQuote.Id,
                    ServicePoint__c = servicePoint.Id
                ));
            }

            return servicePoint;
        }
    }
}
