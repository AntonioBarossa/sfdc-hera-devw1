public with sharing class HDT_SRV_InstallmentPlansTari {

    private static HDT_QR_Case caseQr = new HDT_QR_Case();

    @InvocableMethod(label = 'Predefault valori pianoRate tari')
    public static void predefaultTariInstallmentFields (List<HDT_UTL_FlowInputs> inputs) {

        HDT_UTL_FlowInputs input = inputs.get(0);

        Case currentCase = caseQr.getRecordById(input.recordId);

        System.debug(inputs);


        List<InstallmentsPlanConfig__c> instalmentsPlans = [SELECT AmountToPayInInstallments__c, MaxInstallmentsNumber__c, MinInstallmentAmount__c, MinAmountForSingleInstalment__c, MandatoryAttachments__c 
                                                           FROM InstallmentsPlanConfig__c 
                                                           WHERE City__c = :input.comuneUbicazione AND RateCategory__C = :input.prodottoDiPrimoLivello 
                                                           WITH SECURITY_ENFORCED ];

        for (InstallmentsPlanConfig__c icp : instalmentsPlans) {

            Boolean finalExpressionResult;

            String installmentAmountFormula = icp.AmountToPayInInstallments__c;
            List<String> installmentAmountFormulaSplit = installmentAmountFormula.containsIgnoreCase('AND') ? installmentAmountFormula.split('AND') 
                                                                                                            : installmentAmountFormula.containsIgnoreCase('OR') ? installmentAmountFormula.split('OR') 
                                                                                                                                                                : new List<String>{installmentAmountFormula};

            System.debug('icp ' + icp);
            System.debug(installmentAmountFormula);
            System.debug(installmentAmountFormulaSplit);
            
            Boolean firstExpressionResult = evaluateExpression(input.importoDaRateizzare, installmentAmountFormulaSplit.get(0), '{0}');            
            Boolean secondExpressionResult = installmentAmountFormulaSplit.size() > 1 ? evaluateExpression(input.importoDaRateizzare, installmentAmountFormulaSplit.get(1), '{0}') : false;

            System.debug('firstExpressionResult ' + firstExpressionResult);
            System.debug('secondExpressionResult ' + secondExpressionResult);

            if (installmentAmountFormula.containsIgnoreCase('AND')) {
                finalExpressionResult = firstExpressionResult && secondExpressionResult;
            } else if (installmentAmountFormula.containsIgnoreCase('OR')) {
                finalExpressionResult = firstExpressionResult || secondExpressionResult;
            } else {
                finalExpressionResult = firstExpressionResult;
            }

            system.debug('finalExpressionResult ' + finalExpressionResult);

            if (finalExpressionResult) {
                
                currentCase.MinInstallmentAmount__c = icp.MinInstallmentAmount__c;
                currentcase.MinAmountForSingleInstalment__c = icp.MinAmountForSingleInstalment__c;
                currentcase.MandatoryAttachments__c = icp.MandatoryAttachments__c;
                currentcase.MaxInstallmentsNumber__c = icp.MaxInstallmentsNumber__c;

                break;

            }
            
        }

        system.debug(currentCase);

        update currentCase;

    }

    public static Boolean evaluateExpression(Decimal numericValue, String expression, string placeholderString){

        boolean res = false;

        expression = expression.replace(placeholderString, String.valueOf(numericValue)).trim();

        List<String> expressionSplit = expression.split(' ');

        switch on expressionSplit.get(1) {
            when '<' {
                System.debug('<');
                res = Decimal.valueOf(expressionSplit.get(0)) < Decimal.valueOf(expressionSplit.get(2));
            }
            when '<=' {
                System.debug('<=');
                res = Decimal.valueOf(expressionSplit.get(0)) <= Decimal.valueOf(expressionSplit.get(2));
            }
            when '=' {
                System.debug('=');
                res = Decimal.valueOf(expressionSplit.get(0)) == Decimal.valueOf(expressionSplit.get(2));
            }
            when '==' {
                System.debug('==');
                res = Decimal.valueOf(expressionSplit.get(0)) == Decimal.valueOf(expressionSplit.get(2));
            }
            when '>' {
                System.debug('>');
                res = Decimal.valueOf(expressionSplit.get(0)) > Decimal.valueOf(expressionSplit.get(2));
            }
            when '>=' {
                System.debug('>');
                res = Decimal.valueOf(expressionSplit.get(0)) >= Decimal.valueOf(expressionSplit.get(2));
            }
            when else {
                System.debug('default');
                res = false;
            }
        }

        return res;

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
}
