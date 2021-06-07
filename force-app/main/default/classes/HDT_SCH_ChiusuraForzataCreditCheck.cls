/**
 * @author alessandro.picchiri@eng.it
 * @date 24/05/2021 
*/
global class HDT_SCH_ChiusuraForzataCreditCheck  implements Schedulable{
    global void execute(SchedulableContext sc){
        String query = 'select id from wrts_prcgvr__Activity__c	 where LastModifiedDate != LAST_N_DAYS:60 and Status__c = "KO Definitivo"';
        HDT_BA_chiusuraForzataCreditCheck chiusuraForzataCreditCheck = new HDT_BA_chiusuraForzataCreditCheck(query);
        Id BatchProcessId = Database.ExecuteBatch(chiusuraForzataCreditCheck);
    }
}