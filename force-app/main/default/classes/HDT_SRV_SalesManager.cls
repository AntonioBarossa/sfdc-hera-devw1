/*
 * File: HDT_SRV_SalesManager.cls
 * Project: HERA
 * File Created: Monday, 19th July 2021 12:00:40 pm
 * Author: fdefelice
 * DESCRIPTION: 
 * -----
 * HISTORY:
 */

global inherited sharing class HDT_SRV_SalesManager implements wrts_prcgvr.Interfaces_1_0.IApexAction {
    
    private static final String VAS_SERVICE_TYPE = 'Servizio';
    private static final String ORDER_PHASE_WAIT_FOR_AFTERTHOUGHT = 'In attesa tempi di ripensamento';
    private static final String ORDER_PHASE_VAS_COMMUNICATION = 'Comunicazione Motore VAS';

    private static HDT_SRV_Order orderSrv = new HDT_SRV_Order();
    
    global Object execute(Object args){
        Map<String, Object> argsMap = (Map<String, Object>) args;
        system.debug(json.serialize(args));
        SObject transition = (SObject) argsMap.get('transition');
        SObject action = (SObject) argsMap.get('action');
        String method = (String) argsMap.get('method');
        SObject sender = (SObject) argsMap.get('sender');

        Id objectId = (Id) sender.get('Id');

        switch on method{
            when 'activation', 'deactivation'{
                if(system.isQueueable()){
                    asyncCalloutFuture(objectId, method);
                }else{
                    system.enqueueJob(new HDT_QBL_AsycnronousCallout(
                        objectId, method
                        )
                    );
                }
                
            }
            when 'updatePhase'{
                Id orderId = objectId;
                Order currentOrder = (Order) sender;
                Boolean isServiceType = (currentOrder.VASType__c==VAS_SERVICE_TYPE);
                String newPhase = isServiceType?ORDER_PHASE_WAIT_FOR_AFTERTHOUGHT:ORDER_PHASE_VAS_COMMUNICATION;

                system.enqueueJob(new HDT_QBL_AsycnronousUpdate(
                    objectId, newPhase
                    )
                );
            }
        }
        
        return null;
    }

    @future(callout=true)
    private static void asyncCalloutFuture(Id sobjectId, String method){
        system.debug('asyncCalloutFuture ');
        asyncCallout(sobjectId, method);
    }



    private static void asyncCallout(Id sobjectId, String method){
        HDT_WS_Response res;
        String newPhase;

        switch on method{
            when 'activation'{
                res = HDT_WS_MotoreVas.activationCallout(sobjectId);
                Boolean isSuccess = (res.statusCode==200 || res.statusCode==201);
                newPhase = isSuccess?'Comunicazione verso Motore VAS OK':'Comunicazione verso Motore VAS KO';
            }
            when 'deactivation'{
                res = HDT_WS_MotoreVas.deactivationCallout(sobjectId);
                Boolean isSuccess = (res.statusCode==200 || res.statusCode==201);
                newPhase = isSuccess?'Comunicazione verso Motore VAS OK':'Comunicazione verso Motore VAS KO';
            }
        }

        system.debug('***HDT_QBL_AsycnronousCallout'+res);

        //do UpdatePhase

        if(String.isNotBlank(newPhase)){ 
            new HDT_QBL_AsycnronousUpdate().asyncronousUpdate(SobjectId, newPhase);
        }
    }

    public class HDT_QBL_AsycnronousCallout implements Queueable, Database.AllowsCallouts{
        private Id sobjectId{get;set;}
        private String method{get;set;}

        public HDT_QBL_AsycnronousCallout(){}
        public HDT_QBL_AsycnronousCallout(Id sobjectId, String method){
            this.sobjectId=sobjectId;
            this.method = method;
        }
        public HDT_QBL_AsycnronousCallout(String sobjectId, String method){
            this((Id) sobjectId, method);
        }

        public void execute(QueueableContext context){
            asyncCallout(sobjectId, method);
        }
    }
    
    public class HDT_QBL_AsycnronousUpdate implements Queueable {
        private Id sobjectId{get;set;}
        private String newPhase{get;set;}
        

        public HDT_QBL_AsycnronousUpdate(){}
        public HDT_QBL_AsycnronousUpdate(Id sobjectId, String newPhase){
            this.sobjectId=sobjectId;
            this.newPhase = newPhase;
        }
        public HDT_QBL_AsycnronousUpdate(String sobjectId, String newPhase){
            this((Id) sobjectId, newPhase);
        }

        public void execute(QueueableContext context){
            asyncronousUpdate(sobjectId, newPhase);
        }
        
        public void asyncronousUpdate(Id sobjectId, String newPhase){
            Sobject sender;
            switch on sobjectId.getSobjectType().getDescribe().getName() {
                when 'Case' {
                    sender = (SObject) new Case();
                }
                when 'Order' {
                    sender = (SObject) new Order();
                }
                when else {
                    throw new HDT_UTL_HeraException('Invalid sObject provided');
                }
            }
            
            sender.put('Id', sobjectId);
            sender.put('Phase__c', newPhase);
            Database.update(sender);
        }
    }

    public class HDT_QBL_BulkUpdate implements Queueable {
        private Map<Id, String> vasOrdersToUpdate {get;set;}
        public HDT_QBL_BulkUpdate(Map<Id, String> vasOrdersToUpdate){
            this.vasOrdersToUpdate=vasOrdersToUpdate;
        }

        public void execute(QueueableContext context){
            List<Order> childOrdersToUpdate= new List<Order>();
            for(Id ordId : vasOrdersToUpdate.keySet() ){
                childOrdersToUpdate.add(
                    new Order(Id=ordId, Phase__c=vasOrdersToUpdate.get(ordId))
                );
            }
            new HDT_SRV_Order().updateRecords(childOrdersToUpdate);
        }
    }

}