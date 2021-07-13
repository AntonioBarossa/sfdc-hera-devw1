public with sharing class HDT_BA_QualityCall implements Database.Batchable<sObject>, Database.Stateful {
    private static HDT_QR_CampaignMember campaignMemberQr = new HDT_QR_CampaignMember();

    public List<Order> ordersToUpdate = new List<Order>();
    public List<wrts_prcgvr__Activity__c> callActivities = new List<wrts_prcgvr__Activity__c>();

    public Database.QueryLocator start(Database.BatchableContext bc) {
        system.debug('HDT_BA_QualityCall - Start');
        String query = 'SELECT Id,ComfortCallDaysDue__c,DateComfortCall__c,WizardCompletedDate__c,ParentOrder__c,QualityCall__c,QualityCallUnique__c,Contact__c,CommissioningCampaign__c,PhoneNumber__c,AccountId FROM Order Where Phase__c != \'In attesa conferma cliente\' AND QualityCall__c = true';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Order> orders){

        Map<String,wrts_prcgvr__Activity__c> mapActivitiesParent = new Map<String,wrts_prcgvr__Activity__c>(); //in order not to get duplicate activities associated to same Parent Order

        List<CampaignMember> campaignMembersInsert = new List<CampaignMember>();
        List<CampaignMember> campaignMembersUpdate = new List<CampaignMember>();

        Map<String,Order> orderMap = new Map<String,Order>();
        Map<String,wrts_prcgvr__Activity__c> orderActivityMap = new Map<String,wrts_prcgvr__Activity__c>();

        Date dueDate = Date.today();

        for (Order ord : orders) {
            if (dueDate.daysBetween(ord.WizardCompletedDate__c) > 50) { //check number of days passed after being signed as quality
                ordersToUpdate.add(new Order(
                    Id = ord.Id,
                    QualityCall__c = false
                ));
            } else {
                if (ord.QualityCallUnique__c) {
                    mapActivitiesParent.put(ord.ParentOrder__c, new wrts_prcgvr__Activity__c(
                        Order__c = ord.ParentOrder__c
                    ));
                } else {
                    callActivities.add(new wrts_prcgvr__Activity__c(
                        Order__c = ord.Id,
                        Account__c = ord.AccountId
                    ));
                }
            }
        }

        callActivities.addAll(mapActivitiesParent.values());
        update ordersToUpdate;
        insert callActivities;


        for (String ordId : orderActivityMap.keySet()) {
            if ( orderMap.get(ordId).Contact__c != null && orderMap.get(ordId).CommissioningCampaign__c != null) {
                List<CampaignMember> campaignMembers = campaignMemberQr.getCampaignMemberByCampaingAndContact(orderMap.get(ordId).CommissioningCampaign__c, orderMap.get(ordId).Contact__c);
                CampaignMember campaignMember = new CampaignMember();
                
                if (!campaignMembers.isEmpty()) {
                    campaignMember = campaignMembers[0];

                    campaignMembersUpdate.add(new CampaignMember(
                        Id = campaignMember.Id,
                        RelatedActivity__c = orderActivityMap.get(ordId).Id
                    ));

                } else {
                    campaignMembersInsert.add(new CampaignMember(
                        ContactId = orderMap.get(ordId).Contact__c,
                        CampaignId = orderMap.get(ordId).CommissioningCampaign__c,
                        PhoneNumber__c = orderMap.get(ordId).PhoneNumber__c,
                        RelatedActivity__c = orderActivityMap.get(ordId).Id
                    ));
                }
            }
        }

        insert campaignMembersInsert;
        update campaignMembersUpdate;
    }
    public void finish(Database.BatchableContext bc){
        system.debug('HDT_BA_QualityCall - end');
    }
}
