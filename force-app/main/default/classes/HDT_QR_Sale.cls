/**
 * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
 * @date 02/11/2020
 * @description HDT_QR_Sale.cls - Class that holds queries for Sale__c
 * @history Inserire Nome Cognome – Data Modifica – Descrizione della modifica
 */

public inherited sharing class HDT_QR_Sale {

    private static HDT_UTL_HelperMethods helperMethods = new HDT_UTL_HelperMethods();
    
    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Get Sale__c record by id
     * @param id
     * @param fields
     * @return Sale__c sale
     */
    public Sale__c getRecordById(String id, String fields){

        List<Sale__c> sales = Database.query('SELECT '+ String.escapeSingleQuotes(fields) + ' FROM Sale__c WHERE Id = :id WITH SECURITY_ENFORCED LIMIT 1');

        return sales[0];
    }
}
