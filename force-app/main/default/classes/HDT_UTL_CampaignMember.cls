/**
* @author Fatjola Memishaj (fatjola.memishaj@dunegroup.it)
* @date 18/03/2021
* @description HDT_UTL_CampaignMember
* @history Fatjola Memishaj – 18/03/2021 – Created class
*/

public with sharing class HDT_UTL_CampaignMember {

    public static void createCampaignMemberStatus(List<Campaign> newCampaigns, List<Campaign> oldCampaigns){

        Map<String,Campaign> mapCampaign = new Map<String,Campaign>();
        List<HDT_CampaignMemberStatus__mdt> campaignStatusMdt= HDT_QR_CampaignMemberStatusMetadata.getRecords();
        List<CampaignMemberStatus> campaignMemberStatuses= new List<CampaignMemberStatus>();

        List<Campaign> campaigns= new List<Campaign>();
        for(Campaign ce: oldCampaigns){
            mapCampaign.put(ce.id, ce);
        }
        for (Campaign cam: newCampaigns){
            Campaign oldCampaign = mapCampaign.get(cam.id);
            if(cam.Status != oldCampaign.Status ){
                if(oldCampaign.Status== 'Bozza' && cam.Status== 'Pianificata'){
                    campaigns.add(cam);
                }
            }
        }
        for(Campaign c: campaigns){
            for(HDT_CampaignMemberStatus__mdt cmdt: campaignStatusMdt){
                //filter per campaign category
                if (cmdt.Category__c == 'Tutte' && cmdt.Channel__c == 'Tutti') {
                    CampaignMemberStatus cmStatus = new CampaignMemberStatus(
                        CampaignId = c.Id,
                        Label = cmdt.MasterLabel,
                        HasResponded = cmdt.HasResponded__c,
                        IsDefault = cmdt.Default__c
                    );
                    campaignMemberStatuses.add(cmStatus);
                } else {
                    if (c.Category__c == 'Campagna CRM') {
                        if (cmdt.Category__c == 'Inbound' && cmdt.Channel__c == 'Tutti') {
                            CampaignMemberStatus cmStatus = new CampaignMemberStatus(
                                CampaignId = c.Id,
                                Label = cmdt.MasterLabel,
                                HasResponded = cmdt.HasResponded__c,
                                IsDefault = cmdt.Default__c
                            );
                            campaignMemberStatuses.add(cmStatus);
                        }
                    } else if (c.Category__c == 'Campagna Outbound' && cmdt.Category__c == 'Outbound') {
                        if (c.Channel__c == 'Telefonico Outbound' && cmdt.Channel__c == 'Telefonico Outbound') {
                            CampaignMemberStatus cmStatus = new CampaignMemberStatus(
                                CampaignId = c.Id,
                                Label = cmdt.MasterLabel,
                                HasResponded = cmdt.HasResponded__c,
                                IsDefault = cmdt.Default__c
                            );
                            campaignMemberStatuses.add(cmStatus);
                        } else if (c.Channel__c == 'Cartaceo' && cmdt.Channel__c == 'Cartaceo') {
                            CampaignMemberStatus cmStatus = new CampaignMemberStatus(
                                CampaignId = c.Id,
                                Label = cmdt.MasterLabel,
                                HasResponded = cmdt.HasResponded__c,
                                IsDefault = cmdt.Default__c
                            );
                            campaignMemberStatuses.add(cmStatus);
                        } else {
                            
                        }
                    } else if (c.Category__c == 'Campagna Marketing Cloud' && cmdt.Category__c == 'Marketing Cloud') {
                        CampaignMemberStatus cmStatus = new CampaignMemberStatus(
                            CampaignId = c.Id,
                            Label = cmdt.MasterLabel,
                            HasResponded = cmdt.HasResponded__c,
                            IsDefault = cmdt.Default__c
                        );
                        campaignMemberStatuses.add(cmStatus);
                    } else {
    
                    }
                } 
            }
        }
        try{
            HDT_SRV_CampaignMemberStatus.createRecord(campaignMemberStatuses);
        }
        catch(Exception e){
            system.debug('*******:'+ e);
        }
        

    }

    public static void createCampaignMember(List<CampaignMember> newCampaignMember) {
        List<String> campaignIds = new List<String>();
        for (CampaignMember item : newCampaignMember) {
            campaignIds.add(item.CampaignId);
        }

        List<CampaignMemberAssigmentItem__c> query = [
            SELECT Id, Agency__c, PercentageAllocation__c FROM CampaignMemberAssigmentItem__c WHERE CampaingMemberAssigment__c IN (SELECT CampaignMemberAssigment__c FROM Campaign WHERE Id IN :campaignIds AND AssignmentType__c = 'Peso Percentuale') WITH SECURITY_ENFORCED ORDER BY PercentageAllocation__c DESC
        ];
        
        Map<String,Decimal> agencyPercentage = new Map<String,Decimal>();
        for (CampaignMemberAssigmentItem__c row : query) {
            agencyPercentage.put((String)row.get('Agency__c'), (Decimal)row.get('PercentageAllocation__c'));
        }

        List<AggregateResult> campaignMembers = [
            SELECT COUNT(Id) members, Agency__c from CampaignMember WHERE CampaignId IN :campaignIds WITH SECURITY_ENFORCED GROUP BY Agency__c
        ];

        Map<String,Decimal> agencyCampaignMembers = new Map<String,Decimal>();
        Decimal totalMembers = 0;
        for (AggregateResult row : campaignMembers) {
            agencyCampaignMembers.put((String)row.get('Agency__c'), (Decimal)row.get('members'));
            totalMembers += (Decimal)row.get('members');
        }
        List<String> agencies = new List<String>(agencyPercentage.keySet());

        Integer totalAssigned = 0;
        Decimal total = totalMembers + newCampaignMember.size();

        for (String agency : agencies) {
            Decimal oldMembers = 0;
            if (agencyCampaignMembers.get(agency) != null) {
                oldMembers = agencyCampaignMembers.get(agency);
            }
            Decimal toAssign =  total * (Decimal)agencyPercentage.get(agency) / 100;
            toAssign = toAssign.round(System.RoundingMode.HALF_UP) - oldMembers;
            if ((totalAssigned + toAssign) <= newCampaignMember.size()) {
                //assign agencies to the new campaign members
                for (Integer i = 0; i < toAssign; i++) {
                    Integer index = i + totalAssigned;
                    newCampaignMember[index].Agency__c = agency;
                }
                totalAssigned += (Integer)toAssign;
            }
        }
    }

    public static void createCommercialCode(List<CampaignMember> newCampaignMember) {
        System.debug('createCommercialCode ---- ok');
        List<String> campaignIdList = new List<String>();
        List<String> campaignMemberIdList = new List<String>();
        Set<String> uniqueCampaignId = new Set<String>();
        Map<String,List<String>> allMembers = new Map<String,List<String>>();

        for (CampaignMember member : newCampaignMember) {
            uniqueCampaignId.add(member.CampaignId);
            campaignMemberIdList.add(member.Id);
        }

        campaignIdList.addAll(uniqueCampaignId);

        for (String cmpId : campaignIdList) {
            List<String> newCmList = new List<String>();
            for (CampaignMember newCm : newCampaignMember) {
                if (newCm.CampaignId == cmpId) {
                    newCmList.add(newCm.Id);
                }
            }
            allMembers.put(cmpId, newCmList);            
        }        
        
        if (!system.isBatch()) { // Keltin - added this because it cases error 'Database.executeBatch cannot be called from a batch start, batch execute, or future method' when called from HDT_BA_QualityCall
            //execute batch for each campaign
            for(String cmpId : allMembers.keySet()){
                List<String> cmpMembers = allMembers.get(cmpId);

                HDT_BA_CommercialCode ccBatch = new HDT_BA_CommercialCode(cmpId, cmpMembers);
                ID batchProcessId = Database.executeBatch(ccBatch, 500000);
                System.debug('batchProcessId - ' + batchProcessId);
            }
        }
    }

    public static void campaignSuspension(List<Campaign> newCampaigns, List<Campaign> oldCampaigns) {
        System.debug('campaignSuspension method');

        List<Campaign> campaignsToUpdate = new List<Campaign>();
        Map<String,String> oldStatus = new Map<String,String>();
        for (Campaign oldCmp : oldCampaigns) {
            oldStatus.put(oldCmp.Id, oldCmp.Status);            
        }
        for (Campaign cmp : newCampaigns) {
            if ((cmp.Status == 'Cancellata' || cmp.Status == 'Bloccata') && cmp.Channel__c.Contains('Telefonico Outbound') && oldStatus.get(cmp.Id) == 'In Corso') {
                campaignsToUpdate.add(cmp);                
            }
        }

        if (campaignsToUpdate.size() > 0) {
            List<String> campaignIds = new List<String>();
            for (Campaign camp : campaignsToUpdate) {
                campaignIds.add(camp.Id);
            }
            futureCampaignOutboundSuspensionRequest(campaignIds);
        }
    }

    @future(callout=true)
	public static void futureCampaignOutboundSuspensionRequest(List<String> campaignIds){
        System.debug('future method - ' + campaignIds);
        // for (String id : campaignIds) {
        //     HDT_WS_CampaignOutboundSuspension.HDT_WS_CampaignOutboundSuspensionRequest wsReq = new HDT_WS_CampaignOutboundSuspension.HDT_WS_CampaignOutboundSuspensionRequest();
        //     wsReq.idCampaign = id;            
        //     HDT_WS_Response res = HDT_WS_CampaignOutboundSuspension.campaignOutboundSuspension(wsReq);
        //     System.debug(res.status);
        // }
	}

    public static void activateCampaign(List<Campaign> newCampaigns, List<Campaign> oldCampaigns) {
        System.debug('ok');
        Map<String,String> oldStatus = new Map<String,String>();
        for (Campaign oldCmp : oldCampaigns) {
            oldStatus.put(oldCmp.Id, oldCmp.Status);            
        }
        for (Campaign cmp : newCampaigns) {
            if (cmp.Status == 'In Corso' && oldStatus.get(cmp.Id) == 'Pianificata') {
                cmp.isActive = true;              
            }
        }
    }
}