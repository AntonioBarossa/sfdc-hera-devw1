public with sharing class HDT_UTL_SIE14 {

    private class HDT_WRP_SIE14Rule{
        String segmento;
        List<String> conditions;
        String logic;
        List<String> salesCompany;

        HDT_WRP_SIE14Rule(String segmento, List<String> conditions, String logic, List<String> salesCompany){
            this.segmento = segmento;
            this.conditions = conditions;
            this.logic = logic;
            this.salesCompany = salesCompany;
        }
 
        boolean checkLogic(SObject obj, String company){
            return true;
        }
    }

    List<HDT_WRP_SIE14Rule> getRules(){

        String salesCompany = '';
        return new List<HDT_WRP_SIE14Rule>{
            new HDT_WRP_SIE14Rule('CORPORATE_IC', new List<String>{'Account.CategoryCode__c == Z006'},'', new List<String>{''}),
            new HDT_WRP_SIE14Rule('HCNE_Coporate_GDA', new List<String>{'SBQQ__Order__r.Sale__r.CommercialId__c START "AGSMECON"'},'1 AND 2', new List<String>{'Hera Comm NordEst'}),
                                    
            new HDT_WRP_SIE14Rule('Corporate_GDA', new List<String>{'SBQQ__Order__r.Sale__r.CommercialId__c START "AGSMECON"'},'1 AND 2', new List<String>{'Hera Comm S.p.A', 'Hera Comm Marche' })
        };

    }

    Map<Id,Contract> getContractData(Set<Contract> contractIds){

        List<Contract> contracts = [SELECT Id, AccountId, ContractSalesCompany__c , Account.CategoryCode__c, SBQQ__Order__r.Sale__r.CommercialId__c 
                                    FROM Contract
                                    WHERE Id IN :contractIds
                                    Order By LastModifiedDate ASC];

        Map<Id,Contract> result = new Map<Id,Contract>();
        for(Contract c : contracts){
            result.put(c.AccountId, c);
        }
        system.debug('getContractDataResults -> ' + result);
        return result;

    }

    public Map<Id,String> getMostFrequentCompany(Set<Id> accountId){

        Map<Id, String> result = new Map<Id,String>();
        List<AggregateResult> results = [Select AccountId , ContractSalesCompany__c , Count(Id) counter From Contract WHERE AccountId IN :accountId
                                            AND ContractSalesCompany__c != NULL GROUP BY AccountId, ContractSalesCompany__c ORDER BY Count(Id) ASC];

        for(AggregateResult actualResult : results){
            result.put((Id)actualResult.get('accountId'), (String)actualResult.get('ContractSalesCompany__c') );
        }

        return result;
    }

    List<Account> findRule(Map<Id, Contract> contracts){
        List<HDT_WRP_SIE14Rule> rules = getRules();
        Map<Id,String> accountAndFrequentCompanies = getMostFrequentCompany(contracts.keySet());
        system.debug('accountAndFrequentCompanies -> ' + accountAndFrequentCompanies);
        List<Account> accountToUpdate = new List<Account>();

        for(Contract c : contracts.values()){
            for(HDT_WRP_SIE14Rule rule : rules){
                if(rule.checkLogic(c, accountAndFrequentCompanies.get(c.accountId))){
                    Account a = new Account(Id = c.accountId, Segment__c = rule.segmento);
                    accountToUpdate.add(a);
                    break;
                }
            }
        }

        return accountToUpdate;
    }

    public void initSIE(Set<Contract> data){
        Map<Id,Contract> contracts = getContractData(data);
        system.debug('contracts -> ' + contracts);
        List<Account> accountToUpdate = findRule(contracts);
        system.debug('accountToUpdate -> ' + accountToUpdate);
        if(!accountToUpdate.isEmpty()){
            update accountToUpdate;
        }
    }
}
