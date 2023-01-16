@SuppressWarnings('PMD.AvoidGlobalModifier')
global inherited sharing class HDT_SRV_PostSalesManager implements wrts_prcgvr.Interfaces_1_0.IApexAction{

    private HDT_UTL_PostSalesManager psmUtl = new HDT_UTL_PostSalesManager();

    global Object execute(Object args){

        Map<String, Object> argsMap = (Map<String, Object>) args;

        /*
            @Author: Davide Viola - 20/10/2021
            Description: PMD -> Commentate variabili non utilizzate.
        */
        /*SObject transition = (SObject) argsMap.get('transition');
        SObject action = (SObject) argsMap.get('action');*/
        String method = (String) argsMap.get('method');
        SObject sender = (SObject) argsMap.get('sender');

        switch on method{
            when 'changeCaseValue'{
                psmUtl.changeCaseValue(sender);
            }
            when 'changeQuotationType'{
                psmUtl.changeQuotationType(sender);
            }
            when 'closeContract'{
                psmUtl.closeContract(sender);
            }
            when 'handleVariazioneAnagraficaCliente'{
                psmUtl.handleVariazioneAnagraficaCliente(sender);
            }
            when 'innescoAllineamentoAnagraficaFiscale'{
                psmUtl.innescoAllineamentoAnagraficaFiscale(sender);
            }
            when 'innescoAllineamentoAnagraficaCanoneRai'{
                psmUtl.innescoAllineamentoAnagraficaCanoneRai(sender);
            }
            when 'innescoAllineamentoAnagraficaGestioneDisalimentabilita'{
                psmUtl.innescoAllineamentoAnagraficaGestioneDisalimentabilita(sender);
            }
            when 'evaluateEffectiveDate'{
                psmUtl.evaluateEffectiveDate(sender);
            }
            when 'sbloccoVoltura'{
                psmUtl.sbloccoVoltura(sender);
            }
            when 'changePaymentMethod'{
                psmUtl.changePaymentMethod(sender);
            }
            when 'handleVariazioneAmministratore'{
                psmUtl.handleVariazioneAmministratore(sender);
            }
            when 'advanceParentCasePhase' {
                psmUtl.advanceParentCasePhase(sender);
            }
            when 'advanceRelatedCase'{
                psmUtl.advanceRelatedCase(sender);
            }
            when 'sendDocumentFile'{
                psmUtl.sendDocumentFile(sender);
            }
            when 'updateServicePoint'{
                psmUtl.updateServicePoint(sender);
            }
            when 'handleInvioLettureForzato'{
                HDT_SRV_SelfReadings.handleInvioLettureForzato(sender);
            }
            when 'closeRiattivazione'{
                psmUtl.closeRiattivazione(sender);
            }
            when 'updateDataFineContratto'{
                psmUtl.updateDataFineContratto(sender);
            }
            when 'closeAnnullamentoExtraSistema'{
                psmUtl.closeAnnullamentoExtraSistema(sender);
            }
            when 'createSolAcr'{
                psmUtl.createSolAcr(sender);
            }
            when 'setContractAccountCode'
            {
                psmUtl.setContractAccountCode(sender);
            }
            when 'advanceInstallmentPlan'
            {
                psmUtl.advanceInstallmentPlan(sender);
            }
            when 'submitForApproval'
            {
                psmUtl.submitForApproval(sender);
            }
            when 'recalculateVoltureEffectiveDate'
            {
                psmUtl.recalculateVoltureEffectiveDate(sender);
            }
        }

        return null;

    }

}