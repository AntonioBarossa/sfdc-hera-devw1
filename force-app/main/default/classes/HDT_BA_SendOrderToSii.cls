/*Author: Edoardo Zanatta
* Date: 18/01/2022
 */

public class HDT_BA_SendOrderToSii implements Database.Batchable<sObject> {

    public Iterable<sObject> start(Database.BatchableContext bc) {

        Date tday = System.today();
        List <Order> orderList = new List <Order>();

        orderList = [SELECT id, Phase__c, DateSentToSII__c FROM Order WHERE Phase__c = 'In attesa tempi di ripensamento' AND DateSentToSII__c = :tday];
        return orderList;
    }

    public void execute(Database.BatchableContext bc, List<Order> scope){

        for(Order allOrder : scope){
            allOrder.Phase__c = 'Comunicazione verso Heroku';
        }

        update scope;
    }
    
    public void finish(Database.BatchableContext bc){
        
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