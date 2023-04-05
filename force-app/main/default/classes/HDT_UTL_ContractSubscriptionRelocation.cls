public inherited sharing class HDT_UTL_ContractSubscriptionRelocation {

    private final static Id CAMBIO_TARIFFA_RT_ID = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_CambioTariffa').getRecordTypeId();
    private final static Id MOD_TARIFFA_RT_ID = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_AgevolazioniAmbiente').getRecordTypeId();

    public Map<String, List<Sobject>> moveSubscriptionOffers( List<SBQQ__Subscription__c> subsToMove, Set<Id> oldOfferContracts,  Map<Id, OrderItem> itemsMap){
        //Map<Id, Order> mapOrder;
        if(oldOfferContracts.isEmpty() || subsToMove.isEmpty()){    return null;    }
        /*Set<Id> allContractsIds = new Set<Id>();
        allContractsIds.addAll(newMapContracts.keySet());
        allContractsIds.addAll(oldOfferContracts);*/
        Map<Id, Contract> oldContractWithSubs = new Map<Id, Contract>([
            SELECT
            Id, 
            (   Select 
                    SBQQ__TerminatedDate__c, SBQQ__SubscriptionEndDate__c,
                    SBQQ__Product__r.Family
                from SBQQ__Subscriptions__r
            )
            FROM Contract
            where Id IN :oldOfferContracts 
        ]);

        if(oldContractWithSubs.isEmpty()){    return null;    }

        Map<Id, SBQQ__Subscription__c> subsToUpdate = new Map<Id, SBQQ__Subscription__c>();//before trigger, no need to update/delete stuff
        Map<Id, Contract> contrsToDelete = new Map<Id, Contract>();
        Map<Id, Contract> contrsToUpdate = new Map<Id, Contract>();
        
        for(SBQQ__Subscription__c subToMove : subsToMove){
            Order ord = itemsMap.get(subToMove.SBQQ__OrderProduct__c)?.Order;
            if(checkConditions(ord, ord?.SapContractCode__c)){
                Contract oldContract = oldContractWithSubs.get(ord.ContractReference__r.Id);
                List<SBQQ__Subscription__c> oldSubs = oldContract?.SBQQ__Subscriptions__r;

                for(SBQQ__Subscription__c oldSub : oldSubs){
                    if(oldSub.SBQQ__TerminatedDate__c != null ){       continue;      }
                    
                    if(
                        ord.EffectiveDate__c != null
                        && 'Offerta Commerciale'.equalsIgnoreCase(oldSub.SBQQ__Product__r.Family)
                    ){
                        oldSub.SBQQ__SubscriptionEndDate__c = ord.EffectiveDate__c.addDays(-1);
                        oldSub.SBQQ__TerminatedDate__c = ord.EffectiveDate__c.addDays(-1);
                        subsToUpdate.put(oldSub.Id, oldSub);
                    }
                    else{//se != da offerta commerciale
                        oldSub.SBQQ__RequiredByProduct__c = subToMove.SBQQ__Product__c;
                        oldSub.SBQQ__RequiredById__c = subToMove.Id;
                        oldSub.SBQQ__RootId__c = subToMove.Id;
                        subsToUpdate.put(oldSub.Id, oldSub);
                    }
                }
                
                contrsToDelete.put(subToMove.SBQQ__Contract__c, new Contract(Id=subToMove.SBQQ__Contract__c));
                subToMove.SBQQ__Contract__c = ord.ContractReference__r.Id;
                //subsToUpdate.add(sub);//beforeInsert
                contrsToUpdate.put(ord.ContractReference__r.Id, new Contract(Id=ord.ContractReference__r.Id, SBQQ__Order__c=ord.Id));
            }
        }

        Map<String, List<Sobject>> mapToReturn = new Map<String, List<Sobject>>{
            'deleteContracts' => contrsToDelete.values(),
            'updateContracts' => contrsToUpdate.values(),
            'updateSubs' => subsToUpdate.values()
        };
        return mapToReturn;
    }

    public Boolean checkConditionsBefore(Contract c, Order ord){
        return c.Id != ord?.ContractReference__r?.Id 
                && STRING.isNotBlank(ord?.ContractReference__r?.SAPContractCode__c) 
                && ord.ContractReference__r.SAPContractCode__c == c?.SapContractCode__c
                && (ord.RecordTypeId == CAMBIO_TARIFFA_RT_ID || ord.RecordTypeId == MOD_TARIFFA_RT_ID );
    }

    public Boolean checkConditions(Order ord, String newContractCode){
        /*if(STRING.isBlank(newContractCode)){
            return false;
        }*/
        Boolean check = STRING.isNotBlank(newContractCode)
                        && STRING.isNotBlank(ord?.ContractReference__r?.SAPContractCode__c) 
                        && ord.ContractReference__r.SAPContractCode__c == newContractCode
                        && ord.RecordTypeId == CAMBIO_TARIFFA_RT_ID;
        return check;
    }

}