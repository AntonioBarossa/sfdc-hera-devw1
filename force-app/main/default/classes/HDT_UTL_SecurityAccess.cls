public with sharing class HDT_UTL_SecurityAccess {

    private String objName;
    private String fieldNames;
    private String operation;

    /**
     * Initialize attributes on object creation
     * @param String objNameParam ex.'ServicePoint__c'
     * @param String fieldNamesParam ex.'ServicePointCode__c,SupplyCity__c,SupplyProvince__c,Name'
     * @param String operationParam options: 'read' or 'create' or 'update' or 'delete' or default: 'read'
     */
    public HDT_UTL_SecurityAccess(String objNameParam, String fieldNamesParam, String operationParam){
        objName = objNameParam;
        fieldNames = fieldNamesParam;
        operation = operationParam;
    }

    /**
     * Check if user has permissions to access the object
     * @return Boolean
     */
    private boolean isSafeObject(){

        Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        SObjectType myObj = schemaMap.get(objName);

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
     * Check if user has permission to access the object's field
     * @param String fieldName ex.'Name'
     * @return Boolean
     */
    private boolean isSafeField(String fieldName){

        Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        SObjectType myObj = schemaMap.get(objName);

        SObjectField myField = myObj.getDescribe().fields.getMap().get(fieldName);

        Boolean isOperationAllowed = true;

        if(myField != null){
            switch on operation {
                when  'read' {
                    isOperationAllowed = myField.getDescribe().isAccessible();
                }
                when 'create' {
                    isOperationAllowed = myField.getDescribe().isCreateable();
                }
                when 'update' {
                    isOperationAllowed = myField.getDescribe().isUpdateable();
                }
                when else {
                    isOperationAllowed = myField.getDescribe().isAccessible();
                }
            }
        }

        return isOperationAllowed;
    }

    /**
     * Check if user can access object and object's fields
     */
    public void checkSecurityAccess(){

        if (!isSafeObject()) {
            throw new AuraHandledException('Non ai permessi per accedere al oggeto ' + objName);
        }

        List<String> fieldsList = fieldNames.split(',');
        List<String> fieldsWithoutAccess = new List<String>{};
        
        for (String field : fieldsList) {
            if (!isSafeField(field)) {
                fieldsWithoutAccess.add(field);
            }
        } 

        if (!fieldsWithoutAccess.isEmpty()) {
            throw new AuraHandledException('Non ai permessi per accedere ai campi ' + String.join(fieldsWithoutAccess, ','));
        }

    }
}
