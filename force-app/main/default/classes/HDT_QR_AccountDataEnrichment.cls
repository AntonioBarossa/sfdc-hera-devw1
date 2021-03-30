public  inherited sharing  class HDT_QR_AccountDataEnrichment {

    public static List<AccountDataEnrichment__mdt> getAccountDataEnrichment(List<AccountDataEnrichment__mdt> enrichmentbMetadataList, String tabCode){
        enrichmentbMetadataList = new List<AccountDataEnrichment__mdt>();
        enrichmentbMetadataList = [
            SELECT Label, DeveloperName, Authorization__c, ColumnData__c, Credential__c
            FROM AccountDataEnrichment__mdt
            WHERE DeveloperName = :tabCode
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        return enrichmentbMetadataList;       
    }

}