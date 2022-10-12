@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing class HDT_UTL_InstallmentPlans {

    @InvocableMethod(label = 'checkRateizzazione')
    public static List<HDT_UTL_FlowOutputs> checkRentProcessRule(List<HDT_UTL_FlowInputs> inputs){

        List<HDT_UTL_FlowOutputs> outputs = new List<HDT_UTL_FlowOutputs>();
        HDT_UTL_FlowOutputs output = new HDT_UTL_FlowOutputs();

        HDT_QR_InstallmentPlans installmentsQr = new HDT_QR_InstallmentPlans();
        HDT_SRV_InstallmentPlans installmetnsSrv = new HDT_SRV_InstallmentPlans();
        
        String caseId = inputs[0].caseId;
        String errorMessge = 'Nella ricerca del Piano Rata tutti o alcuni dei valori non hanno permesso il successo dell\'operazione:\n';

        Case c = installmentsQr.getCaseById(caseId);
        List<RentProcessRule__c> ruleList = HDT_QR_InstallmentPlans.queryRules(c);
        Set<String> criteriaFields = new Set<String>{
            'ApplicationInterests__c',
            'CAWithOrWithoutSEPA__c',
            'SuspensionInThePastTwelveMonths__c',
            'Deposit__c',
            'RefundableEscape__c',
            'WorkStatus__c'};

        if (inputs[0].isTariProcess) {
            criteriaFields.addAll( new Set<String>{'BillingCity__c', 'RateCategory__c'});
        }

        Map<String, Object> criteriaMap = new Map<String, Object>();
        for(String fieldName : criteriaFields){
            criteriaMap.put(fieldName, c.get(fieldName));
        }

        output = installmetnsSrv.evaluateRuleList(ruleList, criteriaMap);
        System.debug(LoggingLevel.DEBUG, 'Here');
        if(!String.isBlank(output.errorMessage)){
            output.errorMessage = (String) (errorMessge + output.errorMessage);
        }
        outputs.add(output);
        return outputs;

    }

    public class HDT_UTL_FlowInputs{

        @InvocableVariable
        public String caseId;

        @InvocableVariable
        public Boolean isTariProcess;

    }

    public class HDT_UTL_FlowOutputs{
        @InvocableVariable
        public RentProcessRule__c rentRule;
        @InvocableVariable
        public String errorMessage;
    }


}