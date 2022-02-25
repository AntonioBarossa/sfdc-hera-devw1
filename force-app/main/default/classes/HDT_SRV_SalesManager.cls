/*
 * File: HDT_SRV_SalesManager.cls
 * Project: HERA
 * File Created: Monday, 19th July 2021 12:00:40 pm
 * Author: fdefelice
 * DESCRIPTION: 
 * -----
 * HISTORY:
 */
@SuppressWarnings('PMD.AvoidGlobalModifier')
global inherited sharing class HDT_SRV_SalesManager implements wrts_prcgvr.Interfaces_1_0.IApexAction {
    
    private static final String VAS_SERVICE_TYPE = 'VAS Servizio';
    private static final String ORDER_PHASE_WAIT_FOR_AFTERTHOUGHT = 'In attesa tempi di ripensamento';
    private static final String ORDER_PHASE_VAS_COMMUNICATION = 'Comunicazione Motore VAS';
    private static final String PHASE_SEQUENZIALIZZATO = 'Sequenzializzato';
    private static final String PHASE_KO_PRODOTTO = 'Cod. offerta non mappato';
    private static final String PHASE_FIELD = 'Phase__c';
    private static final String TECNICAL_PHASE_FIELD = 'TecnicalPhase__c';

    private static HDT_QR_Order orderQr = new HDT_QR_Order();
    private static HDT_SRV_Order orderSrv = new HDT_SRV_Order();
    private static boolean isPclickCallout = false;

    global HDT_SRV_SalesManager(){
        return;
    }

    public HDT_SRV_SalesManager(boolean pclickCallout){
        isPclickCallout = pclickCallout;
    }

    
    /**
    * @description Executes action invoked by Process Click
    * @author gabriele.rota@webresults.it | 2021-07-12 
    * @param args  
    * @return Object 
    **/
    global Object execute(Object args){
        Map<String, Object> argsMap = (Map<String, Object>) args;
        //SObject transition = (SObject) argsMap.get('transition');
        //SObject action = (SObject) argsMap.get('action');
        String method = (String) argsMap.get('method');
        SObject sender = (SObject) argsMap.get('sender');

        Id objectId = (Id) sender.get('Id');
        if( (System.isFuture() || System.isBatch()) && method!='service26'){
            return null;
        }

        switch on method{
            when 'activation', 'deactivation', 'service26' {
                Boolean limitQueueablesOk = Limits.getQueueableJobs() < Limits.getLimitQueueableJobs();
                if(system.isQueueable()){// && !limitQueueablesOk){//removed so i won't burn a queable if this is a queueable job
                    asyncCalloutFuture(objectId, method);
                }else if(limitQueueablesOk){
                    system.enqueueJob(new HDT_QBL_AsycnronousCallout(
                        objectId, method
                        )
                    );
                }/*else{//gestione future servizio26
                    HDT_UTL_PrClickDoubleTransaction.asyncCallouts.put(objectId, method);
                }*/
            }
            when 'contracted'{
                asyncUpdateContracted(objectId);
            }when'handleContractVariation'{
                handleContractVariation(sender);
            }
        }
        
        return null;
    }

    private static void handleContractVariation(SObject sender){
        HDT_UTL_Sales saleUtl = new HDT_UTL_Sales();
        HDT_UTL_Sales.handleContractVariation((Order)sender);
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
        customCallout(sobjectId, method);
    }

    public void vasCustomCallouts(Id sobjectId, String method){
        customCallout(sobjectId, method);
    }

    /**
    * @description Executes callout and updates Order/Case phase based on the outcome
    * @author gabriele.rota@webresults.it | 2021-07-12 
    * @param sobjectId  
    * @param method  
    **/
    private static void customCallout(Id sobjectId, String method){
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
                        String resString = JSON.serialize(res);
                        if(resString.contains(PHASE_KO_PRODOTTO)){
                            errorDescription = 'Cod. offerta non mappato';
                        }
                    }
                }
                newPhase = isSuccess?'Comunicazione verso Motore VAS OK': errorDescription.contains(PHASE_KO_PRODOTTO)? 'Ko prodotto vas' : 'Comunicazione verso Motore VAS KO';
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
                Boolean isSuccess = (res.statusCode==200 || res.statusCode==201);
                newPhase = isSuccess ? 'Comunicazione verso Heroku OK' : 'Comunicazione verso Heroku OK';
                if (!isSuccess) {
                    if (String.isNotBlank(res.exceptionMessage)){
                        errorDescription = res.exceptionMessage;
                    }
                    else {
                        errorDescription = res.errorDetails[0].message;
                    }
                }
            }
        }

        //do UpdatePhase

        if(String.isNotBlank(newPhase)){ 
            //new HDT_QBL_AsycnronousUpdate().asyncronousUpdate(SobjectId, newPhase, errorDescription);
            updateVas(SobjectId, newPhase, errorDescription);
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
            customCallout(sobjectId, method);
        }
    }

    private static void updateVas(Id sobjectId, String newPhase, String errorDescription){
        Sobject sender;
        String errorField;
        String phaseField = isPclickCallout? TECNICAL_PHASE_FIELD : PHASE_FIELD;
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
        sender.put(phaseField, newPhase);
        if (String.isNotBlank(errorDescription)) {
            sender.put(errorField, errorDescription);
        }
        Database.update(sender);
    }

}