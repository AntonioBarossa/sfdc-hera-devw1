public class HDT_WRP_MetersList {

    public class HDT_WRP_Table {
        @AuraEnabled public List<HDT_WRP_SingleColumn> columnList;
    }

    public class HDT_WRP_SingleColumn {
        @AuraEnabled public String label;
        @AuraEnabled public String fieldName;
    }

}