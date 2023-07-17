public with sharing class HDT_BA_CampaignMemberManaged implements Database.Batchable<SObject>{
    private Set<Id> recordIdToWorkList;
    private Set<Id> workedActivitySet;
    
    public HDT_BA_CampaignMemberManaged(Set<Id> recordIdToWorkList) {
        this.recordIdToWorkList = recordIdToWorkList;
        this.workedActivitySet = new set<Id>();
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id, HasResponded, RelatedActivity__c, ResultType__c FROM CampaignMember WHERE HasResponded = true AND RelatedActivity__c != null AND ResultType__c = \'Macchina\' AND Id IN :recordIdToWorkList');
    }

    public void execute(Database.BatchableContext context, List<SObject> scope){
        List<CampaignMember> filteredNewCampaignMembList = (List<CampaignMember>)scope;
        Set<String> actIdSet = new Set<String>();
        Set<String> ordIdSet = new Set<String>();
        Map<String, Order> actToOrderIdMap = new Map<String, Order>();
        Map<String, List<Order>> orderToChildMap = new Map<String, List<Order>>();
        Map<String, List<String>> actToOrdersToCancelMap = new Map<String, List<String>>();
        HDT_SRV_ActivityCustom activitySrv = new HDT_SRV_ActivityCustom();
        List<String> isMonitoringList = HDT_UTL_AgentMatrix.agencyCodeIsMonitoringList();
        List<wrts_prcgvr__Activity__c> actToCancelList = new List<wrts_prcgvr__Activity__c>();
        
        for(CampaignMember campMemb : filteredNewCampaignMembList){
            actIdSet.add(campMemb.RelatedActivity__c);    
        }

        Map<Id,String> mapContactResult = new Map<Id,String>();
        for(wrts_prcgvr__Activity__c act : HDT_QR_Activity.getActivityFromIdList(actIdSet)){
            if(act.Order__c != null){
                actToOrderIdMap.put(act.Id, act.Order__r);
                ordIdSet.add(act.Order__c);
            }
            if ('Quality Call'.equalsIgnoreCase(act.Type__c) || 'Comfort Call'.equalsIgnoreCase(act.Type__c)){
                mapContactResult.put(act.Id,'Quality Call'.equalsIgnoreCase(act.Type__c)? 'Annullato Quality Call' : 'Annullato Comfort Call');
            }
        }

        if (!ordIdSet.isEmpty()){
            for(Order ord : HDT_QR_Order.getOrderQuality(ordIdSet)){
                if(!ord.RecordType.Developername.equalsIgnoreCase('HDT_RT_OrderDossier')){
                    if(orderToChildMap.get(ord.ParentOrder__c) != null){
                        orderToChildMap.get(ord.ParentOrder__c).add(ord);
                    }
                    else {
                        orderToChildMap.put(ord.ParentOrder__c, new List<Order>());
                        orderToChildMap.get(ord.ParentOrder__c).add(ord);
                    }
                }
            }
        }
        
        for(CampaignMember member : filteredNewCampaignMembList){
            if(member.ResultType__c == 'Macchina' && member.HasResponded==true && member.RelatedActivity__c != null && !workedActivitySet.contains(member.RelatedActivity__c)){ //&& member.ResultType__c != campMembOldMap.get(member.Id).ResultType__c 
                workedActivitySet.add(member.RelatedActivity__c);
                if(actToOrderIdMap.get(member.RelatedActivity__c) != null && isMonitoringList.contains(actToOrderIdMap.get(member.RelatedActivity__c).AgencyCode__c)){
                    if(!actToOrderIdMap.get(member.RelatedActivity__c).RecordType.DeveloperName.equalsIgnoreCase('HDT_RT_OrderDossier')){
                        actToOrdersToCancelMap.put(member.RelatedActivity__c, new List<String>());
                        actToOrdersToCancelMap.get(member.RelatedActivity__c).add(actToOrderIdMap.get(member.RelatedActivity__c).Id);
                    }
                    else {
                        actToOrdersToCancelMap.put(member.RelatedActivity__c, new List<String>());
                        String ordParentId = actToOrderIdMap.get(member.RelatedActivity__c).Id;
                        if (orderToChildMap.containsKey(ordParentId)){
                            for(Order ord : orderToChildMap.get(ordParentId)){
                                actToOrdersToCancelMap.get(member.RelatedActivity__c).add(ord.Id);
                            }
                        }
                    }
                }
                else {
                    String outcome = mapContactResult.containsKey(member.RelatedActivity__c)? mapContactResult.get(member.RelatedActivity__c) : 'Annullato';
                    wrts_prcgvr__Activity__c act = new wrts_prcgvr__Activity__c(Id = member.RelatedActivity__c, ContactResult__c = outcome, wrts_prcgvr__Status__c = 'Non Esitata');
                    actToCancelList.add(act);
                }
            }
        }

        if(actToOrdersToCancelMap.size() > 0){
            HDT_UTL_CampaignMember.cancelContract(actToOrdersToCancelMap);
        }

        if(actToCancelList.size() > 0){
            activitySrv.updateRecords(actToCancelList);
        }
    }

    @SuppressWarnings('PMD.AvoidDebugStatements')
    public void finish(Database.BatchableContext context) {
        System.debug(LoggingLevel.DEBUG, 'HDT_BA_CampaignMemberManaged - finish method');
    }

}
