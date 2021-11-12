public inherited sharing class HDT_QR_MetersList {

    public static List<HDT_MetersListColumnTable__mdt> getMetersListColumnTable(List<HDT_MetersListColumnTable__mdt> metersListColumnTable){
        metersListColumnTable = new List<HDT_MetersListColumnTable__mdt>();
        metersListColumnTable = [
            SELECT DeveloperName, MasterLabel
            FROM HDT_MetersListColumnTable__mdt
            WITH SECURITY_ENFORCED
            ORDER BY Order__c
        ];

        return metersListColumnTable;
    }

    /*public static List<HDT_ServicePointMetersList__mdt> getNamedCredential(List<HDT_ServicePointMetersList__mdt> metadataList, String code){
        metadataList = new List<HDT_ServicePointMetersList__mdt>();

        SObjectType objtype = Schema.getGlobalDescribe().get('HDT_ServicePointMetersList__mdt');
        Schema.DescribeSObjectResult objRes = objtype.getDescribe();

        if(objRes.isAccessible()){
            metadataList = [
                SELECT Endpoint__c
                FROM HDT_ServicePointMetersList__mdt
                WHERE DeveloperName = :code
                WITH SECURITY_ENFORCED
            ];
        }

        return metadataList;

    }*/

    public static List<ServicePoint__c> getServicePoint(List<ServicePoint__c> servicePointList, String recordId){
        servicePointList = new List<ServicePoint__c>();
        servicePointList = [
            SELECT Id, Name, ServicePointCode__c
            FROM ServicePoint__c
            WHERE Id = :recordId
            WITH SECURITY_ENFORCED
        ];

        return servicePointList;
    }

}