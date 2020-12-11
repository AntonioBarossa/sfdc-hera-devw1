/**
 * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
 * @date 11/12/2020
 * @description Class that holds methods that are called from hdtConfigurePaymentMethods.js
 * @history Inserire Nome Cognome – Data Modifica – Descrizione della modifica
 */
public inherited sharing class HDT_LC_ConfigurePaymentMethods {
    
    private static HDT_SRV_Sale saleSrv = new HDT_SRV_Sale();
    
    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Update Sale
     * @param Sale__c sale
     */
    @AuraEnabled
    public static void updateSale(Sale__c sale){
        saleSrv.updateRecord(sale);
    }
}
