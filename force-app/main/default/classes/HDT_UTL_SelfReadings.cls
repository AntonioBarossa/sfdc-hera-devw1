public inherited sharing class HDT_UTL_SelfReadings {

    private static HDT_QR_SelfReadings queryHandler = new HDT_QR_SelfReadings();

    @InvocableMethod(label = 'isProcessReading')
    public static List<Boolean> isProcessReading(List<HDT_UTL_SelfReadingsFlowInputs> inputs) {
        List<Boolean> results = new List<Boolean>();

        String podPdr = inputs[0].podPdr;
        String accountId = inputs[0].accountId;
        Date caseCreatedDate = inputs[0].caseCreatedDateTime.date();
        String metadataRecordName = inputs[0].metadataRecordName;

        Id recordTypeSwitch = [SELECT Id FROM RecordType WHERE DeveloperName = 'HDT_RT_SwitchIn' WITH SECURITY_ENFORCED LIMIT 1].Id;
        Id recordTypeVoltura = [SELECT Id FROM RecordType WHERE DeveloperName = 'HDT_RT_Voltura' WITH SECURITY_ENFORCED LIMIT 1].Id;

        /*List<Order> activeOrders = [
            SELECT Id, EffectiveDate__c, CreatedDate 
            FROM Order
            WHERE AccountId = :accountId
            AND ServicePointCodeFormula__c = :podPdr
            // TODO: anche HDT_RT_SwitchInVolturaTecnica ?
            AND (
                RecordTypeId = :recordTypeSwitch OR RecordTypeId = :recordTypeVoltura
            )
            // TODO: which status and/or phases ?
            //AND Status = 'In Lavorazione'
            WITH SECURITY_ENFORCED
        ];*/

        List<HDT_SelfReadings__mdt> configs = queryHandler.getConfigurationByName(metadataRecordName);
        if (configs.isEmpty()) {
            System.debug('HDT_UTL_SelfReadings: Nessun custom metadata trovato.');
            results.add(false);
            return results; 
        }

        List<Id> recordTypeIds = new List<Id>{recordTypeSwitch, recordTypeVoltura}; // TODO: move RT to metadata
        List<Order> activeOrders = queryHandler.accountOrders(accountId, podPdr, recordTypeIds);

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
        public String podPdr;

        @InvocableVariable
        public String accountId;

        @InvocableVariable
        public Datetime caseCreatedDateTime;

        @InvocableVariable
        public String metadataRecordName;

    }
}
