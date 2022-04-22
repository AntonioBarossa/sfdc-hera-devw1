@SuppressWarnings('PMD.AvoidDebugStatements, PMD.ClassNamingConventions, PMD.ExcessiveParameterList')
public inherited sharing class HDT_SRV_SIE14 implements Queueable {

    Set<Id> data;

    public HDT_SRV_SIE14(Set<Id> data){
        this.data = data;
    }

    public HDT_SRV_SIE14(){
        this.data= new Set<id>();
    }
    
    private HDT_SRV_Account srvAcc = new HDT_SRV_Account();


    List<HDT_UTL_SIE14.HDT_WRP_SIE14Rule> getRules(){
        return new List<HDT_UTL_SIE14.HDT_WRP_SIE14Rule>{
            new HDT_UTL_SIE14.HDT_WRP_SIE14Rule('CORPORATE_IC', new List<String>{'Account.CategoryCode__c == Z006'},'', ''),
            new HDT_UTL_SIE14.HDT_WRP_SIE14Rule('HCNE_Coporate_GDA', new List<String>{'SBQQ__Order__r.Sale__r.CommercialId__c STARTS AGSMECON'},'1 AND 2', 'Hera Comm NordEst'),                        
            new HDT_UTL_SIE14.HDT_WRP_SIE14Rule('Corporate_GDA', new List<String>{'SBQQ__Order__r.Sale__r.CommercialId__c STARTS AGSMECON'},'1 AND 2', 'Hera Comm S.p.A.;Hera Comm Marche' ),
            new HDT_UTL_SIE14.HDT_WRP_SIE14Rule('ZCOD-DA CODIFICARE', null,'1 AND 2', null )
        };

    }

    public void execute(QueueableContext context) {
        initSie(this.data);
    }

    Map<Id,Contract> getContractData(Set<Id> contractIds){

        List<Contract> contracts = [SELECT Id, AccountId, ContractSalesCompany__c , SBQQ__Order__r.SalesCompany__c, Account.CategoryCode__c, SBQQ__Order__r.Sale__r.CommercialId__c 
                                    FROM Contract
                                    WHERE Id IN :contractIds
                                    WITH SECURITY_ENFORCED
                                    Order By LastModifiedDate ASC
                                    ];

        Map<Id,Contract> result = new Map<Id,Contract>();
        for(Contract c : contracts){
            result.put(c.AccountId, c);
        }
        system.debug('getContractDataResults -> ' + result);
        return result;

    }

    public Map<Id,String> getMostFrequentCompany(Set<Id> accountId){


        Map<Id, String> result = new Map<Id,String>();
        List<AggregateResult> results = [Select AccountId , SBQQ__Order__r.SalesCompany__c salesCompany, Count(Id) counter From Contract WHERE AccountId IN :accountId
                                            //AND SBQQ__Order__r.SalesCompany__c != '' 
                                            GROUP BY AccountId, SBQQ__Order__r.SalesCompany__c ORDER BY Count(Id) ASC];// NO SECURITY ENFORCED

        for(AggregateResult actualResult : results){
            String company = (String) actualResult.get('salesCompany');
            company = String.isNotBlank(company)? company : '';
            result.put((Id)actualResult.get('accountId'), company );
        }

        return result;
    }

    List<Account> findRule(Map<Id, Contract> contracts){
        List<HDT_UTL_SIE14.HDT_WRP_SIE14Rule> rules = getRules();
        Map<Id,String> accountAndFrequentCompanies = getMostFrequentCompany(contracts.keySet());
        system.debug('accountAndFrequentCompanies -> ' + accountAndFrequentCompanies);
        List<Account> accountToUpdate = new List<Account>();

        for(Contract c : contracts.values()){
            for(HDT_UTL_SIE14.HDT_WRP_SIE14Rule rule : rules){
                if(rule.checkLogic(c, accountAndFrequentCompanies.get(c.accountId))){
                    Account a = new Account(Id = c.accountId, Segment__c = rule.segmento);
                    accountToUpdate.add(a);
                    break;
                }
            }
        }

        return accountToUpdate;
    }

    public void initSie(Set<Id> data){
        Map<Id,Contract> contracts = getContractData(data);
        system.debug('contracts -> ' + contracts);
        List<Account> accountToUpdate = findRule(contracts);
        system.debug('accountToUpdate -> ' + accountToUpdate);
        if(!accountToUpdate.isEmpty()){
            srvAcc.updateRecords(accountToUpdate);
        }
    }

    public void checkBpcaChanges(Set<Id> accountIds){
    system.debug('accountIds -> ' + accountIds);
   
        List<Account> results =[Select Id, (select Id FROM Contracts ORDER BY CreatedDate DESC LIMIT 1) FROM Account WHERE Id IN : accountIds];

        system.debug('results -> ' + results);

        Set<Id> contractsId = new Set<Id>();
        for(Account actualResult : results){
            system.debug('actualResult -> ' + actualResult.contracts);
            contractsId.add(actualResult.contracts[0].Id);
        }
        System.debug('contractsIds ->' + contractsId); 
        this.initSie(contractsId);
    }
}