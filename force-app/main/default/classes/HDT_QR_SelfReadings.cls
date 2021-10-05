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

    /*public List<HDT_SelfReadingError__mdt> getDiscardConfiguration(String errorType, String errorCode) {
        List<HDT_SelfReadingError__mdt> config = [SELECT Id, IsAutomaticDiscard__c FROM HDT_SelfReadingError__mdt WHERE Type__c = :errorType AND ErrorCode__c = :errorCode WITH SECURITY_ENFORCED];
        return config;
    }*/

    public List<HDT_SelfReadingError__mdt> getDiscardConfigurations(Set<String> errorCodes) {
        List<String> errorTypes = new List<String>();
        errorTypes.add('Esito KO pre-MDM');
        errorTypes.add('Esito KO da SAP');
        Map<Id, HDT_SelfReadingError__mdt> firstQuery = new Map<Id, HDT_SelfReadingError__mdt>([SELECT Id, ErrorCode__c, IsAutomaticDiscard__c,Description__c FROM HDT_SelfReadingError__mdt WHERE Type__c IN :errorTypes AND ErrorCode__c IN :errorCodes  WITH SECURITY_ENFORCED]);
        Map<Id, HDT_SelfReadingError__mdt> secondQuery = new Map<Id, HDT_SelfReadingError__mdt>([SELECT Id, ErrorCode__c, IsAutomaticDiscard__c,Description__c FROM HDT_SelfReadingError__mdt WHERE Type__c IN :errorTypes AND Description__c IN :errorCodes  WITH SECURITY_ENFORCED]);
        //List<HDT_SelfReadingError__mdt> configs = [SELECT Id, ErrorCode__c, IsAutomaticDiscard__c,Description__c FROM HDT_SelfReadingError__mdt WHERE Type__c IN :errorTypes AND (ErrorCode__c IN :errorCodes OR Description__c IN:errorCodes) WITH SECURITY_ENFORCED];
        firstQuery.putAll(secondQuery);
        List<HDT_SelfReadingError__mdt> recordList = new List<HDT_SelfReadingError__mdt>();
        /*for(HDT_SelfReadingError__mdt singleRecord : firstQuery){
            recordList.add(singleRecord);
        }*/
        System.debug('firstQuery.values() size:' + firstQuery.values().size());
        
        return firstQuery.values();
    }

    public Id getReadingId(String objectName, Id objectId, String commodity) {
        SObjectType objtype = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult objRes = objtype.getDescribe();

        if(objRes.isAccessible()) {
            
            String relationshipName = commodity.equals('Gas') ? 'GasReadings__r' : 'EleReadings__r'; // TODO WAVE 2: adeguare per altre commodity.
            String queryTemplate = 'SELECT Id, (Select Id from {0} LIMIT 1) FROM {1} WHERE Id = :objectId';
            List<String> queryParameters = new List<String> { relationshipName, objectName };
            String query = String.format(queryTemplate, queryParameters);

            System.debug('Query: ' + query);
            List<SObject> objects = Database.query(query);
            
            List<Reading__c> objReadings = objects[0].getSObjects(relationshipName);
            Id readingId = (Id) objReadings[0].get('Id');

            return readingId;
        }

        return null;
    }

    public Reading__c getReading(String objectName, Id objectId, String commodity, String readingFields) {
        SObjectType objtype = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult objRes = objtype.getDescribe();
        
        if(objRes.isAccessible()) {
            
            String relationshipName = commodity.equals('Gas') ? 'GasReadings__r' : 'EleReadings__r';
            String queryTemplate = 'SELECT Id, (Select {0} from {1} LIMIT 1) FROM {2} WHERE Id = :objectId';
            List<String> queryParameters = new List<String> { readingFields, relationshipName, objectName };
            String query = String.format(queryTemplate, queryParameters);

            List<SObject> objects = Database.query(query);
            System.debug('getReading - objects found: ' + objects.size());
            
            List<Reading__c> objReadings = objects[0].getSObjects(relationshipName);
            System.debug('getReading - objects ' + commodity + ' found: ' + objReadings.size());
            
            return objReadings[0];
        }

        return null;
    }

    public Contract getContractBySapCode(String contractCode) {
        List<Contract> contracts = [
            SELECT 
            Id,
            AccountId,
            ServicePoint__r.Distributor__r.Code__c,
            ServicePoint__c
            FROM Contract WHERE SAPContractCode__c = :contractCode
            WITH SECURITY_ENFORCED
        ];

        if (!contracts.isEmpty()) {
            return contracts[0];
        }

        return null;
    }

    public List<Order> accountOrders(String accountId, String servicePointId, List<Id> recordTypeIds, List<String> badPhases, List<String> badStates) {

        List<Order> orders = new List<Order>();

        SObjectType objtype = Schema.getGlobalDescribe().get('Order');
        Schema.DescribeSObjectResult objRes = objtype.getDescribe();

        if(objRes.isAccessible()) {

            String query = 'SELECT Id, EffectiveDate__c, CreatedDate, RecordType.DeveloperName FROM Order';

           /* if (String.isNotBlank(accountId)) {
                query += ' WHERE AccountId = :accountId';
            }*/

            if (String.isNotBlank(servicePointId)) {
                query += ' WHERE ServicePoint__c = :servicePointId';
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
            
            /*
            System.debug('utl_isProcessReadingTest: accountId => ' + accountId);
            System.debug('utl_isProcessReadingTest: servicePointId => ' + servicePointId);
            System.debug('utl_isProcessReadingTest: recordTypeIds => ' + recordTypeIds);
            System.debug('utl_isProcessReadingTest: badPhases => ' + badPhases);
            System.debug('utl_isProcessReadingTest: badStates => ' + badStates);
            */
            orders = Database.query(query);

            //System.debug('HDT_QR_SelfReadings: orders => ' + orders);

        }

        return orders; 
    }

}
