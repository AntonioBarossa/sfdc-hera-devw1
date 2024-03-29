/*
* @Author: Salvatore A. Sarà 20/10/2021
* Risoluzione "Debug Should Use Logging Level"
* Risoluzione "Avoid debug statements since they impact on performance"
*/
@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing class HDT_LC_CustomLookupController {

    @AuraEnabled(cacheable=true)
    public static List<HDT_UTL_ObjDetail> lookUp(String searchTerm, string myObject, String filter, String searchBy, String setAsKey, List<String> detailFields) {
        return lookUpWithOrderBy(searchTerm, myObject, filter, searchBy, setAsKey, null, detailFields);
    }

    @AuraEnabled(cacheable=true)
    public static List<HDT_UTL_ObjDetail> lookUpWithOrderBy(String searchTerm, string myObject, String filter, String searchBy, String setAsKey, String orderBy, List<String> detailFields) {

        Boolean enableDetails = (detailFields != null && detailFields.size()>0 && !detailFields.isEmpty()) ? true : false;
        String myQuery = null;
        List<HDT_UTL_ObjDetail> objList = new List<HDT_UTL_ObjDetail>();
        List<String> statementList = new List<String>();

        System.debug(LoggingLevel.DEBUG, '# Filter -> ' + filter);

        myQuery = 'SELECT ' + String.escapeSingleQuotes(setAsKey)  + ',' + String.escapeSingleQuotes(searchBy) + ' ';

        if(enableDetails){
            myQuery += ',' + String.join(detailFields, ',') + ' '; 
        }

        myQuery += 'FROM ' + myObject + ' ';

        //if(!String.isEmpty(filter)){
        //    myQuery += 'WHERE ' + searchBy + ' LIKE  \'%' + searchTerm + '%\' AND ' + filter + ' LIMIT 5'; 
        //} else {
        //    if(searchTerm == null || searchTerm == ''){
        //        myQuery += 'WHERE LastViewedDate != NULL ORDER BY LastViewedDate DESC LIMIT 5'; 
        //    } else {
        //        myQuery += 'WHERE ' + searchBy + ' LIKE  \'%' + searchTerm + '%\' LIMIT 5';
        //    }
        //}
        
        //if(String.isEmpty(filter)){
        //    myQuery += 'WHERE LastModifiedDate != NULL';
        //    if(!String.isEmpty(filter)){
        //        myQuery += ' AND ' + filter;
        //    }
        //} else {
        //    myQuery += 'WHERE ' + searchBy + ' LIKE  \'%' + searchTerm + '%\'';
        //    if(!String.isEmpty(filter)){
        //        myQuery += ' AND ' + filter;
        //    }
        //}
        
        if(!String.isEmpty(filter)){
            statementList.add(filter);
        }
        
        if(!String.isEmpty(searchBy) && !String.isEmpty(searchTerm)){
            statementList.add(String.escapeSingleQuotes(searchBy) + ' LIKE  \'%' + String.escapeSingleQuotes(searchTerm) + '%\'');
        }        
        
        if(statementList.size()>0){
            myQuery += ' WHERE ';
            myQuery += String.join(statementList, ' AND ');
        }

        if (String.isNotBlank(orderBy)) {
            myQuery += ' ORDER BY ' + orderBy;
        } else {
            myQuery += ' ORDER BY LastModifiedDate DESC';
        }
        myQuery += ' LIMIT 20';

        System.debug(LoggingLevel.DEBUG, '# myQuery -> ' + myQuery);

        List<sObject> lookUpList = database.query(myQuery);

        if(lookUpList.size()>0){

            Map<String, String> fieldMap;
            if(enableDetails){
                fieldMap = getFieldLabel(detailFields, myObject);
            }
            
            HDT_UTL_ObjDetail obj;
            for(sObject so : lookUpList){
                obj = new HDT_UTL_ObjDetail();
                obj.id = (String)so.get('Id');
                try{
                    obj.name = (String)so.get(searchBy);
                    obj.code = (String)so.get(setAsKey);
                }
                catch(SObjectException ex)
                {
                    if(searchBy.contains('.'))
                    {
                        List<String> searchByList = searchBy.split('\\.');
                        obj.name = (String)(so.getSObject(searchByList[0]).get(searchByList[1]));
                    }
                    else
                    {
                        obj.name = (String)so.get(searchBy);
                    }
                    if(setAsKey.contains('.'))
                    {
                        List<String> setAsKeyList = setAsKey.split('\\.');
                        obj.code = (String)(so.getSObject(setAsKeyList[0]).get(setAsKeyList[1]));
                    }
                    else
                    {
                        obj.code = (String)so.get(setAsKey);
                    }
                }
                obj.bDetail = enableDetails;
                
                if(enableDetails){
                    obj.detail = '';
                    for(String key : fieldMap.keySet()){
                        obj.detail += fieldMap.get(key) + ': ' + (String)so.get(key) + ' \n ';
                    }
                }

                objList.add(obj);
            }

        }

        return objList;  
    }

    public static Map<String, String> getFieldLabel(List<String> fieldsName, String objName){
        Map<String, String> fieldMap = new Map<String, String>();
        Map<String, Schema.SObjectField> accountFieldMap = Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap();
        for(String s : fieldsName){
            if(s.containsNone('.')){
                fieldMap.put(s, accountFieldMap.get(s).getDescribe().getLabel());
            }
        }
        return fieldMap;
    }

    public class HDT_UTL_ObjDetail {
        @AuraEnabled public String id;
        @AuraEnabled public String name;
        @AuraEnabled public String code;
        @AuraEnabled public Boolean bDetail;
        @AuraEnabled public String detail;
    }

}