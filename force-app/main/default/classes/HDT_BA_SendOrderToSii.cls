/*Author: Edoardo Zanatta
* Date: 18/01/2022
 */
@SuppressWarnings('PMD.AvoidDebugStatements')
public with sharing class HDT_BA_SendOrderToSii implements Database.Batchable<sObject>, Database.AllowsCallouts {

    public Iterable<sObject> start(Database.BatchableContext bc) {

        Date tday = System.today();
        List <Order> orderList = new List <Order>();

        orderList = [SELECT id, Phase__c, DateSentToSII__c FROM Order WHERE Phase__c = 'In attesa tempi di ripensamento' AND DateSentToSII__c <= :tday];
        return orderList;
    }

    public void execute(Database.BatchableContext bc, List<Order> scope){
        List<Order> orderToUpdate = new List<Order>();
        for(Order ord : scope){
            ord.Phase__c = 'Comunicazione verso Heroku';
            orderToUpdate.add(ord);
        }
        HDT_UTL_DatabaseService.updateSObject(scope);
    }
    
    public void finish(Database.BatchableContext bc){
        System.debug(LoggingLevel.DEBUG, 'Batch SendOrderToSii Completed');
    }    
}