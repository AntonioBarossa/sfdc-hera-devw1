/**
 * @description       : 
 * @author            : federico.defelice@webresults.it
 * @group             : WR
 * @last modified on  : 07-10-2021
 * @last modified by  : federico.defelice@webresults.it
**/
global inherited sharing class HDT_UTL_PclickBulkActionVas implements wrts_prcgvr.Interfaces_1_2.IApexActionBulk {

    private static Map<Id, Id> orderToContract = new Map<Id, Id>();
    
    /**
    * @description 
    * @author federico.defelice@webresults.it | 07-10-2021 
    * @param argsMap.get 
    * @return //SObject 
    **/
    global Object execute(Object args){
        Map<String, Object> argsMap = (Map<String, Object>) args;
        system.debug(json.serialize(args));

        //String method = (String) argsMap.get('method');

        List<Order> senders = (List<Order>) ((Map<String,Object>)argsMap.get('parameter')).get('records');
        Map<Id, Id> orderReferenceToOrder = new Map<Id, Id>();
        //Map<Id, Id> orderToContract = new Map<Id, Id>();

        for(Order o : senders){
            orderReferenceToOrder.put(o.OrderReference__c, o.id);
        }


        List<Contract> contracts =  [Select id, SBQQ__Order__c FROM Contract where SBQQ__Order__c IN :orderReferenceToOrder.keySet() AND SBQQ__Order__c!=null WITH SECURITY_ENFORCED ];

        for(Contract c : contracts){
            orderToContract.put(orderReferenceToOrder.get(c.SBQQ__Order__c), c.id);
        }

        //if(!orderToContract.isEmpty())
        //    asyncUpdate(orderToContract);
        return null;

    }

    /*
    @future
    private static void asyncUpdate(Map<Id, Id> orderToContract){
        List<Order> ordersToUpdate = new List<Order>();
        for(id ordId : orderToContract.keyset()){
            ordersToUpdate.add(
                new Order(ID=ordId, ContractReference__c=orderToContract.get(ordId))
            );
        }
        new HDT_SRV_Order().updateRecords(ordersToUpdate);
    }*/

    public static void checkVasContractAlignmentBeforeUpdate(List<Order> newOrders){
        if(orderToContract.isEmpty())
            return;
        
        for(Order o : newOrders){
            if(orderToContract.get(o.Id)!=null){
                o.ContractReference__c=orderToContract.get(o.Id);
            }
        }
    }

}
