@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing class HDT_QR_SelfReadings {

    public List<HDT_SelfReadings__mdt> getConfigurationByName(String name) {
        try {
            List<HDT_SelfReadings__mdt> config = [SELECT Id, ReadingDateIncrease__c, ReadingDateDecrease__c, OrderRecordTypes__c, OrderBadPhases__c, OrderBadStates__c
                FROM HDT_SelfReadings__mdt WHERE DeveloperName =:name WITH SECURITY_ENFORCED];
            return config;
            
        } catch (Exception ex) {
            System.debug(LoggingLevel.DEBUG, 'getConfigurationByName - Exception TypeName: ' + ex.getTypeName());
            System.debug(LoggingLevel.DEBUG, 'getConfigurationByName - Exception Message: ' + ex.getMessage());
            System.debug(LoggingLevel.DEBUG, 'getConfigurationByName - Exception StackTraceString: ' + ex.getStackTraceString());
            throw ex;
            
        }
    }

    public List<DiscardAnnullmentRule__c> getDiscardConfigurations(Set<String> errorCodes) {
        List<String> errorTypes = new List<String>();
        errorTypes.add('Esito KO pre-MDM');
        errorTypes.add('Esito KO da SAP');
        Map<Id, DiscardAnnullmentRule__c> firstQuery = new Map<Id, DiscardAnnullmentRule__c>([SELECT Id, DiscardCode__c, ControllingCommodity__c, IsActive__c, ControllingValue__c, ActivityType__c, DiscardReason__c FROM DiscardAnnullmentRule__c WHERE ActivityType__c IN :errorTypes AND DiscardCode__c IN :errorCodes AND ProcessValue__c = 'Autolettura da cliente' AND IsActive__c = true AND RecordType.DeveloperName = 'HDT_RT_Automatic'  WITH SECURITY_ENFORCED]);
        Map<Id, DiscardAnnullmentRule__c> secondQuery = new Map<Id, DiscardAnnullmentRule__c>([SELECT Id, DiscardCode__c, ControllingCommodity__c, IsActive__c, ControllingValue__c, ActivityType__c, DiscardReason__c FROM DiscardAnnullmentRule__c WHERE ActivityType__c IN :errorTypes AND ControllingValue__c IN :errorCodes AND ProcessValue__c = 'Autolettura da cliente'  AND IsActive__c = true AND RecordType.DeveloperName = 'HDT_RT_Automatic'  WITH SECURITY_ENFORCED]);
        firstQuery.putAll(secondQuery);

        System.debug(LoggingLevel.DEBUG, 'firstQuery.values() size:' + firstQuery.values().size());
        
        return firstQuery.values();
    }

    public Id getReadingId(String objectName, Id objectId, String commodity) {
        SObjectType objtype = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult objRes = objtype.getDescribe();

        if(objRes.isAccessible()) {
            
            String relationshipName = commodity.equals('Gas') ? 'GasReadings__r' : (commodity.equals('Acqua')?'AcquaReadings__r':'EleReadings__r');
            String queryTemplate = 'SELECT Id, (Select Id from {0} LIMIT 1) FROM {1} WHERE Id = :objectId';
            List<String> queryParameters = new List<String> { relationshipName, objectName };
            String query = String.format(queryTemplate, queryParameters);

            System.debug(LoggingLevel.DEBUG, 'Query: ' + query);
            List<SObject> objects = Database.query(query);
            if(!objects.isEmpty() && (List<Reading__c>)objects[0].getSObjects(relationshipName) != null)
            {
                List<Reading__c> objReadings = objects[0].getSObjects(relationshipName);
                Id readingId = (Id) objReadings[0].get('Id');

                return readingId;
            }
            else
            {
                return null;
            }
        }

        return null;
    }
    
    @SuppressWarnings('PMD.ExcessiveParameterList')
    public Reading__c getReading(String objectName, Id objectId, String commodity, String readingFields) {
        SObjectType objtype = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult objRes = objtype.getDescribe();
        
        if(objRes.isAccessible()) {
            
            String relationshipName = commodity.equals('Gas') ? 'GasReadings__r' : (commodity.equals('Acqua')?'AcquaReadings__r':'EleReadings__r');
            String queryTemplate = 'SELECT Id, (Select {0} from {1} LIMIT 1) FROM {2} WHERE Id = :objectId';
            List<String> queryParameters = new List<String> { readingFields, relationshipName, objectName };
            String query = String.format(queryTemplate, queryParameters);

            List<SObject> objects = Database.query(query);
            System.debug(LoggingLevel.DEBUG, 'getReading - objects found: ' + objects.size());
            
            List<Reading__c> objReadings = objects[0].getSObjects(relationshipName);
            System.debug(LoggingLevel.DEBUG, 'getReading - objects ' + commodity + ' found: ' + objReadings.size());
            
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
            ServicePoint__r.CommoditySector__c,
            ServicePoint__r.ServicePointCode__c,
            ServicePoint__c,
            Status
            FROM Contract WHERE SAPContractCode__c = :contractCode
            WITH SECURITY_ENFORCED
        ];

        if (!contracts.isEmpty()) {
            return contracts[0];
        }

        return null;
    }
    
    @SuppressWarnings('PMD.ExcessiveParameterList')
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

            System.debug(LoggingLevel.DEBUG, 'HDT_QR_SelfReadings: accountOrders query => ' + query);
            
            /*
            System.debug(LoggingLevel.DEBUG, 'utl_isProcessReadingTest: accountId => ' + accountId);
            System.debug(LoggingLevel.DEBUG, 'utl_isProcessReadingTest: servicePointId => ' + servicePointId);
            System.debug(LoggingLevel.DEBUG, 'utl_isProcessReadingTest: recordTypeIds => ' + recordTypeIds);
            System.debug(LoggingLevel.DEBUG, 'utl_isProcessReadingTest: badPhases => ' + badPhases);
            System.debug(LoggingLevel.DEBUG, 'utl_isProcessReadingTest: badStates => ' + badStates);
            */
            orders = Database.query(query);

            //System.debug(LoggingLevel.DEBUG, 'HDT_QR_SelfReadings: orders => ' + orders);

        }

        return orders; 
    }

}
