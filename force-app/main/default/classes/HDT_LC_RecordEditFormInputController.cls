/**
 * Created by Cristiano on 11/04/2023.
 */

public with sharing class HDT_LC_RecordEditFormInputController {

    @AuraEnabled
    public static Map<String,Object> init(Map<String,Object>params){
        String fieldName=String.valueOf(params.get('fieldName'));
        Id objectId=Id.valueOf(String.valueOf(params.get('objectId')));
        String controllingField= params.containsKey('controllingField') ? String.valueOf(params.get('controllingField')):'';
        String process=params.containsKey('process') ? String.valueOf(params.get('process')):'';
        String objectName= String.valueOf(objectId.getSobjectType());
        HDT_UTL_SecurityAccess securityClass = new HDT_UTL_SecurityAccess();
        if(String.isBlank(controllingField)){
            securityClass.setObjName(objectName);
            securityClass.setOperation('read');
            securityClass.setFieldNamesParam('Id, '+fieldName);
            securityClass.checkSecurityAccess();
            List<SObject> objectList=Database.query('SELECT Id, '+fieldName+' FROM '+ objectName+' WHERE Id=:objectId');
            if(objectList.size()==0){
                throw new AuraHandledException('Record not found');
            }

            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Schema.SObjectType leadSchema = schemaMap.get(objectName);
            Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
            String picklistLabel=fieldMap.get(fieldName).getDescribe().getLabel();
            params.put('fieldValue',objectList[0].get(fieldName));
        }else{
            List<HDT_RecordFormFieldDependency__mdt> rffd=HDT_QR_RecordEditFormFlowController.getDependencyConfigurations(controllingField,fieldName,process,objectName);
            if(rffd.size()==0){
                throw new AuraHandledException('No configuration record found');
            }
            params.put('dependencySchema',rffd[0].DependecyJSON__c);
        }
        return params;
    }

}