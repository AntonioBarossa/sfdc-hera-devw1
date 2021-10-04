/**
* @author Sabina Levonja (sabina.levonja@dunegroup.it)
* @date 04/06/21
* @description HDT_TRH_DocumentalActivity
* @history Sabina Levonja – 04/06/21 – created class
*/
public inherited sharing class HDT_TRH_DocumentalActivity extends HDT_TRH_TriggerHandler{

    public override void beforeInsert(){

        HDT_UTL_CompanyOwner.feedCompanyOwner(trigger.new);
        // Valorizza le lookup OrderId__c e CaseId__c, se vuote, a partire dai campi ParentProcessId__c e ProcessId__c che valorizza il MOGA.
        try{
            List<DocumentalActivity__c> docActivityList = (List<DocumentalActivity__c>) trigger.new;
            Set<String> parentSetCase = new Set<String>();
            Set<String> parentSetOrder = new Set<String>();
            Set<String> recordSet = new Set<String>();
            Map<String,Id> numberIdMap = new Map<String,Id>();
            Map<String,Id> caseNumberIdMap = new Map<String,Id>();
            for(DocumentalActivity__c single : docActivityList){
                if(single.ParentProcessId__c != null && single.ParentProcessId__c.indexOf('C-') > -1){
                    parentSetCase.add(single.ParentProcessId__c);
                }else if(single.ParentProcessId__c != null && single.ParentProcessId__c.indexOf('O-') > -1) {
                    parentSetOrder.add(single.ParentProcessId__c);
                }
                if(single.ProcessId__c != null && single.ProcessId__c.indexOf('O-') > -1){
                    parentSetOrder.add(single.ProcessId__c);
                }else if(single.ProcessId__c != null && single.ProcessId__c.indexOf('C-') > -1){
                    parentSetCase.add(single.ProcessId__c);
                }
            }
            List<SObject> orderParentList = HDT_QR_DocumentalConfiguration.getRecordFromServiceItems('Order', parentSetOrder);
            List<SObject> caseParentList = HDT_QR_DocumentalConfiguration.getRecordFromServiceItems('Case', parentSetCase);
            for(Order singleOrder : (List<Order>)orderParentList){
                numberIdMap.put((String) singleOrder.OrderNumber, (Id) singleOrder.Id);
            }
            for(Case singleCase : (List<Case>)caseParentList){
                numberIdMap.put((String) singleCase.CaseNumber, (Id) singleCase.Id);
            }
            for(DocumentalActivity__c single : docActivityList){
                //Id parentRecordId = single.ParentProcessId__c;
                //Id processRecordId = single.ProcessId__c;
                Id parentRecordId = numberIdMap.get(single.ParentProcessId__c) != null? numberIdMap.get(single.ParentProcessId__c):'';
                Id processRecordId = numberIdMap.get(single.ProcessId__c) != null? numberIdMap.get(single.ProcessId__c):'';

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
            System.debug('Error ' + ex.getMessage() + ' at line '+ex.getLineNumber());
        }
    }
}