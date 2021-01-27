public with sharing class HDT_QR_GenericRecordSelection {

    public List<List<sObject>> executeQuery(String fields, String filters, String limitStr,String soslSearchTerm, String objectName){
        String query;

        List<List<sObject>> sObjectsList = new List<List<sObject>>();
        
        //List<String> objType = new List<String>();

        //objType.add(objectName);

        //HDT_UTL_SecurityAccess securityAccess = new HDT_UTL_SecurityAccess(objectName, fields, 'read');

        //securityAccess.checkSecurityAccess();

        //Schema.DescribeSobjectResult[] results = Schema.describeSObjects(objType​);

        SObjectType objtype = Schema.getGlobalDescribe().get(objectName);

        Schema.DescribeSObjectResult objRes = objtype.getDescribe();

        if(objRes.isAccessible()){

            query = 'Id, ' + fields;

            if(String.isNotBlank(filters)){
                query += ' WHERE ' + filters;
            }

            if(String.isNotBlank(limitStr)) {
            query += ' LIMIT ' + limitStr;
            }

            query = 'FIND \'' + String.escapeSingleQuotes(soslSearchTerm) + '\' IN ALL FIELDS RETURNING ' + objectName + '(' + query + ')';
            system.debug('query => '+query);
            sObjectsList = Search.query(query);

            system.debug('sObjectsList => '+sObjectsList);

        }

        return sObjectsList; 
    }
}
