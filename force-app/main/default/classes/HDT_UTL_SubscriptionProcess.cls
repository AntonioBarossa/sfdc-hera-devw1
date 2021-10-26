public inherited sharing class HDT_UTL_SubscriptionProcess {

    private static List<Contract> contractToDelete = new List<Contract>();
    
    public static void adjustVasContractBeforeInsert(List<SBQQ__Subscription__c> newSubs){
        system.debug('******* adjustVasContractBeforeInsert');
        Map<Id, SBQQ__Subscription__c> itemToSub = new Map<Id, SBQQ__Subscription__c>();
        for(SBQQ__Subscription__c sub : newSubs){
            itemToSub.put(sub.SBQQ__OrderProduct__c, sub);
        }
        list<OrderItem> items = [SELECT id, Order.OrderReference__c FROM OrderItem WHERE Id IN :itemToSub.keySet() AND Order.OrderReference__c!=null WITH Security_Enforced ];
        Map<id, id> itemToOrderOffer = new Map<id, id>();
        for(OrderItem item : items){
            itemToOrderOffer.put( item.Order.OrderReference__c, item.id);
        }
        if(itemToOrderOffer.isEmpty()){
            return;
        }
        system.debug(itemToOrderOffer.keySet());
        List<Contract> orderOfferContracts = [Select id, SBQQ__Order__c, ContractNumber from Contract where SBQQ__Order__c IN :itemToOrderOffer.keySet() WITH Security_Enforced];

        system.debug(orderOfferContracts);
        for(Contract c : orderOfferContracts){
            SBQQ__Subscription__c sub = itemToSub.get(itemToOrderOffer.get(c.SBQQ__Order__c));
            system.debug(sub);
            if(sub!=null && c.Id!= sub.SBQQ__Contract__c){
                system.debug(c.ContractNumber);
                contractToDelete.add(new Contract(Id=sub.SBQQ__Contract__c));
                sub.SBQQ__Contract__c=c.Id;
            }   
        }
    }

    public static void deleteContractsOnAfterInsert(){
        if(!contractToDelete.isEmpty()){
            HDT_UTL_DatabaseService.deleteSObject(contractToDelete);
        }
    }

}
