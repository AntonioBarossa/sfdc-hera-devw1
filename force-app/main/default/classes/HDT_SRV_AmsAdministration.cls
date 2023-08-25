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

    public String updateAmsLogRecord(AmsAdministration__c logToUpdate){
        String result = '';

        logToUpdate.Status__c = 'COMPLETED';

        Database.SaveResult saveRes = Database.update(logToUpdate, false);
        if(saveRes.isSuccess())
        {
            result = saveRes.getId();
        }
        
        return result;
    }

}