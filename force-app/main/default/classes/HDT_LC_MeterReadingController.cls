public inherited sharing class HDT_LC_MeterReadingController {

    @AuraEnabled
    public static HDT_LC_MeterReadingControllerHelper.HDT_WRP_ContractObj getContractRecords(String accountId) {
        return HDT_LC_MeterReadingControllerHelper.getContractRecordsHelper(accountId);
    }

    @AuraEnabled(cacheable=true)
    public static HDT_LC_MeterReadingControllerHelper.HDT_WRP_MeterReadingObj getMeterReadingRecords(String contractCode) {
        return HDT_LC_MeterReadingControllerHelper.getMeterReadingRecordsHelper(contractCode);
    }

}