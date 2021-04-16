public inherited sharing class HDT_QR_AccountStatement {

    public static List<HDT_TabConfiguration__mdt> getTabMetaData(List<HDT_TabConfiguration__mdt> tabMetadataList){
        tabMetadataList = new List<HDT_TabConfiguration__mdt>();
        tabMetadataList = [
            SELECT Label, DeveloperName, ShowTab__c, TabOrder__c
            FROM HDT_TabConfiguration__mdt
            WITH SECURITY_ENFORCED
            ORDER BY TabOrder__c
        ];
        return tabMetadataList;       
    }

    public static List<HDT_ColumnsSecondLevel__mdt> getColumnsSecondLevel(List<HDT_ColumnsSecondLevel__mdt> colSecList, String tabValue){
        colSecList = new List<HDT_ColumnsSecondLevel__mdt>();
        colSecList = [
            SELECT MasterLabel, ColumnOrder__c, FieldName__c, InitialWidth__c, IsFilter__c, IsVisible__c, Sortable__c
            FROM HDT_ColumnsSecondLevel__mdt
            WHERE IsVisible__c = true AND Tab__r.DeveloperName = :tabValue
            WITH SECURITY_ENFORCED
            ORDER BY ColumnOrder__c ASC
        ];
        return colSecList;
    }

    /*public static List<HDT_StatementRequest__mdt> getStatementRequestMetaData(List<HDT_StatementRequest__mdt> mdtList, String requestType){
        mdtList = new List<HDT_StatementRequest__mdt>();
        mdtList = [
            SELECT Aggregation__c, StatementType__c, TransactionType__c, LoginId__c
            FROM HDT_StatementRequest__mdt
            WHERE DeveloperName = :requestType
            WITH SECURITY_ENFORCED
        ];
        return mdtList;
    }*/

    public static List<HDT_TabConfiguration__mdt> getTabConfigurationMetaData(List<HDT_TabConfiguration__mdt> endPointMDT, String tabCode){
        endPointMDT = new List<HDT_TabConfiguration__mdt>();
        endPointMDT = [
            SELECT EndpointService__c, UseMockService__c, Authorization__c
            FROM HDT_TabConfiguration__mdt
            WHERE DeveloperName = :tabCode
            WITH SECURITY_ENFORCED
        ];
        return endPointMDT;       
    }

    public static List<HDT_HeraCompany__mdt> getCompanyList(List<HDT_HeraCompany__mdt> companyList){
        companyList = new List<HDT_HeraCompany__mdt>();
        companyList = [
            SELECT DeveloperName, Label
            FROM HDT_HeraCompany__mdt
            WITH SECURITY_ENFORCED
        ];
        return companyList;
    }

    public static List<HDT_ColumnsFirstLevel__mdt> getColumnMetaDataList(List<HDT_ColumnsFirstLevel__mdt> column_mdtList, String tabValue){ 
        column_mdtList = new List<HDT_ColumnsFirstLevel__mdt>();
        column_mdtList = [
            SELECT MasterLabel, FieldName__c, DeveloperName, IsAmountField__c, IsSortable__c, FieldType__c, ShowTotAmountHere__c, ColumnOrder__c, IsVisible__c, IsFilter__c
            FROM HDT_ColumnsFirstLevel__mdt
            WHERE Tab__r.DeveloperName = :tabValue AND IsVisible__c = true
            WITH SECURITY_ENFORCED
            ORDER BY ColumnOrder__c ASC
        ];
        return column_mdtList;
    }

    public static List<HDT_TabConfiguration__mdt> getTabConfMetadataList(List<HDT_TabConfiguration__mdt> mdtTabConfList, String tabValue){
        mdtTabConfList = new List<HDT_TabConfiguration__mdt>();
        mdtTabConfList = [
            SELECT MasterLabel, HasSecondLevel__c, DeveloperName, SecondLevelAPI_Name__c, HasAmountField__c
            FROM HDT_TabConfiguration__mdt
            WHERE DeveloperName = :tabValue
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        return mdtTabConfList;
    }

    public static List<Account> getAccountData(String accId){
        List<Account> accList = new List<Account>();
        accList = [
            SELECT Name, CustomerCode__c
            FROM Account
            WHERE Id = :accId
            WITH SECURITY_ENFORCED
            ];
        return accList;
    }

    public static List<HDT_ButtonDetails__mdt> getButtonMetadataList(List<HDT_ButtonDetails__mdt> mdtButtonList, String tabValue, String level){
        mdtButtonList = new List<HDT_ButtonDetails__mdt>();
        mdtButtonList = [
            SELECT MasterLabel, DeveloperName, ButtonCode__c,ButtonLevel__c,ButtonOrder__c,IsVisible__c, Tab__r.DeveloperName, ButtonType__c
            FROM HDT_ButtonDetails__mdt	
            WHERE Tab__r.DeveloperName = :tabValue AND ButtonLevel__c = :level
            ORDER BY ButtonOrder__c ASC
        ];
        return mdtButtonList;
    }

    public static List<HDT_ButtonDetails__mdt> getButtonParameters(List<HDT_ButtonDetails__mdt> mdtButtonList, String tabValue, String buttonCode){
        mdtButtonList = new List<HDT_ButtonDetails__mdt>();
        mdtButtonList = [
            SELECT Parameters__c
            FROM HDT_ButtonDetails__mdt	
            WHERE Tab__r.DeveloperName = :tabValue AND ButtonCode__c = :buttonCode
            ORDER BY ButtonOrder__c ASC
        ];
        return mdtButtonList;        
    }

}