public with sharing class HDT_LC_ServicePoint {

    public static List<ServicePoint__c> getServicePointById(Id id, String fields) {
        String stringId = String.escapeSingleQuotes(id);
        String stringFields = String.escapeSingleQuotes(fields);

        String query = 'SELECT '+ stringFields +
                ' FROM ServicePoint__c WHERE Id = :stringId LIMIT 1';
        List<ServicePoint__c> servicePoints = Database.query(query);

        return servicePoints;
    }

    @AuraEnabled
    public static List<ServicePoint__c> getServicePoint(String code, String fields) {
        String stringCode = String.escapeSingleQuotes(code.trim());
        String stringFields = String.escapeSingleQuotes(fields);
        String query = 'SELECT '+ stringFields +
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
