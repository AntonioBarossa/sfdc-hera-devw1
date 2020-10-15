public with sharing class HDT_LC_ServicePoint {

    private static CS_SelezioneFornitura__c customSetting = getCustomSetting();

    static CS_SelezioneFornitura__c getCustomSetting() {
        return [SELECT Max_Record__c, OutputServicePoint__c FROM CS_SelezioneFornitura__c][0];
    }

    @AuraEnabled
    public static List<RecordType> getRecordTypeNameById(String strRecordTypeId)
    {
        Id idrecordtypeid = Id.valueOf(strRecordTypeId);
        String recordtypeid = 'ServicePointCode__c';
        String query = 'select name from RecordType where SobjectType = :recordtypeid and Id = :idrecordtypeid' ;
        List<RecordType> recordType = Database.query(query);
        return recordType;
    } 

    @AuraEnabled
    public static List<ServicePoint__c> getServicePoint(String code, String fields) {
        String stringCode = '%' + code.trim() + '%';
        String stringFields = fields;
        String query = 'SELECT '+ fields +
                ' FROM ServicePoint__c WHERE ServicePointCode__c LIKE :stringCode LIMIT 1';
        List<ServicePoint__c> servicePoints = Database.query(query);
        return servicePoints;
    }
}
