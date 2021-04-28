/**
* @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
* @date 18/12/2020
* @description Apex controller for HDT_LCP_ResumeSale.cmp component
* @history Keltin Mesonjesi – 18/12/2020 – Created class
*/
public inherited sharing class HDT_LC_ResumeSaleController {
    
    private static HDT_QR_Sale saleQr = new HDT_QR_Sale();
    private static HDT_SRV_Sale saleSrv = new HDT_SRV_Sale();
    private static HDT_UTL_HelperMethods helperMethods = new HDT_UTL_HelperMethods();

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Get Sale to resume
     * @param String id (Sale__c.Id)
     * @return Map<String, Object>
     */
    @AuraEnabled
    public static Map<String, Object> loadVendite(String id) { 
        
        Map<String, Object> results = new Map<String, Object>();

        Boolean isCommunity = helperMethods.checkCommunityLogin();

        saleSrv.checkReadAccess('Account__c,Status__c');
        Sale__c sale = saleQr.getRecordById(id, 'Account__c,Status__c');

        results.put('isCommunity', isCommunity);
        results.put('sale', sale);

        return results;
    }
}
