public inherited sharing class HDT_UTL_SubscriptionProcess {

    private static List<Contract> contractToDelete = new List<Contract>();
    
    public static void adjustVasContractBeforeInsert(List<SBQQ__Subscription__c> newSubs){
        system.debug('******* adjustVasContractBeforeInsert');
        Map<Id, SBQQ__Subscription__c> itemToSub = new Map<Id, SBQQ__Subscription__c>();
        for(SBQQ__Subscription__c sub : newSubs){
            itemToSub.put(sub.SBQQ__OrderProduct__c, sub);
        }
        Map<Id, OrderItem> itemsMap = new Map<Id, OrderItem>([SELECT id, Order.OrderReference__c, Order.ContractReference__c, Order.ServicePoint__c, Order.RecordType.DeveloperName FROM OrderItem WHERE Id IN :itemToSub.keySet() AND (Order.OrderReference__c!=null OR Order.ContractReference__c!=null OR Order.RecordType.DeveloperName='HDT_RT_ScontiBonus' ) WITH Security_Enforced ]);
        list<OrderItem> items = itemsMap.values();
        Map<id, id> itemToOrderOffer = new Map<id, id>();
        Map<id, id> itemToContract = new Map<id, id>();
        Map<id, id> itemToServicePoint = new Map<id, id>();
        for(OrderItem item : items){
            if(item.Order.OrderReference__c!=null){
                itemToOrderOffer.put( item.Order.OrderReference__c, item.id);
            }else if(item.Order.ContractReference__c!=null){
                itemToContract.put(item.Order.ContractReference__c, item.id);
            }else{
                //bonus e sconti
                itemToServicePoint.put(item.Order.ServicePoint__c, item.id);
            }
        }

        system.debug(itemToOrderOffer.keySet());
        if(!itemToOrderOffer.isEmpty()){
            List<Contract> orderOfferContracts = [Select id, SBQQ__Order__c, ContractNumber from Contract where SBQQ__Order__c IN :itemToOrderOffer.keySet() WITH Security_Enforced];

            system.debug(orderOfferContracts);
            for(Contract c : orderOfferContracts){
                Id itemId = itemToOrderOffer.get(c.SBQQ__Order__c);
                SBQQ__Subscription__c sub = itemToSub.get(itemId);
                system.debug(sub);
                if(sub!=null && c.Id!= sub.SBQQ__Contract__c){
                    system.debug(c.ContractNumber);
                    contractToDelete.add(new Contract(Id=sub.SBQQ__Contract__c));//don't delete "old contract" if it's BonusSconti
                    sub.SBQQ__Contract__c=c.Id;
                }   
            }
        }
        if(!itemToContract.isEmpty()){
            for(id contractId : itemToContract.keySet()){
                SBQQ__Subscription__c sub = itemToSub.get(itemToContract.get(contractId));
                if(sub!=null && contractId != sub.SBQQ__Contract__c){
                    contractToDelete.add(new Contract(Id=sub.SBQQ__Contract__c));
                    sub.SBQQ__Contract__c=contractId;
                } 
            }
        }
        if(!itemToServicePoint.isEmpty()){//bonusSconti
            List<Contract> servicePointContracts = [Select id, SBQQ__Order__r.ServicePoint__c, ContractNumber from Contract where SBQQ__Order__r.ServicePoint__c IN :itemToServicePoint.keySet() AND SBQQ__Order__r.ServicePoint__c!=NULL WITH Security_Enforced];
            system.debug(servicePointContracts);
            for(Contract c : servicePointContracts){
                Id itemId = itemToServicePoint.get(c.SBQQ__Order__r.ServicePoint__c);
                SBQQ__Subscription__c sub = itemToSub.get(itemId);
                system.debug(sub);
                if(sub!=null && c.Id!= sub.SBQQ__Contract__c){
                    system.debug(c.ContractNumber);
                    //don't delete "old contract" if it's BonusSconti
                    sub.SBQQ__Contract__c=c.Id;
                }   
            }
        }
        
    }

    public static void deleteContractsOnAfterInsert(){
        if(!contractToDelete.isEmpty()){
            HDT_UTL_DatabaseService.deleteSObject(contractToDelete);
        }
    }

}
