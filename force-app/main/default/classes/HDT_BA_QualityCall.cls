public with sharing class HDT_BA_QualityCall implements Database.Batchable<sObject>, Database.Stateful {
    private static HDT_QR_CampaignMember campaignMemberQr = new HDT_QR_CampaignMember();

    public List<Order> ordersToUpdate = new List<Order>();
    public List<wrts_prcgvr__Activity__c> callActivities = new List<wrts_prcgvr__Activity__c>();

    public Database.QueryLocator start(Database.BatchableContext bc) {
        system.debug('HDT_BA_QualityCall - Start');
        String query = 'SELECT Id,ComfortCallDaysDue__c,DateComfortCall__c,WizardCompletedDate__c,ParentOrder__c,QualityCall__c,QualityCallUnique__c,Contact__c,CommissioningCampaign__c,PhoneNumber__c,AccountId FROM Order Where Phase__c != \'In attesa conferma cliente\' AND QualityCall__c = true AND ComfortCallDaysDue__c = null';
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

                wrts_prcgvr__Activity__c activity = new wrts_prcgvr__Activity__c(
                        RecordTypeId = HDT_UTL_ActivityCustom.getRecordTypeId('HDT_RT_ComfortQualityCall'),
                        Order__c = ord.Id,
                        Account__c = ord.AccountId,
                        Type__c = 'Quality Call',
                        Status__c = 'Creata'
                );

                if (ord.QualityCallUnique__c) {
                    activity.Order__c = ord.ParentOrder__c;
                    mapActivitiesParent.put(ord.ParentOrder__c, activity);
                } else {
                    activity.Order__c = ord.Id;
                    callActivities.add(activity);
                }
            }
        }

        callActivities.addAll(mapActivitiesParent.values());
        update ordersToUpdate;
        insert callActivities;


        for (String ordId : orderActivityMap.keySet()) {
            if ( orderMap.get(ordId).Contact__c != null) {
                campaignMembersInsert.add(new CampaignMember(
                    ContactId = orderMap.get(ordId).Contact__c,
                    PhoneNumber__c = orderMap.get(ordId).PhoneNumber__c,
                    RelatedActivity__c = orderActivityMap.get(ordId).Id
                ));
            }
        }

        insert campaignMembersInsert;
        update campaignMembersUpdate;
    }
    public void finish(Database.BatchableContext bc){
        system.debug('HDT_BA_QualityCall - end');
    }
}
