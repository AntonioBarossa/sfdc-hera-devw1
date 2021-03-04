public inherited sharing class HDT_QR_SelfReadings {

    public List<HDT_SelfReadings__mdt> getConfigurationByName(String name) {
        try {
            List<HDT_SelfReadings__mdt> config = [SELECT Id, ReadingDateIncrease__c, ReadingDateDecrease__c, OrderRecordTypes__c
                FROM HDT_SelfReadings__mdt WHERE DeveloperName =:name WITH SECURITY_ENFORCED];
            return config;
        } catch (Exception ex) {
            System.debug(ex);
            throw ex;
        }
    }

    public List<Order> accountOrders(String accountId, String podPdr, List<Id> recordTypeIds) {

        List<Order> orders = new List<Order>();

        SObjectType objtype = Schema.getGlobalDescribe().get('Order');
        Schema.DescribeSObjectResult objRes = objtype.getDescribe();

        if(objRes.isAccessible()) {

            String query = 'SELECT Id, EffectiveDate__c, CreatedDate FROM Order';

            if (String.isNotBlank(accountId)) {
                query += ' WHERE AccountId = :accountId';
            }

            if (String.isNotBlank(podPdr)) {
                query += ' AND ServicePointCodeFormula__c = :podPdr';
            }

            // Genera una sottoquery AND (RecordTypeId = RT1 OR RecordTypeId = RT2 OR RecordTypeId = ... )
            String rtSubquery = '';
            if (!recordTypeIds.isEmpty()) {
                rtSubquery = ' AND (RecordTypeId = \'' + recordTypeIds[0] + '\'';
            }
            // Partiamo da i=1 poichè il primo RT l'abbiamo già messo nella query.
            for (Integer i = 1; i < recordTypeIds.size(); i++) {
                rtSubquery += ' OR RecordTypeId = \'' + recordTypeIds[i] + '\'';
            }
            if (!recordTypeIds.isEmpty()) {
                rtSubquery += ')';
            }

            if (String.isNotBlank(rtSubquery)) {
                query += rtSubquery;
            }

            System.debug('HDT_QR_SelfReadings: accountOrders query => ' + query);
            orders = Database.query(query);

            //System.debug('HDT_QR_SelfReadings: orders => ' + orders);

        }

        return orders; 
    }

}
