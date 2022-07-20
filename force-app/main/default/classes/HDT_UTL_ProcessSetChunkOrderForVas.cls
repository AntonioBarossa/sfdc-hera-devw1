@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing class HDT_UTL_ProcessSetChunkOrderForVas extends HDT_UTL_ProcessExecution {

    public override void registryCreation(){

        Map<String, Id> progressiveIdMap = new Map<String, Id>();
        Set<Id> idToRemove = new Set<Id>();

        List<String> progressiveOrderNumbers = new List<String>();
        for(MassiveLoaderRequestItem__c item : requestItemList){
            progressiveOrderNumbers.add(item.NextStepData__c);
        }

        List<MassiveLoaderRequestItem__c> aggregateOrders = [
            SELECT Id, NextStepData__c
            FROM MassiveLoaderRequestItem__c
            WHERE NextStepData__c IN: progressiveOrderNumbers
            AND MassiveLoaderRequest__c = :requestId
            WITH SECURITY_ENFORCED
            ORDER BY NextStepData__c
        ];

        for(MassiveLoaderRequestItem__c item : aggregateOrders){
            if(!progressiveIdMap.containsKey(item.NextStepData__c)){
                progressiveIdMap.put(item.NextStepData__c, item.Id);
                idToRemove.add(item.Id);
            }
        }

        for(MassiveLoaderRequestItem__c item : requestItemList){
            if(idToRemove.contains(item.Id)){
                item.VasOrder__c = true;
                continue;
            }
            if(progressiveIdMap.containsKey(item.NextStepData__c)){
                item.RelatedRequestItem__c = progressiveIdMap.get(item.NextStepData__c);
            }
        }

    }

    public override void finalUpdate(){
        System.debug(LoggingLevel.DEBUG, 'finalUpdate');
        update requestItemList;
    }

}