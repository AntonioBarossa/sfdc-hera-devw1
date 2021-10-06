public with sharing class HDT_LC_EscalationController {
    @AuraEnabled
    public static string getRecordData(String recordId) {
        Map<String,String> result = new Map<String,String> {};

        try {
            Id parentEntityId = (Id) recordId;
            String parentEntityName = parentEntityId.getSObjectType().getDescribe().getName();
            String recordTypeName;
            String parentEntityField;

            switch on parentEntityName {
                when 'Account' {
                    recordTypeName = 'HDT_RT_EscalationAccountLead';
                    parentEntityField = 'Account__c';
                }
                when 'Case' {
                    recordTypeName = 'HDT_RT_EscalationCase';
                    parentEntityField = 'Case__c';
                }
                when 'Interaction__c' {
                    recordTypeName = 'HDT_RT_EscalationInteraction';
                    parentEntityField = 'Interaction__c';
                }
                when 'Lead' {
                    recordTypeName = 'HDT_RT_EscalationAccountLead';
                    parentEntityField = 'Lead__c';
                }
                when 'Opportunity' {
                    recordTypeName = 'HDT_RT_EscalationOpportunity';
                    parentEntityField = 'Opportunity__c';
                }
                when 'Order' {
                    recordTypeName = 'HDT_RT_EscalationOrder';
                    parentEntityField = 'Order__c';
                }
                when else {
                    recordTypeName = 'HDT_RT_EscalationGeneric';
                }
            }
            
            String recordTypeId = Schema.SObjectType.wrts_prcgvr__Activity__c.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
            result.put('recordTypeId', recordTypeId);
            result.put('parentEntityField', parentEntityField);
        } catch (Exception e) {
            result.put('error', 'ERROR: ' + e.getMessage() + ' alla riga: ' + e.getLineNumber());
        }

        return JSON.serialize(result);
    }
}