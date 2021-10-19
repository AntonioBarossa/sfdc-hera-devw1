/*
 * File: HDT_SRV_SalesManager.cls
 * Project: HERA
 * File Created: Monday, 19th July 2021 12:00:40 pm
 * Author: fdefelice
 * DESCRIPTION: 
 * -----
 * HISTORY:
 */

public inherited sharing class HDT_SRV_SalesManager implements wrts_prcgvr.Interfaces_1_0.IApexAction {
    
    private static final String VAS_SERVICE_TYPE = 'VAS Servizio';
    private static final String ORDER_PHASE_WAIT_FOR_AFTERTHOUGHT = 'In attesa tempi di ripensamento';
    private static final String ORDER_PHASE_VAS_COMMUNICATION = 'Comunicazione Motore VAS';
    private static final String PHASE_SEQUENZIALIZZATO = 'Sequenzializzato';
    private static final String PHASE_KO_PRODOTTO = 'Cod. offerta non mappato';

    private static HDT_QR_Order orderQr = new HDT_QR_Order();
    private static HDT_SRV_Order orderSrv = new HDT_SRV_Order();
    
    /**
    * @description Executes action invoked by Process Click
    * @author gabriele.rota@webresults.it | 2021-07-12 
    * @param args  
    * @return Object 
    **/
    public Object execute(Object args){
        Map<String, Object> argsMap = (Map<String, Object>) args;
        //SObject transition = (SObject) argsMap.get('transition');
        //SObject action = (SObject) argsMap.get('action');
        String method = (String) argsMap.get('method');
        SObject sender = (SObject) argsMap.get('sender');

        Id objectId = (Id) sender.get('Id');

        switch on method{
            when 'activation', 'deactivation', 'service26' {
                if(system.isQueueable() || system.isBatch()){
                    asyncCalloutFuture(objectId, method);
                }else{
                    system.enqueueJob(new HDT_QBL_AsycnronousCallout(
                        objectId, method
                        )
                    );
                }
                
            }
            when 'updatePhase'{
                Order currentOrder = (Order) sender;
                Boolean isServiceType = (currentOrder.VASType__c==VAS_SERVICE_TYPE);
                String newPhase = isServiceType?ORDER_PHASE_WAIT_FOR_AFTERTHOUGHT:ORDER_PHASE_VAS_COMMUNICATION;

                system.enqueueJob(new HDT_QBL_AsycnronousUpdate(
                    objectId, newPhase
                    )
                );
            }
            when 'contracted'{
                asyncUpdateContracted(objectId);
            }
        }
        
        return null;
    }


    @future(callout=true)
    private static void asyncUpdateContracted(Id sobjectId){
        orderSrv.updateRecord(new Order(Id=sobjectId, SBQQ__Contracted__c=true));
    }

    /**
    * @description Executes callout in future context
    * @author gabriele.rota@webresults.it | 2021-07-12 
    * @param sobjectId  
    * @param method  
    **/
    @future(callout=true)
    private static void asyncCalloutFuture(Id sobjectId, String method){
        asyncCallout(sobjectId, method);
    }

    /**
    * @description Executes callout and updates Order/Case phase based on the outcome
    * @author gabriele.rota@webresults.it | 2021-07-12 
    * @param sobjectId  
    * @param method  
    **/
    private static void asyncCallout(Id sobjectId, String method){
        HDT_WS_ArrichmentDataEntityResponse res;
        String newPhase;
        String errorDescription;

        //gabriele.rota@webresults.it | 2021-09-27
        if (sobjectId.getSobjectType().getDescribe().getName()=='Order') {
            Order currentOrder = orderQr.getRecordById(sobjectId);
            if (currentOrder.Phase__c==PHASE_SEQUENZIALIZZATO) {
                //l'Ordine è stato sequenzializzato, non deve essere inviato al Motore VAS
                return;
            }
        }

        switch on method{
            when 'activation'{
                res = HDT_WS_MotoreVas.activationCallout(sobjectId);
                Boolean isSuccess = (res.statusCode==200 || res.statusCode==201);
                if (!isSuccess) {
                    if (String.isNotBlank(res.exceptionMessage)){
                        errorDescription = res.exceptionMessage;
                    }
                    else {
                        errorDescription = res.errorDetails[0].message;
                    }
                }
                newPhase = isSuccess?'Comunicazione verso Motore VAS OK': errorDescription.startsWithIgnoreCase(PHASE_KO_PRODOTTO)? 'Ko prodotto vas' : 'Comunicazione verso Motore VAS KO';
            }
            when 'deactivation'{
                res = HDT_WS_MotoreVas.deactivationCallout(sobjectId);
                Boolean isSuccess = (res.statusCode==200 || res.statusCode==201);
                newPhase = isSuccess?'Comunicazione verso Motore VAS OK':'Comunicazione verso Motore VAS KO';
                if (!isSuccess) {
                    if (String.isNotBlank(res.exceptionMessage)){
                        errorDescription = res.exceptionMessage;
                    }
                    else {
                        errorDescription = res.errorDetails[0].message;
                    }
                }
            }
            when 'service26' {
                res = HDT_SRV_ServiceTwentySix.callService26(sobjectId);
            }
        }

        //do UpdatePhase

        if(String.isNotBlank(newPhase)){ 
            new HDT_QBL_AsycnronousUpdate().asyncronousUpdate(SobjectId, newPhase, errorDescription);
        }
    }

    /**
    * @description Class for callout in Queueable context
    * @author gabriele.rota@webresults.it | 2021-07-12 
    **/
    public class HDT_QBL_AsycnronousCallout implements Queueable, Database.AllowsCallouts{
        private Id sobjectId{get;set;}
        private String method{get;set;}

        /**
        * @description Constructor
        * @author gabriele.rota@webresults.it | 2021-07-12 
        **/
        public HDT_QBL_AsycnronousCallout(){
            return;
        }

        /**
        * @description Constructor with record id and method
        * @author gabriele.rota@webresults.it | 2021-07-12 
        * @param sobjectId  
        * @param method  
        **/
        public HDT_QBL_AsycnronousCallout(Id sobjectId, String method){
            this.sobjectId=sobjectId;
            this.method = method;
        }

        /**
        * @description Constructor with record id (string type) and method
        * @author gabriele.rota@webresults.it | 2021-07-12 
        * @param sobjectId  
        * @param method  
        **/
        public HDT_QBL_AsycnronousCallout(String sobjectId, String method){
            this((Id) sobjectId, method);
        }

        /**
        * @description Executes callout
        * @author gabriele.rota@webresults.it | 2021-07-12 
        * @param context  
        **/
        public void execute(QueueableContext context){
            asyncCallout(sobjectId, method);
        }
    }
    
    /**
    * @description Class for update DML in Queueable context
    * @author gabriele.rota@webresults.it | 2021-07-12 
    **/
    public class HDT_QBL_AsycnronousUpdate implements Queueable {
        private Id sobjectId{get;set;}
        private String newPhase{get;set;}
        
        /**
        * @description Constructor
        * @author gabriele.rota@webresults.it | 2021-07-12 
        **/
        public HDT_QBL_AsycnronousUpdate(){
            return;
        }

        /**
        * @description Constructor with record id and new phase
        * @author gabriele.rota@webresults.it | 2021-07-12 
        * @param sobjectId  
        * @param method  
        **/
        public HDT_QBL_AsycnronousUpdate(Id sobjectId, String newPhase){
            this.sobjectId=sobjectId;
            this.newPhase = newPhase;
        }

        /**
        * @description Constructor with record id (string type) and new phase
        * @author gabriele.rota@webresults.it | 2021-07-12 
        * @param sobjectId  
        * @param method  
        **/
        public HDT_QBL_AsycnronousUpdate(String sobjectId, String newPhase){
            this((Id) sobjectId, newPhase);
        }

        /**
        * @description Executes update
        * @author gabriele.rota@webresults.it | 2021-07-12 
        * @param context  
        **/
        public void execute(QueueableContext context){
            asyncronousUpdate(sobjectId, newPhase, null);
        }
        
        /**
        * @description Updates order/case record with given phase and Vas status
        * @author gabriele.rota@webresults.it | 2021-07-12 
        * @param sobjectId  
        * @param newPhase  
        * @param errorDescription  
        **/
        public void asyncronousUpdate(Id sobjectId, String newPhase, String errorDescription){
            Sobject sender;
            String errorField;
            switch on sobjectId.getSobjectType().getDescribe().getName() {
                when 'Case' {
                    sender = (SObject) new Case();
                    errorField = 'DiscardDescription__c';
                }
                when 'Order' {
                    sender = (SObject) new Order();
                    errorField = 'DiscardReason__c';
                }
                when else {
                    throw new HDT_UTL_HeraException('Invalid sObject provided');
                }
            }
            
            sender.put('Id', sobjectId);
            sender.put('Phase__c', newPhase);
            if (String.isNotBlank(errorDescription)) {
                sender.put(errorField, errorDescription);
            }
            Database.update(sender);
        }
    }

}