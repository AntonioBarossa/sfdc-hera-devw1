/**
* @author Andrea Arosio (andrea.arosio@webresults.it)
* @date 15/07/2021
* @description HDT_BA_Dependencies – Batch per lo sblocco dei processi sequenzializzati
*/
public with sharing class HDT_BA_Dependencies implements Database.Batchable<sObject> {
    List<ServiceRequest__c> serviceRequestsToBeSequenced = new List<ServiceRequest__c>();
    List<Order> ordersToBeUpdated = new List<Order>();
    List<Case> casesToBeUpdated = new List<Case>();

    public Database.QueryLocator start(Database.BatchableContext BC) {
         
        String query = 'SELECT Id, Status__c, Case__c, Order__c, Type__c '
                    + 'FROM ServiceRequest__c '
                    + 'WHERE DependOn__r.Status__c <> \''+String.escapeSingleQuotes(HDT_UTL_Dependencies.STATUS_LAVORAZIONE)+'\' '
                    + 'AND Status__c = \''+String.escapeSingleQuotes(HDT_UTL_Dependencies.STATUS_SEQUENZIALIZZATO)+'\' '
                    + ' WITH SECURITY_ENFORCED';

        return Database.getQueryLocator(query);
    }
     
    public void execute(Database.BatchableContext BC, List<ServiceRequest__c> srList) {
        
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
        }
    }   
     
    public void finish(Database.BatchableContext BC) {
        
        Savepoint sp = Database.setSavePoint();
        try{
            if (ServiceRequest__c.SObjectType.getDescribe().isAccessible()&&
                Schema.sObjectType.ServiceRequest__c.fields.Status__c.isAccessible()&&
                Schema.sObjectType.ServiceRequest__c.fields.Status__c.isUpdateable()&&
                Order.SObjectType.getDescribe().isAccessible()&&
                Schema.sObjectType.Order.fields.Status.isAccessible()&&
                Schema.sObjectType.Order.fields.Status.isUpdateable()&&
                Case.SObjectType.getDescribe().isAccessible()&&
                Schema.sObjectType.Case.fields.Status.isAccessible()&&
                Schema.sObjectType.Case.fields.Status.isUpdateable()){

                update serviceRequestsToBeSequenced;
                update casesToBeUpdated;
                update ordersToBeUpdated;
            }
        }catch(Exception ex){
            System.debug(ex.getMessage());
            Database.rollback(sp);
        }
    }
}
