public inherited sharing class HDT_QR_SelfReadings {

    public List<HDT_SelfReadings__mdt> getConfigurationByName(String name) {
        try {
            List<HDT_SelfReadings__mdt> config = [SELECT Id, ReadingDateIncrease__c, ReadingDateDecrease__c, OrderRecordTypes__c, OrderBadPhases__c, OrderBadStates__c
                FROM HDT_SelfReadings__mdt WHERE DeveloperName =:name WITH SECURITY_ENFORCED];
            return config;
        } catch (Exception ex) {
            System.debug(ex);
            throw ex;
        }
    }

    public Id getReadingId(String objectName, Id objectId, String commodity) {
        SObjectType objtype = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult objRes = objtype.getDescribe();

        if(objRes.isAccessible()) {
            
            String relationshipName = commodity.equals('Gas') ? 'GasReadings__r' : 'EleReadings__r';
            String queryTemplate = 'SELECT Id, (Select Id from {0} LIMIT 1) FROM {1} WHERE Id = :objectId';
            List<String> queryParameters = new List<String> { relationshipName, objectName };
            String query = String.format(queryTemplate, queryParameters);

            List<SObject> objects = Database.query(query);

            List<Reading__c> objReadings = objects[0].getSObjects(relationshipName);
            Id readingId = (Id) objReadings[0].get('Id');

            return readingId;
        }

        return null;
    }

    public List<Order> accountOrders(String accountId, String servicePointId, List<Id> recordTypeIds, List<String> badPhases, List<String> badStates) {

        List<Order> orders = new List<Order>();

        SObjectType objtype = Schema.getGlobalDescribe().get('Order');
        Schema.DescribeSObjectResult objRes = objtype.getDescribe();

        if(objRes.isAccessible()) {

            String query = 'SELECT Id, EffectiveDate__c, CreatedDate FROM Order';

            if (String.isNotBlank(accountId)) {
                query += ' WHERE AccountId = :accountId';
            }

            if (String.isNotBlank(servicePointId)) {
                query += ' AND ServicePoint__c = :servicePointId';
            }

            if (!recordTypeIds.isEmpty()) {
                query += ' AND RecordTypeId IN :recordTypeIds';
            }

            if (!badPhases.isEmpty()) {
                query += ' AND Phase__c NOT IN :badPhases';
            }

            if (!badStates.isEmpty()) {
                query += ' AND Status NOT IN :badStates';
            }

            System.debug('HDT_QR_SelfReadings: accountOrders query => ' + query);
            orders = Database.query(query);

            //System.debug('HDT_QR_SelfReadings: orders => ' + orders);

        }

        return orders; 
    }

}
