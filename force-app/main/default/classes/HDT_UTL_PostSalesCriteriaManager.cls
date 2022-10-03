public inherited sharing class HDT_UTL_PostSalesCriteriaManager {


    public Boolean distributorManagement(String phaseStory){

        return !(phaseStory.containsIgnoreCase('Pratica non gestita per il DL'));

    }

    public Boolean secondAdmissibility(String phaseStory){

        return !(phaseStory.containsIgnoreCase('Preventivo Accettato'));

    }

    public Boolean notExecWorks(String phaseStory){

        return !(phaseStory.containsIgnoreCase('Dati Tecnici Ricevuti'));

    }
    public Boolean isRapidoToAnalitico(String orderId)
    {
        List<wrts_prcgvr__Activity__c> activities = [SELECT Id FROM wrts_prcgvr__Activity__c WHERE Type__c = 'Dati tecnici ricevuti_ Extra-sistema' AND Order__c = :orderId WITH SECURITY_ENFORCED];

        return !activities.isEmpty();
    }
    public Boolean totalResidueNotNull(SObject sender)
    {
        Decimal totalResidue = sender.get('TotalResidue__c') != null ? (Decimal)sender.get('TotalResidue__c') : null;
        return totalResidue != null && totalResidue > 0;
    }
    public Boolean totalResidueNull(SObject sender)
    {
        Decimal totalResidue = sender.get('TotalResidue__c') != null ? (Decimal)sender.get('TotalResidue__c') : null;
        return totalResidue != null && totalResidue == 0;
    }
    public Boolean areActivityOpen(String orderId)
    {

        List<wrts_prcgvr__Activity__c> activities = [SELECT Id FROM wrts_prcgvr__Activity__c WHERE Order__c = :orderId AND Type__c = 'Valori non corrispondenti' AND wrts_prcgvr__IsClosed__c = false WITH SECURITY_ENFORCED];

        return activities.isEmpty();
    }
    public Boolean activityLetturaNonInseritaInSapPresente(String caseId)
    {
        List<wrts_prcgvr__Activity__c> activities = [SELECT Id FROM wrts_prcgvr__Activity__c WHERE Case__c = :caseId AND Type__c = 'Gestione Back Office' AND wrts_prcgvr__IsClosed__c = true WITH SECURITY_ENFORCED];

        return !activities.isEmpty();
    }
    public Boolean activityLetturaNonInseritaInSapAssenti(String caseId)
    {
        List<wrts_prcgvr__Activity__c> activities = [SELECT Id, wrts_prcgvr__IsClosed__c FROM wrts_prcgvr__Activity__c WHERE Case__c = :caseId AND Type__c = 'Gestione Back Office' WITH SECURITY_ENFORCED];

        return activities.isEmpty();
    }

}