public class HDT_LC_CustomLookupController {

    @AuraEnabled(cacheable=true)
    public static List<ObjDetail> lookUp(String searchTerm, string myObject, String filter, String searchBy, String setAsKey) {

        String myQuery = null;
        List<ObjDetail> objList = new List<ObjDetail>();

        myQuery = 'SELECT ' + setAsKey + ',' + searchBy + ' ';
        myQuery += 'FROM ' + myObject + ' ';

        if(filter != null && filter != ''){
            myQuery += 'WHERE ' + searchBy + ' LIKE  \'%' + searchTerm + '%\' AND ' + filter + ' LIMIT 5'; 
        } else {
            if(searchTerm == null || searchTerm == ''){
                myQuery += 'WHERE LastViewedDate != NULL ORDER BY LastViewedDate DESC LIMIT 5'; 
            } else {
                myQuery += 'WHERE ' + searchBy + ' LIKE  \'%' + searchTerm + '%\' LIMIT 5';
            }
        }
        
        List<sObject> lookUpList = database.query(myQuery);

        if(lookUpList.size()>0){

            //Map<String, String> fieldMap = getFieldLabel('list api field', 'object api name');

            ObjDetail obj;
            for(sObject so : lookUpList){
                obj = new ObjDetail();
                obj.id = (String)so.get('Id');
                obj.name = (String)so.get(searchBy);
                obj.code = (String)so.get(setAsKey);
                objList.add(obj);
            }

        }

        return objList;  
    }

    public static Map<String, String> getFieldLabel(String fieldsName, String objName){
        Map<String, String> fieldMap = new Map<String, String>();
        List<String> stringList = fieldsName.split(',');
        for(String s : stringList){
            fieldMap.put(s, Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap().get(s).getDescribe().getLabel());
        }
        return fieldMap;
    }

    public class ObjDetail {
        @AuraEnabled public String id;
        @AuraEnabled public String name;
        @AuraEnabled public String code;
    }

}