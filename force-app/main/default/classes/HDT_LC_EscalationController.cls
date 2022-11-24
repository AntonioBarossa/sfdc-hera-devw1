public with sharing class HDT_LC_EscalationController {
    @AuraEnabled
    public static string getRecordData(String recordId) {
        Map<String,String> result = new Map<String,String> {};

        try {
            Id parentEntityId = (Id) recordId;
            String parentEntityName = parentEntityId.getSObjectType().getDescribe().getName();
            String recordTypeName;
            String parentEntityField;
            String showPriorityField;
            String respectCriteria;
            String errorMessage;

            switch on parentEntityName {
                when 'Account' {

                    HDT_QR_Account accList = new HDT_QR_Account();

                    Account acc = new Account();

                    acc = accList.getRecordById(parentEntityId, 'IsDigitalMarking__c'); 

                    if(acc.IsDigitalMarking__c == true){
                        recordTypeName = 'HDT_RT_EscalationAccountLead';
                        parentEntityField = 'Account__c';
                        showPriorityField = 'true';
                        respectCriteria = 'true';
                    }else{
                        recordTypeName = 'HDT_RT_EscalationAccountLead';
                        respectCriteria = 'false';
                        errorMessage = 'Il valore della Marcatura CLiente di questo account non soddisfa i criteri per la corretta visualizzazione dell\'Escalation';
                    }

                }
                when 'Case' {

                    Case caseList = new Case();
                    
                    caseList = [SELECT id, Status FROM Case WHERE Id = :parentEntityId WITH SECURITY_ENFORCED LIMIT 1];

                    if(caseList.Status == 'Bozza' || caseList.Status == 'In Lavorazione'){
                        recordTypeName = 'HDT_RT_EscalationCase';
                        parentEntityField = 'Case__c';
                        showPriorityField = 'false';
                        respectCriteria = 'true';
                    }else{
                        recordTypeName = 'HDT_RT_EscalationCase';
                        respectCriteria = 'false';
                        errorMessage = 'Il valore dello Stato di questo case non soddisfa i criteri per la corretta visualizzazione dell\'Escalation';
                    }

                }
                when 'Interaction__c' {

                    Interaction__c interactionList = new Interaction__c();

                    interactionList = [SELECT id, Status__c FROM Interaction__c WHERE Id = :parentEntityId WITH SECURITY_ENFORCED LIMIT 1];

                    if(interactionList.Status__c == 'Aperta'){
                        recordTypeName = 'HDT_RT_EscalationInteraction';
                        parentEntityField = 'Interaction__c';
                        showPriorityField = 'false';
                        respectCriteria = 'true';
                    }else{
                        recordTypeName = 'HDT_RT_EscalationInteraction';
                        respectCriteria = 'false';
                        errorMessage = 'Il valore dello Stato di questo interazione non soddisfa i criteri per la corretta visualizzazione dell\'Escalation';
                    }

                }
                when 'Lead' {
                    recordTypeName = 'HDT_RT_EscalationAccountLead';
                    parentEntityField = 'Lead__c';
                    showPriorityField = 'false';
                    respectCriteria = 'true';
                }
                when 'Opportunity' {
                    recordTypeName = 'HDT_RT_EscalationOpportunity';
                    parentEntityField = 'Opportunity__c';
                    showPriorityField = 'true';
                    respectCriteria = 'true';
                }
                when 'Order' {

                    Order orderList = new Order();

                    orderList = [SELECT id, Status FROM Order WHERE Id = :parentEntityId WITH SECURITY_ENFORCED LIMIT 1];

                    if(orderList.Status == 'Draft' || orderList.Status == 'In Lavorazione'){
                        recordTypeName = 'HDT_RT_EscalationOrder';
                        parentEntityField = 'Order__c';
                        showPriorityField = 'false';
                        respectCriteria = 'true';
                    }else{
                        recordTypeName = 'HDT_RT_EscalationOrder';
                        respectCriteria = 'false';
                        errorMessage = 'Il valore dello Stato di questo ordine non soddisfa i criteri per la corretta visualizzazione dell\'Escalation';
                    }

                }
                when else {
                    recordTypeName = 'HDT_RT_EscalationGeneric';
                    showPriorityField = 'true';
                    respectCriteria = 'true';
                }
            }
            
            String recordTypeId = Schema.SObjectType.wrts_prcgvr__Activity__c.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
            result.put('recordTypeId', recordTypeId);
            result.put('parentEntityField', parentEntityField);
            result.put('showPriorityField', showPriorityField);
            result.put('respectCriteria', respectCriteria);
            result.put('errorMessage', errorMessage);
        } catch (Exception e) {
            result.put('error', 'ERROR: ' + e.getMessage() + ' alla riga: ' + e.getLineNumber());
        }

        return JSON.serialize(result);
    }
}