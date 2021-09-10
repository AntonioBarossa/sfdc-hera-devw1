public with sharing class HDT_LC_CtToolbar {
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
}