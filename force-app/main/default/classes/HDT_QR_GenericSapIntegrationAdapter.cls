public inherited sharing class HDT_QR_GenericSapIntegrationAdapter {
    /*
    * @Author: Salvatore A. Sarà 21/10/2021
    * Risoluzione "Debug Should Use Logging Level"
    * Risoluzione "Avoid debug statements since they impact on performance"
    */
    @SuppressWarnings('PMD.AvoidDebugStatements')
    public List<sObject> getGenericRecords(String fields, String objectName, String conditions){
        List<sObject> sobjList = new List<sObject>();
        System.debug(LoggingLevel.DEBUG, fields + ' ' + objectName + ' ' + conditions);
        try{
            if(fields != null && String.isNotBlank(fields) && objectName != null && String.isNotBlank(objectName)){
                SObjectType objtype = Schema.getGlobalDescribe().get(objectName);
                Schema.DescribeSObjectResult objRes = objtype.getDescribe(); 
                if(objRes.isAccessible()){
                    String query = 'SELECT ' + String.escapeSingleQuotes(fields) + ' FROM ' + String.escapeSingleQuotes(objectName);
                    if(conditions != null && String.isNotBlank(conditions)){
                        query += ' WHERE ' + conditions;
                    }
                    System.debug(LoggingLevel.DEBUG, query);
                    sobjList = Database.query(query);
                }
            }
        }catch(Exception ex){
            throw ex;
        }
        return sobjList;
    }
}
