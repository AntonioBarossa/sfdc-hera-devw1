/**
* @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
* @date 13/11/2020
* @description HDT_UTL_SecurityAccess Class
* @history Keltin Mesonjesi 13/11/2020 – Created Class
*/
public inherited sharing class HDT_UTL_SecurityAccess {

    private String objName;
    private String fieldNames;
    private String operation;

    private static final Map <String, Schema.SObjectType> SCHEMA_MAP = Schema.getGlobalDescribe();

    /**
     * @description Initialize attributes on object creation
     * @param objNameParam ex.'ServicePoint__c'
     * @param fieldNamesParam ex.'ServicePointCode__c,SupplyCity__c,SupplyProvince__c,Name'
     * @param operationParam options: 'read' or 'create' or 'update' or 'delete' or default: 'read'
     */
    public HDT_UTL_SecurityAccess(String objNameParam, String fieldNamesParam, String operationParam){
        objName = objNameParam;
        fieldNames = fieldNamesParam;
        operation = operationParam;
    }

    /**
     * @description Check if user has permissions to access the object
     * @return Boolean
     */
    private boolean isSafeObject(SObjectType myObj){

        //Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        //SObjectType myObj = schemaMap.get(objName);

        Boolean isOperationAllowed = true;

        switch on operation {
            when  'read' {
                isOperationAllowed = myObj.getDescribe().isAccessible();
            }
            when 'create' {
                isOperationAllowed = myObj.getDescribe().isCreateable();
            }
            when 'update' {
                isOperationAllowed = myObj.getDescribe().isUpdateable();
            }
            when 'delete' {
                isOperationAllowed = myObj.getDescribe().isDeletable();
            }
            when else {
                isOperationAllowed = myObj.getDescribe().isAccessible();
            }
        }

        return isOperationAllowed;
    }

    /**
     * @description Check if user has permission to access the object's field
     * @param fieldName ex.'Name'
     * @return Boolean
     */
    private boolean isSafeField(SObjectField myField){

        //Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        //SObjectType myObj = schemaMap.get(objName);

        //SObjectField myField = myObj.getDescribe().fields.getMap().get(fieldName);

        Boolean isOperationAllowed = true;

        if(myField != null){
            Schema.DescribeFieldResult fieldDescribe = myField.getDescribe();
            switch on operation {
                when  'read' {
                    isOperationAllowed = fieldDescribe.isAccessible();
                }
                when 'create' {
                    isOperationAllowed = fieldDescribe.isCreateable();
                }
                when 'update' {
                    isOperationAllowed = fieldDescribe.isUpdateable();
                }
                when else {
                    isOperationAllowed = fieldDescribe.isAccessible();
                }
            }
        }

        return isOperationAllowed;
    }

    /**
     * @description Check if user can access object and object's fields
     */
    public void checkSecurityAccess(){

        SObjectType mySObject = SCHEMA_MAP.get(objName);

        if (!isSafeObject(mySObject)) {
            throw new AuraHandledException('Non hai permessi per accedere al oggetto ' + objName);
        }

        List<String> fieldsList = fieldNames.split(',');
        List<String> fieldsWithoutAccess = new List<String>{};
        Map<String, SObjectField> fieldsMap = mySObject.getDescribe().fields.getMap();
        
        for (String field : fieldsList) {
            if (!isSafeField(fieldsMap.get(field))) {
                fieldsWithoutAccess.add(field);
            }
        } 

        if (!fieldsWithoutAccess.isEmpty()) {
            String excMessage = 'Non hai permessi per accedere ai campi ' + String.join(fieldsWithoutAccess, ',');
            //system.debug(excMessage);
            throw new AuraHandledException(excMessage);
        }

    }
}