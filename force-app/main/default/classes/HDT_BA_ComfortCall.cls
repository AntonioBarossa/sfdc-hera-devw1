public with sharing class HDT_BA_ComfortCall implements Database.Batchable<sObject>, Database.Stateful {

    public List<wrts_prcgvr__Activity__c> callActivities = new List<wrts_prcgvr__Activity__c>();
    private static HDT_QR_CampaignMember campaignMemberQr = new HDT_QR_CampaignMember();

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id,ComfortCallDaysDue__c,DateComfortCall__c,ParentOrder__c,Contact__c,CommissioningCampaign__c,PhoneNumber__c,AccountId,ActivatedDate,LoginChannel__c, Account.CompanyOwner__c FROM Order Where Phase__c = \'In attesa conferma cliente\' AND QualityCall__c = true AND ParentOrder__r.Status = \'Completed\'';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Order> orders){

        Map<String,wrts_prcgvr__Activity__c> mapActivities = new Map<String,wrts_prcgvr__Activity__c>();
        Map<Id,CampaignMember> campaignMembersUpdate = new Map<Id,CampaignMember>();
        Map<String,Order> orderMap = new Map<String,Order>();
        Map<String,wrts_prcgvr__Activity__c> orderActivityMap = new Map<String,wrts_prcgvr__Activity__c>();

        Date dueDate = Date.today();

        List<Order> ordReminder = new List<Order>();
        String comfortQualityQueId = [Select id,name from group where developername = 'HDT_QUE_ComfortQuality' limit 1].id;

        Set<String> orderIdsSet = new Set<String>();
        Set<String> orderAccountCompanyOwnersSet = new Set<String>();
        for (Order order : orders){
            orderIdsSet.add(order.Id);
            if(order.ParentOrder__c != null){
                orderIdsSet.add(order.ParentOrder__c);
            }
            orderAccountCompanyOwnersSet.add(order.Account.CompanyOwner__c);
        }

        List<String> ordersIdsList = new List<String>();
        ordersIdsList.addAll(orderIdsSet);

        List<wrts_prcgvr__Activity__c> activitiesAssigned = HDT_QR_ActivityCustom.getRecordByOrderListAndQuality(ordersIdsList);
        Set<Id> ordersAlreadyAssigned = new Set<Id>();
        for(wrts_prcgvr__Activity__c activityAssigned : activitiesAssigned){
            ordersAlreadyAssigned.add(activityAssigned.Order__c);
        }

        for (Order ord : orders) {

            Date startDate = ord.DateComfortCall__c;
            Decimal daysDueHalf = ord.ComfortCallDaysDue__c/2;
            Decimal daysDueHalfRound = daysDueHalf.round(System.RoundingMode.DOWN);

            if (ord.ComfortCallDaysDue__c <= startDate.daysBetween(dueDate)) {

                if (!ordersAlreadyAssigned.contains(ord.Id) && (ord.ParentOrder__c != null && !ordersAlreadyAssigned.contains(ord.ParentOrder__c))){

                    orderMap.put(ord.ParentOrder__c, ord);

                    wrts_prcgvr__Activity__c activity = new wrts_prcgvr__Activity__c(
                        RecordTypeId = HDT_UTL_ActivityCustom.getRecordTypeId('HDT_RT_ComfortQualityCall'),
                        Order__c = ord.ParentOrder__c,
                        IsClientInResolution153__c = true,
                        Type__c = 'Comfort Call',
                        wrts_prcgvr__Status__c = 'Aperta',
                        OwnerId = comfortQualityQueId,
                        ActivatedDate__c = ord.ActivatedDate,
                        LoginChannel__c = ord.LoginChannel__c
                    );

                    mapActivities.put(ord.ParentOrder__c, activity);
                    orderActivityMap.put(ord.id, activity);
                }      
            }
            else if(startDate.daysBetween(dueDate) == daysDueHalfRound) {
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

        //List<Campaign> comfortCampaign = HDT_QR_Campaign.getCampaingByTipology('Comfort Call');
        Map<String, Campaign> compOwnerToCampMap = new Map<String, Campaign>();
        compOwnerToCampMap = HDT_QR_Campaign.getCampaignByCompOwner('Comfort Call', orderAccountCompanyOwnersSet);

        List<CampaignMember> campaignMembersBulk = new List<CampaignMember>();
        
        if (compOwnerToCampMap != null && !contactList.isEmpty()) {
            List<String> campaignIdList = new List<String>();
            for(Campaign c : compOwnerToCampMap.values()){
                campaignIdList.add(c.Id);
            }
            campaignMembersBulk = campaignMemberQr.getCampaignMemberByCampaingAndContactInBulk(campaignIdList, contactList);
        }

        Map<Id,CampaignMember> notDuplicatedCampToIns = new Map<Id,CampaignMember>();

        for (String ordId : mapActivities.keySet()) {
            String compOwner = orderMap.get(ordId).Account.CompanyOwner__c;
            if ( orderMap.get(ordId).Contact__c != null && compOwnerToCampMap.get(compOwner) != null) {

                Boolean isCmAlready = false;
                String cmAlreadyId = null;

                if (!campaignMembersBulk.isEmpty()) {
                    for (CampaignMember cmAlready : campaignMembersBulk) {
                        if (cmAlready.CampaignId == compOwnerToCampMap.get(compOwner).Id && cmAlready.ContactId == orderMap.get(ordId).Contact__c) {
                            isCmAlready = true;
                            cmAlreadyId = cmAlready.Id;
                            break;
                        }
                    }
                }

                if (isCmAlready && cmAlreadyId != null) {
                    if (mapActivities.get(ordId).Id != null) {
                        campaignMembersUpdate.put(cmAlreadyId,new CampaignMember(
                            Id = cmAlreadyId,
                            RelatedActivity__c = mapActivities.get(ordId).Id
                        ));
                    }

                }
                else {
                    if (mapActivities.get(ordId).Id != null) {

                        notDuplicatedCampToIns.put(orderMap.get(ordId).Contact__c, new CampaignMember(
                            ContactId = orderMap.get(ordId).Contact__c,
                            CampaignId = compOwnerToCampMap.get(compOwner).Id,
                            PhoneNumber__c = orderMap.get(ordId).PhoneNumber__c,
                            RelatedActivity__c = mapActivities.get(ordId).Id,
                            NumberingValidityStartDate__c = System.today(),
                            NumberingValidityEndDate__c = System.today().addDays(30),
                            ExcludeFub__c = 'Si',
                            GenericField1__c = orderMap.get(ordId).AccountId
                        ));
                    }
                }
            }
        }

        List<CampaignMember> campNotDuplicateList = notDuplicatedCampToIns.values();

        if(!campNotDuplicateList.isEmpty()) {
            insert notDuplicatedCampToIns.values();
        }
        if(!campaignMembersUpdate.isEmpty()){
            update campaignMembersUpdate.values();
        }
    }

    @SuppressWarnings('PMD.AvoidDebugStatements')
    public void finish(Database.BatchableContext bc){
        System.debug(LoggingLevel.DEBUG, 'HDT_BA_ComfortCall - END');
    }
}