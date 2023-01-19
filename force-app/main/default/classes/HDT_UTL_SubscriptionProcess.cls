public inherited sharing class HDT_UTL_SubscriptionProcess {

    private static List<Contract> contractToDelete = new List<Contract>();
    
    public static void adjustVasContractBeforeInsert(List<SBQQ__Subscription__c> newSubs){
        system.debug(LoggingLevel.DEBUG ,'******* adjustVasContractBeforeInsert');
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
                OR Order.RecordType.DeveloperName = 'HDT_RT_AgevolazioniAmbiente'
                OR Order.RecordType.DeveloperName = 'HDT_RT_ModificaTariffaRimozione'
                OR 
                    (
                    Order.RecordType.DeveloperName='HDT_RT_VAS' 
                    AND (Order.OrderReference__c!=null OR Order.ContractReference__c!=null)
                    ) 
                ) 
            WITH Security_Enforced ]);
        list<OrderItem> items = itemsMap.values();
        
        /**@frpanico 27/12/2021
         * Trasformate Map<Id, Id> in Map<Id, List<Id>>
         * Per la ricostruzione della subscription
         */

        Map<Id, List<Id>> itemToOrderOffer = new Map<Id, List<Id>>();
        Map<Id, List<Id>> itemToContract = new Map<Id, List<Id>>();
        Map<Id, List<Id>> itemToServicePoint = new Map<Id, List<Id>>();
        
        /**@frpanico 22/12/2021
         * Dichiarata Map<String, Map<Id, Id>>
         * per ricostruire la struttura della subscription
         */
        /* @frpanico 23/12/2021
        * Trovato bug per cui se due OrderItem creano Subscription
        * Si sovrascrivono se riferiti allo stesso order, contrac o service point
        */
        Map<String, Map<Id, List<Id>>> itemsMapToSub = new Map<String, Map<Id,List<Id>>>();

        for(OrderItem item : items){
            if(item.Order.OrderReference__c!=null){
                if(itemToOrderOffer.isEmpty() || !itemToOrderOffer.containsKey(item.Order.OrderReference__c))
                {
                    itemToOrderOffer.put(item.Order.OrderReference__c, new List<Id>());
                }
                itemToOrderOffer.get(item.Order.OrderReference__c).add(item.Id);
            }
            else if(item.Order.ContractReference__c != null)
            {
                if(itemToContract.isEmpty() || !itemToContract.containsKey(item.Order.ContractReference__c))
                {
                    itemToContract.put(item.Order.ContractReference__c, new List<Id>());
                }
                itemToContract.get(item.Order.ContractReference__c).add(item.Id);
            }
            else
            {
                /* bonus e sconti */
                if(itemToServicePoint.isEmpty() || !itemToServicePoint.containsKey(item.Order.ServicePoint__c))
                {
                    itemToServicePoint.put(item.Order.ServicePoint__c, new List<Id>());
                }
                itemToServicePoint.get(item.Order.ServicePoint__c).add(item.Id);
            }
                //itemToOrderOffer.put( item.Order.OrderReference__c, item.id);
            //}else if(item.Order.ContractReference__c!=null){
                //itemToContract.put(item.Order.ContractReference__c, item.id);
            //}else{

                //itemToServicePoint.put(item.Order.ServicePoint__c, item.id);
            //}
        }

        /**@frpanico 22/12/2021
         * Popola la Map<String,Map<Id,List<Id>>> 
         * per ricostruire la struttura
         */
        
        itemsMapToSub.put('servicePoint', itemToServicePoint);
        itemsMapToSub.put('contract', itemToContract);
        itemsMapToSub.put('order', itemToOrderOffer);
        
        System.debug(LoggingLevel.DEBUG,itemToOrderOffer.keySet());
        if(!itemToOrderOffer.isEmpty())
        {
            List<Contract> orderOfferContracts = [Select id, SBQQ__Order__c, ContractNumber from Contract where SBQQ__Order__c IN :itemToOrderOffer.keySet() WITH Security_Enforced];

            system.debug(LoggingLevel.DEBUG, orderOfferContracts);
            for(Contract c : orderOfferContracts)
            {
                List<Id> itemIds = itemToOrderOffer.get(c.SBQQ__Order__c);
                for(Id itemId : itemIds)
                {
                    SBQQ__Subscription__c sub = itemToSub.get(itemId);
                    if(sub != null && c.Id != sub.SBQQ__Contract__c)
                    {
                        System.debug(LoggingLevel.DEBUG ,'Contract Number ' + c.ContractNumber);
                        contractToDelete.add(new Contract(Id = sub.SBQQ__Contract__c));
                        sub.SBQQ__Contract__c = c.Id;
                    }
                }
            }
        }
        if(!itemToContract.isEmpty())
        {
            for(id contractId : itemToContract.keySet())
            {
                for(Id itemId : itemToContract.get(contractId))
                {
                    SBQQ__Subscription__c sub = itemToSub.get(itemId);
                    if(sub!=null && contractId != sub.SBQQ__Contract__c){
                        contractToDelete.add(new Contract(Id=sub.SBQQ__Contract__c));
                        sub.SBQQ__Contract__c=contractId;
                    }
                }
            }
        }  
        if(!itemToServicePoint.isEmpty()){//bonusSconti
            List<Contract> servicePointContracts = [Select id, SBQQ__Order__r.ServicePoint__c, ContractNumber from Contract where SBQQ__Order__r.ServicePoint__c IN :itemToServicePoint.keySet() AND SBQQ__Order__r.ServicePoint__c!=NULL WITH Security_Enforced];
            system.debug(LoggingLevel.DEBUG ,servicePointContracts);
            for(Contract c : servicePointContracts)
            {
                List<Id> itemIds = itemToServicePoint.get(c.SBQQ__Order__r.ServicePoint__c);
                for(Id itemId : itemIds)
                {
                    SBQQ__Subscription__c sub = itemToSub.get(itemId);
                    if(sub!=null && c.Id!= sub.SBQQ__Contract__c){
                        system.debug(LoggingLevel.DEBUG ,c.ContractNumber);
                        //don't delete "old contract" if it's BonusSconti
                        sub.SBQQ__Contract__c=c.Id;
                    }
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
    private static void recreateSubscriptionStructure(Map<Id, SBQQ__Subscription__c> itemToSub, Map<String, Map<id, List<id>>> itemsMapToSub)
    {
        /* Get "Parent" subscription
        * Al momento viene gestito il caso di
        * "Aggiunta Bonus e Sconti"
        */

        //Set<String> allowedProcess = new Set<String>{'HDT_RT_CambioOfferta'};        

        Map<Id, List<Id>> itemToServicePoint = itemsMapToSub.get('servicePoint');
        Map<Id, List<Id>> itemToContract = itemsMapToSub.get('contract');
        Map<Id, List<Id>> itemToOrderOffer = itemsMapToSub.get('order');

        SObjectAccessDecision securityDecision = 
            Security.stripInaccessible(accessType.READABLE, 
            [SELECT Id,
            SBQQ__Product__c,
            SBQQ__Contract__r.SBQQ__Order__r.ServicePoint__c,
            SBQQ__Contract__c,
            SBQQ__Contract__r.SBQQ__Order__c
            FROM SBQQ__Subscription__c
            WHERE SBQQ__Product__r.Family = 'Offerta commerciale' 
            AND(
                SBQQ__Contract__r.SBQQ__Order__r.ServicePoint__c IN :itemToServicePoint.keySet()
                OR SBQQ__Contract__c IN :itemToContract.keySet()
                OR SBQQ__Contract__r.SBQQ__Order__c IN :itemToOrderOffer.keySet()
                )
            ]);
        for(SBQQ__Subscription__c parentSub : (List<SBQQ__Subscription__c>)securityDecision.getRecords())
        {
            List<SBQQ__Subscription__c> childSubs = new List<SBQQ__Subscription__c>();

            
            if(!itemToServicePoint.isEmpty())
            {   
                for(Id itemId : itemToServicePoint.get(parentSub.SBQQ__Contract__r.SBQQ__Order__r.ServicePoint__c))
                {
                    if(itemToSub.get(itemId) != null)
                    {
                        childSubs.add(itemToSub.get(itemId));
                    }
                }
            }
            else if(!itemToContract.isEmpty())
            {
                for(Id itemId : itemToContract.get(parentSub.SBQQ__Contract__c))
                {
                    if(itemToSub.get(itemId) != null)
                    {
                        childSubs.add(itemToSub.get(itemId));
                    }
                }
            }

            else if(!itemToOrderOffer.isEmpty())
            {
                for(Id itemId : itemToOrderOffer.get(parentSub.SBQQ__Contract__r.SBQQ__Order__c))
                {
                    if(itemToSub.get(itemId) != null)
                    {
                        childSubs.add(itemToSub.get(itemId));
                    }
                }

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

    /**
    * @author Marco Arci (marco.arci@webresults.it)
    * @date 17/01/2023
    * @description closeSubscriptionsToday - chiusura subscription per processo di cessazione 
    *              metodo richiamato nell'HDT_UTL_HerokuPostSalesManager
    * @param contractId - Id del contratto
    * @return Void
    */
    public static void closeSubscriptionsToday(Id contractId){
        List<SBQQ__Subscription__c> toCloseSub = [  SELECT Id, SBQQ__TerminatedDate__c, SBQQ__EndDate__c
                                                    FROM SBQQ__Subscription__c
                                                    WHERE SBQQ__Contract__c =: contractId];
        if(toCloseSub != null){
            DateTime nowDateTime = DateTime.now();
            Date closingDate = date.newinstance(nowDateTime.year(), nowDateTime.month(), nowDateTime.day()-1);
            for(SBQQ__Subscription__c currentSub : toCloseSub){
                currentSub.SBQQ__TerminatedDate__c = closingDate;
            }
            HDT_UTL_DatabaseService.updateSObject(toCloseSub);
        }
    }

}