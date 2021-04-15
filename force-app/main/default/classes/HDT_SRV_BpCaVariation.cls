public with sharing class HDT_SRV_BpCaVariation {
    public static HDT_WRP_GenericSapIntegration generateJson(HDT_WRP_GenericSapIntegration inputParams){
        switch on inputParams.requestType {
            when 'MA3Disattivazioni' {
                return manageMA3Disattivazioni(inputParams);
            }
            when else {
               return null; 
            }
        }
    }

    private static HDT_WRP_GenericSapIntegration manageMA3Disattivazioni(HDT_WRP_GenericSapIntegration inputParams){
        String fieldQ;
        String whereQ;
        String fromQ = 'Case';
        String queryString;
        fieldQ = 'Id,Account.CustomerCode__c,CaseNumber, BillingProfile__r.ContractAccountCode__c, InvoicingCity__c, InvoicingCityCode__c, InvoicingCountry__c, InvoicingPlace__c, InvoicingPostalCode__c, InvoicingProvince__c, InvoicingStreetCode__c, InvoicingStreetName__c, InvoicingStreetNumber__c, InvoicingStreetNumberExtension__c ,InvoicingStreetToponym__c, IsInvoicingVerified__c';
        whereQ = 'Id = \''+inputParams.recordId+'\'';
        queryString = 'SELECT ' + fieldQ + ' FROM ' + fromQ + ' WHERE ' +  whereQ;
        List<SObject> sobjectRecordList = HDT_QR_GenericQuery.getGenericRecords(queryString, fromQ);
        HDT_WRP_BpCaVariation requestBody = new HDT_WRP_BpCaVariation();
        Case caseRecord = (Case) sobjectRecordList[0];
        Account acc = (Account) caseRecord.Account;	
        BillingProfile__c bp = (BillingProfile__c) caseRecord.BillingProfile__r;
        requestBody.numeroSr = (String) caseRecord.get('CaseNumber');
        requestBody.codiceCausale = 'MA3';
        requestBody.dataCreazione = '20150303';
        requestBody.account.partner = (String) acc.get('CustomerCode__c');
        requestBody.ordine.contoContrattuale = (String) bp.get('ContractAccountCode__c');
        requestBody.ordine.indirizzo.comune = (String) caseRecord.get('InvoicingCity__c');
        requestBody.ordine.indirizzo.nazione = (String) caseRecord.get('InvoicingCountry__c');
        requestBody.ordine.indirizzo.civico = (String) caseRecord.get('InvoicingStreetCode__c');
        requestBody.ordine.indirizzo.suffissoCivico = (String) caseRecord.get('InvoicingStreetNumberExtension__c') != null? (String) caseRecord.get('InvoicingStreetNumberExtension__c'):'';
        requestBody.ordine.indirizzo.cap = (String) caseRecord.get('InvoicingPostalCode__c');
        requestBody.ordine.indirizzo.provincia = (String) caseRecord.get('InvoicingProvince__c');
        requestBody.ordine.indirizzo.via = (String) caseRecord.get('InvoicingStreetName__c');
        requestBody.ordine.indirizzo.piano = '';
        inputParams.requestBody = JSON.serialize(requestBody);
        inputParams.namedCredential = 'Callout:BpCaVariation';
        return inputParams;
    }
}
