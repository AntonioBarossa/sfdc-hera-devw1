public with sharing class HDT_UTL_ContentDocumentLink {
    public static void checkLead(List<ContentDocumentLink> newCDL){
        for(ContentDocumentLink cdl:newCDL){
            if(cdl.LinkedEntityId.getSObjectType().getDescribe().getName() == 'Lead'){
                cdl.visibility = 'AllUsers';
            }
        }
        
        
    }

    public static void updatePhaseAllegatiRicevuti(List<ContentDocumentLink> attachments){

        List<ContentDocumentLink> cdls = attachments;
        Id recordTypeConsumoAnomaloIdrico = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_ConsumoAnomaloIdrico').getRecordTypeId();

    
        Set<ID> caseIds = new Set<ID>();
        List<Case> caseList = new List<Case>();
        List<Case> caseListToUpdate = new List<Case>();
        Case caseForRefresh = new Case();

        for (ContentDocumentLink cdl : cdls) {
            String sObjName = cdl.LinkedEntityId.getSObjectType().getDescribe().getName();
            if(sObjName == 'Case'){
                caseIds.add( cdl.LinkedEntityId );
            }
        }

        if(!caseIds.isEmpty()){
             caseList = [SELECT Id, Phase__c, Cluster__c, RecordTypeId, AccountId, (SELECT Id FROM ContentDocumentLinks LIMIT 1) 
                                FROM Case WHERE Id IN :caseIds WITH SECURITY_ENFORCED];
            
            for (Case c : caseList) {
                if(c.Cluster__c == 'Segnalazioni' && c.RecordTypeId == recordTypeConsumoAnomaloIdrico){
                    if(c.Phase__c == 'Risposta ricevuta'){
                        c.Phase__c = 'Allegati ricevuti';
                        caseListToUpdate.add(c);
                        caseForRefresh = c;
                    }
                }
            }   
            if(!caseListToUpdate.isEmpty()){
                HDT_UTL_DatabaseService.updateSObject(caseListToUpdate);
            }
        }
    }
}