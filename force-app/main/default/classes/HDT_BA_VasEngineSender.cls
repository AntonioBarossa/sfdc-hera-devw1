/**
 * @description       : Scheduled job for sending Orders to Vas engine automatically after N days
 * @author            : gabriele.rota@webresults.it
 * @group             : WR
 * @last modified on  : 2021-07-27
 * @last modified by  : gabriele.rota@webresults.it
**/
public with sharing class HDT_BA_VasEngineSender implements Database.Batchable<SObject>, Schedulable{

    private static final Integer AFTERTHOUGHT_DAYS_NUMBER = 14;
    private static final String ORDER_RT_VAS = 'HDT_RT_VAS';
    private static final String ORDER_PHASE_WAIT_FOR_AFTERTHOUGHT = 'In attesa tempi di ripensamento';
    private static final String ORDER_PHASE_VAS_ENGINE_COMMUNICATION = 'Comunicazione Motore VAS';
    private static final String ORDER_PHASE_VAS_HEROKU_COMMUNICATION = 'Comunicazione verso Heroku';

    private static HDT_SRV_Order orderSrv = new HDT_SRV_Order();

    /**
    * @description Running batch
    * @author gabriele.rota@webresults.it | 2021-07-27 
    * @param sc 
    **/
    public void execute(SchedulableContext sc){
        Database.executeBatch(this);
    }

    /**
    * @description Getting orders with expired time for afterthought
    * @author gabriele.rota@webresults.it | 2021-07-27 
    * @param bc 
    * @return Database.QueryLocator 
    **/
    public Database.QueryLocator start(Database.BatchableContext bc) {
        Date nDaysAgo = Date.today().addDays(AFTERTHOUGHT_DAYS_NUMBER*-1);
        System.debug('nDaysAgo value: '+nDaysAgo);
        String query = 'SELECT Id, VASType__c FROM Order';
        query += ' WHERE Phase__c = :ORDER_PHASE_WAIT_FOR_AFTERTHOUGHT';
        query += ' AND RecordType.DeveloperName = :ORDER_RT_VAS';
        query += ' AND SignedDate__c <= :nDaysAgo';
        return Database.getQueryLocator(query);
    }

    /**
    * @description Updating Phase
    * @author gabriele.rota@webresults.it | 2021-07-27 
    * @param bc 
    * @param orders 
    **/
    public void execute(Database.BatchableContext bc, List<Order> orders) {
        for (Order currentOrder:orders) {
            currentOrder.Phase__c = currentOrder.VASType__c?.equalsIgnoreCase('VAS Fatturabili') ? ORDER_PHASE_VAS_HEROKU_COMMUNICATION : ORDER_PHASE_VAS_ENGINE_COMMUNICATION;
        }

        orderSrv.updateRecords(orders);
    }

    /**
    * @description Finish logic
    * @author gabriele.rota@webresults.it | 2021-07-27 
    * @param bc 
    **/
    public void finish(Database.BatchableContext bc) {
        /**@frpanico 17/02/2022
         * Aggiunto batch pclick per sbloccare la callout
         */
        Schedulable instance = (Schedulable) wrts_prcgvr.VersionManager.newClassInstance('AsyncJobBatchSchedule');
        instance.execute(null);
        return;
    }
}
