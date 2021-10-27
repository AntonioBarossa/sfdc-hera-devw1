public inherited sharing class HDT_UTL_SubscriptionProcess {
    
    public static void adjustVasContractBeforeInsert(List<SBQQ__Subscription__c> newSubs){
        Map<Id, SBQQ__Subscription__c> contractToSub = new Map<Id, SBQQ__Subscription__c>();
        for(SBQQ__Subscription__c sub : newSubs){
            contractToSub.put(sub.SBQQ__Contract__c, sub);
        }
        List<Contract> relatedContracts = [SELECT id, SBQQ__Order__r.OrderReference__c FROM Contract WHERE Id IN :contractToSub.keySet() AND SBQQ__Order__r.OrderReference__c!=null WITH Security_Enforced ];
        Map<id, id> fakeContrToOrderOffer = new Map<id, id>();
        for(Contract c : relatedContracts){
            fakeContrToOrderOffer.put( c.SBQQ__Order__r.OrderReference__c, c.id);
        }
        List<Contract> orderOfferContracts = [Select id, SBQQ__Order__c from Contract where SBQQ__Order__c IN :fakeContrToOrderOffer.keySet() WITH Security_Enforced];
        
        List<Contract> contractToDelete = new List<Contract>();
        for(Contract c : orderOfferContracts){
            SBQQ__Subscription__c sub = contractToSub.get(fakeContrToOrderOffer.get(c.id));
            if(sub!=null){
                contractToDelete.add(new Contract(Id=sub.SBQQ__Contract__c));
                sub.SBQQ__Contract__c=c.Id;
            }   
        }
        if(!contractToDelete.isEmpty()) HDT_UTL_DatabaseService.deleteSObject(contractToDelete);
    }
}
