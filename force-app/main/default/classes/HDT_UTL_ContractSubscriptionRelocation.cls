public inherited sharing class HDT_UTL_ContractSubscriptionRelocation {

    private final static Id CAMBIO_TARIFFA_RT_ID = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_CambioTariffa').getRecordTypeId();
    private final static Id MOD_TARIFFA_RT_ID = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_AgevolazioniAmbiente').getRecordTypeId();

    public void moveSubscriptions( Set<Id> oldOfferContracts, Map<Id, Sobject> newMapContracts, Map<Id, Order> mapOrder){
        if(oldOfferContracts.isEmpty()){    return;    }
        /*Set<Id> allContractsIds = new Set<Id>();
        allContractsIds.addAll(newMapContracts.keySet());
        allContractsIds.addAll(oldOfferContracts);*/
        Map<Id, Contract> contractWithSubs = new Map<Id, Contract>([
            SELECT
            Id, (Select SBQQ__TerminatedDate__c, SBQQ__SubscriptionEndDate__c from SBQQ__Subscriptions__r)
            FROM Contract
            where Id IN :oldOfferContracts 
        ]);

        if(contractWithSubs.isEmpty()){    return;    }

        List<SBQQ__Subscription__c> subsToUpdate = new List<SBQQ__Subscription__c>();
        Set<Id> contractsToDelete = new Set<Id>();

        for(Contract c : (List<Contract>) newMapContracts.values()){
            Order ord = mapOrder.get(c.SBQQ__Order__c);
            if(
                checkConditions(c, ord)
            ){                
                //SF Created a New Contract but SAP didn't
                List<SBQQ__Subscription__c> oldSubs = contractWithSubs.get(ord.ContractReference__r.Id)?.SBQQ__Subscriptions__r;
                for(SBQQ__Subscription__c sub : oldSubs){
                    if(ord.EffectiveDate__c != null){
                        sub.SBQQ__SubscriptionEndDate__c = ord.EffectiveDate__c.addDays(-1);
                        sub.SBQQ__TerminatedDate__c = ord.EffectiveDate__c.addDays(-1);
                        subsToUpdate.add(sub);
                    } 
                }

                List<SBQQ__Subscription__c> newSubs = contractWithSubs.get(c.Id)?.SBQQ__Subscriptions__r;
                for(SBQQ__Subscription__c sub : newSubs){
                    sub.SBQQ__Contract__c = ord.ContractReference__r.Id;
                    subsToUpdate.add(sub);
                    contractsToDelete.add(c.Id);
                }
            }    
        }
        dmlOperations(subsToUpdate, contractsToDelete);
        
    }

    private static void dmlOperations(List<SBQQ__Subscription__c> subsToUpdate, Set<Id> contractsToDelete){
        if(!subsToUpdate.isEmpty()){    HDT_UTL_DatabaseService.updateSObject(subsToUpdate);    }
        system.debug('@@@@@@ delete operation');
        system.debug(contractsToDelete);
        if(!contractsToDelete.isEmpty()){    System.attachFinalizer(new HDT_QBL_Finalizer(contractsToDelete));  }
    }
    
    /*@future
    private static void dmlOperations(Set<Id> contractsToDelete){
        if(!contractsToDelete.isEmpty()){    HDT_UTL_DatabaseService.deleteSObject(new List<Id>(contractsToDelete));  }
    }*/

    public Boolean checkConditions(Contract c, Order ord){
        return c.Id != ord?.ContractReference__r?.Id && checkConditions(ord, c?.SapContractCode__c);
    }

    public Boolean checkConditionsBefore(Contract c, Order ord){
        return c.Id != ord?.ContractReference__r?.Id 
                && STRING.isNotBlank(ord?.ContractReference__r?.SAPContractCode__c) 
                && ord.ContractReference__r.SAPContractCode__c == c?.SapContractCode__c
                && (ord.RecordTypeId == CAMBIO_TARIFFA_RT_ID || ord.RecordTypeId == MOD_TARIFFA_RT_ID );
    }

    public Boolean checkConditions(Order ord, String newContractCode){
        if(STRING.isBlank(newContractCode)){
            return false;
        }
        Boolean check = STRING.isNotBlank(ord?.ContractReference__r?.SAPContractCode__c) 
                        && ord.ContractReference__r.SAPContractCode__c == newContractCode
                        && ord.RecordTypeId == CAMBIO_TARIFFA_RT_ID;
        return check;
    }


    public class HDT_QBL_Finalizer implements Finalizer {
        Set<Id> contractsToDelete;

        HDT_QBL_Finalizer(Set<Id> contractsToDelete){
            this.contractsToDelete = contractsToDelete;
        }

        public void execute(FinalizerContext ctx){
            //se queueable success chiamare servizio deda con case
            if(!contractsToDelete.isEmpty()){    HDT_UTL_DatabaseService.deleteSObject(new List<Id>(contractsToDelete));  }
        }
    }

}