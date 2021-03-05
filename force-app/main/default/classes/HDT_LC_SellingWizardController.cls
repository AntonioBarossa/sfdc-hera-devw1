/**
* @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
* @date 27/11/2020
* @description Apex controller for HDT_LCP_SellingWizard.cmp component
* @history Keltin Mesonjesi – 27/11/2020 – Created class
*/
public inherited sharing class HDT_LC_SellingWizardController {

    private static HDT_SRV_Sale saleService = new HDT_SRV_Sale();
    private static HDT_QR_Sale saleQuery = new HDT_QR_Sale();
    private static HDT_QR_Account accountQuery = new HDT_QR_Account();
    private static HDT_SRV_Account accountSrv = new HDT_SRV_Account();

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Get Account
     * @param String accountId
     * @param String fields
     * @return Account
     */
    @AuraEnabled
    public static Account getAccount(String id, String fields){
        accountSrv.checkReadAccess(fields);
        return accountQuery.getRecordById(id, fields);
    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Get Sale__c
     * @param String saleId
     * @param String fields
     * @return Sale__c
     */
    @AuraEnabled
    public static Sale__c getSale(String id, String fields){
        saleService.checkReadAccess(fields);
        return saleQuery.getRecordById(id, fields);
    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Create Sale__c
     * @param Sale__c sale
     * @return Sale__c
     */
    @AuraEnabled
    public static Sale__c createSale(Sale__c sale){

        Sale__c newSale = saleService.createRecord(sale);

        saleService.checkReadAccess('Id,Name,Account__r.Name,Account__r.FiscalCode__c,CurrentStep__c,CreatedDate');
        Sale__c retrievedSale = saleQuery.getRecordById(newSale.id, 'Id,Name,Account__r.RecordType.DeveloperName,Account__r.Name,Account__r.FiscalCode__c,Account__r.CompanyOwner__c,Account__r.Owner.Name,CurrentStep__c,CreatedDate,Campaign__c');

        return retrievedSale;
    }

}
