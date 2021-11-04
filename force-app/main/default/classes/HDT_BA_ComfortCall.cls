public with sharing class HDT_BA_ComfortCall implements Database.Batchable<sObject>, Database.Stateful {
    public List<wrts_prcgvr__Activity__c> callActivities = new List<wrts_prcgvr__Activity__c>();
    private static HDT_QR_CampaignMember campaignMemberQr = new HDT_QR_CampaignMember();

    public Database.QueryLocator start(Database.BatchableContext bc) {
        system.debug('HDT_BA_ComfortCall - Start');
        String query = 'SELECT Id,ComfortCallDaysDue__c,DateComfortCall__c,ParentOrder__c,Contact__c,CommissioningCampaign__c,PhoneNumber__c,AccountId,ActivatedDate,LoginChannel__c FROM Order Where Phase__c = \'In attesa conferma cliente\' AND QualityCall__c = true';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Order> orders){

        system.debug('keltin orders: ' + orders);

        Map<String,wrts_prcgvr__Activity__c> mapActivities = new Map<String,wrts_prcgvr__Activity__c>(); //in order not to get duplicate activities associated to same Parent Order

        //List<CampaignMember> campaignMembersInsert = new List<CampaignMember>();
        Map<Id,CampaignMember> campaignMembersUpdate = new Map<Id,CampaignMember>();

        Map<String,Order> orderMap = new Map<String,Order>();
        Map<String,wrts_prcgvr__Activity__c> orderActivityMap = new Map<String,wrts_prcgvr__Activity__c>();

        Date dueDate = Date.today();

        List<Order> ordReminder = new List<Order>();

        String comfortQualityQueId = [Select id,name from group where developername = 'HDT_QUE_ComfortQuality' limit 1].id;

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
                    // Account__c = ord.AccountId, //should not be shown on Account related activities
                    IsClientInResolution153__c = true,
                    Type__c = 'Comfort Call',
                    Status__c = 'Creata',
                    OwnerId = comfortQualityQueId,
                    ActivatedDate__c = ord.ActivatedDate,
                    LoginChannel__c = ord.LoginChannel__c
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

        List<String> contactList = new List<String>();
        for (Order orderCm : orderMap.values()) {
            if ( orderCm.Contact__c != null) {
                contactList.add(orderCm.Contact__c);
            }
        }
        system.debug('>> contactList: ' + contactList);
        List<Campaign> comfortCampaign = HDT_QR_Campaign.getCampaignIds('Comfort Campaign');

        /* for (String ordId : orderActivityMap.keySet()) {
            if ( orderMap.get(ordId).Contact__c != null && !comfortCampaign.isEmpty()) {
                List<CampaignMember> campaignMembers = campaignMemberQr.getCampaignMemberByCampaingAndContact(comfortCampaign[0].Id, orderMap.get(ordId).Contact__c);
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
                        CampaignId = comfortCampaign[0].Id,
                        PhoneNumber__c = orderMap.get(ordId).PhoneNumber__c,
                        RelatedActivity__c = orderActivityMap.get(ordId).Id
                    ));
                }
            }
        }
        insert campaignMembersInsert;
        update campaignMembersUpdate; */ //logic that was before


        List<CampaignMember> campaignMembersBulk = new List<CampaignMember>();
        if (!comfortCampaign.isEmpty() && !contactList.isEmpty()) {
            campaignMembersBulk = campaignMemberQr.getCampaignMemberByCampaingAndContactInBulk(new List<String>{comfortCampaign[0].Id}, contactList);
            system.debug('>> campaignMembersBulk: ' + campaignMembersBulk);
        }

        system.debug('>> orderActivityMap.keySet: ' + orderActivityMap.keySet());


        Map<Id,CampaignMember> notDuplicatedCampToIns = new Map<Id,CampaignMember>();

        for (String ordId : orderActivityMap.keySet()) {
            if ( orderMap.get(ordId).Contact__c != null && !comfortCampaign.isEmpty()) {

                Boolean isCmAlready = false;
                String cmAlreadyId = null;

                if (!campaignMembersBulk.isEmpty()) {
                    for (CampaignMember cmAlready : campaignMembersBulk) {
                        if (cmAlready.CampaignId == comfortCampaign[0].Id 
                            && cmAlready.ContactId == orderMap.get(ordId).Contact__c) {
                            isCmAlready = true;
                            cmAlreadyId = cmAlready.Id;
                            break;
                        }
                    }
                }

                if (isCmAlready && cmAlreadyId != null) {
                    if (orderActivityMap.get(ordId).Id != null) {
                        campaignMembersUpdate.put(cmAlreadyId,new CampaignMember(
                            Id = cmAlreadyId,
                            RelatedActivity__c = orderActivityMap.get(ordId).Id
                        ));
                    }

                } else {
                    if (orderActivityMap.get(ordId).Id != null) {

                        notDuplicatedCampToIns.put(orderMap.get(ordId).Contact__c, new CampaignMember(
                            ContactId = orderMap.get(ordId).Contact__c,
                            CampaignId = comfortCampaign[0].Id,
                            PhoneNumber__c = orderMap.get(ordId).PhoneNumber__c,
                            RelatedActivity__c = orderActivityMap.get(ordId).Id
                        ));
                    }
                }
            }
        }


        List<CampaignMember> campNotDuplicateList = notDuplicatedCampToIns.values();
        system.debug('>>campNotDuplicateList: ' + campNotDuplicateList);


        if(!campNotDuplicateList.isEmpty()) {
            insert notDuplicatedCampToIns.values();
        }

        system.debug('>>campaignMembersUpdate: ' + campaignMembersUpdate.values());
        if(!campaignMembersUpdate.isEmpty()){
            update campaignMembersUpdate.values();
        }
    }
    public void finish(Database.BatchableContext bc){
        system.debug('HDT_BA_ComfortCall - end');
    }
}
