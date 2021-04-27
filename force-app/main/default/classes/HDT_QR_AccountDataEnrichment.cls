public  inherited sharing  class HDT_QR_AccountDataEnrichment {

    public static List<HDT_AccountDataEnrichment__mdt> getAccountDataEnrichment(List<HDT_AccountDataEnrichment__mdt> enrichmentbMetadataList, String tabCode){
        enrichmentbMetadataList = new List<HDT_AccountDataEnrichment__mdt>();
        enrichmentbMetadataList = [
            SELECT Label, DeveloperName, Authorization__c, ColumnData__c, Credential__c, UseMock__c
            FROM HDT_AccountDataEnrichment__mdt
            WHERE DeveloperName = :tabCode
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        return enrichmentbMetadataList;       
    }

    public static List<Account> getAccountRecords(List<Account> accList, String recordId){
        accList = new List<Account>();
        accList = [
            SELECT Id, CustomerCode__c
            FROM Account
            WHERE Id = :recordId
            WITH SECURITY_ENFORCED
            LIMIT 1            
        ];
        return accList;
    }

    public static List<HDT_MeterReadingTranscodeMap__mdt> getReadingsTranscodeMap(){
        List<HDT_MeterReadingTranscodeMap__mdt> transcodeMap = [
            SELECT TranscodeType__c, SapValue__c, SalesforceValue__c
            FROM HDT_MeterReadingTranscodeMap__mdt
            WITH SECURITY_ENFORCED
        ];

        return transcodeMap;
    }

}