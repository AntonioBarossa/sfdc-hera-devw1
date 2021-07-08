public with sharing class HDT_UTL_CaseProcess {
    private static HDT_QR_Contact contactQr = new HDT_QR_Contact();
    private static HDT_QR_Account accountQr = new HDT_QR_Account();
    private static HDT_UTL_CommunicationLog commUtl = new HDT_UTL_CommunicationLog();
    private static HDT_SRV_CommunicationLog commSrv = new HDT_SRV_CommunicationLog();

    private static HDT_QR_CampaignMember campaignMemberQr = new HDT_QR_CampaignMember();
    private static HDT_SRV_CampaignMember campaignMemberSrv = new HDT_SRV_CampaignMember();



    public static void casePhaseManagementAfterUpdate(List<Case> newCasesList, List<Case> oldCasesList) {

        
        Map<String,Case> caseMapNewToOld = new Map<String,Case>();
        Map<String,Case> caseMapOld = new Map<String,Case>();
        Map<String,Case> caseMapNew = new Map<String,Case>();
        
        ////// stesso Case se phase__c diverso tra old e new chiamiamo funzione di una classe HDT_UTL_CommunicationLog
        
        for (Case oldCase : oldCasesList) {
            CaseMapOld.put(oldCase.id,oldCase);
        }
        for (Case newCase : newCasesList) {
           	caseMapNew.put(newCase.id,newCase);
            if(caseMapOld.get(newCase.id)!= null){
                caseMapNewToOld.put(newCase.id,caseMapOld.get(newCase.id));
            }
        }
        
        insertLogForCaseChangedPhase(caseMapOld,caseMapNew);

    }

    private static void insertLogForCaseChangedPhase(Map<String,Case> CaseMapOld, Map<String,Case> CaseMapNew){
        List<CommunicationLog__c> commList = new List<CommunicationLog__c>();
        Map<String,String> mapCaseToContact = new map<String,String>();
        Map<String,String> mapCaseToAccount = new map<String,String>();
        for (Case c : CaseMapNew.values()){
            mapCaseToContact.put(c.id,c.contactId);
            mapCaseToAccount.put(c.id,c.accountId);
        }
        Map<String,Contact> mapContact = new Map<String,Contact>(contactQr.getRecordsById(mapCaseToContact.values()));
        map<String,Account> mapAccount = new Map<String,Account>(accountQr.getRecordsById(mapCaseToAccount.values(),'Id,CompanyOwner__c'));
        for(String cas : CaseMapOld.keyset()){
           Case oldCase =  CaseMapOld.get(cas);
           if(CaseMapNew.get(cas) != null){
               Case newCase = CaseMapNew.get(cas);
               if(oldCase.phase__c != newCase.Phase__c){
                   Contact c = null;
                   Account a = null;
                   if(mapContact.get(newCase.Contactid) != null){
                       c = mapContact.get(newCase.Contactid);
                   }
                   if(mapAccount.get(newCase.AccountId) != null){
                       a = mapAccount.get(newCase.AccountId);
                   }
                   if(a != null && c != null){
                    commList.add(commUTL.instanceCommunicationLog(newCase.cluster__c,newCase.type,newCase.Phase__c,newCase.status,newCase.CancellationReasonDescription__c,'',newCase.id,newCase.ContactId,newCase.AccountId,c != null ? c.company__c : 'ND',a != null ? a.CompanyOwner__c : ''));
                   }  
               }
           }
        }
        if(commList != null && !commList.isEmpty()){
            commSRV.createRecords(commList);
        }
    }

    public static Boolean manageCancellationProcess(List<Case> caseList, Map<Id,SObject> caseOldMap){
		Case caseNew = caseList[0];
		Case caseOld = (Case) caseOldMap.get(caseNew.Id);
		String newPhase = caseNew.Phase__c;
		String oldPhase = caseOld.Phase__c;
        DateTime nowDateTime = DateTime.now();
		if(String.isNotBlank(newPhase) && String.isNotBlank(oldPhase) && newPhase != oldPhase){
			if(newPhase.indexOf('Annullamento') > -1 || newPhase.equalsIgnoreCase('Annullato') || newPhase.indexOf('Ripensamento') > -1 || newPhase.equalsIgnoreCase('Ripensato')){
				caseNew.PhaseStory__c = oldPhase+'@@'+newPhase+'@@'+nowDateTime.getTime()+'@@A||'+caseNew.PhaseStory__c;
                if(caseNew.Type.containsIgnoreCase('Variazione indirizzo di fornitura')){
                    System.debug('Inside Condition');
                    createActivity(caseNew.Id, 'Annullare Case di Allineamento Anagrafica o crearne uno opposto', 'Annullamento Allineamento');
                }
                return true;
			}else if(oldPhase.indexOf('Annullamento - ') > -1 || oldPhase.indexOf('Ripensamento - ') > -1){
                caseNew.PhaseStory__c = oldPhase+'@@'+newPhase+'@@'+nowDateTime.getTime()+'@@A||'+caseNew.PhaseStory__c;

				return true;
			}
		}
		return false;
	}

    private static void createActivity(String recordId, String description, String type){
        String queryString = 'Select id,wrts_prcgvr__Assignees__c, wrts_prcgvr__Subject__c, wrts_prcgvr__DueDateField__c,Name from wrts_prcgvr__ActivityTemplate__c  where Name = \''+ type +'\'';
        String objectName = 'wrts_prcgvr__ActivityTemplate__c';
        List<SObject> listRecord = HDT_QR_GenericQuery.getGenericRecords(queryString, objectName);
        wrts_prcgvr__ActivityTemplate__c template = new wrts_prcgvr__ActivityTemplate__c();
        if(listRecord.size()>0){
            template = (wrts_prcgvr__ActivityTemplate__c) listRecord[0];
            wrts_prcgvr__Activity__c activity = new wrts_prcgvr__Activity__c();
            activity.wrts_prcgvr__ActivityTemplate__c = template.Id;
            activity.Case__c = recordId;
            activity.CausalError__c = description;
            activity.wrts_prcgvr__Description__c = description;
            Boolean insertAct = HDT_UTL_DatabaseService.insertSObject(activity);
        }
    }
    public static void updateMemberStatusforClosedCases(List<Case> newCasesList, List<Case> oldCasesList) {
        try{
            List<Id> closedCaseIds = new List<Id>();
            Map<String,Case> oldCaseMap = new Map<String,Case>();
            for(Case c : oldCasesList){
                oldCaseMap.put(c.id,c);
            }
            Map<String,String> accountIdCase = new Map<String,String> ();
            Map<String,String> campaignIdCase = new Map<String,String>();
            for (Case newCase : newCasesList) {
                if (oldCaseMap.get(newCase.id) != null && oldCaseMap.get(newCase.id).status == 'New' && newCase.Status == 'In Lavorazione') {
                    closedCaseIds.add(newCase.Id);
                    accountIdCase.put(newCase.AccountId, newCase.Id);
                    campaignIdCase.put(newCase.Campaign__c, newCase.Id);
                }
            }

            List<String> accountIds = new List<String>(accountIdCase.keySet());
            List<String> campaignIds = new List<String>(campaignIdCase.keySet());

            List<CampaignMember> membersToUpdate = new List<CampaignMember>();

            List<CampaignMember> cmembers = campaignMemberQr.getMembersByAccountAndCampaign(accountIds, campaignIds);
            for (CampaignMember cm : cmembers) {
                if (accountIdCase.get(cm.Contact.AccountId) == campaignIdCase.get(cm.CampaignId)) {
                    CampaignMember updateMember = new CampaignMember();
                    updateMember.Id = cm.Id;
                    updateMember.Status = 'Positivo';
                    membersToUpdate.add(updateMember);
                }
            }
        
			campaignMemberSrv.updateRecords(membersToUpdate);
		}catch(Exception e)
		{
		
		}
    }
}