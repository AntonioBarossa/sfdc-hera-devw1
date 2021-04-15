public inherited sharing class HDT_UTL_InstallmentPlans {

    @InvocableMethod(label = 'checkRateizzazione')
    public static List<RentProcessRule__c> checkRentProcessRule(List<HDT_UTL_FlowInputs> inputs){

        List<RentProcessRule__c> acceptedRules = new List<RentProcessRule__c>();

        String caseId = inputs[0].caseId;

        Case c = [SELECT ClientCategory__c,TypeInstallmentPlan__c,Reason__c,CAWithOrWithoutSEPA__c,
        ExistingInstallmentPlanUnpaid__c,AmountToPayInInstallments__c,Deposit__c,Amount__c,
        CutomerAssisted__c,RefundableEscape__c,WorkStatus__c,
        ApplicationInterests__c,SuspensionInThePastTwelveMonths__c, CreatedDate,
        FirstExpirationDate__c
        FROM Case
        WHERE Id = :caseId
        WITH SECURITY_ENFORCED
        ];

        RentProcessRule__c returnedRule = HDT_QR_InstallmentPlans.queryRules(c);

        if(returnedRule != null){
               
            acceptedRules.add(returnedRule);

            return acceptedRules;

        } else {

            return null;

        }


    }

    public class HDT_UTL_FlowInputs{

        @InvocableVariable
        public String caseId;

  }


}