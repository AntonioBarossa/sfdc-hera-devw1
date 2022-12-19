@SuppressWarnings('PMD.AvoidDebugStatements,PMD.CyclomaticComplexity, PMD.NcssMethodCount')
public with sharing class HDT_BA_CloseQualityCall implements Database.Batchable<sObject>, Database.Stateful{
    //possibile classe utility
    private final Integer DAYS_TO_WORK = 50;
    private final Date START_DATE = Date.today().addDays(-DAYS_TO_WORK);
    //fine possibile classe utility

    private Set<Id> parentOrdersId = new Set<Id>();
    private Set<Id> childOrdersId = new Set<Id>();
    private Map<Id,wrts_prcgvr__Activity__c> actMap = new Map<Id,wrts_prcgvr__Activity__c>();

    public Database.QueryLocator start(Database.BatchableContext bc) {
        
        String query = 'SELECT id,Order__c, Order__r.RecordType.DeveloperName, Order__r.ParentOrder__c '
            + 'FROM wrts_prcgvr__Activity__c '
            + 'WHERE RecordTypeDevName__c = \'HDT_RT_ComfortQualityCall\' AND wrts_prcgvr__IsClosed__c = false AND Type__c = \'Quality Call\' AND Order__r.CreatedDate < :DAYS_TO_WORK';
        return Database.getQueryLocator([SELECT id,Order__c, Order__r.RecordType.DeveloperName, Order__r.ParentOrder__c
            FROM wrts_prcgvr__Activity__c
            WHERE RecordTypeDevName__c = 'HDT_RT_ComfortQualityCall' AND wrts_prcgvr__IsClosed__c = false AND Type__c = 'Quality Call' AND Order__r.CreatedDate < :DAYS_TO_WORK]
        );
    }

    public void execute(Database.BatchableContext bc, List<wrts_prcgvr__Activity__c> activities){
        for (wrts_prcgvr__Activity__c act : activities){
            if ('HDT_RT_OrderDossier'.equalsIgnoreCase(act.Order__r.RecordType.DeveloperName)){
                this.parentOrdersId.add('\''+act.Order__c+'\'');
                this.actMap.put(act.Order__c,act);
                continue;
            }
            this.actMap.put(act.Order__r.ParentOrder__c,act);
            this.childOrdersId.add(act.Order__c);
        }  
    }

    public void finish(Database.BatchableContext bc){
        System.debug(LoggingLevel.DEBUG, 'HDT_BA_CLoseQualityCall - END');
    }

}
