public with sharing class HDT_WS_RunBatch {
    
    @InvocableMethod
    public static List<String> launchBatch(List<String> batchNames){
        List<String> response = new List<String>();

        if(batchNames.size()>0){
            String bName = batchNames[0];
            HDT_BatchMapping__mdt mapping = HDT_BatchMapping__mdt.getInstance(bName);
            Integer size = mapping!=null && mapping.BatchSize__c!=null && mapping.BatchSize__c!=0 ? Integer.valueOf(mapping.BatchSize__c) : 200;
            Type className = Type.forName(bName);

            if(className != null){
                Object bInstance = className.newInstance();
                if(bInstance != null){
                    try{
                        Database.executeBatch((Database.Batchable<sObject>) bInstance, size);
                        response.add('Success: Batch ' + bName + ' lanciato con successo');
                        return response;
                    }catch(Exception e){
                        response.add('Error: ' + e.getMessage());
                        return response;
                    }
                }
            }
        }
        response.add('Error: Si è verificato un errore imprevisto');
        return response;
    }

}
