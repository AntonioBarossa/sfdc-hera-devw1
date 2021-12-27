/**
* @author Andrea Arosio (andrea.arosio@webresults.it)
* @date 15/07/2021
* @description HDT_BA_Dependencies – Batch per lo sblocco dei processi sequenzializzati
*/
@SuppressWarnings('PMD.AvoidDebugStatements')
public with sharing class HDT_BA_Dependencies implements Database.Batchable<sObject>, Schedulable {

    /**
    * @description 
    * @author federico.defelice@webresults.it | 10-11-2021 
    * @param ctx 
    **/
    public void execute(SchedulableContext ctx){
        Database.executebatch(this, 1);//Concordato con P. Sarais
    }
    
    /**
    * @author Andrea Arosio (andrea.arosio@webresults.it)
    * @date 15/07/2021
    * @description start method
    */
    public Database.QueryLocator start(Database.BatchableContext bc) {
         
        String query = 'SELECT Id, Status__c, Case__c, Order__c, Type__c, NextPhase__c '
                    + 'FROM ServiceRequest__c '
                    + 'WHERE DependOn__c = null
                    + 'AND Status__c = \''+String.escapeSingleQuotes(HDT_UTL_Dependencies.STATUS_SEQUENZIALIZZATO)+'\' '
                    + ' WITH SECURITY_ENFORCED';

        return Database.getQueryLocator(query);
    }
     
    /**
    * @author Andrea Arosio (andrea.arosio@webresults.it)
    * @date 15/07/2021
    * @description execute method
    */
    public void execute(Database.BatchableContext bc, List<ServiceRequest__c> srList) {
        Integer recordsProcessed = 0;
        List<ServiceRequest__c> serviceRequestsToBeSequenced = new List<ServiceRequest__c>();
        List<Order> ordersToBeUpdated = new List<Order>();
        List<Case> casesToBeUpdated = new List<Case>();

        for(ServiceRequest__c sr : srList) {        
            if(sr.Type__c.equalsIgnoreCase(HDT_UTL_Dependencies.TIPOLOGY_POSTSALES)){
                Case caseToUpdate = new Case(ID=sr.Case__c);
                caseToUpdate.Status = HDT_UTL_Dependencies.STATUS_LAVORAZIONE;
                caseToUpdate.Phase__c = sr.NextPhase__c;
                casesToBeUpdated.add(caseToUpdate);
            }else if(sr.Type__c.equalsIgnoreCase(HDT_UTL_Dependencies.TIPOLOGY_SALES)){
                Order orderToUpdate = new Order(ID=sr.Order__c);
                orderToUpdate.Status = HDT_UTL_Dependencies.STATUS_LAVORAZIONE;
                orderToUpdate.Phase__c = sr.NextPhase__c;
                ordersToBeUpdated.add(orderToUpdate);
            }
            sr.DependOn__c = null;
            sr.Status__c = HDT_UTL_Dependencies.STATUS_LAVORAZIONE;
            serviceRequestsToBeSequenced.add(sr);
            recordsProcessed++;
        }
        if(srList.size()>0){
            Savepoint sp = Database.setSavePoint();
            try{
                if (ServiceRequest__c.SObjectType.getDescribe().isAccessible()&&
                    Schema.sObjectType.ServiceRequest__c.fields.Status__c.isAccessible()&&
                    Schema.sObjectType.ServiceRequest__c.fields.Status__c.isUpdateable()&&
                    Schema.sObjectType.ServiceRequest__c.fields.DependOn__c.isAccessible()&&
                    Schema.sObjectType.ServiceRequest__c.fields.DependOn__c.isUpdateable()&&
                    Order.SObjectType.getDescribe().isAccessible()&&
                    Schema.sObjectType.Order.fields.Status.isAccessible()&&
                    Schema.sObjectType.Order.fields.Status.isUpdateable()&&
                    Schema.sObjectType.Order.fields.Phase__c.isAccessible()&&
                    Schema.sObjectType.Order.fields.Phase__c.isUpdateable()&&
                    Case.SObjectType.getDescribe().isAccessible()&&
                    Schema.sObjectType.Case.fields.Status.isAccessible()&&
                    Schema.sObjectType.Case.fields.Status.isUpdateable()&&
                    Schema.sObjectType.Case.fields.Phase__c.isAccessible()&&
                    Schema.sObjectType.Case.fields.Phase__c.isUpdateable()){
                    
                    if(serviceRequestsToBeSequenced.size()>0){
                        update serviceRequestsToBeSequenced;
                    }
                    if(ordersToBeUpdated.size()>0){
                        update ordersToBeUpdated;
                    }
                    if(casesToBeUpdated.size()>0){
                        update casesToBeUpdated;
                    }
                }
            }catch(Exception ex){
                System.debug(LoggingLevel.ERROR, ex.getMessage());
                Database.rollback(sp);
            }
        }
        System.debug(LoggingLevel.DEBUG, recordsProcessed + ' records unlocked in the sequentialization processing');
    }   
     
    /**
    * @author Andrea Arosio (andrea.arosio@webresults.it)
    * @date 15/07/2021
    * @description finish method
    */
    public void finish(Database.BatchableContext bc) {
        System.debug(LoggingLevel.DEBUG, 'Batch execution, for unlock records in the sequentialization processing, finished');
        scheduleCallouts();
    }

    private void scheduleCallouts(){
        DateTime now = Datetime.now();
        now.addMinutes(2);
        String hour = String.valueOf(now.hour());
        String min = String.valueOf(now.minute());
        String ss = String.valueOf(now.second());

        String fireTime = ss + ' ' + min + ' ' + hour + ' * * ? '+now.year();
        Object instance = wrts_prcgvr.VersionManager.newClassInstance('AsyncJobBatchSchedule');
        System.schedule('Async Callout retry '+now, fireTime, (Schedulable) instance);
    }
}
