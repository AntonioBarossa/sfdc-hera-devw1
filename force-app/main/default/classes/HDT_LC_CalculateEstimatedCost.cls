public inherited sharing class HDT_LC_CalculateEstimatedCost {
    private static HDT_SRV_Order orderSrv = new HDT_SRV_Order();

    @AuraEnabled
    public static void updateOrder(Order order){
        orderSrv.updateRecord(new Order(
            Id = order.Id,
            EstimateAmount__c = order.EstimateAmount__c,
            PowerQuote__c = order.PowerQuote__c,
            AdministrativeBurden__c = order.AdministrativeBurden__c,
            EstimatedVAT__c = order.EstimatedVAT__c,
            ValidityDateEstimate__c = order.ValidityDateEstimate__c
        ));
    }
}