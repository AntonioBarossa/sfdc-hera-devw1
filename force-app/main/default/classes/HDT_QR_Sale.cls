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
     * @param String id
     * @param String fields
     * @return Sale__c sale
     */
    public Sale__c getRecordById(String id, String fields){

        String query = 'SELECT '+ fields +
                ' FROM Sale__c WHERE Id = :id LIMIT 1';
        List<Sale__c> sales = Database.query(query);

        return sales[0];
    }
}
