public with sharing class HDT_UTL_VoltureChangeManager {
    
    public SObject cloneSObject(SObject sobj, Map<String,Object> extraParams)
    {
        String recordTypeId = (String)extraParams.get('recordTypeId');
        String processType  = (String)extraParams.get('processType');
        Set<String> extraExcludedFields = (Set<String>)extraParams.get('excludedFields');
        Set<String> defaultExcludedFields = new Set<String>
        {
            'LastModifiedDate', 
            'Id', 
            'SystemModstamp', 
            'Phase__c', 
            'PhaseStory__c', 
            'Status',
            'RecordTypeId',
            'ServiceRequestID__c',
            'CreatedDate',
            'CreatedById',
            'OwnerId',
            'LastModifiedById'
        };
        Set<String> excludedFields = defaultExcludedFields;
        if(extraExcludedFields != null && defaultExcludedFields.addAll(extraExcludedFields))
        {
            excludedFields = defaultExcludedFields;
        }

        return null;
    }


}
