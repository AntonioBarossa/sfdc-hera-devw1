@SuppressWarnings('PMD.AvoidDebugStatements,PMD.CyclomaticComplexity, PMD.NcssMethodCount')
public with sharing class HDT_BA_CloseQualityCall implements Database.Batchable<sObject>, Database.Stateful{
    

    private Set<Id> parentOrdersId = new Set<Id>();
    private Set<Id> childOrdersId = new Set<Id>();
    private Map<Id,wrts_prcgvr__Activity__c> actMap = new Map<Id,wrts_prcgvr__Activity__c>();

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT id,Order__c, Order__r.RecordType.DeveloperName, Order__r.ParentOrder__c
            FROM wrts_prcgvr__Activity__c
            WHERE wrts_prcgvr__IsClosed__c = false AND Type__c = 'Quality Call' AND RecordType.Developername ='HDT_RT_ComfortQualityCall' AND Order__r.CreatedDate <= :HDT_UTL_QualityCall.START_DATE]
        );
    }

    public void execute(Database.BatchableContext bc, List<wrts_prcgvr__Activity__c> activities){
        for (wrts_prcgvr__Activity__c act : activities){
            if ('HDT_RT_OrderDossier'.equalsIgnoreCase(act.Order__r.RecordType.DeveloperName)){
                this.parentOrdersId.add(act.Order__c);
                this.actMap.put(act.Order__c,act);
                continue;
            }
            this.actMap.put(act.Order__r.ParentOrder__c,act);
            this.childOrdersId.add(act.Order__c);
        }  
    }

    public void finish(Database.BatchableContext bc){
        if (!this.parentOrdersId.isEmpty() || !this.childOrdersId.isEmpty()){
            Database.executeBatch(new HDT_BA_OrderQualityCallManagement(this.childOrdersId, this.parentOrdersId,this.actMap),HDT_UTL_QualityCall.ORDER_BATCH_SIZE);
        }
    }

}
