public class HDT_LC_CustomLookupController {

    @AuraEnabled(cacheable=true)
    public static List<ObjDetail> lookUp(String searchTerm, string myObject, String filter, String searchBy, String setAsKey, List<String> detailFields) {

        Boolean enableDetails = (detailFields != null && detailFields.size()>0 && !detailFields.isEmpty()) ? true : false;
        String myQuery = null;
        List<ObjDetail> objList = new List<ObjDetail>();

        System.debug('# Filter -> ' + filter);

        myQuery = 'SELECT ' + setAsKey + ',' + searchBy + ' ';

        if(enableDetails){
            myQuery += ',' + String.join(detailFields, ',') + ' '; 
        }

        myQuery += 'FROM ' + myObject + ' ';

        //if(filter != null && filter != ''){
        //    myQuery += 'WHERE ' + searchBy + ' LIKE  \'%' + searchTerm + '%\' AND ' + filter + ' LIMIT 5'; 
        //} else {
        //    if(searchTerm == null || searchTerm == ''){
        //        myQuery += 'WHERE LastViewedDate != NULL ORDER BY LastViewedDate DESC LIMIT 5'; 
        //    } else {
        //        myQuery += 'WHERE ' + searchBy + ' LIKE  \'%' + searchTerm + '%\' LIMIT 5';
        //    }
        //}
        
        if(String.isEmpty(filter)){
        //if(searchTerm == null || searchTerm == ''){
            myQuery += 'WHERE LastModifiedDate != NULL';
            if(!String.isEmpty(filter)){
                myQuery += ' AND ' + filter;
            }
            myQuery += ' ORDER BY LastModifiedDate DESC';
        } else {
            myQuery += 'WHERE ' + searchBy + ' LIKE  \'%' + searchTerm + '%\'';
            if(!String.isEmpty(filter)){
                myQuery += ' AND ' + filter;
            }
        }

        myQuery += ' LIMIT 5';

        List<sObject> lookUpList = database.query(myQuery);

        if(lookUpList.size()>0){

            Map<String, String> fieldMap;
            if(enableDetails){
                fieldMap = getFieldLabel(detailFields, myObject);
            }
            
            ObjDetail obj;
            for(sObject so : lookUpList){
                obj = new ObjDetail();
                obj.id = (String)so.get('Id');
                obj.name = (String)so.get(searchBy);
                obj.code = (String)so.get(setAsKey);
                obj.bDetail = enableDetails;
                
                if(enableDetails){
                    obj.detail = '';
                    for(String key : fieldMap.keySet()){
                        obj.detail += fieldMap.get(key) + ': ' + (String)so.get(key) + ' | ';
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
            fieldMap.put(s, accountFieldMap.get(s).getDescribe().getLabel());
        }
        return fieldMap;
    }

    public class ObjDetail {
        @AuraEnabled public String id;
        @AuraEnabled public String name;
        @AuraEnabled public String code;
        @AuraEnabled public Boolean bDetail;
        @AuraEnabled public String detail;
    }

}