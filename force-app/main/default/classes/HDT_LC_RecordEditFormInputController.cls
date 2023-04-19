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
        if(String.isBlank(controllingField)){
            List<SObject> objectList=HDT_QR_RecordEditFormFlowController.getRecordFromIdQueryString(fieldName, objectName, objectId);
            if(objectList.size()==0){
                throw new AuraHandledException('Record not found');
            }
            String picklistLabel='';
            for(PicklistEntry ple:Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(fieldName).getDescribe().picklistValues){
                if(ple.isActive()==true && ple.value==objectList[0].get(fieldName)){
                    picklistLabel=ple.getLabel();
                    break;
                }
            }
            params.put('fieldLabel',String.isNotBlank(picklistLabel) ? picklistLabel:objectList[0].get(fieldName));
            params.put('fieldValue',objectList[0].get(fieldName));
        }else{
            System.debug('parameters: '+controllingField+' | '+fieldName+' | '+process+' | '+objectName);
            List<HDT_RecordFormFieldDependency__mdt> rffd=HDT_QR_RecordEditFormFlowController.getDependencyConfigurations(controllingField,fieldName,process,objectName);
            if(rffd.size()==0){
                throw new AuraHandledException('No configuration record found');
            }
            params.put('dependencySchema',rffd[0].DependecyJSON__c);
        }
        return params;
    }

}