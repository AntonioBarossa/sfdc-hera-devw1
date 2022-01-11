public with sharing class HDT_UTL_ElegibilityCriteriaCheck {
    
    @InvocableMethod(label='Check Criterio Elegibilità')
    public static List<HDT_WRP_ElegibilityCriteriaCheckOutput> execute(List<HDT_WRP_ElegibilityCriteriaCheckInput> inputs){
        if(inputs==null || inputs.size()<=0) return null;
      
        HDT_WRP_ElegibilityCriteriaCheckInput input = inputs[0];
        HDT_WRP_ElegibilityCriteriaCheckOutput output = new HDT_WRP_ElegibilityCriteriaCheckOutput();
        List<HDT_WRP_ElegibilityCriteriaCheckOutput> outputList = new List<HDT_WRP_ElegibilityCriteriaCheckOutput>();

        // Query su Case
        HDT_QR_Case caseQuery = new HDT_QR_Case();
        String caseQueryFields = 'Id,Contract__c,Type,BillSendingMethod__c,Resident__c,UseCategory__c,PowerRequested__c';
        List<String> caseIds = new List<String>();
        caseIds.add(input.caseId);
        List<Case> cases = caseQuery.getRecordsById(caseIds, caseQueryFields);
        if (cases.isEmpty()){
            outputList.add(output);
            return outputList;
        }

        Case caseRecord = cases[0];
        Id contractId = caseRecord.Contract__c;

        if (contractId == null) {
            // TODO: se non ho un contratto sul case (es. sulle Domiciliazioni o sulle Mod. Anagrafiche) bisogna scorrersi tutti i contratti del cliente...
            outputList.add(output);
            return outputList;
        }

        // Query su Contract
        String objectName = 'Contract';
        String queryFields = 'Id,ContractNumber,Status';
        String queryString = 'SELECT ' + queryFields;
        String fromString = ' FROM '+ objectName;
        String controllingField = 'Id';
        String whereString = ' WHERE ' + controllingField + ' =\''+ contractId + '\'';
        //String relatedQueryString = ',(SELECT Id,SBQQ__ProductName__c FROM SBQQ__Subscriptions__r WHERE SBQQ__Product__r.Family = \'Offerta commerciale\')';//montors fix --
        String relatedQueryString = ',(SELECT SBQQ__Product__c FROM SBQQ__Subscriptions__r WHERE SBQQ__Product__r.Family = \'Offerta commerciale\')';//montors fix ++
        queryString = queryString + relatedQueryString + fromString + whereString; 
        System.debug('contract query: ' + queryString);

        List<sObject> contracts = HDT_QR_GenericQuery.getGenericRecords(queryString, objectName);
        if (contracts.isEmpty()){
            outputList.add(output);
            return outputList;
        }

        Contract c = (Contract) contracts[0];
        List<SBQQ__Subscription__c> subscriptions = (List<SBQQ__Subscription__c>) c.SBQQ__Subscriptions__r;
        //String productName = subscriptions[0].SBQQ__ProductName__c;//montors fix --
        String productId = subscriptions[0].SBQQ__Product__c;//montors fix ++

        // Query oggetto criteri eleggibilità
        objectName = 'EligibilityCriteria__c';
        queryFields = 'Id,BillSendingMethod__c,UseCategory__c,ResidentDeliveryAddress__c,PowerRangeMax__c';
        queryString = 'SELECT ' + queryFields;
        fromString = ' FROM '+ objectName;
        whereString = ' WHERE Product__c =\''+ productId + '\'';//montors fix ++
        queryString = queryString + fromString + whereString; 
        System.debug('criteria query: ' + queryString);

        List<sObject> criterias = HDT_QR_GenericQuery.getGenericRecords(queryString, objectName);
        if (criterias.isEmpty()){
            outputList.add(output);
            return outputList;
        }

        for (Integer i = 0; i < criterias.size(); i++) {
            EligibilityCriteria__c criteria = (EligibilityCriteria__c) criterias[i];

            switch on caseRecord.Type {
                when 'Modifica Tariffa Residente/Non Residente' {
                    String caseValue = caseRecord.Resident__c ? 'Si' : 'No';
                    if (caseValue != criteria.ResidentDeliveryAddress__c) {
                        output.abortProcess = true;
                        output.abortProcessWarning = 'L\'offerta attiva sul contratto selezionato è incompatibile con la variazione del campo Residente. Per poter procedere è necessario eseguire un cambio offerta.';
                        outputList.add(output);
                        return outputList;
                    }
                }
                when 'Marcatura/Uso PdR' {
                    if (criteria.UseCategory__c != null && !criteria.UseCategory__c.contains(caseRecord.UseCategory__c)) {
                        output.abortProcess = true;
                        output.abortProcessWarning = 'L\'offerta attiva sul contratto selezionato è incompatibile con la variazione del campo Tipologia Uso. Per poter procedere è necessario eseguire un cambio offerta.';
                        outputList.add(output);
                        return outputList;
                    }
                }
                when 'Variazione Anagrafica Cliente' {
                    if (caseRecord.BillSendingMethod__c != criteria.BillSendingMethod__c) {
                        output.abortProcess = true;
                        output.abortProcessWarning = 'L\'offerta attiva sul contratto selezionato è incompatibile con la variazione del campo Modalità Invio Bolletta. Per poter procedere è necessario eseguire un cambio offerta.';
                        outputList.add(output);
                        return outputList;
                    }
                }
                when 'Variazione Potenza' {
                    if (criteria.PowerRangeMax__c > 0 && caseRecord.PowerRequested__c > criteria.PowerRangeMax__c) {
                        output.abortProcess = true;
                        output.abortProcessWarning = 'L\'offerta attiva sul contratto selezionato è incompatibile con l\'aumento di potenza richiesto. Per poter procedere è necessario eseguire un cambio offerta.';
                        outputList.add(output);
                        return outputList;
                    }
                }
                when 'Richiesta Domiciliazione' {
                    if (criteria.PaymentMode__c != 'RID') {
                        output.abortProcess = true;
                        output.abortProcessWarning = 'L\'offerta attiva sul contratto selezionato è incompatibile con l\'attivazione della Domiciliazione. Per poter procedere è necessario eseguire un cambio offerta.';
                        outputList.add(output);
                        return outputList;
                    }
                }
                when 'Revoca Domiciliazione' {
                    if (criteria.PaymentMode__c == 'RID') {
                        output.abortProcess = true;
                        output.abortProcessWarning = 'L\'offerta attiva sul contratto selezionato è incompatibile con la revoca della Domiciliazione. Per poter procedere è necessario eseguire un cambio offerta.';
                        outputList.add(output);
                        return outputList;
                    }
                }
            }
        }

        outputList.add(output);
        return outputList;
    }

    public class HDT_WRP_ElegibilityCriteriaCheckInput {
        @InvocableVariable
        public String caseId;
    }

    public class HDT_WRP_ElegibilityCriteriaCheckOutput {
        @InvocableVariable
        public Boolean abortProcess;    // Indica se il processo deve essere interrotto poichè sta modificando un criterio di elegibilità.

        @InvocableVariable
        public String abortProcessWarning; // Indica il motivo per cui il processo deve essere interrotto.
    }
}
