public with sharing class HDT_UTL_CaseProcess {
    private static HDT_QR_Contact contactQr = new HDT_QR_Contact();
    private static HDT_QR_Account accountQr = new HDT_QR_Account();
    private static HDT_UTL_CommunicationLog commUtl = new HDT_UTL_CommunicationLog();
    private static HDT_SRV_CommunicationLog commSrv = new HDT_SRV_CommunicationLog();


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

}
