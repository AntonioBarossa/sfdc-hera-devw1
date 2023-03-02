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
    /* TK 945508C - Solo per i processi di Sost. contatore cliente, richiesta lettura cliente e Consegna copia chiave GDM
    * e' necessario eseguire un controllo se il distributore sia InRete o no in modo da veicolare corretamente
    * l'avanzamento del Case.
    */
    public Boolean isDistributoreInRete(SObject sender)
    {   
        Case currentCase = (Case) sender;
        if(String.isBlank(currentCase.DistributorCode__c))
        {
            return false;
        }
        if((currentCase.Type != 'Sost. contatore cliente' && currentCase.Type != 'Richiesta lettura cliente' && currentCase.Type != 'Consegna copia chiave GdM')) 
        {
            return true;
        }
        List<HDT_LocalDispatcherInrete__mdt> cmdtInRete = [SELECT Id FROM HDT_LocalDispatcherInrete__mdt WHERE DispatcherCode__c = :currentCase.DistributorCode__c WITH SECURITY_ENFORCED];
        
        return !cmdtInRete.isEmpty();
    }
    public Boolean isNotDistributorInRete(SObject sender)
    {
        return !(isDistributoreInRete(sender));
    }

}
