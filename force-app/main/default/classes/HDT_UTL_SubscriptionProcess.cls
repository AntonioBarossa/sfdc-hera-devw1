public inherited sharing class HDT_UTL_SubscriptionProcess {

    @TestVisible private static List<Contract> contractToDelete = new List<Contract>();
    @TestVisible private static List<Contract> contractToUpdate = new List<Contract>();
    @TestVisible private static List<SBQQ__Subscription__c> subscriptionToUpdate = new List<SBQQ__Subscription__c>();
    @TestVisible private static List<Sobject> sobjsToUpdateAsync = new List<Sobject>();
    @TestVisible private static List<SBQQ__Subscription__c> subscriptionToDelete = new List<SBQQ__Subscription__c>();
    private static HDT_UTL_ContractSubscriptionRelocation subsRelocation = new HDT_UTL_ContractSubscriptionRelocation();
    private static Boolean isFinalizerAttached = false;

    public class HDT_QBL_Finalizer implements Finalizer {
        List<Contract> contrsToDelete;
        List<SBQQ__Subscription__c> subsToDelete;
        List<Sobject> sobjsToUpdate;

        @TestVisible
        HDT_QBL_Finalizer(List<Contract> contrsToDelete, List<SBQQ__Subscription__c> subsToDelete, List<Sobject> sobjsToUpdate){
            this.contrsToDelete = contrsToDelete;
            this.subsToDelete = subsToDelete;
            this.sobjsToUpdate = sobjsToUpdate;
        }

        public void execute(FinalizerContext ctx){
            //se queueable success chiamare servizio deda con case
            if(!this.sobjsToUpdate.isEmpty()){
                Map<Id, Sobject> removeDuplicates = new Map<Id, Sobject>(this.sobjsToUpdate);
                HDT_UTL_DatabaseService.updateSObject(removeDuplicates.values());
            }
            if(!this.subsToDelete.isEmpty()){
                Map<Id, SBQQ__Subscription__c> removeDuplicates = new Map<Id, SBQQ__Subscription__c>(this.subsToDelete);
                HDT_UTL_DatabaseService.deleteSObject(removeDuplicates.values());
            }
            if(!this.contrsToDelete.isEmpty()){
                Map<Id, Contract> removeDuplicates = new Map<Id, Contract>(this.contrsToDelete);
                HDT_UTL_DatabaseService.deleteSObject(removeDuplicates.values());
            }
        }
    }
    /**
     * Il Metodo si occupa di estrarre l'Id della Subscription di tipo Offerta commerciale e la applica alle Subscriptions
     * di tipo Related Product che hanno il RequiredBy null
     */
    public static void adjustLookup(List<SBQQ__Subscription__c> newSubs,Map<Id,SObject> oldSubMap){
        Set<Id> contractSet = new Set<Id>();
        List<SBQQ__Subscription__c> subsToAdjustList = new List<SBQQ__Subscription__c>();
        for(SBQQ__Subscription__c sub : newSubs){
            SBQQ__Subscription__c oldSub = (SBQQ__Subscription__c)oldSubMap.get(sub.Id);
            Id oldRootId = oldSub.SBQQ__RootId__c;
            Id newRootId = sub.SBQQ__RootId__c;
            if(String.isBlank(oldRootId) && String.isNotBlank(newRootId)){
                Boolean isOption = 'Related Product'.equalsIgnoreCase(sub.SBQQ__OptionType__c)? true : false;
                Boolean isRequiredBlank = String.isBlank(sub.SBQQ__RequiredById__c);
                if(isOption && isRequiredBlank){
                    subsToAdjustList.add(sub);
                    contractSet.add(sub.SBQQ__Contract__c);
                }
            }
        }
        if(!contractSet.isEmpty()){
            List<SBQQ__Subscription__c> subOfferList = [SELECT Id,SBQQ__Product__c,SBQQ__Contract__c FROM SBQQ__Subscription__c WHERE SBQQ__Contract__c IN:contractSet  AND SBQQ__Product__r.Family = 'Offerta commerciale'];
            Map<Id,RootLookup> contractRootLookupMap = new Map<Id,RootLookup>();
            for(SBQQ__Subscription__c singleSub : subOfferList){
                RootLookup rootLookup = new RootLookup(singleSub.Id, singleSub.SBQQ__Product__c);
                contractRootLookupMap.put(singleSub.SBQQ__Contract__c, rootLookup);
            }
            for(SBQQ__Subscription__c sub : subsToAdjustList){
                RootLookup rootLookup = contractRootLookupMap.get(sub.SBQQ__Contract__c);
                if(rootLookup != null){
                    sub.SBQQ__RootId__c = rootLookup.rootId;
                    sub.SBQQ__RequiredById__c = rootLookup.rootId;
                    sub.SBQQ__RequiredByProduct__c  = rootLookup.productId;
                }
            }
        }
    }
    public static void alignFields(List<SBQQ__Subscription__c> newSubs){
        Map<Id, SBQQ__Subscription__c> itemToSub = new Map<Id, SBQQ__Subscription__c>();
        for(SBQQ__Subscription__c sub : newSubs){
            itemToSub.put(sub.SBQQ__OrderProduct__c, sub);
        }

        Map<Id, OrderItem> itemsMap = new Map<Id, OrderItem>(
            [SELECT id, 
            Order.OrderReference__c, 
            Order.ContractReference__c, 
            Order.ServicePoint__c, 
            Order.Commodity__c,
            Order.EffectiveDate__c, 
            Order.RecordType.DeveloperName 
            FROM OrderItem 
            WHERE Id IN :itemToSub.keySet()
            WITH Security_Enforced ]);

        for(SBQQ__Subscription__c sub : newSubs){
            OrderItem item = itemsMap.get(sub.SBQQ__OrderProduct__c);
            if(item == null ){   continue;   }
            if('Ambiente'.equalsIgnoreCase(item?.Order?.Commodity__c) && item?.Order?.EffectiveDate__c!=null){      
                sub.SBQQ__SubscriptionStartDate__c = item.Order.EffectiveDate__c;
                if(sub.SBQQ__Quantity__c < 0){
                    Date effDateMinusOne = item.Order.EffectiveDate__c.addDays(-1);
                    sub.SBQQ__SubscriptionStartDate__c = effDateMinusOne;
                    sub.SBQQ__SubscriptionEndDate__c = effDateMinusOne;
                    sub.SBQQ__TerminatedDate__c = effDateMinusOne;
                }
            }
        }
    }


    public static void checkSubsToTerminate(List<SBQQ__Subscription__c> newSubs){
        Set<Id> contrsId = new Set<Id>();
        Set<Id> prodsId = new Set<Id>();
        Map<String, SBQQ__Subscription__c> negativeQuantitySubsToTerminate = new Map<String, SBQQ__Subscription__c>();
        for(SBQQ__Subscription__c sub : newSubs){
            if(sub.SBQQ__Quantity__c < 0){
                contrsId.add(sub.SBQQ__Contract__c);
                prodsId.add(sub.SBQQ__Product__c);
                negativeQuantitySubsToTerminate.put(String.valueOf(sub.SBQQ__Contract__c)+String.valueOf(sub.SBQQ__Product__c), sub);
            }
        }

        if(contrsId.isEmpty() || prodsId.isEmpty()){        return;         }

        for(SBQQ__Subscription__c relatedSub :  [   SELECT id, SBQQ__Contract__c, SBQQ__Product__c
                                                    FROM SBQQ__Subscription__c 
                                                    WHERE SBQQ__Contract__c IN :contrsId
                                                    AND SBQQ__Product__c IN :prodsId
                                                    AND SBQQ__Quantity__c > 0
                                                    WITH SECURITY_ENFORCED
                                                ]
        ){
            SBQQ__Subscription__c negativeSub = negativeQuantitySubsToTerminate.get(String.valueOf(relatedSub.SBQQ__Contract__c)+String.valueOf(relatedSub.SBQQ__Product__c));
            if(negativeSub == null){        continue;       }

            subscriptionToDelete.add(new SBQQ__Subscription__c(Id=negativeSub.Id));
            relatedSub.SBQQ__SubscriptionEndDate__c = negativeSub.SBQQ__SubscriptionEndDate__c;
            relatedSub.SBQQ__TerminatedDate__c = negativeSub.SBQQ__SubscriptionEndDate__c;
            sobjsToUpdateAsync.add(relatedSub);
        }
    }

    public static void fakeMoveOutMoveInForOffers(List<SBQQ__Subscription__c> newSubs){
        Map<Id, SBQQ__Subscription__c> itemToSub = new Map<Id, SBQQ__Subscription__c>();
        for(SBQQ__Subscription__c sub : newSubs){
            itemToSub.put(sub.SBQQ__OrderProduct__c, sub);
        }
        Map<Id, OrderItem> itemsMap = new Map<Id, OrderItem>(
            [
                SELECT id, 
                Order.OrderReference__c, 
                Order.ContractReference__c, 
                Order.ServicePoint__c, 
                Order.ContractReference__r.SAPContractCode__c,
                Order.SapContractCode__c,
                Order.EffectiveDate__c,
                Order.RecordTypeId,
                Order.RecordType.DeveloperName 
                FROM OrderItem 
                WHERE Id IN :itemToSub.keySet()
                WITH Security_Enforced 
            ]
        );


        List<SBQQ__Subscription__c> subsToMove = new List<SBQQ__Subscription__c>();
        Set<Id> oldOfferContracts = new Set<Id>();
        for(SBQQ__Subscription__c sub : newSubs){
            OrderItem item = itemsMap.get(sub.SBQQ__OrderProduct__c);
            if(subsRelocation.checkConditions(item?.Order, item?.Order?.SapContractCode__c)){
                subsToMove.add(sub);
                oldOfferContracts.add(item.Order.ContractReference__c);
            }
        }

        Map<String, List<Sobject>> sobjectsToDml = subsRelocation.moveSubscriptionOffers( subsToMove, oldOfferContracts, itemsMap );
        if(sobjectsToDml?.get('deleteContracts')?.isEmpty() == false){
            contractToDelete.addAll((List<Contract>) sobjectsToDml?.get('deleteContracts'));
        }
        if(sobjectsToDml?.get('updateContracts')?.isEmpty() == false){
            contractToUpdate.addAll((List<Contract>) sobjectsToDml?.get('updateContracts'));
        }
        if(sobjectsToDml?.get('updateSubs')?.isEmpty() == false){
            subscriptionToUpdate.addAll((List<SBQQ__Subscription__c>) sobjectsToDml?.get('updateSubs'));
        }
    }
    
    /**
     * Questo metodo serve solo per i VAS venduti su Contratti Attivi
     * In Caso di Amend o Contratti generati da una quote comune a piu order (Cambio Offerta + Analisi Consumi), 
     * il CPQ non genera un contratto e associa automaticamente le subscriptions sotto il contratto corretto
     * **/
    public static void adjustVasContractBeforeInsert(List<SBQQ__Subscription__c> newSubs){
        system.debug(LoggingLevel.DEBUG ,'******* adjustVasContractBeforeInsert');
        Map<Id, SBQQ__Subscription__c> itemToSub = new Map<Id, SBQQ__Subscription__c>();
        for(SBQQ__Subscription__c sub : newSubs){
            itemToSub.put(sub.SBQQ__OrderProduct__c, sub);
        }
        /* Modificata query per includere nella query del recordtype HDT_RT_VAS la casistica dell'analisi consumi */
        Map<Id, OrderItem> itemsMap = new Map<Id, OrderItem>(
            [SELECT id, 
            Order.OrderReference__c, 
            Order.ContractReference__c, 
            Order.ServicePoint__c, 
            Order.RecordType.DeveloperName,
            Order.SBQQ__Quote__r.IsFromVasSection__c 
            FROM OrderItem 
            WHERE 
                Id IN :itemToSub.keySet() 
            /*AND (
				Order.RecordType.DeveloperName='HDT_RT_ScontiBonus' OR 
				Order.RecordType.DeveloperName = 'HDT_RT_AgevolazioniAmbiente'
                OR Order.RecordType.DeveloperName = 'HDT_RT_ModificaTariffaRimozione'
                OR 
                    (
                    Order.RecordType.DeveloperName='HDT_RT_VAS' 
                    AND (Order.OrderReference__c!=null OR Order.ContractReference__c!=null OR Order.VasSubtype__c = 'Analisi Consumi')
                    ) 
                )*/
                AND(
                    Order.RecordType.DeveloperName = 'HDT_RT_AgevolazioniAmbiente'
                    OR Order.RecordType.DeveloperName = 'HDT_RT_ModificaTariffaRimozione'
                    OR Order.SBQQ__Quote__r.IsFromVasSection__c = true
                )
            WITH Security_Enforced ]);
        list<OrderItem> items = itemsMap.values();
        
        /**@frpanico 27/12/2021
         * Trasformate Map<Id, Id> in Map<Id, List<Id>>
         * Per la ricostruzione della subscription
         */

        Map<Id, Set<Id>> itemToOrderOffer = new Map<Id, Set<Id>>();
        Map<Id, Set<Id>> itemToContract = new Map<Id, Set<Id>>();
        Map<Id, Set<Id>> itemToServicePoint = new Map<Id, Set<Id>>();
        
        /**@frpanico 22/12/2021
         * Dichiarata Map<String, Map<Id, Id>>
         * per ricostruire la struttura della subscription
         */
        /* @frpanico 23/12/2021
        * Trovato bug per cui se due OrderItem creano Subscription
        * Si sovrascrivono se riferiti allo stesso order, contrac o service point
        */
        Map<String, Map<Id, Set<Id>>> itemsMapToSub = new Map<String, Map<Id,Set<Id>>>();

        for(OrderItem item : items){
            if(item.Order.OrderReference__c!=null){
                if(itemToOrderOffer.isEmpty() || !itemToOrderOffer.containsKey(item.Order.OrderReference__c))
                {
                    itemToOrderOffer.put(item.Order.OrderReference__c, new Set<Id>());
                }
                itemToOrderOffer.get(item.Order.OrderReference__c).add(item.Id);
            }
            else if(item.Order.ContractReference__c != null)
            {
                if(itemToContract.isEmpty() || !itemToContract.containsKey(item.Order.ContractReference__c))
                {
                    itemToContract.put(item.Order.ContractReference__c, new Set<Id>());
                }
                itemToContract.get(item.Order.ContractReference__c).add(item.Id);
            }
            else
            {
                /* bonus e sconti */
                if(itemToServicePoint.isEmpty() || !itemToServicePoint.containsKey(item.Order.ServicePoint__c))
                {
                    itemToServicePoint.put(item.Order.ServicePoint__c, new Set<Id>());
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
            List<Contract> orderOfferContracts = [Select id, AccountId, SBQQ__Order__c, ContractNumber from Contract where Status NOT IN ('Cessato','Annullato') AND SBQQ__Order__c IN :itemToOrderOffer.keySet() WITH Security_Enforced];

            system.debug(LoggingLevel.DEBUG, orderOfferContracts);
            for(Contract c : orderOfferContracts)
            {   
                Set<Id> contractToDeleteSet = new Set<Id>();
                Set<Id> itemIds = itemToOrderOffer.get(c.SBQQ__Order__c);
                for(Id itemId : itemIds)
                {
                    SBQQ__Subscription__c sub = itemToSub.get(itemId);
                    if(sub != null && c.Id != sub.SBQQ__Contract__c && c.AccountId == sub.SBQQ__Account__c)
                    {
                        contractToDeleteSet.add(sub.SBQQ__Contract__c);
                        //contractToDelete.add(new Contract(Id = sub.SBQQ__Contract__c));
                        sub.SBQQ__Contract__c = c.Id;
                    }
                }
                for(Id contrId : contractToDeleteSet){
                    contractToDelete.add(new Contract(Id=contrId));
                }
            }
        }
        if(!itemToContract.isEmpty())
        {
            for(id contractId : itemToContract.keySet())
            {   
                Set<Id> contractToDeleteSet = new Set<Id>();
                for(Id itemId : itemToContract.get(contractId))
                {
                    SBQQ__Subscription__c sub = itemToSub.get(itemId);
                    if(sub!=null && contractId != sub.SBQQ__Contract__c){
                        //contractToDelete.add(new Contract(Id=sub.SBQQ__Contract__c));
                        contractToDeleteSet.add(sub.SBQQ__Contract__c);
                        sub.SBQQ__Contract__c=contractId;
                        
                    }
                }
                for(Id contrId : contractToDeleteSet){
                    contractToDelete.add(new Contract(Id=contrId));
                }
            }
        }  
        if(!itemToServicePoint.isEmpty()){//bonusSconti
            List<Contract> servicePointContracts = [Select id, AccountId, SBQQ__Order__r.ServicePoint__c, ContractNumber from Contract where Status NOT IN ('Cessato','Annullato') AND SBQQ__Order__r.ServicePoint__c IN :itemToServicePoint.keySet() AND SBQQ__Order__r.ServicePoint__c!=NULL WITH Security_Enforced];
            system.debug(LoggingLevel.DEBUG ,servicePointContracts);
            for(Contract c : servicePointContracts)
            {
                Set<Id> itemIds = itemToServicePoint.get(c.SBQQ__Order__r.ServicePoint__c);
                for(Id itemId : itemIds)
                {
                    SBQQ__Subscription__c sub = itemToSub.get(itemId);
                    if(sub!=null && c.Id!= sub.SBQQ__Contract__c && c.AccountId == sub.SBQQ__Account__c){
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
    private static void recreateSubscriptionStructure(Map<Id, SBQQ__Subscription__c> itemToSub, Map<String, Map<id, Set<id>>> itemsMapToSub)
    {
        /* Get "Parent" subscription
        * Al momento viene gestito il caso di
        * "Aggiunta Bonus e Sconti"
        */

        //Set<String> allowedProcess = new Set<String>{'HDT_RT_CambioOfferta'};        

        Map<Id, Set<Id>> itemToServicePoint = itemsMapToSub.get('servicePoint');
        Map<Id, Set<Id>> itemToContract = itemsMapToSub.get('contract');
        Map<Id, Set<Id>> itemToOrderOffer = itemsMapToSub.get('order');
        if(!itemToServicePoint.isEmpty() || !itemToContract.isEmpty() || !itemToOrderOffer.isEmpty() ){
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
    }

    public static void deleteContractsOnAfterInsert(){
        if(!contractToDelete.isEmpty()){
            HDT_UTL_DatabaseService.deleteSObject(contractToDelete);
            contractToDelete.clear();
        }
    }

    public static void dmlOnAfterInsert(){
        if(!(contractToDelete.isEmpty() && subscriptionToDelete.isEmpty() && sobjsToUpdateAsync.isEmpty())){
            if(System.isQueueable() && !isFinalizerAttached && !Test.isRunningTest()){
                System.attachFinalizer(new HDT_QBL_Finalizer(contractToDelete, subscriptionToDelete, sobjsToUpdateAsync));
                //anche dopo aver attaccato il finalizer, è possibile continuare ad agganciare oggetti alla lista.
                //la lista è passata per riferimento e l'oggetto finalizer viene serializzato e accodato solo a fine transazione
                isFinalizerAttached = true;
            }else if(!System.isQueueable()){
                if(subscriptionToDelete.isEmpty()){
                    HDT_UTL_DatabaseService.deleteSObject(subscriptionToDelete);
                    subscriptionToDelete.clear();
                }
                if(contractToDelete.isEmpty()){
                    HDT_UTL_DatabaseService.deleteSObject(contractToDelete);
                    contractToDelete.clear();
                }
            }
        }
        if(!contractToUpdate.isEmpty()){
            HDT_UTL_DatabaseService.updateSObject(contractToUpdate);
            contractToUpdate.clear();
        }
        if(!subscriptionToUpdate.isEmpty()){
            //system.debug('updateSubs ');
            //system.debug(json.serializePretty(subscriptionToUpdate));
            HDT_UTL_DatabaseService.updateSObject(subscriptionToUpdate);
            subscriptionToUpdate.clear();
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

    public class RootLookup{
        public Id rootId;
        public Id productId;
        public RootLookup(Id rootId, Id productId){
            this.rootId = rootId;
            this.productId = productId;
        }
        public RootLookup(){}
    }
}