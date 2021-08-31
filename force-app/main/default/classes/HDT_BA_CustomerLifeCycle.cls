public with sharing class HDT_BA_CustomerLifeCycle implements Database.Batchable<SObject> {
    private static Set<String> energyCommodities = new Set<String> {'Energia Elettrica', 'Gas'};
    private static Map<String,Integer> statusWeight = new Map<String,Integer> {
        'LOST' => 7,
        'LEAVING' => 6,
        'USAGE' => 5,
        'GROWTH' => 4,
        'ENGAGEMENT' => 3,
        'WELCOME' => 2,
        'ONBOARDING' => 1
    };
    private static Date today = Date.today();

    public Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT' +
                'Id,' +
                'ActiveServicesEle__c,' +
                'ActiveServicesGas__c,' +
                'ActiveServicesTLR__c,' +
                'ActiveServicesWaste__c,' +
                'ActiveServicesWater__c,' +
                'CustomerLifeCycleEle__c,' +
                'CustomerLifeCycleEnergy__c,' +
                'CustomerLifeCycleGas__c,' +
                'CustomerLifeCycleNonEnergy__c,' +
                'CustomerLifeCycleTLR__c,' +
                'CustomerLifeCycleVAS__c,' +
                'CustomerLifeCycleWaste__c,' +
                'CustomerLifeCycleWater__c' +
            'FROM Account'
        ;
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<SObject> scope) {
        Map<Id, Account> accountMap = new Map<Id, Account>((List<Account>) scope);
        Map<Id, Account> processedAccountMap = new Map<Id, Account>();
        Map<Id, Case> caseMap = new Map<Id, Case>();

        for(Case c : [SELECT Id, Contract__c, CancellationRequestDate__c FROM Case WHERE Contract__r.AccountId IN :accountMap.keySet() AND Cluster__c = 'Disattivazioni' AND Status != 'Closed' ORDER BY CreatedDate ASC]) {
            caseMap.put(c.Contract__c, c);
        }

        String commodity;
        Account account;
        String status;
        for(Contract contract : [
            SELECT
                Id,
                (SELECT Id FROM Assets__r WHERE Product2.family = 'VAS Prodotto'),
                (SELECT Id FROM SBQQ__Subscriptions__r WHERE SBQQ__Product__r.family in ('VAS Fatturabili','VAS Servizio')),
                CustomerSignedDate,
                ActivatedDate,
                EndDate,
                ServicePoint__r.CommoditySector__c
            FROM Contract
            WHERE
                AccountId IN :accountMap.keySet() AND
                ServicePoint__r.CommoditySector__c IN ('Energia Elettrica','Gas','Teleriscaldamento','Acqua','Ambiente')
            ORDER BY AccountId, CreatedDate DESC
        ]) {
            commodity = contract.ServicePoint__r.CommoditySector__c;
            if(processedAccountMap.containsKey(contract.AccountId)) {
                account = processedAccountMap.get(contract.AccountId);
            } else {
                account = new Account(
                    Id = contract.AccountId
                );
                processedAccountMap.put(contract.AccountId, account);
            }

            if(contract.EndDate >= today) {
                status = 'LOST';
            } else if(isEnergy(commodity) && (caseMap.get(contract.Id).CancellationRequestDate__c <= today)) {
                status = 'LEAVING';
            } else if(!isEnergy(commodity) && (contract.StartDate.addDays(60) <= today) && (today < contract.EndDate)) {
                status = 'USAGE';
            } else if(isEnergy(commodity) && (contract.StartDate.addYears(2) <= today || hasMultipleContracts(account, commodity))) {
                status = 'GROWTH';
            } else if(isEnergy(commodity) && contract.StartDate.addYears(1) <= today && today < contract.StartDate.addYears(2)) {
                status = 'ENGAGEMENT';
            } else if(contract.StartDate <= today && today <= contract.StartDate.addDays(isEnergy(commodity) ? 365 : 60)) {
                status = 'WELCOME';
            } else if (contract.CustomerSignedDate <= today && today < contract.StartDate) {
                status = 'ONBOARDING';
            }

            // if(isVas(contract) && )

            switch on commodity {
                when 'Energia Elettrica' {
                    account.CustomerLifeCycleEle__c = status;
                }
                when 'Gas' {
                    account.CustomerLifeCycleGas__c = status;
                }
                when 'Teleriscaldamento' {
                    account.CustomerLifeCycleTLR__c = status;
                }
                when 'Acqua' {
                    account.CustomerLifeCycleWater__c = status;
                }
                when 'Ambiente' {
                    account.CustomerLifeCycleWaste__c = status;
                }
            }

            if(
                isVas(contract) &&
                (String.isBlank(account.CustomerLifeCycleVAS__c) || statusWeight.get(account.CustomerLifeCycleVAS__c) < statusWeight.get(status))
            ) {
                account.CustomerLifeCycleVAS__c = status;
            }
        }

        Account processedAccount;
        for(Account originalAccount : accountMap.values()) {
            if(processedAccountMap.containsKey(originalAccount.Id)) {
                processedAccount = processedAccountMap.get(originalAccount.Id);
                if(
                    originalAccount.CustomerLifeCycleEle__c == processedAccount.CustomerLifeCycleEle__c &&
                    originalAccount.CustomerLifeCycleGas__c == processedAccount.CustomerLifeCycleGas__c &&
                    originalAccount.CustomerLifeCycleTLR__c == processedAccount.CustomerLifeCycleTLR__c &&
                    originalAccount.CustomerLifeCycleVAS__c == processedAccount.CustomerLifeCycleVAS__c &&
                    originalAccount.CustomerLifeCycleWaste__c == processedAccount.CustomerLifeCycleWaste__c &&
                    originalAccount.CustomerLifeCycleWater__c == processedAccount.CustomerLifeCycleWater__c
                ) {
                    processedAccountMap.remove(originalAccount.Id);
                } else {
                    if(statusWeight.get(processedAccount.CustomerLifeCycleEle__c) >= statusWeight.get(processedAccount.CustomerLifeCycleGas__c)) {
                        status = processedAccount.CustomerLifeCycleEle__c;
                    } else {
                        status = processedAccount.CustomerLifeCycleGas__c;
                    }
                    if(statusWeight.get(status) >= statusWeight.get(processedAccount.CustomerLifeCycleVAS__c)) {
                        processedAccount.CustomerLifeCycleEnergy__c = status;
                    } else {
                        processedAccount.CustomerLifeCycleEnergy__c = processedAccount.CustomerLifeCycleVAS__c;
                    }

                    if(statusWeight.get(processedAccount.CustomerLifeCycleTLR__c) >= statusWeight.get(processedAccount.CustomerLifeCycleWaste__c)) {
                        status = processedAccount.CustomerLifeCycleTLR__c;
                    } else {
                        status = processedAccount.CustomerLifeCycleWaste__c;
                    }
                    if(statusWeight.get(status) >= statusWeight.get(processedAccount.CustomerLifeCycleWater__c)) {
                        processedAccount.CustomerLifeCycleNonEnergy__c = status;
                    } else {
                        processedAccount.CustomerLifeCycleNonEnergy__c = processedAccount.CustomerLifeCycleWater__c;
                    }
                }
            }
        }

        update processedAccountMap.values();
    }

    public void finish(Database.BatchableContext BC) {
    }

    private Boolean isEnergy(String commodity) {
        return energyCommodities.contains(commodity);
    }

    private Boolean isVas(Contract contract) {
        return (!contract.Assets__r.isEmpty() || !contract.SBQQ__Subscriptions__r.isEmpty());
    }

    private Boolean hasMultipleContracts(Account account, String commodity) {
        switch on commodity {
            when 'Energia Elettrica' {
                return account.ActiveServicesEle__c > 1;
            }
            when 'Gas' {
                return account.ActiveServicesGas__c > 1;
            }
            when else {
                return false;
            }
        }
    }
}