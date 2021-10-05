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
        String causalQuality = '';

        Order orderUpdate = new Order(
            Id = ordId,
            ConfirmCustomerContract__c = confirmText
        );

        if(confirmtext == 'Comfort call'){
            //SwitchIn, cambioOfferta -> communicazione verso heroku
            List<Order> ordComf = orderQr.getOrderForComfort(ordId);

            String phase = null;

            switch on ordComf[0].RecordType.DeveloperName {
                when  'HDT_RT_VAS'{
                    phase ='Comunicazione Motore VAS';
                }
                when 'HDT_RT_CambioOfferta' {
                    phase = 'Comunicazione verso Heroku';
                }
                when 'HDT_RT_SwitchIn' {
                    phase = 'Comunicazione verso Heroku';
                }
            }
            
            orderUpdate.SignedDate__c = Date.today();
            orderUpdate.Phase__c = phase;
        } else {
            List<Order> orderActiveMonitoring = orderQr.getOrderForActiveMonitoringCheck(ordId);
            List<String> isMonitoringList = HDT_UTL_AgentMatrix.agencyCodeIsMonitoringList();
            
            if(isMonitoringList.contains(orderActiveMonitoring[0].AgencyCode__c)){
                orderUpdate.Phase__c = 'Quality Call OK';
                orderUpdate.SignedDate__c = Date.today();
            }

            causalQuality = 'Quality Call OK';

        }

        orderSrv.updateRecord(orderUpdate);

        activitySrv.updateRecord(new wrts_prcgvr__Activity__c(
            Id = activityId,
            Status__c = 'Esitata',
            ContactResult__c	 = causalQuality
        ));
    }

    @AuraEnabled
    public static void cancelContract(String ordId, String activityId, String causal){

        String causalQuality = '';

        orderSrv.updateRecord(new Order(
            Id = ordId,
            Phase__c = 'Annullato',
            CancellationReason__c = causal,
            Status = 'Activated'
        ));

        activitySrv.updateRecord(new wrts_prcgvr__Activity__c(
            Id = activityId,
            Status__c = 'Esitata',
            ContactResult__c	 = 'Annullato'
        ));
    }
}
