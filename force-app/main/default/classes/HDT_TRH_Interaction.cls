public with sharing class HDT_TRH_Interaction extends HDT_TRH_TriggerHandler {
    protected override void beforeUpdate() {
        Map<Id,Interaction__c> interactionsMap = (Map<Id,Interaction__c>) trigger.newMap;
        Map<Id,Interaction__c> oldInteractionsMap = (Map<Id,Interaction__c>) trigger.oldMap;
        Set<Id> idSet = new Set<Id>();

        for(Interaction__c interaction : interactionsMap.values()) {
            if(interaction.Status__c == 'Chiusa' && oldInteractionsMap.get(interaction.Id).Status__c != interaction.Status__c) {
                idSet.add(interaction.Id);
            }
        }

        /*for(wrts_prcgvr__Activity__c activity : [SELECT Id, Name, Interaction__c FROM wrts_prcgvr__Activity__c WHERE wrts_prcgvr__Status__c = 'Aperta' AND Interaction__c IN :idSet WITH SECURITY_ENFORCED]) {
            interactionsMap.get(activity.Interaction__c).addError('Impossibile chiudere l\'Interazione corrente, in quanto associata ad Attività ancora aperte.');
        }*/
    }

    protected override void beforeInsert() {
        HDT_UTL_Utils.setUsersField(trigger.new);
    }
}
