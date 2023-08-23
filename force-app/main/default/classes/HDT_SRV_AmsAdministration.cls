public with sharing class HDT_SRV_AmsAdministration {


    public String insertAmsLogRecord(String method)
    {
        String result = '';

        AmsAdministration__c newLogRecord = new AmsAdministration__c();
        newLogRecord.Status__c = 'PENDING';
        newLogRecord.Process__c = method;
        
        Database.SaveResult saveRes = Database.insert(newLogRecord, false);
        if(saveRes.isSuccess())
        {
            result = saveRes.getId();
        }


        return result;
    }

    public String updateAmsLogRecord(String recordId, Map<String, Object> operationResults){
        String result = '';

        AmsAdministration__c updateLogRecord = new AmsAdministration__c();
        updateLogRecord.Id = recordId;
        updateLogRecord.Status__c = 'COMPLETED';
        if(!operationResults.isEmpty())
        {
            for(String key : operationResults.keySet())
            {
                updateLogRecord.put(key, operationResults.get(key));
            }
        }

        Database.SaveResult saveRes = Database.update(updateLogRecord, false);
        if(saveRes.isSuccess())
        {
            result = saveRes.getId();
        }
        
        return 'Success';
    }

}