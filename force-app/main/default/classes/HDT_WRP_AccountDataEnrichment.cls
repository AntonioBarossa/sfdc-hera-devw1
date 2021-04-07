public inherited sharing class HDT_WRP_AccountDataEnrichment {

    public class HDT_WRP_ReturnMetadataObj {
        @AuraEnabled public Boolean success;
        @AuraEnabled public String message;
        @AuraEnabled public List<HDT_WRP_TableMetadata> tables;
    }

    public class HDT_WRP_TableMetadata {
        @AuraEnabled public String tableTitle;
        @AuraEnabled public String iconName;
        @AuraEnabled public List<HDT_WRP_ColumnObj> columns;
    }

    public class HDT_WRP_ColumnObj {
        @AuraEnabled public String fieldName;
        @AuraEnabled public String label;
    }

    public class HDT_WRP_RequestResponse {
        @AuraEnabled public Boolean success;
        @AuraEnabled public String message;
        @AuraEnabled public String body;
    }

}