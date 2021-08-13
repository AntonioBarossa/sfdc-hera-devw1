/**
* @author Sabina Levonja (sabina.levonja@dunegroup.it)
* @date 04/06/21
* @description HDT_TRH_DocumentalActivity
* @history Sabina Levonja – 04/06/21 – created class
*/
public inherited sharing class HDT_TRH_DocumentalActivity extends HDT_TRH_TriggerHandler{

    public override void beforeInsert(){
        HDT_UTL_CompanyOwner.feedCompanyOwner(trigger.new);
        try{
            List<DocumentalActivity__c> docActivityList = (List<DocumentalActivity__c>) trigger.new;
            for(DocumentalActivity__c single : docActivityList){
                Id parentRecordId = single.ParentProcessId__c;
                Id processRecordId = single.ProcessId__c;
                String parentObjectName = parentRecordId != null? parentRecordId.getSObjectType().getDescribe().getName():'';
                String processObjectName = processRecordId != null? processRecordId.getSObjectType().getDescribe().getName():'';
                /*if(String.isNotBlank(parentRecordId) && parentObjectName.equalsIgnoreCase('Order')){
                    single.OrderId__c = parentRecordId;
                }else*/
                if(String.isNotBlank(parentRecordId) && parentObjectName.equalsIgnoreCase('Case')){
                    single.CaseId__c = parentRecordId;
                }
    
                if(String.isNotBlank(processRecordId) && processObjectName.equalsIgnoreCase('Order')){
                    single.OrderId__c = processRecordId;
                }/*else if(String.isNotBlank(parentRecordId) && parentObjectName.equalsIgnoreCase('Case')){
                    single.CaseId__c = parentRecordId;
                }*/
                
            }
        }catch(Exception ex){
            System.debug('Error ' + ex.getMessage());
        }
    }
}