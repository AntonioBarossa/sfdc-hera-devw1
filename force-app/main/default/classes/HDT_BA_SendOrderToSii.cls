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

        List<HDT_PEV_VoltureChangeManagerUpdateSObj__e> orderToSendList = new List<HDT_PEV_VoltureChangeManagerUpdateSObj__e>();

        for(Order ord : scope){
            ord.Phase__c = 'Comunicazione verso Heroku';
            HDT_PEV_VoltureChangeManagerUpdateSObj__e orderToSend = new HDT_PEV_VoltureChangeManagerUpdateSObj__e();
            orderToSend.SerializedSobj__c = JSON.serialize(ord);
            orderToSendList.add(orderToSend);
        }
        Eventbus.publish(orderToSendList);
    }
    
    public void finish(Database.BatchableContext bc){
        System.debug(LoggingLevel.DEBUG, 'Batch SendOrderToSii Completed');
    }    
}