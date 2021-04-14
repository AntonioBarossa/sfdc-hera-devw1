public with sharing class HDT_QR_DataEnrichmentPostSales {


    public List<HDT_DataEnrichmentTransocode__mdt> getTranscodeConfig(){

        return [SELECT Id,
        SapField__c,
        SfdcField__c,
        IsNumber__c,
        Precision__c,
        IsTranscode__c,
        Method__c
        FROM HDT_DataEnrichmentTransocode__mdt
        WITH SECURITY_ENFORCED
        ];

    }

    public BillingProfile__c getBillingProfileIdBySapCode(String sapCode){

        return [SELECT Id
        FROM BillingProfile__c
        WHERE ContractAccountCode__c = :sapCode
        WITH SECURITY_ENFORCED
        LIMIT 1
        ];


    }


}
