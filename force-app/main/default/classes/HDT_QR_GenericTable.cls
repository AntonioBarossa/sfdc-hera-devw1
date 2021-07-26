public inherited sharing class HDT_QR_GenericTable {

    public HDT_GenericTable__mdt getTableConfiguration(String tableName){

        return [SELECT Id,
            Object__c,
            Mapping__c
            FROM HDT_GenericTable__mdt
            WHERE TableName__c = :tableName
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];

    }


}
