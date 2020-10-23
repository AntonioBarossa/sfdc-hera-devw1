public with sharing class HDT_LC_ServicePoint {

    public static List<String> getObjAttrList(ServicePoint__c obj){

        Map<String,Object> objMap = obj.getPopulatedFieldsAsMap();

        List<String> fields = new List<String>();
        for (String field: objMap.keySet()) {
            if (! (field.equalsIgnoreCase('Id') || field.equalsIgnoreCase('attributes'))){
                fields.add(field); 
            } 
        }

        return fields;
    }

    public static List<ServicePoint__c> getServicePointById(Id id, String fields) {
        
        HDT_UTL_SecurityAccess securityAccess = new HDT_UTL_SecurityAccess('ServicePoint__c', fields, 'read');
        securityAccess.checkSecurityAccess();

        String stringId = String.escapeSingleQuotes(id);
        String stringFields = String.escapeSingleQuotes(fields);

        String query = 'SELECT '+ stringFields +
                ' FROM ServicePoint__c WHERE Id = :stringId LIMIT 1';
        List<ServicePoint__c> servicePoints = Database.query(query);

        return servicePoints;
    }

    @AuraEnabled
    public static List<ServicePoint__c> getServicePoint(String code, String fields) {
        
        HDT_UTL_SecurityAccess securityAccess = new HDT_UTL_SecurityAccess('ServicePoint__c', fields, 'read');
        securityAccess.checkSecurityAccess();

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

            List<String> fields = getObjAttrList(servicePoint);
            
            HDT_UTL_SecurityAccess securityAccess = new HDT_UTL_SecurityAccess('ServicePoint__c', String.join(fields, ','), 'create');
            securityAccess.checkSecurityAccess();

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

            Map<String,Object> objMap = servicePoint.getPopulatedFieldsAsMap();

            List<String> fields = getObjAttrList(servicePoint);
            
            HDT_UTL_SecurityAccess securityAccess = new HDT_UTL_SecurityAccess('ServicePoint__c', String.join(fields, ','), 'update');
            securityAccess.checkSecurityAccess();

            update servicePoint;
            return servicePoint;
        }
    }
}
