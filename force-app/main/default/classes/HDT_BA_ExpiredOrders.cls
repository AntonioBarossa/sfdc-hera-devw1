@SuppressWarnings('PMD.AvoidDebugStatements')
public with sharing class HDT_BA_ExpiredOrders implements Database.Batchable<sObject> ,Database.AllowsCallouts, Schedulable {

    public void execute(SchedulableContext ctx){
        //Marco Ficorella - 10/11/2022 GestioneAnnullamentoOrdiniNonFirmati --> ora che la query prende il padre e dovendo chiudere tutte le entità correlate, si abbassa il parametro da 100 a 1
        Database.executebatch(this,1);
    }

    //BATCH START
    
    //TODO: SOSTITUIRE SEND DATE CON DocusignExpirationDate__c --> Fatto
    public Database.QueryLocator start(Database.BatchableContext bc){
        //Marco Ficorella - 10/11/2022 GestioneAnnullamentoOrdiniNonFirmati --> rimosso in quanto utilizzo il TODAY all'interno della query stessa
        //Date todayDate = Date.today();
        //Marco Ficorella - 10/11/2022 GestioneAnnullamentoOrdiniNonFirmati --> rimosso filtro per record type in quanto devono essere considerati tutti gli ordini
        //Set<String> recordTypeSet = new Set<String>{'HDT_RT_VAS','HDT_RT_ScontiBonus'};
        //Marco Ficorella - 11/11/2022 GestioneAnnullamentoOrdiniNonFirmati --> Recupero Parametri filtro da custom metadata
        List<HDT_NotSignedOrderFilterBatch__mdt> customMtdList = [SELECT ChildOrdersStatus__c,ParentOrdersStatus__c,SignatureMethod__c FROM HDT_NotSignedOrderFilterBatch__mdt where DeveloperName='NotSignedOrders' LIMIT 1];
        List<String>childOrdersStatus=customMtdList[0].ChildOrdersStatus__c.split('\n');
        List<String>parentOrdersStatus=customMtdList[0].ParentOrdersStatus__c.split('\n');
        List<String>signatureMethod=customMtdList[0].SignatureMethod__c.split('\n');

        return Database.getQueryLocator('SELECT Id,Status, DocusignExpirationDate__c,SignatureMethod__c,Phase__c,CancellationReason__c,(select id,Status,Phase__c from Orders__r where Phase__c NOT IN :childOrdersStatus ) FROM Order WHERE (DocusignExpirationDate__c != null AND DocusignExpirationDate__c < TODAY ) and Phase__c NOT IN :parentOrdersStatus and SignatureMethod__c IN :signatureMethod  ');
    }
    
    //BATCH EXECUTE
    public void execute(Database.BatchableContext bc, List<Order> ordersToNullify){
        try{
            Set<Id> orderIdSetToWork=new Set<Id>();
            List<Id> parentOrderList=new List<Id>(ordersToNullify.size());
            for(Order myOrder : ordersToNullify){
                orderIdSetToWork.add(myOrder.Id);
                parentOrderList.add(myOrder.Id);
                if(myOrder.Orders__r.size()==0){
                    continue;
                } else {
                    
                    for(Order myChildOrder:myOrder.Orders__r){
                        //Marco Ficorella - 10/11/2022 GestioneAnnullamentoOrdiniNonFirmati --> Recupero i figli
                        orderIdSetToWork.add(myChildOrder.Id);
                    }
                }
            
            }

            //Marco Ficorella - 10/11/2022 GestioneAnnullamentoOrdiniNonFirmati --> Recupero le attività da chiudere in stato Aperta e le aggiorno in Annullata
            List<wrts_prcgvr__Activity__c > actToClose=[select Id,wrts_prcgvr__Status__c from wrts_prcgvr__Activity__c where Order__c in :orderIdSetToWork and wrts_prcgvr__Status__c  ='Aperta' ];
            
            if(!actToClose.isEmpty()){
                for(wrts_prcgvr__Activity__c act : actToClose){
                    act.wrts_prcgvr__Status__c='Annullata';
                }
                System.debug(LoggingLevel.DEBUG, 'HDT_BA_ExpiredOrders - Aggiorno wrts_prcgvr__Activity__c Record: ' + actToClose.size());
            
                HDT_UTL_DatabaseService.updateSObject(actToClose);
            }

            //Marco Ficorella - 10/11/2022 GestioneAnnullamentoOrdiniNonFirmati --> Preparo la lista e aggiorno i record di order
            if(!orderIdSetToWork.isEmpty()){
                List<Order> orderListToUpdate=new List<Order>();
                for(Id orderId : orderIdSetToWork){
                    Order order = new Order(Id=orderId, Phase__c = 'Annullato',Status = 'Annullato',CancellationReason__c = 'Annullato per no conferma cliente');
                    orderListToUpdate.add(order);
                }
                System.debug(LoggingLevel.DEBUG, 'HDT_BA_ExpiredOrders - Aggiorno Order Record: ' + orderListToUpdate.size());
                
                HDT_UTL_DatabaseService.updateSObject(orderListToUpdate);

            }
            
            //Marco Ficorella - 10/11/2022 GestioneAnnullamentoOrdiniNonFirmati --> Chiamata a Docusign per la chiusura envelope
            for(Id parentOrderIdToSend:parentOrderList){
                HDT_SRV_DocumentalManagementFacade.discardDocusignEnvelope(parentOrderIdToSend);
            }

        }catch(Exception e){
            System.debug(LoggingLevel.DEBUG , e.getStackTraceString());
        }
    }
    
    //BATCH FINISH
    public void finish(Database.BatchableContext bc) {
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :bc.getJobId()];
        System.debug(LoggingLevel.DEBUG, 'HDT_BA_ExpiredOrders - finished job: ' + a);
    }
    
}