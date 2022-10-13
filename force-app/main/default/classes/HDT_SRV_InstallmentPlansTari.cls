/**
 * @author Andrei Necsulescu (andrei.necsulescu@webresults.it)
 * @date 04/08/2022
 * @description populate readonly fields for tari process
 * @history Andrei Necsulescu – 04/08/2022 – Created class
 */

public with sharing class HDT_SRV_InstallmentPlansTari {

    private static HDT_QR_Case caseQr = new HDT_QR_Case();

    @InvocableMethod(label = 'Predefault valori pianoRate tari')
    public static List<HDT_UTL_FlowOutputs> predefaultTariInstallmentFields (List<HDT_UTL_FlowInputs> inputs) {

        HDT_UTL_FlowInputs input = inputs.get(0);
        HDT_UTL_FlowOutputs output = new HDT_UTL_FlowOutputs();

        Case currentCase = caseQr.getRecordById(input.recordId);

        System.debug(inputs);


        List<RentProcessRule__c> instalmentsPlans = [SELECT AmountToPayInInstallmentsFrom__c, AmountToPayInInstallmentsTo__c, MaxInstallmentsNumber__c, MinInstallmentAmount__c, MinAmountForSingleInstalment__c, MandatoryAttachments__c 
                                                     FROM RentProcessRule__c 
                                                     WHERE City__c = :input.comuneUbicazione 
                                                     AND RateCategory__C = :input.prodottoDiPrimoLivello 
                                                     AND (AmountToPayInInstallmentsFrom__c <= :input.importoDaRateizzare OR AmountToPayInInstallmentsFrom__c = null)
                                                     AND (AmountToPayInInstallmentsTo__c >= :input.importoDaRateizzare OR AmountToPayInInstallmentsTo__c = null)
                                                     WITH SECURITY_ENFORCED ];

        if (!instalmentsPlans.isEmpty()) {
            
            currentCase.MinInstallmentAmount__c = instalmentsPlans.get(0).MinInstallmentAmount__c;
            currentcase.MandatoryAttachments__c = instalmentsPlans.get(0).MandatoryAttachments__c;
            currentcase.MaxInstallmentsNumber__c = instalmentsPlans.get(0).MaxInstallmentsNumber__c;
            currentCase.Note__c = '€ ' + instalmentsPlans.get(0).MinAmountForSingleInstalment__c;
            currentCase.SupplyCity__c = input.comuneUbicazione;

            output.importoMinimoSingolaRata = instalmentsPlans.get(0).MinAmountForSingleInstalment__c;
            output.pianoRateizzazioneTrovato = true;

        }

        system.debug(currentCase);

        update currentCase;

        return new List<HDT_UTL_FlowOutputs>{output};

    }

    public class HDT_UTL_FlowInputs{

        @InvocableVariable
        public String recordId;

        @InvocableVariable
        public String comuneUbicazione;

        @InvocableVariable
        public Decimal importoDaRateizzare;

        @InvocableVariable
        public String prodottoDiPrimoLivello;

    }

    public class HDT_UTL_FlowOutputs{

        @InvocableVariable
        public Decimal importoMinimoSingolaRata;

        @InvocableVariable
        public Boolean pianoRateizzazioneTrovato = false;

    }
}
