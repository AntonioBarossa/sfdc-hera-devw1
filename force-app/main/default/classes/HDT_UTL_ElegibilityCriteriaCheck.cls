@suppressWarnings('PMD.ApexSOQLInjection')
public with sharing class HDT_UTL_ElegibilityCriteriaCheck {

    @InvocableMethod(label='Check Criterio Elegibilità')
    public static List<HDT_WRP_ElegibilityCriteriaCheckOutput> execute(List<HDT_WRP_ElegibilityCriteriaCheckInput> inputs){
        if(inputs==null || inputs.size()<=0) return null;
      
        HDT_WRP_ElegibilityCriteriaCheckInput input = inputs[0];
        HDT_WRP_ElegibilityCriteriaCheckOutput output = new HDT_WRP_ElegibilityCriteriaCheckOutput();
        List<HDT_WRP_ElegibilityCriteriaCheckOutput> outputList = new List<HDT_WRP_ElegibilityCriteriaCheckOutput>();

        // Query su Case
        HDT_QR_Case caseQuery = new HDT_QR_Case();
        String caseQueryFields = 'Id,BillingProfile__c,Contract__c,Type,BillSendingMethod__c,Resident__c,UseCategory__c,PowerRequested__c';
        List<String> caseIds = new List<String>();
        caseIds.add(input.caseId);
        List<Case> cases = caseQuery.getRecordsById(caseIds, caseQueryFields);
        if (cases.isEmpty()){
            outputList.add(output);
            return outputList;
        }

        List<String> contractIds = new List<String>();
        Case caseRecord = cases[0];
        Id contractId = caseRecord.Contract__c;
        if (contractId == null) {
            // Sulle modifiche angrafiche o sulle domiciliazioni non c'è la selezione del contratto.
            // Quindi ci scorriamo tutti i contratti del cliente e consideriamo quelli che hanno lo stesso Billing Profile che sta modificando il processo.
            HDT_QR_Contract contractQueryHandler = new HDT_QR_Contract();
            List<Contract> activeContracts = contractQueryHandler.getActiveRecordsByAccountId(caseRecord.AccountId);
            for (Contract c : activeContracts) {
                if (c.BillingProfile__c == caseRecord.BillingProfile__c) {
                    contractIds.add(c.Id);
                }
            }
        } else {
            contractIds.add(contractId);
        }

        if (contractIds.isEmpty()){
            outputList.add(output);
            return outputList;
        }

        // Query su Contract
        String objectName = 'Contract';
        String queryFields = 'Id,ContractNumber,Status';
        String queryString = 'SELECT ' + queryFields;
        String fromString = ' FROM '+ objectName;
        String controllingField = 'Id';
        String whereString = ' WHERE ' + controllingField + ' IN :contractIds';
        //String relatedQueryString = ',(SELECT Id,SBQQ__ProductName__c FROM SBQQ__Subscriptions__r WHERE SBQQ__Product__r.Family = \'Offerta commerciale\')';//montors fix --
        String relatedQueryString = ',(SELECT SBQQ__Product__c FROM SBQQ__Subscriptions__r WHERE SBQQ__Product__r.Family = \'Offerta commerciale\')';//montors fix ++
        queryString = queryString + relatedQueryString + fromString + whereString; 
        System.debug(LoggingLevel.DEBUG, 'contracts query ' + queryString);

        List<sObject> recordList = new List<sObject>();
        SObjectType objtype = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult objRes = objtype.getDescribe(); 
        if (objRes.isAccessible()) {
            recordList = Database.query(queryString);
        }

        if (recordList.isEmpty()){
            outputList.add(output);
            return outputList;
        }

        List<String> productIds = new List<String>();
        for (Integer i = 0; i < recordList.size(); i++) {
            Contract c = (Contract) recordList[i];
            List<SBQQ__Subscription__c> subscriptions = (List<SBQQ__Subscription__c>) c.SBQQ__Subscriptions__r;
            String productId = subscriptions[0].SBQQ__Product__c;
            productIds.add(productId);
        }

        // Query oggetto criteri eleggibilità
        objectName = 'EligibilityCriteria__c';
        queryFields = 'Id,BillSendingMethod__c,UseCategory__c,ResidentDeliveryAddress__c,PowerRangeMax__c';
        queryString = 'SELECT ' + queryFields;
        fromString = ' FROM '+ objectName;
        whereString = ' WHERE Product__c IN :productIds';
        queryString = queryString + fromString + whereString; 
        System.debug(LoggingLevel.DEBUG, 'criteria query: ' + queryString);

        objtype = Schema.getGlobalDescribe().get(objectName);
        objRes = objtype.getDescribe(); 
        if (objRes.isAccessible()) {
            recordList = Database.query(queryString);
        }

        if (recordList.isEmpty()){
            outputList.add(output);
            return outputList;
        }

        for (Integer i = 0; i < recordList.size(); i++) {
            EligibilityCriteria__c criteria = (EligibilityCriteria__c) recordList[i];

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
