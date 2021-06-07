/**
 * @author alessandro.picchiri@eng.it
 * @date 28/05/2021
 * @description  
*/
public with sharing class HDT_UTL_ActivityProcess {
    public static void createActivity(Map<String,List<Order>> orderMap){

        
        system.debug('HDT_UTL_ActivityProcess createActivity --> orderMap : ' + JSON.serializePretty(orderMap));

        // 3.1.2 Invio richiesta e ricezione risposta 
        // Alla ricezione di un esito KO, verrà creata su Salesforce un Activities

        List<wrts_prcgvr__Activity__c> list_activity = new List<wrts_prcgvr__Activity__c>();
        Id rtOldCustomer = [SELECT Id FROM RecordType WHERE DeveloperName = 'HDT_RT_KoPrecedeteCliente' limit 1].id;
        Id rtNewCustomer = [SELECT Id FROM RecordType WHERE DeveloperName = 'HDT_RT_CreditCheckKO' limit 1].id;

        for(String typeCustomer : orderMap.keyset()){
            for(Order order : orderMap.get(typeCustomer)){
                wrts_prcgvr__Activity__c activity = new wrts_prcgvr__Activity__c();

                if(typeCustomer == 'oldCustomer'){
                    activity.RecordTypeId = rtOldCustomer;                     
                    activity.CreditCheckResults__c = order.OutgoingCreditCheckResult__c;
                }
                        
                if(typeCustomer == 'newCustomer'){
                    activity.RecordTypeId = rtNewCustomer;                     
                    activity.CreditCheckResults__c = order.IncomingCreditCheckResult__c;
                }

                //activity.Reason__c = CreditCheckDescription__c;  // viene popolato a mano dall'operatore          
        
                //activity.CreditCheckReason__c = order.CreditCheckDescription__c; // aggiornare data model
                activity.Order__c = order.Id;
                activity.Account__c = order.AccountId;
                activity.Contact__c = order.Contact__c;
                                
                activity.Status__c = 'Creata';                
                activity.Note__c = order.CommentForDL__c;

                list_activity.add(activity);
            }

        }

        insert list_activity;
    
    }
}