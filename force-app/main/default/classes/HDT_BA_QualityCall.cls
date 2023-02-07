@SuppressWarnings('PMD.CyclomaticComplexity, PMD.NcssMethodCount')
public with sharing class HDT_BA_QualityCall implements Database.Batchable<sObject>, Database.Stateful {

    private HDT_QR_CampaignMember campaignMemberQr = new HDT_QR_CampaignMember();
    private HDT_QR_RecordType rctype = new  HDT_QR_RecordType();
    private final String LOG_SERVICE = String.valueOf(this).substring(0,String.valueOf(this).indexOf(':'));
    private HDT_UTL_QualityCall qCall = new HDT_UTL_QualityCall();

    public Map<String, List<String>> parentToChildOrderMap = new Map<String, List<String>>();

    public Database.QueryLocator start(Database.BatchableContext bc) {
        //modifica ticket 937835C anche lo stato completata deve avere la possibilità di esitare le QC
        String query = 'SELECT Id,Skip_Callout__c, ParentOrder__r.Status, OrderNumber, IsVAS__c,Phase__c,PhaseStory__c,Channel__c,CustomerCategory__c,SignatureMethod__c,RecordType.DeveloperName,ComfortCallDaysDue__c,DateComfortCall__c,WizardCompletedDate__c,ParentOrder__c,QualityCall__c,QualityCallUnique__c,Contact__c,CommissioningCampaign__c,PhoneNumber__c,AccountId,AgencyCode__c,ActivatedDate,LoginChannel__c,VASType__c, Account.CompanyOwner__c, isTransition__c, QualityCallStatus__c, HerokuPracticeCode__c, ProcessType__c FROM Order '+
        'Where Phase__c NOT IN (\'In attesa validazione\', \'Accettazione Voltura\', \'Da Inviare\', \'Bozza\',  \'In attesa conferma cliente\', \'Voltura Rifiutata\', \'Annullato\',\'Attesa Credit Check\',\'Credit Check KO\') AND QualityCall__c = true AND ComfortCallDaysDue__c = null AND VasSubtype__c != \'Analisi Consumi\' AND QualityCallStatus__c = \'\' AND ParentOrder__r.Status = \'Completed\'';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Order> orders){

        List<Order> ordersToUpdate = new List<Order>();
        Map<Id,CampaignMember> campaignMembersUpdate = new Map<Id,CampaignMember>();
        Map<String,Order> orderMap = new Map<String,Order>();
        Map<String,wrts_prcgvr__Activity__c> orderActivityMap = new Map<String,wrts_prcgvr__Activity__c>();
        HDT_SRV_LogService logs = new HDT_SRV_LogService(LOG_SERVICE);

        Set<String> orderIdsSet = new Set<String>();
        Set<String> orderAccountCompanyOwnersSet = new Set<String>();
        try{
            for (Order order : orders) {
                orderIdsSet.add(order.Id);
                if (order.ParentOrder__c != null) {
                    orderIdsSet.add(order.ParentOrder__c);
                }
                
                orderAccountCompanyOwnersSet.add(order.Account.CompanyOwner__c);
            }        

            List<wrts_prcgvr__Activity__c> activitiesAssigned = HDT_QR_ActivityCustom.getRecordByOrderListAndQuality(orderIdsSet);
            Set<Id> ordersAlreadyAssigned = new Set<Id>();
            for (wrts_prcgvr__Activity__c activityAssigned : activitiesAssigned) {
                ordersAlreadyAssigned.add(activityAssigned.Order__c);
            }


            String comfortQualityQueId = [Select id,name from group where developername = 'HDT_QUE_ComfortQuality' limit 1].id;
            Map<Id,wrts_prcgvr__Activity__c> mapActivityCreated = new Map<Id,wrts_prcgvr__Activity__c>();
            List<String> contactList = new List<String>();
            for (Order ord : orders) {
                Integer newSkipCall = ord.Skip_Callout__c == null ? -1 : null; 
                ordersToUpdate.add(new Order(Id=ord.Id, QualityCallStatus__c = HDT_UTL_QualityCall.HANDLE_ACTIVITY, Skip_Callout__c = newSkipCall));
                Id actOrderId = ord.QualityCallUnique__c ? ord.ParentOrder__c : ord.Id;
                if (!ordersAlreadyAssigned.contains(ord.Id) && !ordersAlreadyAssigned.contains(ord.ParentOrder__c) && !mapActivityCreated.containsKey(actOrderId)) {
                    mapActivityCreated.put(actOrderId,new wrts_prcgvr__Activity__c(
                        RecordTypeId = HDT_UTL_ActivityCustom.getRecordTypeId('HDT_RT_ComfortQualityCall'),
                        Type__c = 'Quality Call',
                        wrts_prcgvr__Status__c = 'Aperta',
                        OwnerId = comfortQualityQueId,
                        ActivatedDate__c = ord.ActivatedDate,
                        LoginChannel__c = ord.LoginChannel__c,
                        Order__c = actOrderId
                    ));
                    orderMap.put(ord.Id, ord);
                    orderActivityMap.put(ord.id, mapActivityCreated.get(actOrderId));
                    if (ord.Contact__c != null && !contactList.contains(ord.Contact__c)){
                        contactList.add(ord.Contact__c);
                    }
                }
            }
            

            if (!ordersToUpdate.isEmpty()) {
                List<Database.SaveResult> srList = Database.update(ordersToUpdate, false);
                qCall.setLogRecord(srList, ordersToUpdate, logs, 'update Order');
            }
            if (!mapActivityCreated.isEmpty()) {
                List<Database.SaveResult> srList = Database.insert(mapActivityCreated.values(), false);
                qCall.setLogRecord(srList, mapActivityCreated.values(), logs, 'insert activities');
            }

            Map<String, Campaign> compOwnerToCampMap = new Map<String, Campaign>();
            compOwnerToCampMap = HDT_QR_Campaign.getCampaignByCompOwner('Quality Call', orderAccountCompanyOwnersSet);

            List<CampaignMember> campaignMembersBulk = new List<CampaignMember>();
            if (compOwnerToCampMap != null && !contactList.isEmpty()) {
                List<String> campaignIdList = new List<String>();
                for(Campaign c : compOwnerToCampMap.values()){
                    campaignIdList.add(c.Id);
                }
                campaignMembersBulk = campaignMemberQr.getCampaignMemberByCampaingAndContactInBulk(campaignIdList, contactList);
            }

            Map<Id,CampaignMember> notDuplicatedCampToIns = new Map<Id,CampaignMember>();

            for (String ordId : orderActivityMap.keySet()) {
                String compOwner = orderMap.get(ordId).Account.CompanyOwner__c;
                if (orderMap.get(ordId).Contact__c != null && compOwnerToCampMap.get(compOwner) != null) {

                    Boolean isCmAlready = false;
                    String cmAlreadyId = null;
                    Id activityId = null;

                    if (!campaignMembersBulk.isEmpty()) {
                        for (CampaignMember cmAlready : campaignMembersBulk) {
                            if (cmAlready.CampaignId == compOwnerToCampMap.get(compOwner).Id 
                                && cmAlready.ContactId == orderMap.get(ordId).Contact__c) {
                                isCmAlready = true;
                                cmAlreadyId = cmAlready.Id;
                                activityId = cmAlready.RelatedActivity__c;
                                break;
                            }
                        }
                    }

                    if (isCmAlready && cmAlreadyId != null) {
                        if (orderActivityMap.containsKey(ordId) && orderActivityMap.get(ordId).Id != activityId) {
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
                                CampaignId = compOwnerToCampMap.get(compOwner).Id ,
                                PhoneNumber__c = orderMap.get(ordId).PhoneNumber__c,
                                RelatedActivity__c = orderActivityMap.get(ordId).Id,
                                NumberingValidityStartDate__c = System.today(),
                                NumberingValidityEndDate__c = System.today().addDays(50),
                                ExcludeFub__c = 'Si',
                                GenericField1__c = orderMap.get(ordId).AccountId
                            ));
                        }
                    }
                }
            }

            List<CampaignMember> campNotDuplicateList = notDuplicatedCampToIns.values();

            if(!campNotDuplicateList.isEmpty()) {
                List<Database.SaveResult> srList = Database.insert(notDuplicatedCampToIns.values(), false);
                qCall.setLogRecord(srList, notDuplicatedCampToIns.values(), logs, 'insert Campaign Member');
            }
            if(!campaignMembersUpdate.isEmpty()){
                List<Database.SaveResult> srList = Database.update(campaignMembersUpdate.values(), false);
                qCall.setLogRecord(srList, campaignMembersUpdate.values(), logs, 'update Campaign Member');
            }
        }catch(Exception ex){
            logs.addLog(LOG_SERVICE, 'execute', orders != null ? JSON.serialize(orders) : null , null, ex.getStackTraceString() + ' Error Message: ' + ex.getMessage(), null, null, null);
        }
        logs.saveMassiveRecords();
    }

    @SuppressWarnings('PMD.AvoidDebugStatements')
    public void finish(Database.BatchableContext bc){
        Database.executeBatch(new HDT_BA_CloseQualityCall());
    }

}