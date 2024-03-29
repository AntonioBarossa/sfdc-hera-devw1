public inherited sharing class HDT_LC_MeterReadingController {

    @AuraEnabled
    public static HDT_WRP_MeterReading.HDT_WRP_ColumnsMetadata getConfigurationData(){
        return HDT_LC_MeterReadingControllerHelper.getConfigurationDataHelper();
    }

    @AuraEnabled
    public static HDT_WRP_MeterReading.HDT_WRP_ColumnsMetadata getConfigurationDetailTable(String contractService, Boolean isFromFlow){
        return HDT_LC_MeterReadingControllerHelper.getConfigurationDetailTableHelper(contractService, isFromFlow);
    }

    @AuraEnabled
    public static HDT_WRP_MeterReading.HDT_WRP_ContractObj getContractRecords(String accountId) {
        return HDT_LC_MeterReadingControllerHelper.getContractRecordsHelper(accountId);
    }

    @AuraEnabled
    public static HDT_WRP_MeterReading.HDT_WRP_MeterReadingObj getMeterReadingRecords(String contractCode, String modality, String contractService, Boolean isFromFlow) {
        return HDT_LC_MeterReadingControllerHelper.getMeterReadingRecordsHelper(contractCode, modality, contractService, isFromFlow);
    }

}