public with sharing class HDT_BA_QualityCall implements Database.Batchable<sObject>, Database.Stateful {
    private static HDT_QR_CampaignMember campaignMemberQr = new HDT_QR_CampaignMember();
    private static HDT_QR_RecordType rctype = new  HDT_QR_RecordType();

    public List<Order> ordersToUpdate = new List<Order>();
    public List<wrts_prcgvr__Activity__c> callActivities = new List<wrts_prcgvr__Activity__c>();

    public Database.QueryLocator start(Database.BatchableContext bc) {
        system.debug('HDT_BA_QualityCall - Start');
        String query = 'SELECT Id,IsVAS__c,Phase__c,PhaseStory__c,Channel__c,CustomerCategory__c,SignatureMethod__c,RecordType.DeveloperName,ComfortCallDaysDue__c,DateComfortCall__c,WizardCompletedDate__c,ParentOrder__c,QualityCall__c,QualityCallUnique__c,Contact__c,CommissioningCampaign__c,PhoneNumber__c,AccountId,ActivityQualityToBeCanceled__c,AgencyCode__c,ActivatedDate,LoginChannel__c,VASType__c FROM Order Where Phase__c NOT IN (\'In attesa conferma cliente\', \'Completata\',\'Annullato\') AND QualityCall__c = true AND ComfortCallDaysDue__c = null';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Order> orders){

        system.debug('>>orders: ' + orders);
        system.debug('>>orders count: ' + orders.size());

        List<String> notCancelNonBillable = new List<String>{
            'Completata',
            'Comunicazione verso Motore VAS OK',
            'Accettato Motore VAS',
            'Comunicazione verso Motore VAS'
        };

        List<String> notCancelBillable = new List<String>{
            'Comunicazione verso Heroku Ok',
            'Completata',
            'Comunicazione verso Heroku'
        };

        RecordType rc= rctype.getRecordType('HDT_RT_AttivitaGestionali', 'wrts_prcgvr__Activity__c');

        List<wrts_prcgvr__Activity__c> activityVas = new List<wrts_prcgvr__Activity__c>();

        Map<String,wrts_prcgvr__Activity__c> mapActivitiesParent = new Map<String,wrts_prcgvr__Activity__c>(); //in order not to get duplicate activities associated to same Parent Order

        // List<CampaignMember> campaignMembersInsert = new List<CampaignMember>();
        // Set<CampaignMember> campaignMembersUpdateAdd = new Set<CampaignMember>();
        Map<Id,CampaignMember> campaignMembersUpdate = new Map<Id,CampaignMember>();

        Map<String,Order> orderMap = new Map<String,Order>();
        Map<String,wrts_prcgvr__Activity__c> orderActivityMap = new Map<String,wrts_prcgvr__Activity__c>();

        Date dueDate = Date.today();

        Set<String> orderIdsSet = new Set<String>();
        for (Order order : orders) {
            orderIdsSet.add(order.Id);
            if (order.ParentOrder__c != null) {
                orderIdsSet.add(order.ParentOrder__c);
            }
        }
        

        List<String> ordersIdsList = new List<String>();
        ordersIdsList.addAll(orderIdsSet);
        
        List<wrts_prcgvr__Activity__c> activitiesAssigned = HDT_QR_ActivityCustom.getRecordByOrderListAndQuality(ordersIdsList);
        system.debug('>> activitiesAssigned: ' + activitiesAssigned);
        system.debug('>> activitiesAssigned size: ' + activitiesAssigned.size());
        Set<Id> ordersAlreadyAssigned = new Set<Id>();
        for (wrts_prcgvr__Activity__c activityAssigned : activitiesAssigned) {
            ordersAlreadyAssigned.add(activityAssigned.Order__c);
        }

        system.debug('>> ordersAlreadyAssigned: ' + ordersAlreadyAssigned);
        system.debug('>> ordersAlreadyAssigned size: ' + ordersAlreadyAssigned.size());

        List<String> isMonitoringList = HDT_UTL_AgentMatrix.agencyCodeIsMonitoringList();

        String comfortQualityQueId = [Select id,name from group where developername = 'HDT_QUE_ComfortQuality' limit 1].id;

        List<ComfortQualityCall__c> docValidList = HDT_QR_ComfortQualityCall.getRecordsWithDocumentValidationAndQualityEnabled();

        for (Order ord : orders) {

            Date startDate = ord.WizardCompletedDate__c;
            system.debug('>>>startDate before: ' + ord.Id + ' <:> ' + startDate);

            for (ComfortQualityCall__c cqc : docValidList) {
                if (
                    'Documentazione Validata'.equalsIgnoreCase(ord.Phase__c)
                    && cqc.Process__c == ord.RecordType.DeveloperName
                    && cqc.Channel__c == ord.Channel__c
                    && cqc.CustomerType__c == ord.CustomerCategory__c
                    && cqc.QualitySignatureMethod__c == ord.SignatureMethod__c
                ) {
                    startDate = HDT_UTL_Utils.exctrPhaseTransDateFromStory(ord.PhaseStory__c, 'Documentazione Validata');
                    break;
                }
            }

            system.debug('>>>startDate after: ' + ord.Id + ' <:> ' + startDate);

            if (startDate.daysBetween(dueDate) > 50) { //check number of days passed after being signed as quality
                
                Order ordToUpd = new Order(Id = ord.Id);

                if ((ord.ActivityQualityToBeCanceled__c || isMonitoringList.contains(ord.AgencyCode__c))
                    && (ord.IsVAS__c && !notCancelNonBillable.contains(ord.Phase__c) && !notCancelBillable.contains(ord.Phase__c))) {
                    ordToUpd.Phase__c = 'Annullato';
                    ordToUpd.Status = 'Activated';
                } else {
                    ordToUpd.QualityCall__c = false;
                }

                if ((ord.VASType__c != 'VAS Fatturabili' && notCancelNonBillable.contains(ord.Phase__c))
                    || (ord.VASType__c == 'VAS Fatturabili' && notCancelBillable.contains(ord.Phase__c))) {
                    
                    String ordIdToAssoc = ord.Id;

                    system.debug('Keltin test last1: ' + ord.ParentOrder__c);
                    system.debug('Keltin test last2: ' + ordersAlreadyAssigned.contains(ord.ParentOrder__c));

                    if(ordersAlreadyAssigned.contains(ord.ParentOrder__c)){
                        ordIdToAssoc = ord.ParentOrder__c;
                    }
                    activityVas.add(new wrts_prcgvr__Activity__c(
                        RecordTypeId = rc.Id,
                        Account__c = ord.AccountId,
                        Order__c = ordIdToAssoc,
                        wrts_prcgvr__Description__c = 'Non è stato possibile procedere all’annullamento allo scadere dei 50 giorni di quality call, verificare la richiesta e procedere tramite ripensamento o tramite il case di post sales Disattivazione VAS'
                    ));
                }
                
                ordersToUpdate.add(ordToUpd);
            } else {

                system.debug('>> ordersAlreadyAssigned contains: ' + ord.Id + ' -> ' + ordersAlreadyAssigned.contains(ord.Id));

                if (!ordersAlreadyAssigned.contains(ord.Id) && (ord.ParentOrder__c != null && !ordersAlreadyAssigned.contains(ord.ParentOrder__c))) {
                    // if (dueDate.daysBetween(ord.WizardCompletedDate__c) > 50) { //check number of days passed after being signed as quality
                    //     ordersToUpdate.add(new Order(
                    //         Id = ord.Id,
                    //         QualityCall__c = false
                    //     ));
                    // } else {
                        orderMap.put(ord.Id, ord);
        
                        wrts_prcgvr__Activity__c activity = new wrts_prcgvr__Activity__c(
                                RecordTypeId = HDT_UTL_ActivityCustom.getRecordTypeId('HDT_RT_ComfortQualityCall'),
                                // Account__c = ord.AccountId, //should not be shown on Account related activities
                                Type__c = 'Quality Call',
                                wrts_prcgvr__Status__c = 'Creata',
                                OwnerId = comfortQualityQueId,
                                ActivatedDate__c = ord.ActivatedDate,
                                LoginChannel__c = ord.LoginChannel__c
                        );
        
                        if (ord.QualityCallUnique__c) {
                            activity.Order__c = ord.ParentOrder__c;
                            mapActivitiesParent.put(ord.ParentOrder__c, activity);
                        } else {
                            activity.Order__c = ord.Id;
                            callActivities.add(activity);
                        }
        
                        orderActivityMap.put(ord.id, activity);
                    // }
                }

            }
        }

        callActivities.addAll(mapActivitiesParent.values());
        system.debug('>> ordersToUpdate before: ' + ordersToUpdate);

        if (!ordersToUpdate.isEmpty()) {
            update ordersToUpdate;
        }
        system.debug('>> ordersToUpdate after: ' + ordersToUpdate);

        system.debug('>> callActivities before: ' + callActivities);
        system.debug('>> callActivities before size: ' + callActivities.size());

        if (!callActivities.isEmpty()) {
            insert callActivities;
        }

        system.debug('>> callActivities after: ' + callActivities);

        List<String> commissioningCampaignList = new List<String>();
        List<String> contactList = new List<String>();
        for (Order orderCm : orderMap.values()) {
            if ( orderCm.Contact__c != null) {
                // commissioningCampaignList.add(orderCm.CommissioningCampaign__c);
                contactList.add(orderCm.Contact__c);
            }
        }
        system.debug('>> commissioningCampaignList: ' + commissioningCampaignList);
        system.debug('>> contactList: ' + contactList);

        List<Campaign> qualityCampaign = HDT_QR_Campaign.getCampaignIds('Quality Campaign');

        List<CampaignMember> campaignMembersBulk = new List<CampaignMember>();
        if (!qualityCampaign.isEmpty() && !contactList.isEmpty()) {
            campaignMembersBulk = campaignMemberQr.getCampaignMemberByCampaingAndContactInBulk(new List<String>{qualityCampaign[0].Id}, contactList);
            system.debug('>> campaignMembersBulk: ' + campaignMembersBulk);
        }

        system.debug('>> orderActivityMap.keySet: ' + orderActivityMap.keySet());


        Map<Id,CampaignMember> notDuplicatedCampToIns = new Map<Id,CampaignMember>();

        for (String ordId : orderActivityMap.keySet()) {
            if ( orderMap.get(ordId).Contact__c != null && !qualityCampaign.isEmpty()) {

                Boolean isCmAlready = false;
                String cmAlreadyId = null;

                if (!campaignMembersBulk.isEmpty()) {
                    for (CampaignMember cmAlready : campaignMembersBulk) {
                        if (cmAlready.CampaignId == qualityCampaign[0].Id 
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
                        // campaignMembersInsert.add(new CampaignMember(
                        //     ContactId = orderMap.get(ordId).Contact__c,
                        //     CampaignId = qualityCampaign[0].Id,
                        //     PhoneNumber__c = orderMap.get(ordId).PhoneNumber__c,
                        //     RelatedActivity__c = orderActivityMap.get(ordId).Id
                        // ));

                        notDuplicatedCampToIns.put(orderMap.get(ordId).Contact__c, new CampaignMember(
                            ContactId = orderMap.get(ordId).Contact__c,
                            CampaignId = qualityCampaign[0].Id,
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

        // campaignMembersUpdateAdd.addAll(campaignMembersUpdate);
        // campaignMembersUpdate.addAll(campaignMembersUpdateAdd);
        // system.debug('>>campaignMembersUpdate set: ' + campaignMembersUpdateAdd);
        system.debug('>>campaignMembersUpdate: ' + campaignMembersUpdate.values());
        if(!campaignMembersUpdate.isEmpty()){
            update campaignMembersUpdate.values();
        }

        if (!activityVas.isEmpty()) {
            insert activityVas;
        }

    }
    public void finish(Database.BatchableContext bc){
        system.debug('HDT_BA_QualityCall - end');
    }
}
