/**
 * @description       : 
 * @author            : federico.defelice@webresults.it
 * @group             : WR
 * @last modified on  : 03-11-2021
 * @last modified by  : federico.defelice@webresults.it
**/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global inherited sharing class HDT_UTL_PrClickEndSubscriptionBulk implements wrts_prcgvr.Interfaces_1_2.IApexActionBulk {


    private static List<SBQQ__Subscription__c> subsToBeTerminated = new List<SBQQ__Subscription__c>();


    /**
    * @description 
    * @author federico.defelice@webresults.it | 03-11-2021 
    * @param args 
    * @return Object 
    **/
    global Object execute(Object args){
        Map<String, Object> argsMap = (Map<String, Object>) args;
        //system.debug(json.serialize(args));

        //String method = (String) argsMap.get('method');

        List<Case> senders = (List<Case>) ((Map<String,Object>)argsMap.get('parameter')).get('records');
        //Map<Id, Id> orderToContract = new Map<Id, Id>();
        Date terminationDay = Date.today();
        for(Case c : senders){
            if(c.Subscription__c!=null){
                subsToBeTerminated.add(new SBQQ__Subscription__c(Id=c.Subscription__c, SBQQ__SubscriptionEndDate__c=terminationDay, SBQQ__TerminatedDate__c=terminationDay));
            }
        }
        return null;
    }


    /**
    * @description 
    * @author federico.defelice@webresults.it | 03-11-2021 
    * @param newOrders 
    **/
    public static void updateCorrelatedObjects(){
        if(subsToBeTerminated.isEmpty()){
            return;
        }
        HDT_UTL_DatabaseService.updateSObject(subsToBeTerminated);
    }
}
