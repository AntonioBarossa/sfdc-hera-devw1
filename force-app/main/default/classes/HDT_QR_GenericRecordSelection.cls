public with sharing class HDT_QR_GenericRecordSelection {

    public List<List<sObject>> executeQuery(String fields, String filters, String limitStr,String soslSearchTerm, String objectName){
        String query;
        query = 'Id, ' + fields;

        if(String.isNotBlank(filters)){
            query += ' WHERE ' + filters;
        }

        if(String.isNotBlank(limitStr)) {
        query += ' LIMIT ' + limitStr;
        }

        query = 'FIND \'' + String.escapeSingleQuotes(soslSearchTerm) + '\' IN ALL FIELDS RETURNING ' + objectName + '(' + query + ')';
        system.debug('query => '+query);
        List<List<sObject>> sObjectsList = Search.query(query);

        system.debug('sObjectsList => '+sObjectsList);

        return sObjectsList; 
    }
}
