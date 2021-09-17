public with sharing class HDT_LC_CtToolbar {
    public static HDT_SRV_ActivityCustom activitySrv = new HDT_SRV_ActivityCustom();
    @auraEnabled
    public static boolean updateCampaignMember(String ecid,string campaignMember,string agent){
        HDT_SRV_CampaignMember cmSrv = new HDT_SRV_CampaignMember();
        CampaignMember cm = new CampaignMember();
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
        if(cm != null){
            cm.isToSendStatusReitek__c = false;
            cmSrv.updateRecord(cm);
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
    public static wrts_prcgvr__Activity__c createActivity(String startCall, String clientNumber, String registrationLink, String ecid, String campaignMemberId){
        HDT_QR_CampaignMember cmQr = new HDT_QR_CampaignMember();
        CampaignMember cm = cmQr.getRecordById(campaignMemberId);
        wrts_prcgvr__Activity__c activity = new wrts_prcgvr__Activity__c();
        Datetime sdt = Datetime.newInstance(Long.valueOf(startCall));
        activity.CallStartTime__c = sdt;
        activity.StartDate__c = Date.newInstance(sdt.year(),sdt.month(),sdt.day()); 
        activity.Type__c = 'Chiamata outbound';
        activity.wrts_prcgvr__Status__c = 'Aperta'; //Chiusa
        activity.ClientNumber__c = clientNumber;
        activity.RecordingLink__c = registrationLink;
        activity.Ecid__c = ecid;
        if (cm.ContactId != null) {
            activity.Contact__c = cm.ContactId;
        } else if(cm.LeadId != null) {
            activity.Lead__c = cm.LeadId;
        }
        try {
            System.debug('###### activity #### ' +activity);
            return activitySrv.createRecord(activity);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Boolean updateActivity(String activityId, String endCall, Decimal callDuration, Decimal waitingTime){
        wrts_prcgvr__Activity__c activity = new wrts_prcgvr__Activity__c();
        Datetime edt = Datetime.newInstance(Long.valueOf(endCall));
        activity.Id = activityId;
        activity.CallEndTime__c = edt;
        activity.EndDate__c = Date.newInstance(edt.year(),edt.month(),edt.day());
        activity.CallDuration__c = callDuration;
        activity.WaitingTime__c = waitingTime;
        activity.wrts_prcgvr__Status__c = 'Chiusa';
        try {
            System.debug('###### activity #### ' +activity);
            activitySrv.updateRecord(activity);
            return true;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}