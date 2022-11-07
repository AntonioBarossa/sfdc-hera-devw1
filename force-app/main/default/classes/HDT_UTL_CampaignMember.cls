/**
* @author Fatjola Memishaj (fatjola.memishaj@dunegroup.it)
* @date 18/03/2021
* @description HDT_UTL_CampaignMember
* @history Fatjola Memishaj – 18/03/2021 – Created class
*/


@SuppressWarnings('PMD.AvoidDebugStatements, PMD.EmptyStatementBlock, PMD.CyclomaticComplexity')
public with sharing class HDT_UTL_CampaignMember {

    public static void createCampaignMemberStatus(List<Campaign> newCampaigns, List<Campaign> oldCampaigns){
        Map<String,Campaign> mapCampaign = new Map<String,Campaign>();
        List<HDT_CampaignMemberStatus__mdt> campaignStatusMdt = HDT_QR_CampaignMemberStatusMetadata.getRecords();
        List<CampaignMemberStatus> campaignMemberStatuses= new List<CampaignMemberStatus>();

        List<Campaign> campaigns= new List<Campaign>();
        for(Campaign ce: oldCampaigns){
            mapCampaign.put(ce.id, ce);
        }

        for (Campaign cam: newCampaigns){
            Campaign oldCampaign = mapCampaign.get(cam.id);
            if(cam.Status != oldCampaign.Status ){
                if(oldCampaign.Status == 'Bozza' && cam.Status == 'Pianificata'){
                    campaigns.add(cam);
                }
            }
        }

        for(Campaign c: campaigns){
            for(HDT_CampaignMemberStatus__mdt cmdt : campaignStatusMdt){
                if (
                    (cmdt.Category__c == 'Entrambi' && cmdt.Channel__c == 'Tutti' && c.Channel__c!='Door to Door') ||
                    (c.Category__c == 'Campagna CRM' && (cmdt.Category__c == 'Inbound' || cmdt.Category__c == 'Entrambi') && cmdt.Channel__c == 'Tutti') || (
                        (c.Category__c == 'Campagna Outbound' && cmdt.Category__c == 'Outbound') && (
                            (c.Channel__c == 'Telefonico Outbound' && cmdt.Channel__c == 'Telefonico Outbound') ||
                            (c.Channel__c == 'Cartaceo' && cmdt.Channel__c == 'Cartaceo')
                        )
                    ) ||
                    (c.Category__c == 'Campagna Marketing Cloud' && cmdt.Category__c == 'Marketing Cloud') || 
                    (cmdt.Category__c == 'Outbound' && cmdt.Channel__c == 'Door to Door' && c.Channel__c=='Door to Door')
                ) {
                    campaignMemberStatuses.add(new CampaignMemberStatus(
                        CampaignId = c.Id,
                        Label = cmdt.StatusName__c,
                        HasResponded = cmdt.HasResponded__c,
                        IsDefault = cmdt.Default__c
                    ));
                }
            }
        }
        try {
            HDT_SRV_CampaignMemberStatus.createRecord(campaignMemberStatuses);
        }
        catch(Exception e) {
            System.debug(LoggingLevel.DEBUG, 'Andato in Eccezione');
        }
    }

    public static void createCampaignMember(List<CampaignMember> newCampaignMember) {
        List<String> campaignIds = new List<String>();
        for (CampaignMember item : newCampaignMember) {
            campaignIds.add(item.CampaignId);
        }
      
        Map <Id,Campaign> campMap=new Map<Id, Campaign>([SELECT Id, EndDate, Tipology__c FROM Campaign WHERE Id IN: campaignIds]);

        for (Integer i = 0; i < newCampaignMember.size(); i++) {
            if ( campMap.containsKey(newCampaignMember[i].CampaignId)) {
                if(campMap.get(newCampaignMember[i].CampaignId).EndDate!=null){
                    newCampaignMember[i].NumberingValidityEndDate__c=campMap.get(newCampaignMember[i].CampaignId).EndDate;
                }
                else{
                    newCampaignMember[i].NumberingValidityEndDate__c=campMap.get(newCampaignMember[i].CampaignId).Tipology__c=='Quality Call' ? System.today().addDays(50) : Date.today().addYears(1); 
                    //newCampaignMember[i].NumberingValidityEndDate__c=Date.today().addYears(1);
                }
            }
        }
        
        List<CampaignMemberAssigmentItem__c> query = [
            SELECT Id, Agency__c, PercentageAllocation__c, CampaingMemberAssigment__c, ProcessingType__c  FROM CampaignMemberAssigmentItem__c WHERE CampaingMemberAssigment__c IN (SELECT CampaignMemberAssigment__c FROM Campaign WHERE Id IN :campaignIds AND AssignmentType__c = 'Peso Percentuale') WITH SECURITY_ENFORCED ORDER BY PercentageAllocation__c DESC
        ];

        if (query.size()>0 && query[0].CampaingMemberAssigment__c!=null) {
            String campaignMemberAssigmentId = query[0].CampaingMemberAssigment__c;
 
            List<AggregateResult> totalPercentageQuery = [
                SELECT SUM(PercentageAllocation__c) totalPercentage FROM CampaignMemberAssigmentItem__c WHERE CampaingMemberAssigment__c = :campaignMemberAssigmentId WITH SECURITY_ENFORCED
            ];

            Decimal totalPercentage = (Decimal)totalPercentageQuery[0].get('totalPercentage');

            Map<String,Decimal> agencyPercentage = new Map<String,Decimal>();
            if (totalPercentage < 100) {
                for (CampaignMemberAssigmentItem__c row : query) {
                    Decimal perc = (Decimal)row.get('PercentageAllocation__c');
                    perc = perc/totalPercentage * 100;
                    agencyPercentage.put((String)row.get('Agency__c'), perc.round(System.RoundingMode.HALF_UP));
                }
            } else {
                for (CampaignMemberAssigmentItem__c row : query) {
                    agencyPercentage.put((String)row.get('Agency__c'), (Decimal)row.get('PercentageAllocation__c'));
                }
            }

            Map<String,String> agencyProcessingType = new Map<String,String>();
            for (CampaignMemberAssigmentItem__c row : query) {
                agencyProcessingType.put((String)row.get('Agency__c'), (String)row.get('ProcessingType__c'));
            }

            List<String> agencies = new List<String>(agencyPercentage.keySet());

            Integer totalAssigned = 0;
            Decimal total = newCampaignMember.size();

            for (String agency : agencies) {
                Decimal toAssign =  total * (Decimal)agencyPercentage.get(agency) / 100;
                toAssign = toAssign.round(System.RoundingMode.HALF_UP);
                if ((totalAssigned + toAssign) == (newCampaignMember.size() + 1)) {
                    toAssign = toAssign - 1;
                }
                if ((totalAssigned + toAssign) <= newCampaignMember.size()) {
                    //assign agencies to the new campaign members
                    for (Integer i = 0; i < toAssign; i++) {
                        Integer index = i + totalAssigned;
                        newCampaignMember[index].Agency__c = agency;
                        newCampaignMember[index].ProcessingType__c = agencyProcessingType.get(agency);
                    }
                    totalAssigned += (Integer)toAssign;
                }
            }
        }
    }

    public static void campaignSuspension(List<Campaign> newCampaigns, List<Campaign> oldCampaigns) {

        List<Campaign> campaignsToUpdate = new List<Campaign>();
        Map<String,String> oldStatus = new Map<String,String>();
        for (Campaign oldCmp : oldCampaigns) {
            oldStatus.put(oldCmp.Id, oldCmp.Status);            
        }
        for (Campaign cmp : newCampaigns) {
            if ((cmp.Status == 'Cancellata' || cmp.Status == 'Bloccata') && cmp.Channel__c.Contains('Telefonico Outbound') && oldStatus.get(cmp.Id) == 'In Corso') {
                campaignsToUpdate.add(cmp);                
            }
        }

        if (campaignsToUpdate.size() > 0) {
            List<String> campaignIds = new List<String>();
            for (Campaign camp : campaignsToUpdate) {
                campaignIds.add(camp.Id);
            }
            futureCampaignOutboundSuspensionRequest(campaignIds);
        }
    }

    @future(callout=true)
	public static void futureCampaignOutboundSuspensionRequest(List<String> campaignIds){

        // for (String id : campaignIds) {
        //     HDT_WS_CampaignOutboundSuspension.HDT_WS_CampaignOutboundSuspensionRequest wsReq = new HDT_WS_CampaignOutboundSuspension.HDT_WS_CampaignOutboundSuspensionRequest();
        //     wsReq.idCampaign = id;            
        //     HDT_WS_Response res = HDT_WS_CampaignOutboundSuspension.campaignOutboundSuspension(wsReq);
        //     System.debug(res.status);
        // }
	}

    public static void activateCampaign(List<Campaign> newCampaigns, List<Campaign> oldCampaigns) {

        Map<String,String> oldStatus = new Map<String,String>();
        for (Campaign oldCmp : oldCampaigns) {
            oldStatus.put(oldCmp.Id, oldCmp.Status);            
        }
        for (Campaign cmp : newCampaigns) {
            if (cmp.Status == 'In Corso' && oldStatus.get(cmp.Id) == 'Pianificata') {
                cmp.isActive = true;              
            }
        }
    }

    @SuppressWarnings('PMD.ApexCRUDViolation, PMD.NcssMethodCount')
    public static void checkTipoEsito(List<CampaignMember> newCampMembList, Map<Id, CampaignMember> campMembOldMap){

        /* 
        fix Too Many SQL
        Set<String> ordIdSet = new Set<String>();
        Set<String> actIdSet = new Set<String>();
        List<String> isMonitoringList = HDT_UTL_AgentMatrix.agencyCodeIsMonitoringList();
        List<wrts_prcgvr__Activity__c> actToCancelList = new List<wrts_prcgvr__Activity__c>();
        Map<String, Order> actToOrderIdMap = new Map<String, Order>();
        Map<String, List<Order>> orderToChildMap = new Map<String, List<Order>>();
        Map<String, List<String>> actToOrdersToCancelMap = new Map<String, List<String>>();
        HDT_SRV_ActivityCustom activitySrv = new HDT_SRV_ActivityCustom(); */

        Set<Id> filteredNewCampaignMembList = new Set<Id>();

        // Modificata per Apex CPU time limit exceeded for(CampaignMember campMemb : newCampMembList){
        for(CampaignMember campMemb : [SELECT Id, HasResponded, RelatedActivity__c, ResultType__c FROM CampaignMember WHERE HasResponded = true AND RelatedActivity__c != null AND ResultType__c = 'Macchina' AND Id IN : newCampMembList WITH SECURITY_ENFORCED]){
            filteredNewCampaignMembList.add(campMemb.Id);
        }

        if (!filteredNewCampaignMembList.isEmpty()){
            System.scheduleBatch(new HDT_BA_CampaignMemberManaged(filteredNewCampaignMembList), 'ManagedCampaignMember'+String.valueOf(Datetime.now().getTime()), 1);
        }
        /* 
        Logica spostata nel batch a causa del Too Many SQL
        if(actIdSet.size() > 0) {
            for(wrts_prcgvr__Activity__c act : HDT_QR_Activity.getActivityFromIdList(actIdSet)){
                if(act.Order__c != null){
                    actToOrderIdMap.put(act.Id, act.Order__r);
                    ordIdSet.add(act.Order__c);
                }
            }
        }

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

        for(CampaignMember member : filteredNewCampaignMembList){
            if(member.ResultType__c == 'Macchina' && member.HasResponded==true && member.RelatedActivity__c != null){ //&& member.ResultType__c != campMembOldMap.get(member.Id).ResultType__c 
                if(actToOrderIdMap.get(member.RelatedActivity__c) != null && isMonitoringList.contains(actToOrderIdMap.get(member.RelatedActivity__c).AgencyCode__c)){
                    if(!actToOrderIdMap.get(member.RelatedActivity__c).RecordType.DeveloperName.equalsIgnoreCase('HDT_RT_OrderDossier')){
                        actToOrdersToCancelMap.put(member.RelatedActivity__c, new List<String>());
                        actToOrdersToCancelMap.get(member.RelatedActivity__c).add(actToOrderIdMap.get(member.RelatedActivity__c).Id);
                    }
                    else {
                        actToOrdersToCancelMap.put(member.RelatedActivity__c, new List<String>());
                        String ordParentId = actToOrderIdMap.get(member.RelatedActivity__c).Id;
                        for(Order ord : orderToChildMap.get(ordParentId)){
                            actToOrdersToCancelMap.get(member.RelatedActivity__c).add(ord.Id);
                        }
                    }
                }
                else {
                    wrts_prcgvr__Activity__c act = new wrts_prcgvr__Activity__c(Id = member.RelatedActivity__c, ContactResult__c = 'Annullato', wrts_prcgvr__Status__c = 'Non Esitata');
                    actToCancelList.add(act);
                }
            }
        }

        if(actToOrdersToCancelMap.size() > 0){
            cancelContract(actToOrdersToCancelMap);
        }

        if(actToCancelList.size() > 0){
            activitySrv.updateRecords(actToCancelList);
        } */
    }

    public static void cancelContract(Map<String, List<String>> actToOrdersToCancelMap){

        List<String> notCancelPhase = new List<String>{
            'Esito Ok da DL',
            'Dati discordanti',
            'Annullato',
            'In lavorazione SAP',
            'Errore lavorazione SAP',
            'Completata',
            'Esito OK da SII',
            'Esito KO da SII',
            'KO rilavorato',
            'KO definitivo'
        };

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

        HDT_SRV_ActivityCustom activitySrv = new HDT_SRV_ActivityCustom();
        HDT_SRV_Order orderSrv = new HDT_SRV_Order();
        HDT_QR_RecordType recTypeQr = new HDT_QR_RecordType();
        HDT_QR_Order orderQr = new HDT_QR_Order();
        List<String> ordIdList = new List<String>();
        List<wrts_prcgvr__Activity__c> actToCloseList = new List<wrts_prcgvr__Activity__c>();
        List<wrts_prcgvr__Activity__c> actToCreateList = new List<wrts_prcgvr__Activity__c>();
        List<Order> ordToCloseList = new List<Order>();
        RecordType attGestRt = recTypeQr.getRecordType('HDT_RT_AttivitaGestionali', 'wrts_prcgvr__Activity__c');

        for(String str : actToOrdersToCancelMap.keySet()){
            ordIdList.addAll(actToOrdersToCancelMap.get(str));
        }
        Map<String, Order> ordToCheckMap = new Map<String, Order>(orderQr.getOrdersList(ordIdList));

        Map<Id,String> mapContactResult = new Map<Id,String>();
        for(wrts_prcgvr__Activity__c act : HDT_QR_Activity.getActivityFromIdList(actToOrdersToCancelMap.keySet())){
            if ('Quality Call'.equalsIgnoreCase(act.Type__c) || 'Comfort Call'.equalsIgnoreCase(act.Type__c)){
                mapContactResult.put(act.Id,'Quality Call'.equalsIgnoreCase(act.Type__c)? 'Annullato Quality Call' : 'Annullato Comfort Call');
            }
        }

        for (String actId : actToOrdersToCancelMap.keySet()) {

            String outcome = mapContactResult.containsKey(actId)? mapContactResult.get(actId) : 'Annullato';
            wrts_prcgvr__Activity__c act = new wrts_prcgvr__Activity__c(Id = actId, ContactResult__c = outcome, wrts_prcgvr__Status__c = 'Non Esitata');
            actToCloseList.add(act);

            for(String ordId : actToOrdersToCancelMap.get(actId)){

                Order ordToCheck = ordToCheckMap.get(ordId);

                if (notCancelPhase.contains(ordToCheck.Phase__c) || notCancelNonBillable.contains(ordToCheck.Phase__c) || notCancelBillable.contains(ordToCheck.Phase__c)) {                
                    wrts_prcgvr__Activity__c actNew = new wrts_prcgvr__Activity__c(
                        RecordTypeId= attGestRt.Id,
                        Cluster__c = 'Attivazioni',
                        Process__c = transcodeProcessForActivity(ordToCheck.RecordType.DeveloperName) != null ? transcodeProcessForActivity(ordToCheck.RecordType.DeveloperName) : ordToCheck.ProcessType__c,
                        Note__c = 'Non è stato possibile procedere all’annullamento, inserire un case di Annullamento contratti'
                    );
                    actToCreateList.add(actNew);
                }
                else {
                    Order ordToCancel = new Order(Id = ordId, Phase__c = 'Annullato', CancellationReason__c = 'Contatto Quality Fallito', Status = 'Activated');
                    ordToCloseList.add(ordToCancel);
                }
            }
        }

        if(actToCreateList.size() > 0){
            activitySrv.createRecord(actToCreateList);
        }
        if(actToCloseList.size() > 0){
            activitySrv.updateRecords(actToCloseList);
        }
        if(ordToCloseList.size() > 0){
            orderSrv.updateRecords(ordToCloseList);
        }
    }

    public static String transcodeProcessForActivity(String orderRecordType){

        Map<String,String> processActivityMap = new Map<String,String>{
            'HDT_RT_SwitchIn' => 'Switch In',
            'HDT_RT_CambioOfferta' => 'Cambio offerta',
            'HDT_RT_VAS' => 'Segnalazioni VAS'
        };
        return processActivityMap.get(orderRecordType);
    }

    public static void handleStatusChange(List<CampaignMember> newList, Map<Id,CampaignMember> oldMap) {
        User currentUser = [SELECT Id, Name, LoginChannel__c FROM User WHERE Id =: UserInfo.getUserId() WITH SECURITY_ENFORCED];
        if(currentUser.Name.contains('Mulesoft')) {
            currentUser.LoginChannel__c = 'Telefonico Outbound';
        }

        Map<String, HDT_CampaignMemberStatus__mdt> statusMap =  new Map<String, HDT_CampaignMemberStatus__mdt>();
        Map<String, HDT_CampaignMemberStatus__mdt> statusCodeMap =  new Map<String, HDT_CampaignMemberStatus__mdt>();
        for(HDT_CampaignMemberStatus__mdt status : HDT_CampaignMemberStatus__mdt.getAll().values()) {
            statusMap.put(status.StatusName__c, status);
            statusCodeMap.put(status.DeveloperName, status);
        }

        HDT_CampaignMemberStatus__mdt status;
        for(CampaignMember member : newList) {
            if(oldMap == null || (member.Status != oldMap.get(member.Id).Status)) {
                if(statusMap.containsKey(member.Status)) {
                    status = statusMap.get(member.Status);
                    member.ResultType__c = status.OutcomeType__c;
                    member.ResultCategory__c = status.OutcomeCategory__c;
                }
            }
            else if(member.StatusCode__c != oldMap.get(member.Id).StatusCode__c) {
                status = statusCodeMap.get(member.StatusCode__c);
                member.Status = status.StatusName__c;
                member.ResultType__c = status.OutcomeType__c;
                member.ResultCategory__c = status.OutcomeCategory__c;
            }

            if(status != null && status.HasResponded__c) {
                member.FinalStateUser__c = currentUser.Id;
                member.FinalStateChannel__c = currentUser.LoginChannel__c;
                member.FinalStatusDate__c = Date.today();
            }

            status = null;
        }

        /*if(oldMap != null){
            checkTipoEsito(newList, oldMap);
        }*/
    }

    public static void setValidityStartDate(List<CampaignMember> members) {
        Set<Id> parentCampaignsIds = new Set<Id>();
        for(CampaignMember member : members) {
            parentCampaignsIds.add(member.CampaignId);
        }
        Map<Id,Campaign> parentCampaignsMap = new Map<Id,Campaign>([SELECT Id,Channel__c FROM Campaign WHERE Id IN: parentCampaignsIds WITH SECURITY_ENFORCED]);
        Date todaysDate = Date.today();
        for(CampaignMember member : members) {
            if(parentCampaignsMap.get(member.CampaignId).Channel__c == 'Telefonico Outbound' && member.NumberingValidityStartDate__c == null) {
                member.NumberingValidityStartDate__c = todaysDate;
            }
        }
    }
    
    public static void setAgency (List<CampaignMember> members) {
        List <CampaignMemberLeadAssigment__c> cmlaList=[SELECT Id, Active__c FROM CampaignMemberLeadAssigment__c WHERE Active__c=true WITH SECURITY_ENFORCED limit 1];
        List <CampaignMemberLeadAssigmentItem__c> cmlaItemList=new List <CampaignMemberLeadAssigmentItem__c>();
        if (cmlaList!=null && cmlaList.size()>0) {
            cmlaItemList=[SELECT Id, SourceAgency__c, Agency__c, InterestProduct__c, CampaignMemberLeadAssigment__c, ProcessingType__c FROM CampaignMemberLeadAssigmentItem__c WHERE CampaignMemberLeadAssigment__c=:cmlaList[0].Id WITH SECURITY_ENFORCED];
        }

        Map <String, CampaignMemberLeadAssigmentItem__c> sourceInterestMap=new Map<String, CampaignMemberLeadAssigmentItem__c>();

        for (CampaignMemberLeadAssigmentItem__c cmla : cmlaItemList) {
            String key='';
            key=cmla.SourceAgency__c+cmla.InterestProduct__c;
            sourceInterestMap.put(key, cmla);
            System.debug('mappa: ' +sourceInterestMap);
        }
        set <String> leadOrContIds=new set <String>();
        set <String> campIds=new set <String>();

        for(CampaignMember cm : members){
            if (String.isNotBlank(cm.LeadId)) {
                leadOrContIds.add(cm.LeadId);
            }
            if (String.isNotBlank(cm.ContactId)) {
                leadOrContIds.add(cm.ContactId);
            }
            if (String.isNotBlank(cm.CampaignId)) {
                campIds.add(cm.CampaignId);
            }
        }

        if(campIds!=null && campIds.size()>0){
            Map <Id, Campaign> campMap=new Map <Id, Campaign> ([SELECT id, AssignmentType__c FROM Campaign WHERE Id IN:campIds]);
            if (leadOrContIds!=null && leadOrContIds.size()>0) {
                Map <Id, Lead>ldMap= new Map <Id, Lead> ([SELECT Id, SourceAgency__c, InterestProduct__c FROM Lead WHERE Id IN:leadOrContIds]);
                Map <Id, Contact>ctMap= new Map <Id, Contact> ([SELECT Id, SourceAgency__c, InterestProduct__c FROM Contact WHERE Id IN:leadOrContIds]);

                for(CampaignMember cm : members){
                    if(String.isNotBlank(cm.CampaignId)){
                        if(campMap.containsKey(cm.CampaignId)){
                            if(campMap.get(cm.CampaignId).AssignmentType__c == 'Su Base Lead'){
                                String key='';
                                if(String.isNotBlank(cm.LeadId) && ldMap!=null && ldMap.size()>0 && ldMap.containsKey(cm.LeadId)){
                                    key=ldMap.get(cm.LeadId).SourceAgency__c+ldMap.get(cm.LeadId).InterestProduct__c;
                                }
                                else if(String.isNotBlank(cm.ContactId) && ctMap!=null && ctMap.size()>0 && ctMap.containsKey(cm.ContactId)){
                                    key=ctMap.get(cm.ContactId).SourceAgency__c+ctMap.get(cm.ContactId).InterestProduct__c;
                                }
                                if(String.isNotBlank(key) && sourceInterestMap.containsKey(key)){
                                    cm.Agency__c=sourceInterestMap.get(key).Agency__c;
                                    cm.ProcessingType__c=sourceInterestMap.get(key).ProcessingType__c;
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    public static void assignCmAgency (List<CampaignMember> members){
        set <String> agencyNames=new set <String>();
        List <Account> agencies=new list <Account>();
        map <String, String> agencyNameIdMap=new Map <String, String>();

        for(CampaignMember cm : members){
            if(String.isNotBlank(cm.Ext_Agency_Name__c)){
                agencyNames.add(cm.Ext_Agency_Name__c);
            }
        }
        if(agencyNames!=null && agencyNames.size()>0){
            agencies=[SELECT id, Name FROM Account WHERE Name IN:agencyNames];

            if(agencies!=null && agencies.size()>0){
                for (Account ag : agencies) {
                    agencyNameIdMap.put(ag.Name, ag.Id);
                }

                for(CampaignMember cm : members){
                    if(String.isNotBlank(cm.Ext_Agency_Name__c) && agencyNameIdMap.containsKey(cm.Ext_Agency_Name__c)){
                        cm.Agency__c=agencyNameIdMap.get(cm.Ext_Agency_Name__c);
                        cm.Ext_Agency_Name__c='';
                    }
                }
            }
        }
    }
    @future(callout=true)
    public static void assignCallDateTime(List<Id> context){
        List<CampaignMember> updList = [SELECT Id, PhoneNumber__c, Lead.ContactDate__c, Agency__r.Name, Campaign.MacroActivityEasyCIM__r.Name, Campaign.ReitekIntegrationTechnology__c FROM CampaignMember WHERE Id IN :context AND Campaign.ReitekIntegrationTechnology__c = 'Web Service' WITH SECURITY_ENFORCED];
            
        for(CampaignMember curCm : updList){
            String macroactivity = curCm.Campaign.MacroActivityEasyCIM__r.Name;
            String phonenumber = curCm.PhoneNumber__c;
            Datetime callDateTime = curCm.Lead.ContactDate__c;
            String agency=curCm.Agency__r.Name;
            HDT_WS_Response response = HDT_WS_InvioNumerazioni.callService(macroactivity, phonenumber, callDateTime, curCm.Id, agency);
            System.debug('@@ futureAssignCallDateTime reitek resp: '+curCm.Id+' '+response);
        }
        

    }
    public static void assignCallDateTimeHandle(List<CampaignMember> context){
        List<Id> camMemList = new List<Id>();
        for(CampaignMember curCm : context){
            camMemList.add(curCm.Id);
            
        }
        List<CampaignMember> updList = [SELECT Id, ReitekSendDate__c FROM CampaignMember WHERE Id IN :camMemList];

        for(CampaignMember curCm : updList) curCm.ReitekSendDate__c = Date.today();
        HDT_UTL_DatabaseService.updateSObject(updList);
        assignCallDateTime(camMemList);

    }
}