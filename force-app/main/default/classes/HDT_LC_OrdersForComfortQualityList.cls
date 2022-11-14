public inherited sharing class HDT_LC_OrdersForComfortQualityList {
    
    private static HDT_QR_Order orderQr = new HDT_QR_Order();
    private static HDT_SRV_Order orderSrv = new HDT_SRV_Order();
    private static HDT_SRV_ActivityCustom activitySrv = new HDT_SRV_ActivityCustom();
    private static HDT_SRV_CampaignMember campMembSrv = new HDT_SRV_CampaignMember();
    private static HDT_QR_RecordType rctype = new  HDT_QR_RecordType();

    @AuraEnabled
    public static List<SObject> getTableData(String activityId) {
        
        List<SObject> resultList = new List<SObject>();

        List<wrts_prcgvr__Activity__c> actList = HDT_QR_ActivityCustom.getActivityByRecordId(activityId);

        if (actList[0].Order__r.RecordType.DeveloperName == 'HDT_RT_OrderDossier') {
            resultList = orderQr.getOrderForComfortQualityResult(actList[0].Order__c);
        }
        else {
            resultList = actList;
        }
        return resultList;
    }

    @AuraEnabled
    public static CampaignMember confirmContract(String ordId, String activityId, String type){

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
            causalQuality = 'Comfort Call OK';
            orderUpdate.SignedDate__c = Date.today();
            orderUpdate.Phase__c = phase;
        }
        else {
            List<Order> orderActiveMonitoring = orderQr.getOrderForActiveMonitoringCheck(ordId);
            // List<String> isMonitoringList = HDT_UTL_AgentMatrix.agencyCodeIsMonitoringList();
            
            if(orderActiveMonitoring[0].Phase__c != null && orderActiveMonitoring[0].Phase__c.equalsIgnoreCase('In attesa di quality call')){
                orderUpdate.Phase__c = 'Quality Call OK';
                if (orderActiveMonitoring[0].SignedDate__c==null) {
                    orderUpdate.SignedDate__c = Date.today();
                }
            }
            causalQuality = 'Quality Call OK';

        }
        orderSrv.updateRecord(orderUpdate);

        wrts_prcgvr__Activity__c act = createActivityToClose(activityId);
        act.wrts_prcgvr__Status__c = 'Esitata';
        act.ContactResult__c = causalQuality;
        activitySrv.updateRecord(act);

        List<CampaignMember> campMembList = HDT_QR_CampaignMember.getCampMembByActivity(activityId);
        for(CampaignMember cm : campMembList){
            if(String.isNotBlank(cm.Campaign.PositiveOutcomeDefaultStatus__c)){
                cm.Status = cm.Campaign.PositiveOutcomeDefaultStatus__c;
            }
        }
        campMembSrv.updateRecords(campMembList);
        if (campMembList!=null && campMembList.size()>0) {
            return campMembList[0];
        }
        else {
            return null;
        }
    }

    @SuppressWarnings('PMD.CyclomaticComplexity')
    @AuraEnabled
    public static CampaignMember cancelContract(String ordId, String activityId, String causal){

        List<String> notCancelPhase = new List<String>{
            'Esito OK da DL',
            'Dati discordanti',
            'Annullato',
            'In lavorazione SAP',
            'Errore lavorazione SAP',
            'Completata',
            'Esito OK da SII',
            //'Esito KO da SII',
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
            'Comunicazione verso Heroku',
            'Caricamento Siebel OK'
        };
        
        Boolean checkOk = false;
        List<Order> ordToCheck = orderQr.getOrderForComfort(ordId);

        List<Order> allOrders = orderQr.getAllOrdersForComfort(ordToCheck[0].ParentOrder__c);

        if (allOrders!=null && allOrders.size()>0) {
            for (Order currOrd:allOrders){
                if (currOrd.Id!=ordToCheck[0].Id) {
                    if (!String.isBlank(currOrd.ConfirmCustomerContract__c) ||
                    (String.isBlank(currOrd.ConfirmCustomerContract__c) && String.isBlank(currOrd.CancellationReason__c) )) {
                        checkOk=true;
                        break;
                    }
                }
            }
        }
        
        String result = ordToCheck[0].DateComfortCall__c == null ? 'Annullato Quality Call' : 'Annullato Comfort Call';

        if (notCancelPhase.contains(ordToCheck[0].Phase__c) || notCancelNonBillable.contains(ordToCheck[0].Phase__c) || notCancelBillable.contains(ordToCheck[0].Phase__c)) {
            if ('Firma Falsa'.equalsIgnoreCase(causal) || 'Volontà estorta'.equalsIgnoreCase(causal) || causal.equalsIgnoreCase('Contatto Quality Fallito')) {
                
                wrts_prcgvr__Activity__c act = new wrts_prcgvr__Activity__c(Id = activityId);
                if(causal.equalsIgnoreCase('Contatto Quality Fallito')){
                    act = createActivityToClose(activityId);
                    act.wrts_prcgvr__Status__c = 'Non Esitata';
                    act.ContactResult__c = result; 
                    activitySrv.updateRecord(act);
                }
                else if(!checkOk){
                    act = createActivityToClose(activityId);
                    act.wrts_prcgvr__Status__c = 'Esitata';
                    act.ContactResult__c =result; 
                    activitySrv.updateRecord(act);
                }
                if(ordToCheck[0].Phase__c!='Annullato'){
                    RecordType rc= rctype.getRecordType('HDT_RT_AttivitaGestionali', 'wrts_prcgvr__Activity__c');
                    activitySrv.createRecord(new wrts_prcgvr__Activity__c(
                        RecordTypeId= rc.Id,
                        Cluster__c = 'Attivazioni',
                        Type__c = ordToCheck[0].isTransition__c ? HDT_UTL_ActivityCustom.ANNULLAMENTO_SIEBEL : HDT_UTL_ActivityCustom.CONTRATTO_NON_RICHIESTO, 
                        Process__c = transcodeProcessForActivity(ordToCheck[0].RecordType.DeveloperName) != null ? transcodeProcessForActivity(ordToCheck[0].RecordType.DeveloperName) : ordToCheck[0].ProcessType__c,
                        Note__c = 'Quality esitata negativamente'
                    ));
                }
            }
            if(!causal.equalsIgnoreCase('Contatto Quality Fallito')){
                throw new AuraHandledException('Non è possibile procedere all’annullamento, effettuare una richiesta di recesso');
            }
        }
        else
        {
            String phase = (HDT_UTL_Order.checkCancellationPhase(new Set<String>{ordId})).get(ordId);
            String status = phase.equalsIgnoreCase('Annullato') ? 'Annullato' : 'In Lavorazione';
            wrts_prcgvr__Activity__c act = new wrts_prcgvr__Activity__c(Id = activityId);
            if(causal.equalsIgnoreCase('Contatto Quality Fallito')){
                act = createActivityToClose(activityId);
                act.wrts_prcgvr__Status__c = 'Non Esitata';
                act.ContactResult__c = result;
                activitySrv.updateRecord(act);
            }
            else if(!checkOk){
                act = createActivityToClose(activityId);
                act.wrts_prcgvr__Status__c = 'Esitata';
                act.ContactResult__c = result; 
                activitySrv.updateRecord(act);
            }
            orderSrv.updateRecord(new Order(
                Id = ordId,
                Phase__c = phase,
                CancellationReason__c = causal,
                CancellationRequestDate__c = System.today(),
                Status = status
            ));

        }

        List<CampaignMember> campMembList = HDT_QR_CampaignMember.getCampMembByActivity(activityId);
        for(CampaignMember cm : campMembList){
            if(String.isNotBlank(cm.Campaign.PositiveOutcomeDefaultStatus__c)){
                cm.Status = cm.Campaign.PositiveOutcomeDefaultStatus__c;
            }
        }
        campMembSrv.updateRecords(campMembList);
        if (campMembList!=null && campMembList.size()>0) {
            return campMembList[0];
        }
        else {
            return null;
        }
    }

    @AuraEnabled
    public static String checkOwner(String activityId){
        try {
            List<wrts_prcgvr__Activity__c> activities = HDT_QR_GenericQuery.getGenericRecords('Id, isUserActivity__c', 'wrts_prcgvr__Activity__c', 'Id =\''+String.escapeSingleQuotes(activityId)+'\'');
            return (activities[0].isUserActivity__c) ? 'OK' : 'KO';
        } catch (Exception e) {
            return 'NO CHECK';
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

    private static wrts_prcgvr__Activity__c createActivityToClose(String activityId){
        wrts_prcgvr__Activity__c actAppo = HDT_UTL_Scarti.closeDiscardActivity(activityId);
        return new wrts_prcgvr__Activity__c(
            Id = activityId,
            EndDate__c = actAppo.EndDate__c, 
            UserCompany__c = actAppo.UserCompany__c, 
            ClosedByUsername__c=actAppo.ClosedByUsername__c,
            ClosingCreatorGroup__c = actAppo.ClosingCreatorGroup__c,
            ClosingUserChannel__c = actAppo.ClosingUserChannel__c,
            //@ealpi valorizzato in apertura activity --> Place__c = actAppo.Place__c,
            ActivityEndTime__c = actAppo.ActivityEndTime__c
        );
    }
}
