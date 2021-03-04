public inherited sharing class HDT_UTL_SelfReadings {

    @InvocableMethod(label = 'isProcessReading')
    public static List<Boolean> isProcessReading(List<HDT_UTL_SelfReadingsFlowInputs> inputs) {
        List<Boolean> results = new List<Boolean>();

        String podPdr = inputs[0].podPdr;
        String accountId = inputs[0].accountId;
        Date caseCreatedDate = inputs[0].caseCreatedDateTime.date();

        Id recordTypeSwitch = [SELECT Id FROM RecordType WHERE DeveloperName = 'HDT_RT_SwitchIn' WITH SECURITY_ENFORCED LIMIT 1].Id;
        Id recordTypeVoltura = [SELECT Id FROM RecordType WHERE DeveloperName = 'HDT_RT_Voltura' WITH SECURITY_ENFORCED LIMIT 1].Id;

        List<Order> activeOrders = [
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
        ];

        Date contractStartDate = null;
        for (Order activeOrder : activeOrders) {
            contractStartDate = activeOrder.EffectiveDate__c;
            if (contractStartDate == null) {
                contractStartDate = activeOrder.CreatedDate.date();
            }
            Date minimumDate = contractStartDate.addDays(-5);
            Date maximumDate = contractStartDate.addDays(3);

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

    }
}
