public inherited sharing class HDT_LC_OrdersForComfortQualityList {
    
    private static HDT_QR_Order orderQr = new HDT_QR_Order();
    private static HDT_SRV_Order orderSrv = new HDT_SRV_Order();
    private static HDT_SRV_ActivityCustom activitySrv = new HDT_SRV_ActivityCustom();

    @AuraEnabled
    public static List<SObject> getTableData(String activityId) {
        
        List<SObject> resultList = new List<SObject>();

        List<wrts_prcgvr__Activity__c> actList = HDT_QR_ActivityCustom.getActivityByRecordId(activityId);

        if (actList[0].Order__r.RecordType.DeveloperName == 'HDT_RT_OrderDossier') {
            resultList = orderQr.getOrderForComfortQualityResult(actList[0].Order__c);
        } else {
            resultList = actList;
        }

        return resultList;
    }

    @AuraEnabled
    public static void confirmContract(String ordId, String activityId, String type){

        String confirmText = type == 'Comfort' ? 'Comfort call' : 'Quality call';

        Order orderUpdate = new Order(
            Id = ordId,
            ConfirmCustomerContract__c = confirmText
        );

        List<Order> orderActiveMonitoring = orderQr.getOrderForActiveMonitoringCheck(ordId);

        orderUpdate.Phase__c = 'Quality Call OK';

        orderSrv.updateRecord(orderUpdate);

        activitySrv.updateRecord(new wrts_prcgvr__Activity__c(
            Id = activityId,
            Status__c = 'Chiusa'
        ));
    }

    @AuraEnabled
    public static void cancelContract(String ordId, String activityId, String causal){

        orderSrv.updateRecord(new Order(
            Id = ordId,
            Phase__c = 'Annullato',
            CancellationReason__c = causal,
            Status = 'Activated'
        ));

        activitySrv.updateRecord(new wrts_prcgvr__Activity__c(
            Id = activityId,
            Status__c = 'Chiusa'
        ));
    }
}
