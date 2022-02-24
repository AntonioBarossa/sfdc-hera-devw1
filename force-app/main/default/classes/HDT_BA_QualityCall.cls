@SuppressWarnings('PMD.CyclomaticComplexity, PMD.NcssMethodCount')
public with sharing class HDT_BA_QualityCall implements Database.Batchable<sObject>, Database.Stateful {

    private static HDT_QR_CampaignMember campaignMemberQr = new HDT_QR_CampaignMember();
    private static HDT_QR_RecordType rctype = new  HDT_QR_RecordType();
    public List<Order> ordersToUpdate = new List<Order>();
    public List<wrts_prcgvr__Activity__c> callActivities = new List<wrts_prcgvr__Activity__c>();

    public Database.QueryLocator start(Database.BatchableContext bc) {

        String query = 'SELECT Id,IsVAS__c,Phase__c,PhaseStory__c,Channel__c,CustomerCategory__c,SignatureMethod__c,RecordType.DeveloperName,ComfortCallDaysDue__c,DateComfortCall__c,WizardCompletedDate__c,ParentOrder__c,QualityCall__c,QualityCallUnique__c,Contact__c,CommissioningCampaign__c,PhoneNumber__c,AccountId,AgencyCode__c,ActivatedDate,LoginChannel__c,VASType__c FROM Order '+
        'Where Phase__c NOT IN (\'In attesa conferma cliente\', \'Completata\',\'Annullato\') AND QualityCall__c = true AND ComfortCallDaysDue__c = null';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Order> orders){

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
        Map<String,wrts_prcgvr__Activity__c> mapActivitiesParent = new Map<String,wrts_prcgvr__Activity__c>();
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
        List<wrts_prcgvr__Activity__c> activitiesToClose = new List<wrts_prcgvr__Activity__c>();
        Map<String, wrts_prcgvr__Activity__c> orderToActivityMap = new Map<String, wrts_prcgvr__Activity__c>();
        Set<Id> ordersAlreadyAssigned = new Set<Id>();
        for (wrts_prcgvr__Activity__c activityAssigned : activitiesAssigned) {
            ordersAlreadyAssigned.add(activityAssigned.Order__c);
        }

        for(wrts_prcgvr__Activity__c activity : activitiesAssigned){
            orderToActivityMap.put(activity.Order__c, activity);
        }

        List<String> isMonitoringList = HDT_UTL_AgentMatrix.agencyCodeIsMonitoringList();
        String comfortQualityQueId = [Select id,name from group where developername = 'HDT_QUE_ComfortQuality' limit 1].id;
        List<ComfortQualityCall__c> docValidList = HDT_QR_ComfortQualityCall.getRecordsWithDocumentValidationAndQualityEnabled();

        for (Order ord : orders) {

            Date startDate = ord.WizardCompletedDate__c;

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

            if (startDate != null && startDate.daysBetween(dueDate) > 50) {
                
                Order ordToUpd = new Order(Id = ord.Id);

                if (isMonitoringList.contains(ord.AgencyCode__c) && ord.IsVAS__c && !notCancelNonBillable.contains(ord.Phase__c) && !notCancelBillable.contains(ord.Phase__c)) {
                    ordToUpd.Phase__c = 'Annullato';
                    ordToUpd.Status = 'Activated';
                }
                else {
                    ordToUpd.QualityCall__c = false;

                    wrts_prcgvr__Activity__c activityToClose = new wrts_prcgvr__Activity__c();
                    
                    if(orderToActivityMap.get(ord.Id) != null){
                        activityToClose = orderToActivityMap.get(ord.Id);
                        activityToClose.wrts_prcgvr__Status__c = 'Non Esitata';
                        activitiesToClose.add(activityToClose);
                    }
                    else if(orderToActivityMap.get(ord.ParentOrder__c) != null){
                        activityToClose = orderToActivityMap.get(ord.ParentOrder__c);
                        activityToClose.wrts_prcgvr__Status__c = 'Non Esitata';
                        activitiesToClose.add(activityToClose);
                    }
                }

                if ((ord.VASType__c != 'VAS Fatturabili' && notCancelNonBillable.contains(ord.Phase__c)) || (ord.VASType__c == 'VAS Fatturabili' && notCancelBillable.contains(ord.Phase__c))) {
                    
                    String ordIdToAssoc = ord.Id;

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
            }
            else {

                if (!ordersAlreadyAssigned.contains(ord.Id) && (ord.ParentOrder__c != null && !ordersAlreadyAssigned.contains(ord.ParentOrder__c))) {
                    orderMap.put(ord.Id, ord);
        
                    wrts_prcgvr__Activity__c activity = new wrts_prcgvr__Activity__c(
                        RecordTypeId = HDT_UTL_ActivityCustom.getRecordTypeId('HDT_RT_ComfortQualityCall'),
                        Type__c = 'Quality Call',
                        wrts_prcgvr__Status__c = 'Creata',
                        OwnerId = comfortQualityQueId,
                        ActivatedDate__c = ord.ActivatedDate,
                        LoginChannel__c = ord.LoginChannel__c
                    );
    
                    if (ord.QualityCallUnique__c) {
                        activity.Order__c = ord.ParentOrder__c;
                        mapActivitiesParent.put(ord.ParentOrder__c, activity);
                    }
                    else {
                        activity.Order__c = ord.Id;
                        callActivities.add(activity);
                    }    
                    orderActivityMap.put(ord.id, activity);
                }
            }
        }

        callActivities.addAll(mapActivitiesParent.values());

        if (!ordersToUpdate.isEmpty()) {
            update ordersToUpdate;
        }
        if (!callActivities.isEmpty()) {
            insert callActivities;
        }
        if(activitiesToClose.size() > 0){
            update activitiesToClose;
        }

        List<String> contactList = new List<String>();
        for (Order orderCm : orderMap.values()) {
            if ( orderCm.Contact__c != null) {
                contactList.add(orderCm.Contact__c);
            }
        }

        List<Campaign> qualityCampaign = HDT_QR_Campaign.getCampaingByTipology('Quality Call');

        List<CampaignMember> campaignMembersBulk = new List<CampaignMember>();
        if (!qualityCampaign.isEmpty() && !contactList.isEmpty()) {
            campaignMembersBulk = campaignMemberQr.getCampaignMemberByCampaingAndContactInBulk(new List<String>{qualityCampaign[0].Id}, contactList);
        }

        Map<Id,CampaignMember> notDuplicatedCampToIns = new Map<Id,CampaignMember>();

        for (String ordId : orderActivityMap.keySet()) {
            if (orderMap.get(ordId).Contact__c != null && !qualityCampaign.isEmpty()) {

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
                }
                else {
                    if (orderActivityMap.get(ordId).Id != null) {

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

        if(!campNotDuplicateList.isEmpty()) {
            insert notDuplicatedCampToIns.values();
        }
        if(!campaignMembersUpdate.isEmpty()){
            update campaignMembersUpdate.values();
        }
        if (!activityVas.isEmpty()) {
            insert activityVas;
        }
    }

    @SuppressWarnings('PMD.AvoidDebugStatements')
    public void finish(Database.BatchableContext bc){
        System.debug(LoggingLevel.DEBUG, 'HDT_BA_QualityCall - END');
    }
}