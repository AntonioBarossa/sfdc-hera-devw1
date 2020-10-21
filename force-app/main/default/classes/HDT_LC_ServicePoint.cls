public with sharing class HDT_LC_ServicePoint {

    public static List<ServicePoint__c> getServicePointById(Id id, String fields) {
        String stringFields = fields;
        String query = 'SELECT '+ fields +
                ' FROM ServicePoint__c WHERE Id = :id LIMIT 1';
        List<ServicePoint__c> servicePoints = Database.query(query);
        return servicePoints;
    }

    @AuraEnabled
    public static List<ServicePoint__c> getServicePoint(String code, String fields) {
        String stringCode = code.trim();
        String stringFields = fields;
        String query = 'SELECT '+ fields +
                ' FROM ServicePoint__c WHERE ServicePointCode__c = :stringCode LIMIT 1';
        List<ServicePoint__c> servicePoints = Database.query(query);
        return servicePoints;
    }

    @AuraEnabled
    public static ServicePoint__c createServicePoint(ServicePoint__c servicePoint) {

        List<ServicePoint__c> existingServicePoint = getServicePoint(servicePoint.ServicePointCode__c, 'ServicePointCode__c');

        if (!existingServicePoint.isEmpty()) {
            throw new AuraHandledException('Codice POD/PDR duplicato');
        } else {
            insert servicePoint;
            return servicePoint;
        }
    }

    @AuraEnabled
    public static ServicePoint__c updateServicePoint(ServicePoint__c servicePoint){
        List<ServicePoint__c> existingServicePoint = getServicePointById(servicePoint.Id, 'ServicePointCode__c');

        if (existingServicePoint[0].ServicePointCode__c != servicePoint.ServicePointCode__c) {
            throw new AuraHandledException('Codice POD/PDR e stato cambiato');
        } else {
            update servicePoint;
            return servicePoint;
        }
    }
}
