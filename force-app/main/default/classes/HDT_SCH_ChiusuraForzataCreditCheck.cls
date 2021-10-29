/**
 * @author alessandro.picchiri@eng.it
 * @date 24/05/2021 
*/
public inherited sharing class HDT_SCH_ChiusuraForzataCreditCheck  implements Schedulable{
    public void execute(SchedulableContext sc){
        Integer lastNDays = (Integer)[SELECT LAST_N_DAYS__c FROM ForzaturaChiusuraCreditCheck__c].LAST_N_DAYS__c;
        String query = 'SELECT id,Order__c,Status__c FROM wrts_prcgvr__Activity__c	 WHERE LastModifiedDate != LAST_N_DAYS:'+ lastNDays + ' and CreditCheckResults__c = \'KO\'';
        HDT_VFC_ForzaturaChiusuraCreditCheck chiusuraForzataCreditCheck = new HDT_VFC_ForzaturaChiusuraCreditCheck(query);
        Database.ExecuteBatch(chiusuraForzataCreditCheck);
    } 
}