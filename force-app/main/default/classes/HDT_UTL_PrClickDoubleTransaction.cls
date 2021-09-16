/**
 * @description       : 
 * @author            : federico.defelice@webresults.it
 * @group             : WR
 * @last modified on  : 16-09-2021
 * @last modified by  : federico.defelice@webresults.it
**/
global inherited sharing class HDT_UTL_PrClickDoubleTransaction implements wrts_prcgvr.Interfaces_1_0.IApexAction {

    private static Map<Id, String> idToNewPhase = new Map<Id, String>();

    /**
    * @description 
    * @author federico.defelice@webresults.it | 16-09-2021 
    * @param args 
    * @return Object 
    **/
    global Object execute(Object args){
        Map<String, Object> argsMap = (Map<String, Object>) args;
        system.debug(json.serialize(args));
        SObject transition = (SObject) argsMap.get('transition');
        SObject action = (SObject) argsMap.get('action');
        String method = (String) argsMap.get('method');
        SObject sender = (SObject) argsMap.get('sender');

        Id objectId = (Id) sender.get('Id');
        Id orderId = objectId;
        Order currentOrder = (Order) sender;
        String newPhase = method.replaceAll('_', ' ');
        idToNewPhase.put(objectId, newPhase);

        /*system.enqueueJob(new HDT_SRV_SalesManager.HDT_QBL_AsycnronousUpdate(
                objectId, newPhase
            )
        );*/
        
        return null;
    }

    /**
    * @description 
    * @author federico.defelice@webresults.it | 16-09-2021 
    **/
    public static void enqueueDoublePhaseTransactions(){
        if(idToNewPhase.isEmpty()){
            return;
        }
        system.debug('enqueueDoublePhaseTransactions');
        Map<Id, String> bulkMapForDoubleTransasction = new Map<Id, String>(idToNewPhase);
        idToNewPhase.clear();

        if(system.isQueueable()){
            asyncBulkUpdateFuture(bulkMapForDoubleTransasction);
        }else{
            system.enqueueJob(new HDT_QBL_BulkUpdate(bulkMapForDoubleTransasction));
        }
    }

    @future(callout=true)
    private static void asyncBulkUpdateFuture(Map<Id, String> vasOrdersToUpdate){
        system.debug('asyncBulkUpdateFuture ');
        asyncBulkUpdate(vasOrdersToUpdate);
    }

    /**
    * @description 
    * @author federico.defelice@webresults.it | 16-09-2021 
    * @param vasOrdersToUpdate 
    **/
    private static void asyncBulkUpdate(Map<Id, String> vasOrdersToUpdate){
        List<Order> childOrdersToUpdate= new List<Order>();
        for(Id ordId : vasOrdersToUpdate.keySet() ){
            childOrdersToUpdate.add(
                new Order(Id=ordId, Phase__c=vasOrdersToUpdate.get(ordId))
            );
        }
        new HDT_SRV_Order().updateRecords(childOrdersToUpdate);
    }


    public class HDT_QBL_BulkUpdate implements Queueable {
        private Map<Id, String> bulkMapForDoubleTransasction {get;set;}
        public HDT_QBL_BulkUpdate(Map<Id, String> vasOrdersToUpdate){
            this.bulkMapForDoubleTransasction=vasOrdersToUpdate;
        }

        public void execute(QueueableContext context){
            asyncBulkUpdate(bulkMapForDoubleTransasction);
        }
    }
}
