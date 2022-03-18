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

            switch on parentEntityName {
                when 'Account' {
                    recordTypeName = 'HDT_RT_EscalationAccountLead';
                    parentEntityField = 'Account__c';
                    showPriorityField = 'true';
                }
                when 'Case' {
                    recordTypeName = 'HDT_RT_EscalationCase';
                    parentEntityField = 'Case__c';
                    showPriorityField = 'false';
                }
                when 'Interaction__c' {
                    recordTypeName = 'HDT_RT_EscalationInteraction';
                    parentEntityField = 'Interaction__c';
                    showPriorityField = 'false';
                }
                when 'Lead' {
                    recordTypeName = 'HDT_RT_EscalationAccountLead';
                    parentEntityField = 'Lead__c';
                    showPriorityField = 'false';
                }
                when 'Opportunity' {
                    recordTypeName = 'HDT_RT_EscalationOpportunity';
                    parentEntityField = 'Opportunity__c';
                    showPriorityField = 'true';
                }
                when 'Order' {
                    recordTypeName = 'HDT_RT_EscalationOrder';
                    parentEntityField = 'Order__c';
                    showPriorityField = 'false';
                }
                when else {
                    recordTypeName = 'HDT_RT_EscalationGeneric';
                    showPriorityField = 'true';
                }
            }
            
            String recordTypeId = Schema.SObjectType.wrts_prcgvr__Activity__c.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
            result.put('recordTypeId', recordTypeId);
            result.put('parentEntityField', parentEntityField);
            result.put('showPriorityField', showPriorityField);
        } catch (Exception e) {
            result.put('error', 'ERROR: ' + e.getMessage() + ' alla riga: ' + e.getLineNumber());
        }

        return JSON.serialize(result);
    }
}