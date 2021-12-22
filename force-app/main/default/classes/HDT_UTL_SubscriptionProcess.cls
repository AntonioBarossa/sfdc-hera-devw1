public inherited sharing class HDT_UTL_SubscriptionProcess {

    private static List<Contract> contractToDelete = new List<Contract>();
    
    public static void adjustVasContractBeforeInsert(List<SBQQ__Subscription__c> newSubs){
        system.debug('******* adjustVasContractBeforeInsert');
        Map<Id, SBQQ__Subscription__c> itemToSub = new Map<Id, SBQQ__Subscription__c>();
        for(SBQQ__Subscription__c sub : newSubs){
            itemToSub.put(sub.SBQQ__OrderProduct__c, sub);
        }
        Map<Id, OrderItem> itemsMap = new Map<Id, OrderItem>(
            [SELECT id, 
            Order.OrderReference__c, 
            Order.ContractReference__c, 
            Order.ServicePoint__c, 
            Order.RecordType.DeveloperName 
            FROM OrderItem 
            WHERE Id IN :itemToSub.keySet() 
            AND (Order.RecordType.DeveloperName='HDT_RT_ScontiBonus' 
                OR 
                    (
                    Order.RecordType.DeveloperName='HDT_RT_VAS' 
                    AND (Order.OrderReference__c!=null OR Order.ContractReference__c!=null)
                    ) 
                ) 
            WITH Security_Enforced ]);
        list<OrderItem> items = itemsMap.values();
        Map<id, id> itemToOrderOffer = new Map<id, id>();
        Map<id, id> itemToContract = new Map<id, id>();
        Map<id, id> itemToServicePoint = new Map<id, id>();
        /**@frpanico 22/12/2021
         * Dichiarata Map<String, Map<Id, Id>>
         * per ricostruire la struttura della subscription
         */
        Map<String, Map<Id, Id>> itemsMapToSub = new Map<String, Map<Id,Id>>();
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

        /**@frpanico 22/12/2021
         * Popola la Map<String,Map<Id,Id>> 
         * per ricostruire la struttura
         */
        itemsMapToSub.put('servicePoint', itemToServicePoint);
        itemsMapToSub.put('contract', itemToContract);
        itemsMapToSub.put('order', itemToOrderOffer);

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

        recreateSubscriptionStructure(itemToSub, itemsMapToSub);
        
    }

    /*@frpanico 20/12/2021
    * Aggiunto Modulo
    * Ricostruisce la struttura della subscription 
    * nel caso di: "Cambio Offerta"
    */
    private static void recreateSubscriptionStructure(Map<Id, SBQQ__Subscription__c> itemToSub, Map<String, Map<id, id>> itemsMapToSub)
    {
        /* Get "Parent" subscription
        * Al momento viene gestito il caso di
        * "Aggiunta Bonus e Sconti"
        */

        //Set<String> allowedProcess = new Set<String>{'HDT_RT_CambioOfferta'};        

        Map<Id, Id> itemToServicePoint = itemsMapToSub.get('servicePoint');
        Map<Id, Id> itemToContract = itemsMapToSub.get('contract');
        Map<Id, Id> itemToOrderOffer = itemsMapToSub.get('order');

        SObjectAccessDecision securityDecision = 
            Security.stripInaccessible(accessType.READABLE, 
            [SELECT Id,
            SBQQ__Product__c,
            SBQQ__Contract__r.SBQQ__Order__r.ServicePoint__c,
            SBQQ__Contract__c,
            SBQQ__Contract__r.SBQQ__Order__c
            FROM SBQQ__Subscription__c
            WHERE SBQQ__Contract__r.SBQQ__Order__r.ServicePoint__c IN :itemToServicePoint.keySet()
            OR SBQQ__Contract__c IN :itemToContract.keySet()
            OR SBQQ__Contract__r.SBQQ__Order__c IN :itemToOrderOffer.keySet()]);
        for(SBQQ__Subscription__c parentSub : (List<SBQQ__Subscription__c>)securityDecision.getRecords())
        {
            List<SBQQ__Subscription__c> childSubs = new List<SBQQ__Subscription__c>();

            if(!itemToServicePoint.isEmpty())
            {
                childSubs.add(itemToSub.get(itemToServicePoint.get(parentSub.SBQQ__Contract__r.SBQQ__Order__r.ServicePoint__c)));
            }
            else if(!itemToContract.isEmpty())
            {
                childSubs.add(itemToSub.get(itemToContract.get(parentSub.SBQQ__Contract__c)));
            }
            else if(!itemToContract.isEmpty())
            {
                childSubs.add(itemToSub.get(itemToOrderOffer.get(parentSub.SBQQ__Contract__r.SBQQ__Order__c)));
            }

            for(SBQQ__Subscription__c sub : childSubs)
            {
                sub.SBQQ__RequiredByProduct__c = parentSub.SBQQ__Product__c;
                sub.SBQQ__RequiredById__c = parentSub.Id;
                sub.SBQQ__RootId__c = parentSub.Id;
            }

        }
        
    }

    public static void deleteContractsOnAfterInsert(){
        if(!contractToDelete.isEmpty()){
            HDT_UTL_DatabaseService.deleteSObject(contractToDelete);
        }
    }

}