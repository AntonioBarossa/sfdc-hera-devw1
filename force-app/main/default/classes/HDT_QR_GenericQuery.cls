public with sharing class HDT_QR_GenericQuery {
    public static List<sObject> getGenericRecords(String fields, String objectName, String conditions){
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
	public static List<sObject> getGenericRecords(String queryString, String objectName){
		SObjectType objtype = Schema.getGlobalDescribe().get(objectName);
		Schema.DescribeSObjectResult objRes = objtype.getDescribe(); 
		if(objRes.isAccessible())
			return Database.query(queryString);
		else
			return null;
	}
}