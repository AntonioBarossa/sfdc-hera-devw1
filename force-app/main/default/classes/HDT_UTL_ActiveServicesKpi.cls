public with sharing class HDT_UTL_ActiveServicesKpi {
    public static void run(Map<Id,SObject> newMap, Map<Id,SObject> oldMap) {
        Set<Id> contractIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();

        for(Contract c : (List<Contract>) newMap.values()) {
            contractIds.add(c.Id);
            accountIds.add(c.AccountId);
        }

        Map<Id,Contract> contractMap = new Map<Id,Contract>([SELECT Id,ServicePoint__r.CommoditySector__c FROM Contract WHERE Id IN :contractIds]);
        Map<Id,Account> accountMap = new Map<Id,Account>([SELECT Id, ActiveServicesEle__c, ActiveServicesGas__c, ActiveServicesTLR__c, ActiveServicesWater__c, ActiveServicesWaste__c FROM Account WHERE Id IN :accountIds]);

        Account account;
        String service;
        Contract oldContract;
        for(Contract c : (List<Contract>) newMap.values()) {
            account = accountMap.get(c.AccountId);
            service = contractMap.get(c.Id).ServicePoint__r.CommoditySector__c;
            oldContract = oldMap != null ? (Contract) oldMap.get(c.Id) : null;

            if(oldContract == null || (c.Status == 'Attivo' && oldContract.Status != 'Attivo')) {
                updateServicesCount(account, service, 1);
            } else if(c.Status != 'Attivo' && oldContract.Status == 'Attivo') {
                updateServicesCount(account, service, (-1));
            }
        }

        update accountMap.values();
    }

    public static void updateServicesCount(Account account, String service, Integer delta) {
        switch on service {
            when 'Energia Elettrica' {
                if (account.ActiveServicesEle__c == null) {
                    account.ActiveServicesEle__c = 0;
                }
                account.ActiveServicesEle__c += delta;
            }
            when 'Gas' {
                if (account.ActiveServicesGas__c == null) {
                    account.ActiveServicesGas__c = 0;
                }
                account.ActiveServicesGas__c += delta;
            }
            // when 'Multi' {
            //    if (account.ActiveServices__c == null) {
            //           account.ActiveServices__c = 0;
            //    }
            //     account.ActiveServices__c += delta;
            // }
            when 'Teleriscaldamento' {
                if (account.ActiveServicesTLR__c == null) {
                    account.ActiveServicesTLR__c = 0;
                }
                account.ActiveServicesTLR__c += delta;
            }
            when 'Acqua' {
                if (account.ActiveServicesWater__c == null) {
                    account.ActiveServicesWater__c = 0;
                }
                account.ActiveServicesWater__c += delta;
            }
            when 'Ambiente' {
                if (account.ActiveServicesWaste__c == null) {
                    account.ActiveServicesWaste__c = 0;
                }
                account.ActiveServicesWaste__c += delta;
            }
        }
    }
}
