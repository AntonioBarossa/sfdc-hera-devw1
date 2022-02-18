public inherited sharing class HDT_WRP_Practices {

    public class HDT_WRP_ReturnMetadataObj {
        @AuraEnabled public Boolean success;
        @AuraEnabled public String message;
        @AuraEnabled public List<HDT_WRP_TableMetadata> tables;
    }

    public class HDT_WRP_TableMetadata {
        @AuraEnabled public String tableTitle;
        @AuraEnabled public String tableName;
        @AuraEnabled public String iconName;
        @AuraEnabled public List<HDT_WRP_ColumnObj> columns;
    }

    public class HDT_WRP_ColumnObj {
        @AuraEnabled public String fieldName;
        @AuraEnabled public String label;
        @AuraEnabled public Integer initialWidth;
        @AuraEnabled public String type;
        @AuraEnabled public Boolean sortable;
    }

}