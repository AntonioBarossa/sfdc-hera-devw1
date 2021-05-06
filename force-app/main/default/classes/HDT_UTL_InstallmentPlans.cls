public inherited sharing class HDT_UTL_InstallmentPlans {

    @InvocableMethod(label = 'checkRateizzazione')
    public static List<RentProcessRule__c> checkRentProcessRule(List<HDT_UTL_FlowInputs> inputs){

        HDT_QR_InstallmentPlans installmentsQr = new HDT_QR_InstallmentPlans();

        List<RentProcessRule__c> acceptedRules = new List<RentProcessRule__c>();

        String caseId = inputs[0].caseId;

        Case c = installmentsQr.getCaseById(caseId);

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