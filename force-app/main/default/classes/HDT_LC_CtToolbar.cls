public with sharing class HDT_LC_CtToolbar {
    public static HDT_SRV_ActivityCustom activitySrv = new HDT_SRV_ActivityCustom();
    public static HDT_SRV_Sale saleSrv = new HDT_SRV_Sale();
    private static HDT_UTL_Constants utlConstants = new HDT_UTL_Constants();
    //public static HDT_QR_ActivityCustom actQr = new HDT_QR_ActivityCustom();
    @auraEnabled
    public static boolean updateCampaignMember(String ecid,string campaignMember,string agent){
        HDT_SRV_CampaignMember cmSrv = new HDT_SRV_CampaignMember();
        CampaignMember cm = new CampaignMember();
        System.debug('********TRY12');
        cm.ecid__c = ecid;
        if(agent != null){
            cm.reitekAgentUserId__c = agent.split('@')[0];
        }
        cm.id = campaignMember;
        try{
            system.debug('ECCO IN TRY'); 
            cmSrv.updateRecord(cm);
            system.debug('ECCO IN TRY POST');
            return true;
        }catch(Exception e){
            system.debug('ECCO IN Catch:' + e);
           return false;
        }
    }
    @auraEnabled
    public static String getStatusByEcid(String ecid){
        HDT_SRV_CampaignMember cmSrv = new HDT_SRV_CampaignMember();
        HDT_QR_CampaignMember cmQr = new HDT_QR_CampaignMember();
        CampaignMember cm = cmQr.getByEcid(ecid);
        system.debug('********esitCampaignMember');
        system.debug('********esitCampaignMember:' + ecid);
        system.debug('********esitCampaignMember:' + ecid);
        CampaignMember cmUp = new CampaignMember();
        if(cm != null){
            cmUp.id = cm.id;
            cmUp.isToSendStatusReitek__c = false;
            cmSrv.updateRecord(cmUp);
            return cm.status;
        }else{
            return null;
        }

    }

    @AuraEnabled
    public static boolean updateCampaignMemberStatus(String status, String campaignMember, Boolean isToSendStatusReitek){
        HDT_SRV_CampaignMember cmSrv = new HDT_SRV_CampaignMember();
        CampaignMember cm = new CampaignMember();
        cm.id = campaignMember;
        cm.status = status;
        cm.isToSendStatusReitek__c = isToSendStatusReitek;
        try{
            system.debug('ECCO IN TRY');
            cmSrv.updateRecord(cm);
            system.debug('ECCO IN TRY POST');
            return true;
        }catch(Exception e){
            system.debug('ECCO IN Catch:' + e.getMessage());
           return false;
        }
    }

    @AuraEnabled
    public static String createActivityInbound(String reiteklink, String username, String password){
        HDT_SRV_LogService logs = new HDT_SRV_LogService('HDT_LC_CtToolbar');
        Order ord = HDT_LC_CanaleContattoIVRLogin.checkLogin(username,password);
        wrts_prcgvr__Activity__c activity = new wrts_prcgvr__Activity__c();
        Datetime sdt = Datetime.now();
        activity.CallStartTime__c = sdt;
        System.debug('*******:TRYMETHOD3');
        activity.StartDate__c = Date.newInstance(sdt.year(),sdt.month(),sdt.day()); 
        activity.Type__c = 'Chiamata outbound';
        activity.wrts_prcgvr__Status__c = 'Aperta'; //Chiusa
        activity.RecordingLink__c = reiteklink;
        activity.RecordTypeId = utlConstants.ACTIVITYCUSTOM_RECORDTYPEID_CHIAMATAOUTBOUND;
        if(ord != null){
            activity.order__c = ord.id;
        }
        
        activitySrv.createRecord(activity);
        logs.addLog('HDT_LC_CtToolbar', 'createActivityInbound', JSON.serialize(activity), null, null, activity.Id, null, null);
        if(ord != null) {
            return ord.id;
        } else {
            return null;
        }
    }
    @AuraEnabled
    public static wrts_prcgvr__Activity__c createActivity(/*String startCall, */String clientNumber, String registrationLink, String ecid, String campaignMemberId, String agent){
        HDT_QR_CampaignMember cmQr = new HDT_QR_CampaignMember();
        HDT_SRV_LogService logs = new HDT_SRV_LogService('HDT_LC_CtToolbar');
        System.debug('*******:TRYMETHOD');
        CampaignMember cm = cmQr.getRecordById(campaignMemberId);
        System.debug('*******:TRYMETHOD2');
        wrts_prcgvr__Activity__c activity = new wrts_prcgvr__Activity__c();
        Datetime sdt = Datetime.now();
        activity.CallStartTime__c = sdt;
        System.debug('*******:TRYMETHOD3');
        activity.StartDate__c = Date.newInstance(sdt.year(),sdt.month(),sdt.day()); 
        activity.Type__c = 'Chiamata outbound';
        activity.wrts_prcgvr__Status__c = 'Aperta'; //Chiusa
        activity.ClientNumber__c = clientNumber;
        activity.RecordingLink__c = registrationLink;
        activity.Ecid__c = ecid;
        activity.RecordTypeId = utlConstants.ACTIVITYCUSTOM_RECORDTYPEID_CHIAMATAOUTBOUND;

        if (cm.ContactId != null) {
            activity.Contact__c = cm.ContactId;
        } else if(cm.LeadId != null) {
            activity.Lead__c = cm.LeadId;
        }
        try {
            System.debug('###### activity #### ' +activity);
            System.debug('*******:TRYMETHOD4');
            // boolean cmRes = updateCampaignMember(ecid, campaignMemberId, agent);
            updateCampaignMember(ecid, campaignMemberId, agent);
            System.debug('*******:TRYMETHOD5');
            wrts_prcgvr__Activity__c act =  activitySrv.createRecord(activity);
            logs.addLog('HDT_LC_CtToolbar', 'createActivity', JSON.serialize(act), null, null, act.Id, null, null);
            return act;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Boolean updateActivity(String ecid, String endCall, Decimal callDuration, Decimal waitingTime){
        HDT_SRV_LogService logs = new HDT_SRV_LogService('HDT_LC_CtToolbar');
        wrts_prcgvr__Activity__c activity = new wrts_prcgvr__Activity__c();
        List<wrts_prcgvr__Activity__c> actList = HDT_QR_ActivityCustom.getActivityTelesellingOutbound(ecid);
        if(actList != null && !actList.isEmpty()){
            wrts_prcgvr__Activity__c activityQ = actList[0];
            Datetime edt = Datetime.newInstance(Long.valueOf(endCall));
            activity.Id = activityQ.id;
            activity.CallEndTime__c = edt;
            activity.EndDate__c = Date.newInstance(edt.year(),edt.month(),edt.day());
            activity.CallDuration__c = callDuration;
            activity.WaitingTime__c = waitingTime;
            activity.wrts_prcgvr__Status__c = 'Chiusa';
            try {
                System.debug('###### activity #### ' +activity);
                activitySrv.updateRecord(activity);
                logs.addLog('HDT_LC_CtToolbar', 'updateActivity', JSON.serialize(activity), null, null, activity.Id, null, null);
                return true;
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
        }
        return false;
    }

    @AuraEnabled
    public static Boolean saveEcidInSales(String saleId, String ecid){
        try {
            Sale__c sale = new Sale__c(
                Id = saleId,
                Ecid__c = ecid
            );
        saleSrv.updateRecord(sale);
        return true;            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void cacheUuid(String uuid) {
        if(String.isNotBlank(uuid)) {
            Cache.Session.put('local.ReitekAgentsSessionCache.uuid', uuid);
        }
    }

    @AuraEnabled
    public static String getCachedUuid() {
        return (String) Cache.Session.get('local.ReitekAgentsSessionCache.uuid');
    }

    @InvocableMethod
    public static List<String> getCachedUuidInvocable() {
        List<String> listreturn=new List<String>();
        listreturn.add((String)Cache.Session.get('local.ReitekAgentsSessionCache.uuid'));
        return listreturn;
    }
}