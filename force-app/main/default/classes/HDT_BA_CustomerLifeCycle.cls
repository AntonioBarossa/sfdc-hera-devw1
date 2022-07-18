public with sharing class HDT_BA_CustomerLifeCycle implements Database.Batchable<SObject> {
    private static final Map<String,Integer> STATUS_WEIGHT_MAP = new Map<String,Integer> {
        'LOST' => 7,
        'LEAVING' => 6,
        'USAGE' => 5,
        'GROWTH' => 4,
        'ENGAGEMENT' => 3,
        'WELCOME' => 2,
        'ONBOARDING' => 1,
        null => 0
    };
    private static final Set<String> ENERGY_COMMODITIES = new Set<String> {
        'Energia Elettrica',
        'Gas'
    };
    private static final Date TODAY = Date.today();
    private List<String> idList;

    public HDT_BA_CustomerLifeCycle() {}

    public HDT_BA_CustomerLifeCycle(List<String> idList) {
        this.idList = idList;
    }

    public static void testRun(String idList) {
        Database.executeBatch(new HDT_BA_CustomerLifeCycle(idList.split(',')));
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT ' +
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
            ' FROM Account'
        ;

        if(idList != null) {
            query += ' WHERE Id IN :idList';
        }else{
            query+= ' WHERE IsDigitalMarking__c = true';
        }

        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<SObject> scope) {
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
                AccountId,
                (SELECT Id FROM Assets__r WHERE Product2.family = 'VAS Prodotto'),
                (SELECT Id FROM SBQQ__Subscriptions__r WHERE SBQQ__Product__r.family in ('VAS Fatturabili','VAS Servizio')),
                CustomerSignedDate,
                ActivatedDate,
                StartDate,
                EndDate,
                ServicePoint__r.CommoditySector__c
            FROM Contract
            WHERE
                StartDate != null AND
                AccountId IN :accountMap.keySet() AND
                ServicePoint__r.CommoditySector__c IN ('Energia Elettrica','Gas','Teleriscaldamento','Acqua','Ambiente')
            ORDER BY AccountId, CreatedDate DESC
        ]) {
            commodity = contract.ServicePoint__r.CommoditySector__c;
            if(processedAccountMap.containsKey(contract.AccountId)) {
                account = processedAccountMap.get(contract.AccountId);
            } else {
                account = new Account(
                    Id = contract.AccountId,
                    ActiveServicesEle__c = 0,
                    ActiveServicesGas__c = 0
                );
                processedAccountMap.put(contract.AccountId, account);
            }
            if(contract.EndDate != null && contract.EndDate <= TODAY) {
                status = 'LOST';
            } else if(isEnergy(commodity) && caseMap.get(contract.Id) != null && (caseMap.get(contract.Id).CancellationRequestDate__c <= TODAY)) {
                status = 'LEAVING';
            } else if(!isEnergy(commodity) && (contract.StartDate.addDays(60) <= TODAY) && (contract.EndDate != null) && (TODAY < contract.EndDate)) {
                status = 'USAGE';
            } else if(isEnergy(commodity) && (contract.StartDate.addYears(2) <= TODAY || hasMultipleContracts(account, commodity))) {
                status = 'GROWTH';
            } else if(isEnergy(commodity) && contract.StartDate.addYears(1) <= TODAY && TODAY < contract.StartDate.addYears(2)) {
                status = 'ENGAGEMENT';
            } else if(contract.StartDate <= TODAY && TODAY <= contract.StartDate.addDays(isEnergy(commodity) ? 365 : 60)) {
                status = 'WELCOME';
            } else if (contract.CustomerSignedDate <= TODAY && TODAY < contract.StartDate) {
                status = 'ONBOARDING';
            }

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
                (String.isBlank(account.CustomerLifeCycleVAS__c) || STATUS_WEIGHT_MAP.get(account.CustomerLifeCycleVAS__c) < STATUS_WEIGHT_MAP.get(status))
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
                    if(STATUS_WEIGHT_MAP.get(processedAccount.CustomerLifeCycleEle__c) >= STATUS_WEIGHT_MAP.get(processedAccount.CustomerLifeCycleGas__c)) {
                        status = processedAccount.CustomerLifeCycleEle__c;
                    } else {
                        status = processedAccount.CustomerLifeCycleGas__c;
                    }
                    if(STATUS_WEIGHT_MAP.get(status) >= STATUS_WEIGHT_MAP.get(processedAccount.CustomerLifeCycleVAS__c)) {
                        processedAccount.CustomerLifeCycleEnergy__c = status;
                    } else {
                        processedAccount.CustomerLifeCycleEnergy__c = processedAccount.CustomerLifeCycleVAS__c;
                    }

                    if(STATUS_WEIGHT_MAP.get(processedAccount.CustomerLifeCycleTLR__c) >= STATUS_WEIGHT_MAP.get(processedAccount.CustomerLifeCycleWaste__c)) {
                        status = processedAccount.CustomerLifeCycleTLR__c;
                    } else {
                        status = processedAccount.CustomerLifeCycleWaste__c;
                    }
                    if(STATUS_WEIGHT_MAP.get(status) >= STATUS_WEIGHT_MAP.get(processedAccount.CustomerLifeCycleWater__c)) {
                        processedAccount.CustomerLifeCycleNonEnergy__c = status;
                    } else {
                        processedAccount.CustomerLifeCycleNonEnergy__c = processedAccount.CustomerLifeCycleWater__c;
                    }
                }
            }
        }

        Database.update(processedAccountMap.values(), false);
    }

    /*
    @Author:        Francesco Vitiello
    CreatedDate:    19/10/2021
    Reason: Avoid Debug Statements
    */
    @SuppressWarnings('PMD.AvoidDebugStatements')
    public void finish(Database.BatchableContext bc) {
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :bc.getJobId()];
        System.debug(LoggingLevel.DEBUG, 'HDT_BA_CustomerLifeCycle - finished job: ' + a);
        
    }

    private Boolean isEnergy(String commodity) {
        return ENERGY_COMMODITIES.contains(commodity);
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