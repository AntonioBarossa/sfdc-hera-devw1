public with sharing class HDT_BA_RiconciliazioneSubscriptions implements Database.Batchable<sObject>, Database.Stateful{

    public Map<String, SBQQ__Subscription__c> oldContToNew = new Map<String, SBQQ__Subscription__c>();

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'select Id,SBQQ__Contract__c,SBQQ__Contract__r.SAPContractCode__c, SBQQ__Contract__r.OldContractMoMi__c from SBQQ__Subscription__c where  SBQQ__Contract__r.OldContractMoMi__c != null and SBQQ__Product__r.Family = \'Offerta commerciale\' and CreatedDate >= TODAY';
        List<SBQQ__Subscription__c> toBeCloned = Database.query(query);
        List<String> listaOldContractMoMi = new List<String>();
        for(SBQQ__Subscription__c sub : toBeCloned){
            listaOldContractMoMi.add(sub.SBQQ__Contract__r.OldContractMoMi__c);
            oldContToNew.put(sub.SBQQ__Contract__r.OldContractMoMi__c, sub);
        }

        query = 'SELECT Id,SBQQ__Contract__r.SAPContractCode__c, CompanyOwner__c ,PaymentMode__c ,DurationVas__c ,DwellingType__c ,EmailRecipientVAS__c ,KeepConsumptionsAnalysis__c ,OccupantsNumber__c ,OwnerAC__c ,RecordTypeId ,SBQQ__Account__c ,SBQQ__BundledQuantity__c ,SBQQ__Contract__c ,SBQQ__CustomerPrice__c ,SBQQ__ListPrice__c ,SBQQ__NetPrice__c ,SBQQ__Number__c ,SBQQ__OptionLevel__c ,SBQQ__OptionType__c ,SBQQ__PricingMethod__c ,SBQQ__Product__c ,SBQQ__ProductOption__c ,SBQQ__ProductSubscriptionType__c ,SBQQ__ProrateMultiplier__c ,SBQQ__Quantity__c ,SBQQ__RenewalQuantity__c ,SBQQ__RequiredByProduct__c ,SBQQ__RootId__c ,SBQQ__SubscriptionEndDate__c ,SBQQ__SubscriptionStartDate__c ,SBQQ__SubscriptionType__c ,ServicePoint__c ,Surface__c ,VasActivationDate__c FROM SBQQ__Subscription__c where SBQQ__Product__r.Family like \'VAS%\' AND SBQQ__Contract__r.SAPContractCode__c IN: listaOldContractMoMi';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<SBQQ__Subscription__c> scope){
        List<SBQQ__Subscription__c> clones = new List<SBQQ__Subscription__c>();
        for(SBQQ__Subscription__c sub : scope){
            SBQQ__Subscription__c clone= sub.clone(false,true,false,true);
            clone.SBQQ__Contract__c = oldContToNew.get(sub.SBQQ__Contract__r.SAPContractCode__c).SBQQ__Contract__c;
            clone.SBQQ__RootId__c = oldContToNew.get(sub.SBQQ__Contract__r.SAPContractCode__c).Id;
            clones.add(clone);
        }
        insert clones;
        
    }
    public void finish(Database.BatchableContext bc){
        System.debug(LoggingLevel.DEBUG,'End Batch');

    }
    
}
