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
        return Database.getQueryLocator('SELECT Id,Status, DocusignExpirationDate__c,SignatureMethod__c,Phase__c,CancellationReason__c,(select id,Status,Phase__c from Orders__r where Phase__c NOT IN (\'Completata\', \'Annullato\',\'Voltura Rifiutata\')) FROM Order WHERE (DocusignExpirationDate__c != null AND DocusignExpirationDate__c < TODAY ) and Phase__c NOT IN (\'Documentazione Gestita\',\'Annullato\',\'Completata\') and SignatureMethod__c=\'OTP Remoto\'');
    }
    
    //BATCH EXECUTE
    public void execute(Database.BatchableContext bc, List<Order> ordersToNullify){
        Set<Id> orderIdSetToWork=new Set<Id>();
        List<Id> parentOrderList=new List<Id>(ordersToNullify.size());
        for(Order myOrder : ordersToNullify){
            orderIdSetToWork.add(myOrder.Id);
            parentOrderList(myOrder.Id);
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
        for(wrts_prcgvr__Activity__c act : actToClose){
            act.wrts_prcgvr__Status__c='Annullata';
        }
        HDT_UTL_DatabaseService.updateSObject(actToClose);

        //Marco Ficorella - 10/11/2022 GestioneAnnullamentoOrdiniNonFirmati --> Preparo la lista e aggiorno i record di order
        List<Order> orderListToUpdate=new List<Order>(orderIdSetToWork.size());
        for(Id orderId : orderIdSetToWork){
            orderListToUpdate.add(new Order(Id=orderId, Phase__c = 'Annullato',Status = 'Annullato',CancellationReason__c = 'Annullato per no conferma cliente'));
        }
        System.debug(LoggingLevel.DEBUG, 'HDT_BA_ExpiredOrders - Aggiorno Order Record: ' + orderListToUpdate.size());
        HDT_UTL_DatabaseService.updateSObject(orderListToUpdate);

        //Marco Ficorella - 10/11/2022 GestioneAnnullamentoOrdiniNonFirmati --> Chiamata a Docusign per la chiusura envelope
        for(Id parentOrderIdToSend:parentOrderList){
            HDT_SRV_DocumentalManagementFacade.discardDocusignEnvelope(parentOrderIdToSend);
        }
    }
    
    //BATCH FINISH
    public void finish(Database.BatchableContext bc) {
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :bc.getJobId()];
        System.debug(LoggingLevel.DEBUG, 'HDT_BA_ExpiredOrders - finished job: ' + a);
    }
    
}