public inherited sharing class HDT_LC_SellingWizardController {

    private static HDT_SRV_Sale saleService = new HDT_SRV_Sale();
    private static HDT_QR_Sale saleQuery = new HDT_QR_Sale();
    private static HDT_QR_Account accountQuery = new HDT_QR_Account();

    @AuraEnabled
    public static Account getAccount(String id, String fields){
        return accountQuery.getRecordById(id, fields);
    }

    @AuraEnabled
    public static Sale__c getSale(String id, String fields){
        return saleQuery.getRecordById(id, fields);
    }

    @AuraEnabled
    public static Sale__c createSale(Sale__c sale){

        Sale__c newSale = saleService.createRecord(sale);

        Sale__c retrievedSale = saleQuery.getRecordById(newSale.id, 'Id,Name,Account__r.Name,Account__r.FiscalCode__c,CreatedDate');

        return retrievedSale;
    }

}
