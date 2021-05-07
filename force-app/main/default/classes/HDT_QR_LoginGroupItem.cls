/**
 * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
 * @date 05/05/2021
 * @description HDT_QR_LoginGroupItem.cls - Class that holds queries for LoginGroupItem__c
 * @history Inserire Nome Cognome – Data Modifica – Descrizione della modifica
 */
public inherited sharing class HDT_QR_LoginGroupItem {
    public static List<LoginGroupItem__c> getRecordByLogin(String login){
        return [
            SELECT
            Name,
            Login__c,
            LoginGroup__c,
            LoginGroup__r.NameGroup__c
            FROM LoginGroupItem__c
            WHERE Login__c = :login
            WITH SECURITY_ENFORCED
        ];
    }
}
