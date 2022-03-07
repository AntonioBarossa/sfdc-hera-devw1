public inherited sharing class HDT_LC_OrdersForComfortQualityList {
    
    private static HDT_QR_Order orderQr = new HDT_QR_Order();
    private static HDT_SRV_Order orderSrv = new HDT_SRV_Order();
    private static HDT_SRV_ActivityCustom activitySrv = new HDT_SRV_ActivityCustom();
    private static HDT_QR_RecordType rctype = new  HDT_QR_RecordType();

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
                    phase = calculateVasPhase(ordComf[0]);
                }
                when 'HDT_RT_CambioOfferta' {
                    phase = 'Comunicazione verso Heroku';
                }
                when 'HDT_RT_SwitchIn' {
                    phase = 'Comunicazione verso Heroku';
                }
                when 'HDT_RT_Voltura'{
                    phase = 'Documentazione Validata';
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
            wrts_prcgvr__Status__c = 'Esitata',
            ContactResult__c	 = causalQuality
        ));
    }

    @AuraEnabled
    public static void cancelContract(String ordId, String activityId, String causal){

        List<String> notCancelPhase = new List<String>{
            'Esito Ok da DL',
            'Dati discordanti',
            'Annullato',
            'In lavorazione SAP',
            'Errore lavorazione SAP',
            'Completata',
            'Esito OK da SII',
            'Esito KO da SII',
            'KO rilavorato',
            'KO definitivo'
        };

        List<String> notCancelNonBillable = new List<String>{
            'Completata',
            'Comunicazione verso Motore VAS OK',
            'Accettato Motore VAS',
            'Comunicazione verso Motore VAS'
        };

        List<String> notCancelBillable = new List<String>{
            'Comunicazione verso Heroku Ok',
            'Completata',
            'Comunicazione verso Heroku'
        };

        List<Order> ordToCheck = orderQr.getOrderForComfort(ordId);

        if (notCancelPhase.contains(ordToCheck[0].Phase__c) || notCancelNonBillable.contains(ordToCheck[0].Phase__c) || notCancelBillable.contains(ordToCheck[0].Phase__c)) {
            if ('Firma Falsa'.equalsIgnoreCase(causal) || 'Volontà estorta'.equalsIgnoreCase(causal)) {
                activitySrv.updateRecord(new wrts_prcgvr__Activity__c(
                    Id = activityId,
                    //wrts_prcgvr__Status__c = 'Esitata',
                    ContactResult__c	 = 'Annullato'
                ));

                RecordType rc= rctype.getRecordType('HDT_RT_AttivitaGestionali', 'wrts_prcgvr__Activity__c');
                activitySrv.createRecord(new wrts_prcgvr__Activity__c(
                    RecordTypeId= rc.Id,
                    Cluster__c = 'Attivazioni',
                    Process__c = transcodeProcessForActivity(ordToCheck[0].RecordType.DeveloperName) != null ? transcodeProcessForActivity(ordToCheck[0].RecordType.DeveloperName) : ordToCheck[0].ProcessType__c,
                    Note__c = 'Non è stato possibile procedere all’annullamento, inserire un case di Annullamento contratti'
                ));
            }
            throw new AuraHandledException('Non è possibile procedere all’annullamento, effettuare una richiesta di recesso');
        } else {

            orderSrv.updateRecord(new Order(
                Id = ordId,
                Phase__c = 'Annullato',
                CancellationReason__c = causal,
                Status = 'Activated'
            ));

            activitySrv.updateRecord(new wrts_prcgvr__Activity__c(
                Id = activityId,
                //wrts_prcgvr__Status__c = 'Esitata',
                ContactResult__c	 = 'Annullato'
            ));
        }
    }

    private static String transcodeProcessForActivity(String orderRecordType){

        Map<String,String> processActivityMap = new Map<String,String>{
            'HDT_RT_SwitchIn' => 'Switch In',
            'HDT_RT_CambioOfferta' => 'Cambio offerta',
            'HDT_RT_VAS' => 'Segnalazioni VAS'
        };

        return processActivityMap.get(orderRecordType);

    }

    private static String calculateVasPhase(Order currentOrder)
    {
        String newPhase = '';
        if( currentOrder.VASType__c == 'VAS Servizio' && !currentOrder.IsEarlyActivation__c ){
            newPhase =  'In attesa tempi di ripensamento';
        }else if( currentOrder.VASType__c == 'VAS Fatturabili' ){
            newPhase = 'Comunicazione verso Heroku';
        }else{
            newPhase =  'Comunicazione Motore VAS';
        }
        return newPhase;
    }
}
