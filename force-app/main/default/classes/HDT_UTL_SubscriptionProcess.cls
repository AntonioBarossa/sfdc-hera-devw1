public inherited sharing class HDT_UTL_SubscriptionProcess {
    
    public static void adjustVasContractBeforeInsert(List<SBQQ__Subscription__c> newSubs){
        Map<Id, SBQQ__Subscription__c> contractToSub = new Map<Id, SBQQ__Subscription__c>();
        for(SBQQ__Subscription__c sub : newSubs){
            contractToSub.put(sub.SBQQ__Contract__c, sub);
        }
        List<Contract> lc = [SELECT id, SBQQ__Order__r.OrderReference__c FROM Contract WHERE Id IN :contractToSub.keySet() AND SBQQ__Order__r.OrderReference__c!=null WITH Security_Enforced ];
        for(Contract c : lc){
            contractToSub.get(c.Id).SBQQ__Contract__c=c.SBQQ__Order__r.OrderReference__c;
        }
    }
}
