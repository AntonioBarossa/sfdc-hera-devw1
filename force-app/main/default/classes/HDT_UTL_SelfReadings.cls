public inherited sharing class HDT_UTL_SelfReadings {

    private static HDT_QR_SelfReadings queryHandler = new HDT_QR_SelfReadings();
    private static HDT_QR_RecordType rtQueryHandler = new HDT_QR_RecordType();
    
    @InvocableMethod(label = 'isProcessReading')
    public static List<Boolean> isProcessReading(List<HDT_UTL_SelfReadingsFlowInputs> inputs) {
        List<Boolean> results = new List<Boolean>();

        String servicePointId = inputs[0].servicePointId;
        String accountId = inputs[0].accountId;
        Date caseCreatedDate = inputs[0].caseCreatedDateTime.date();
        String metadataRecordName = inputs[0].metadataRecordName;

        List<HDT_SelfReadings__mdt> configs = queryHandler.getConfigurationByName(metadataRecordName);
        if (configs.isEmpty()) {
            System.debug('HDT_UTL_SelfReadings: Nessun custom metadata trovato.');
            results.add(false);
            return results; 
        }

        List<String> recordTypes = configs[0].OrderRecordTypes__c.split(',');
        List<Id> recordTypeIds = rtQueryHandler.getRecordTypeIdsByNames(recordTypes);
        
        List<String> badPhases = new List<String>();
        List<String> badStates = new List<String>();

        if (!String.isBlank(configs[0].OrderBadPhases__c)) {
            badPhases = configs[0].OrderBadPhases__c.split(',');
        }

        if (!String.isBlank(configs[0].OrderBadStates__c)) {
            badStates = configs[0].OrderBadStates__c.split(',');
        }

        List<Order> activeOrders = queryHandler.accountOrders(accountId, servicePointId, recordTypeIds, badPhases, badStates);

        Date contractStartDate = null;
        for (Order activeOrder : activeOrders) {
            contractStartDate = activeOrder.EffectiveDate__c;
            if (contractStartDate == null) {
                contractStartDate = activeOrder.CreatedDate.date();
            }

            Date minimumDate = contractStartDate.addDays(Integer.valueOf(configs[0].ReadingDateDecrease__c));
            Date maximumDate = contractStartDate.addDays(Integer.valueOf(configs[0].ReadingDateIncrease__c));

            if (caseCreatedDate > minimumDate && caseCreatedDate < maximumDate) {
                System.debug('Trovato processo elegibile per innesco autolettura da processo.');
                results.add(true);
                return results;
            }
        }
        
        System.debug('Nessun processo trovato per innescare una autolettura da processo.');
        results.add(false);
        return results; 
    }

    public class HDT_UTL_SelfReadingsFlowInputs {

        @InvocableVariable
        public String servicePointId;

        @InvocableVariable
        public String accountId;

        @InvocableVariable
        public Datetime caseCreatedDateTime;

        @InvocableVariable
        public String metadataRecordName;

    }
}
