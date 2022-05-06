@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing class HDT_UTL_ProcessSetOrderForVas extends HDT_UTL_ProcessExecution {

    
    public override void registryCreation(){
        List<String> tempSplitedFields;
        Integer orderUniqueKeyIndex = mapHeaderForWrapper.get('Progressivo_rds');

        for(MassiveLoaderRequestItem__c item : requestItemList){
            tempSplitedFields = item.Data__c.split(splitCharacter, -1);
            item.NextStepData__c = tempSplitedFields[orderUniqueKeyIndex];
            item.Status__c = 'In Lavorazione';
        }

    }

    public override void finalUpdate(){
        System.debug(LoggingLevel.DEBUG, 'finalUpdate');
        update requestItemList;
    }

}