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
        @AuraEnabled public HDT_WRP_TypeAttributes typeAttributes;
        @AuraEnabled public Boolean sortable;
    }

    public class HDT_WRP_TypeAttributes {
        @AuraEnabled public HDT_WRP_Label label; 
        @AuraEnabled public String tooltip;
        @AuraEnabled public String target;
    }

    public class HDT_WRP_Label {
        @AuraEnabled public String fieldName;
    }
}