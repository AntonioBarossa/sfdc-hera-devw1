/**
 * @description       : Controller for hdtAccountVasOrdersView lwc
 * @author            : gabriele.rota@webresults.it
 * @group             : WR
 * @last modified on  : 2021-08-18
 * @last modified by  : gabriele.rota@webresults.it
**/
public with sharing class HDT_LC_AccountVasOrdersView {

    /**
    * @description Get Vas orders for given account
    * @author gabriele.rota@webresults.it | 2021-08-18 
    * @param accountId 
    * @return List<Order> 
    **/
    @AuraEnabled(cacheable=true)
    public static List<Order> getOrders(Id accountId){
        try {
            return [SELECT OrderNumber, Status, EffectiveDate, Contract.ContractNumber, TotalAmount, ServicePointCodeFormula__c
                FROM Order
                WHERE AccountId=:accountId AND RecordType.DeveloperName = 'HDT_RT_VAS'
                WITH SECURITY_ENFORCED];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}