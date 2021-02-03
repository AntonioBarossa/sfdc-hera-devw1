/**
* @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
* @date 18/12/2020
* @description Apex controller for HDT_LCP_ResumeSale.cmp component
* @history Keltin Mesonjesi – 18/12/2020 – Created class
*/
public inherited sharing class HDT_LC_ResumeSaleController {
    
    private static HDT_QR_Sale saleQr = new HDT_QR_Sale();
    private static HDT_SRV_Sale saleSrv = new HDT_SRV_Sale();

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Get Sale to resume
     * @param String id
     * @return Sale__c
     */
    @AuraEnabled
    public static Sale__c loadVendite(String id) { 
        
        saleSrv.checkReadAccess('Account__c,Status__c');
        return saleQr.getRecordById(id, 'Account__c,Status__c');
    }
}
