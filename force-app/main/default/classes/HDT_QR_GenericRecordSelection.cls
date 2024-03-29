@SuppressWarnings('PMD.AvoidDebugStatements')
public with sharing class HDT_QR_GenericRecordSelection {

    public List<HDT_Generic_Record_Selection__mdt>  getConfigurationByName(String searchKey) {
        try{
            List<HDT_Generic_Record_Selection__mdt> config = [SELECT Id, Distinct__c, Query_Type__c, Columns__c,Default_Search_Key__c,Fields__c,Max_Rows__c,Row_Limit__c,sObject__c,Where_Conditions__c
            FROM HDT_Generic_Record_Selection__mdt WHERE DeveloperName =:searchKey WITH SECURITY_ENFORCED];
            return config;
        }catch(Exception ex){
            throw ex;
        }
    }

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
            system.debug(LoggingLevel.DEBUG, 'query => '+query);
            sObjectsList = Search.query(query);

            //system.debug('sObjectsList => '+sObjectsList);

        }

        return sObjectsList;
    }
    /**@frpanico 25/10/2021
     * Inserita Annotazione @SuppressWarning
     * Alla query viene fatto l'escape lato client
     * Eseguirlo nuovamente lato server comporta il fallimento della query
     */
    @suppressWarnings('PMD.ApexSOQLInjection')
    public List<sObject> executeSoqlQuery(String fields, String filters, String limitStr, String objectName) {
        String query;

        List<sObject> sObjectList = new List<sObject>();

        SObjectType objtype = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult objRes = objtype.getDescribe();

        if(objRes.isAccessible()) {

            query = 'SELECT Id, ' + fields + ' FROM ' + objectName;

            if(String.isNotBlank(filters)) {
                query += ' WHERE ' + filters;
            }

            if(String.isNotBlank(limitStr)) {
                query += ' LIMIT ' + limitStr;
            }
            
            System.debug(LoggingLevel.DEBUG, 'query => '+ query);
            sObjectList = Database.query(query);

            //system.debug('sObjectList => '+sObjectList);

        }

        return sObjectList;
    }
}