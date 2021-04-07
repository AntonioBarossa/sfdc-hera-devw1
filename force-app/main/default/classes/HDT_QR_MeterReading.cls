public inherited sharing class HDT_QR_MeterReading {
    
    public static List<HDT_AccountDataEnrichment__mdt> getAccountDataEnrichment(List<HDT_AccountDataEnrichment__mdt> enrichmentbMetadataList, String code){
        enrichmentbMetadataList = new List<HDT_AccountDataEnrichment__mdt>();
        enrichmentbMetadataList = [
            SELECT Label, DeveloperName, Authorization__c, ColumnData__c, Credential__c, UseMock__c
            FROM HDT_AccountDataEnrichment__mdt
            WHERE DeveloperName = :code
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        return enrichmentbMetadataList;       
    }

    public static List<Contract> getAccountContracts(List<Contract> contractList, String accountId){
        contractList = new List<Contract>();
        contractList = [
            SELECT Id, SAPContractCode__c, Status, EndDate, StartDate, ServicePoint__r.CommoditySector__c, ServicePoint__r.SAPImplantCode__c
            FROM Contract
            WHERE AccountId = :accountId
            AND SAPContractCode__c != null
            AND ServicePoint__c != null
            AND ServicePoint__r.CommoditySector__c != null
            AND ServicePoint__r.SAPImplantCode__c != null
            WITH SECURITY_ENFORCED
            ORDER BY Status
        ];
        return contractList;
    }

}