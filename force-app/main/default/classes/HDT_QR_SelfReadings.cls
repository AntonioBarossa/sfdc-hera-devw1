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

            if (!recordTypeIds.isEmpty()) {
                query += ' AND RecordTypeId IN :recordTypeIds';
            }

            System.debug('HDT_QR_SelfReadings: accountOrders query => ' + query);
            orders = Database.query(query);

            //System.debug('HDT_QR_SelfReadings: orders => ' + orders);

        }

        return orders; 
    }

}
