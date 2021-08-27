public with sharing class HDT_BA_ComfortCall implements Database.Batchable<sObject>, Database.Stateful {
    public List<wrts_prcgvr__Activity__c> callActivities = new List<wrts_prcgvr__Activity__c>();
    private static HDT_QR_CampaignMember campaignMemberQr = new HDT_QR_CampaignMember();

    public Database.QueryLocator start(Database.BatchableContext bc) {
        system.debug('HDT_BA_ComfortCall - Start');
        String query = 'SELECT Id,ComfortCallDaysDue__c,DateComfortCall__c,ParentOrder__c,Contact__c,CommissioningCampaign__c,PhoneNumber__c,AccountId FROM Order Where Phase__c = \'In attesa conferma cliente\' AND QualityCall__c = true';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Order> orders){

        system.debug('keltin orders: ' + orders);

        Map<String,wrts_prcgvr__Activity__c> mapActivities = new Map<String,wrts_prcgvr__Activity__c>(); //in order not to get duplicate activities associated to same Parent Order

        List<CampaignMember> campaignMembersInsert = new List<CampaignMember>();
        List<CampaignMember> campaignMembersUpdate = new List<CampaignMember>();

        Map<String,Order> orderMap = new Map<String,Order>();
        Map<String,wrts_prcgvr__Activity__c> orderActivityMap = new Map<String,wrts_prcgvr__Activity__c>();

        Date dueDate = Date.today();

        List<Order> ordReminder = new List<Order>();

        for (Order ord : orders) {

            Date startDate = ord.DateComfortCall__c;

            Decimal daysDueHalf = ord.ComfortCallDaysDue__c/2;
            Decimal daysDueHalfRound = daysDueHalf.round(System.RoundingMode.DOWN);
            // system.debug('order: ' + ord.id + ' start date: ' + startDate);
            // system.debug( 'days due: ' + ord.ComfortCallDaysDue__c + ' days between: ' + startDate.daysBetween(dueDate));
            // system.debug( 'days due half: ' +  daysDueHalfRound + ' days between: ' + startDate.daysBetween(dueDate));
            // system.debug('first check: ' + ord.ComfortCallDaysDue__c == startDate.daysBetween(dueDate));
            // system.debug('second check: ' + startDate.daysBetween(dueDate) == ord.ComfortCallDaysDue__c/2);

            if (ord.ComfortCallDaysDue__c == startDate.daysBetween(dueDate)) { //check number of days passed after being signed as quality
                orderMap.put(ord.Id, ord);

                wrts_prcgvr__Activity__c activity = new wrts_prcgvr__Activity__c(
                    RecordTypeId = HDT_UTL_ActivityCustom.getRecordTypeId('HDT_RT_ComfortQualityCall'),
                    Order__c = ord.Id,
                    Account__c = ord.AccountId,
                    IsClientInResolution153__c = true,
                    Type__c = 'Comfort Call',
                    Status__c = 'Creata'
                );

                mapActivities.put(ord.ParentOrder__c, activity);
                orderActivityMap.put(ord.id, activity);

            } else if(startDate.daysBetween(dueDate) == daysDueHalfRound) {
                ordReminder.add(
                    new Order(
                        Id = ord.Id,
                        ReminderComfortCall__c = true
                    )
                );
            }
        }

        if (!ordReminder.isEmpty()) {
            update ordReminder;
        }

        callActivities = mapActivities.values();
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
        system.debug('HDT_BA_ComfortCall - end');
    }
}
