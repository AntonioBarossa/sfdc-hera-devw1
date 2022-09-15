@SuppressWarnings('PMD.CyclomaticComplexity, PMD.NcssMethodCount')
public with sharing class HDT_BA_QualityCall implements Database.Batchable<sObject>, Database.Stateful {

    private HDT_QR_CampaignMember campaignMemberQr = new HDT_QR_CampaignMember();
    private HDT_QR_RecordType rctype = new  HDT_QR_RecordType();
    private final String HANDLE_ACTIVITY = 'Attività gestita';
    private final String HANDLE_DEADLINE = 'Scadenza gestita';

    //public List<Order> ordersToUpdate = new List<Order>();
    public Map<String, List<String>> parentToChildOrderMap = new Map<String, List<String>>();

    public Database.QueryLocator start(Database.BatchableContext bc) {

        String query = 'SELECT Id, OrderNumber, IsVAS__c,Phase__c,PhaseStory__c,Channel__c,CustomerCategory__c,SignatureMethod__c,RecordType.DeveloperName,ComfortCallDaysDue__c,DateComfortCall__c,WizardCompletedDate__c,ParentOrder__c,QualityCall__c,QualityCallUnique__c,Contact__c,CommissioningCampaign__c,PhoneNumber__c,AccountId,AgencyCode__c,ActivatedDate,LoginChannel__c,VASType__c, Account.CompanyOwner__c, isTransition__c, QualityCallStatus__c, HerokuPracticeCode__c, ProcessType__c FROM Order '+
        'Where Phase__c NOT IN (\'In attesa validazione\', \'Accettazione Voltura\', \'Da Inviare\', \'Bozza\',  \'In attesa conferma cliente\', \'Completata\',\'Annullato\',\'Credit Check KO\') AND QualityCall__c = true AND ComfortCallDaysDue__c = null AND VasSubtype__c != \'Analisi Consumi\' AND QualityCallStatus__c != \'Scadenza Gestita\'';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Order> orders){

        List<String> notCancelNonBillable = new List<String>{
            'Completata',
            'Comunicazione verso Motore VAS OK',
            'Accettato Motore Vas',
            'Comunicazione verso Motore VAS'
        };

        List<String> notCancelBillable = new List<String>{
            'Comunicazione verso Heroku Ok',
            'Completata',
            'Comunicazione verso Heroku',
            'Caricamento Siebel OK'
        };

        List<Order> ordersToUpdate = new List<Order>();
        RecordType rc= rctype.getRecordType('HDT_RT_AttivitaGestionali', 'wrts_prcgvr__Activity__c');
        List<wrts_prcgvr__Activity__c> activityVas = new List<wrts_prcgvr__Activity__c>();
        List<wrts_prcgvr__Activity__c> callActivities = new List<wrts_prcgvr__Activity__c>();
        Map<String,wrts_prcgvr__Activity__c> mapActivitiesParent = new Map<String,wrts_prcgvr__Activity__c>();
        Map<Id,CampaignMember> campaignMembersUpdate = new Map<Id,CampaignMember>();
        Map<String,Order> orderMap = new Map<String,Order>();
        Map<String,wrts_prcgvr__Activity__c> orderActivityMap = new Map<String,wrts_prcgvr__Activity__c>();

        Date dueDate = Date.today();

        Set<String> orderIdsSet = new Set<String>();
        Set<String> orderAccountCompanyOwnersSet = new Set<String>();
        for (Order order : orders) {
            orderIdsSet.add(order.Id);
            if (order.ParentOrder__c != null) {
                orderIdsSet.add(order.ParentOrder__c);
            }
            
            orderAccountCompanyOwnersSet.add(order.Account.CompanyOwner__c);
        }        

        List<String> ordersIdsList = new List<String>();
        ordersIdsList.addAll(orderIdsSet);
        
        List<wrts_prcgvr__Activity__c> activitiesAssigned = HDT_QR_ActivityCustom.getActivityCreatedByQualityBatch(ordersIdsList);
        List<wrts_prcgvr__Activity__c> activitiesToClose = new List<wrts_prcgvr__Activity__c>();
        Map<String, wrts_prcgvr__Activity__c> orderToActivityMap = new Map<String, wrts_prcgvr__Activity__c>();
        Set<Id> siebelOrderWithActivity = new Set<Id>();
        Set<Id> sfdcOrderWithActivity = new Set<Id>();
        Set<Id> ordersAlreadyAssigned = new Set<Id>();
        for (wrts_prcgvr__Activity__c activityAssigned : activitiesAssigned) {
            if ('HDT_RT_ComfortQualityCall'.equalsIgnoreCase(activityAssigned.RecordType.DeveloperName)){
                ordersAlreadyAssigned.add(activityAssigned.Order__c);
                orderToActivityMap.put(activityAssigned.Order__c, activityAssigned);
            }else if (HDT_UTL_ActivityCustom.ANNULLAMENTO_SIEBEL.equalsIgnoreCase(activityAssigned.type__c)){
                siebelOrderWithActivity.add(activityAssigned.Order__c);
            }else if(HDT_UTL_ActivityCustom.CONTRATTO_NON_RICHIESTO.equalsIgnoreCase(activityAssigned.type__c)){
                sfdcOrderWithActivity.add(activityAssigned.Order__c);
            }
        }

        Map<String, List<OrderItem>> orderToItemMap = new Map<String, List<OrderItem>>();
        for(OrderItem item : HDT_QR_OrderItem.getItemFromOrderIdList(ordersIdsList)){
            if(orderToItemMap.get(item.OrderId) != null){
                orderToItemMap.get(item.OrderId).add(item);
            }
            else {
                orderToItemMap.put(item.OrderId, new List<OrderItem>());
                orderToItemMap.get(item.OrderId).add(item);
            }
        }

        List<String> isMonitoringList = HDT_UTL_AgentMatrix.agencyCodeIsMonitoringList();
        String comfortQualityQueId = [Select id,name from group where developername = 'HDT_QUE_ComfortQuality' limit 1].id;
        List<ComfortQualityCall__c> docValidList = HDT_QR_ComfortQualityCall.getRecordsWithDocumentValidationAndQualityEnabled();

        for (Order ord : orders) {

            Date startDate = ord.WizardCompletedDate__c;

            for (ComfortQualityCall__c cqc : docValidList) {
                if (
                    'Documentazione Validata'.equalsIgnoreCase(ord.Phase__c) && cqc.Process__c == ord.RecordType.DeveloperName && cqc.Channel__c == ord.Channel__c && cqc.CustomerType__c == ord.CustomerCategory__c && cqc.QualitySignatureMethod__c == ord.SignatureMethod__c
                ) {
                    startDate = HDT_UTL_Utils.exctrPhaseTransDateFromStory(ord.PhaseStory__c, 'Documentazione Validata');
                    break;
                }
            }

            wrts_prcgvr__Activity__c activityQualityCall = (ord.ParentOrder__c != null && orderToActivityMap.containsKey(ord.ParentOrder__c))
                    ? orderToActivityMap.get(ord.ParentOrder__c) : orderToActivityMap.get(ord.Id);

            if (startDate != null && startDate.daysBetween(dueDate) > 50) {
                
                Order ordToUpd = new Order(Id = ord.Id, QualityCallStatus__c = HANDLE_DEADLINE );

                if (activityQualityCall!= null && activityQualityCall.wrts_prcgvr__IsClosed__c){
                    ordersToUpdate.add(ordToUpd);
                    continue;
                }

                Boolean hasCancellableProduct = false;
                if(orderToItemMap.get(ord.Id) != null){
                    for(OrderItem item : orderToItemMap.get(ord.Id)){
                        if(item.Product2.CancelableQC__c){
                            hasCancellableProduct= true;
                            break;
                        }
                    }
                }

                Boolean canDeleteOrder = !this.notCancellableOrder(ord);
                Boolean needsActivity = false;
                if (!notCancelNonBillable.contains(ord.Phase__c) && !notCancelBillable.contains(ord.Phase__c) && canDeleteOrder 
                    && ((isMonitoringList.contains(ord.AgencyCode__c) && ord.IsVAS__c) || hasCancellableProduct)) {
                    ordToUpd.Phase__c = 'Annullato';
                    ordToUpd.Status = 'Activated';         
                }else if ((isMonitoringList.contains(ord.AgencyCode__c) && ord.IsVAS__c) || hasCancellableProduct){
                    needsActivity = true;
                }
                //DV: VADO A CREARMI UNA MAPPA DI TUTTI GLI ORDINI VECCHI, CORRELATI AL PARENT
                if(parentToChildOrderMap.get(ord.ParentOrder__c) != null){
                    parentToChildOrderMap.get(ord.ParentOrder__c).add(ord.OrderNumber);
                }
                else {
                    parentToChildOrderMap.put(ord.ParentOrder__c, new List<String>());
                    parentToChildOrderMap.get(ord.ParentOrder__c).add(ord.OrderNumber);
                }

                if (!this.skipActivityCreation(ord.Id,ord.ParentOrder__c, siebelOrderWithActivity, sfdcOrderWithActivity) && needsActivity && ((ord.VASType__c != 'VAS Fatturabili' && notCancelNonBillable.contains(ord.Phase__c)) || (ord.VASType__c == 'VAS Fatturabili' && notCancelBillable.contains(ord.Phase__c)))) {
                    
                    String ordIdToAssoc = ord.Id;

                    if(ordersAlreadyAssigned.contains(ord.ParentOrder__c)){
                        ordIdToAssoc = ord.ParentOrder__c;
                    }
                    String activityType = ord.isTransition__c ? HDT_UTL_ActivityCustom.ANNULLAMENTO_SIEBEL : HDT_UTL_ActivityCustom.CONTRATTO_NON_RICHIESTO;
                    activityVas.add(new wrts_prcgvr__Activity__c(
                        RecordTypeId = rc.Id,
                        Account__c = ord.AccountId,
                        Order__c = ordIdToAssoc,
                        Type__c = activityType,
                        wrts_prcgvr__Status__c = 'Aperta',
                        wrts_prcgvr__Description__c = 'Non è stato possibile procedere all’annullamento allo scadere dei 50 giorni di quality call, verificare la richiesta e procedere tramite ripensamento o tramite il case di post sales Disattivazione VAS'
                    ));
                }                
                ordersToUpdate.add(ordToUpd);
            }else if (HANDLE_ACTIVITY.equalsIgnoreCase(ord.QualityCallStatus__c) && activityQualityCall!= null && activityQualityCall.wrts_prcgvr__IsClosed__c){
                Order ordToUpd = new Order(Id = ord.Id, QualityCallStatus__c = HANDLE_DEADLINE );
                ordersToUpdate.add(ordToUpd);
            }else if (String.isBlank(ord.QualityCallStatus__c)){
                ordersToUpdate.add(new Order(Id=ord.Id, QualityCallStatus__c = HANDLE_ACTIVITY));
                if (!ordersAlreadyAssigned.contains(ord.Id) && (ord.ParentOrder__c != null && !ordersAlreadyAssigned.contains(ord.ParentOrder__c))) {
                    orderMap.put(ord.Id, ord);
        
                    wrts_prcgvr__Activity__c activity = new wrts_prcgvr__Activity__c(
                        RecordTypeId = HDT_UTL_ActivityCustom.getRecordTypeId('HDT_RT_ComfortQualityCall'),
                        Type__c = 'Quality Call',
                        wrts_prcgvr__Status__c = 'Aperta',
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

        //Dv: applico logica dei 50gg -> se tutti gli ordini su un ordine parent (esclusi gli ordini di analisi consumi) sono stati messi in annullato, e sul parent e' presente un'activity di 
        //quality call, la vado a chiudere. 
        //Vado a controllare se ci sono ordini annullati perche' superati i 50gg
        if(!parentToChildOrderMap.keySet().isEmpty()){
            //Mi vado a prendere tutti gli ordini correlati ai parent censiti e le relative activities
            Map<String, List<String>> allChildByParent = HDT_QR_Order.getOrdersByParent(parentToChildOrderMap.keySet());
            Map<String, wrts_prcgvr__Activity__c> parentQualCallMap = HDT_QR_ActivityCustom.getQualCallByParentOrder(parentToChildOrderMap.keySet());
            //Controllo che ci siano attività da chiudere
            if(!parentQualCallMap.keySet().isEmpty()){
                for(String parent : parentQualCallMap.keySet()){
                    Boolean allCanceled = true;
                    //Per ogni parent vado a controllare che tutti i suoi figli stiano passando in annullato
                    for(String child : allChildByParent.get(parent)){
                        if(!parentToChildOrderMap.get(parent).contains(child)){
                            allCanceled = false;
                            break;
                        }
                    }
                    if(allCanceled && parentQualCallMap.get(parent) != null){
                        //Devo andare a controllare se sul Parent Order è presente una QualityCall aperta. Nel caso, vado a chiuderla.
                        wrts_prcgvr__Activity__c actToClose = parentQualCallMap.get(parent);
                        actToClose.wrts_prcgvr__Status__c = 'Chiusa';
                        activitiesToClose.add(actToClose);
                    }
                }
            }
        }

        callActivities.addAll(mapActivitiesParent.values());

        if (!ordersToUpdate.isEmpty()) {
            Database.update(ordersToUpdate, false);
        }
        if (!callActivities.isEmpty()) {
            Database.insert(callActivities, false);
        }
        if(activitiesToClose.size() > 0){
            Database.update(activitiesToClose, false);
        }

        List<String> contactList = new List<String>();
        for (Order orderCm : orderMap.values()) {
            if ( orderCm.Contact__c != null) {
                contactList.add(orderCm.Contact__c);
            }
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

                if (!campaignMembersBulk.isEmpty()) {
                    for (CampaignMember cmAlready : campaignMembersBulk) {
                        if (cmAlready.CampaignId == compOwnerToCampMap.get(compOwner).Id 
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
                            CampaignId = compOwnerToCampMap.get(compOwner).Id ,
                            PhoneNumber__c = orderMap.get(ordId).PhoneNumber__c,
                            RelatedActivity__c = orderActivityMap.get(ordId).Id,
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
            Database.insert(notDuplicatedCampToIns.values(), false);
        }
        if(!campaignMembersUpdate.isEmpty()){
            Database.update(campaignMembersUpdate.values(), false);
        }
        if (!activityVas.isEmpty()) {
            Database.insert(activityVas, false);
        }
    }

    private Boolean skipActivityCreation(Id orderId, Id parentOrderId, Set<Id> siebelOrderWithActivity, Set<Id> sfdcOrderWithActivity){
        return siebelOrderWithActivity.contains(orderId) 
            || sfdcOrderWithActivity.contains(orderId) 
            || (parentOrderId != null && (siebelOrderWithActivity.contains(parentOrderId) || sfdcOrderWithActivity.contains(parentOrderId)));
    }

    private Boolean notCancellableOrder(Order ord){
        Set<String> annullablePhase = new Set<String>{'Amm. Precheck KO SII','Amm. Precheck OK SII', 'Esito KO da DL', 'Esito KO da SII', 'Ammissibilità KO','Dati discordanti'};
        Boolean switchCancellationEligibility = (ord.ProcessType__c!= null && ord.ProcessType__c.containsIgnoreCase('Switch In')) ? (ord.PhaseStory__c != null && ord.PhaseStory__c.containsIgnoreCase('Ammissibilità OK')) : true;
        return ord.HerokuPracticeCode__c != null && !annullablePhase.contains(ord.Phase__c) && switchCancellationEligibility;
    }

    @SuppressWarnings('PMD.AvoidDebugStatements')
    public void finish(Database.BatchableContext bc){
        System.debug(LoggingLevel.DEBUG, 'HDT_BA_QualityCall - END');
    }
}