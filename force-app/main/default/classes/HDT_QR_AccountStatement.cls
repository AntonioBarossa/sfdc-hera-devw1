public inherited sharing class HDT_QR_AccountStatement {

    public static List<HDT_ColumnsSecondLevel__mdt> getColumnsSecondLevel(List<HDT_ColumnsSecondLevel__mdt> colSecList, String tabValue){
        colSecList = new List<HDT_ColumnsSecondLevel__mdt>();
        colSecList = [
            SELECT MasterLabel, ColumnOrder__c, FieldName__c, InitialWidth__c, IsFilter__c, IsVisible__c, Sortable__c
            FROM HDT_ColumnsSecondLevel__mdt
            WHERE IsVisible__c = true AND Tab__r.DeveloperName =: tabValue
            WITH SECURITY_ENFORCED
            ORDER BY ColumnOrder__c ASC
        ];
        return colSecList;
    }

    public static List<HDT_StatementRequest__mdt> getStatementRequestMetaData(List<HDT_StatementRequest__mdt> mdtList, String requestType){
        mdtList = new List<HDT_StatementRequest__mdt>();
        mdtList = [
            SELECT Aggregation__c, StatementType__c, TransactionType__c, LoginId__c
            FROM HDT_StatementRequest__mdt
            WHERE DeveloperName =: requestType
        ];
        return mdtList;
    }

    public static List<HDT_TabConfiguration__mdt> getTabConfigurationMetaData(List<HDT_TabConfiguration__mdt> endPointMDT, String tabCode){
        endPointMDT = new List<HDT_TabConfiguration__mdt>();
        endPointMDT = [
            SELECT EndpointService__c
            FROM HDT_TabConfiguration__mdt
            WHERE DeveloperName =: tabCode
        ];
        return endPointMDT;       
    }

}