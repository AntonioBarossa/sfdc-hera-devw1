public inherited sharing class HDT_QR_GenerateJsonSAP {
   
    /**
        Author: Everis
        Method Name : getGenericRecords
        Method Description : Return a generic list of records according to the target sObject and Where conditions
        @parms : fields, objectName, conditions  
    **/
    
    public List<sObject> getGenericRecords(String fields, String objectName, String conditions){
        List<sObject> sobjList = new List<sObject>();
        System.debug(fields + ' ' + objectName + ' ' + conditions);
        try{
            if(fields != null && String.isNotBlank(fields) && objectName != null && String.isNotBlank(objectName)){
                SObjectType objtype = Schema.getGlobalDescribe().get(objectName);
                Schema.DescribeSObjectResult objRes = objtype.getDescribe(); 
                if(objRes.isAccessible()){
                    String query = 'SELECT ' + String.escapeSingleQuotes(fields) + ' FROM ' + String.escapeSingleQuotes(objectName);
                    if(conditions != null && String.isNotBlank(conditions)){
                        query += ' WHERE ' + conditions;
                    }
                    System.debug(query);
                    sobjList = Database.query(query);
                }
            }
        }catch(Exception ex){
            throw ex;
        }
        return sobjList;
    }
}