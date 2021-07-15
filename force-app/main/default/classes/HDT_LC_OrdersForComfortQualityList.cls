public inherited sharing class HDT_LC_OrdersForComfortQualityList {
    
    private static HDT_SRV_Order orderSrv = new HDT_SRV_Order();

    @AuraEnabled
    public static List<wrts_prcgvr__Activity__c> getTableData(String activityId) {
        return HDT_QR_ActivityCustom.getActivityByRecordId(activityId);
    }

    @AuraEnabled
    public static void confirmContract(String ordId){
        orderSrv.updateRecord(new Order(
            Id = ordId,
            Phase__c = 'Comunicazione verso Heroku'
        ));
    }

    @AuraEnabled
    public static void cancelContract(String ordId, String causal){
        orderSrv.updateRecord(new Order(
            Id = ordId,
            Phase__c = 'Annullato',
            CancellationReason__c = causal
        ));
    }
}
