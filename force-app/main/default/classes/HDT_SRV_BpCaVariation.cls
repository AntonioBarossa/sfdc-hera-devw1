public with sharing class HDT_SRV_BpCaVariation {
    public static HDT_WRP_GenericSapIntegration generateJson(HDT_WRP_GenericSapIntegration inputParams){
        System.debug('Generating JSON for request type: ' + inputParams.requestType);
        switch on inputParams.requestType {
            when 'MA3Disattivazioni' {
                return manageMA3Disattivazioni(inputParams);
            }
            when 'MA2DatiFiscali' {
                return manageMA2DatiFiscali(inputParams);
            }
            when 'GruppoIva' {
                return manageGruppoIva(inputParams);
            }
            when else {
               return null;
            }
        }
    }

    private static HDT_WRP_GenericSapIntegration manageMA3Disattivazioni(HDT_WRP_GenericSapIntegration inputParams){
        String fieldq;
        String whereq;
        String fromq = 'Case';
        String queryString;
        fieldq = 'Id,Account.CustomerCode__c,CaseNumber, CareOf__c,BillSendingMethod__c,InvoiceEmail__c,InvoiceCertifiedEmailAddress__c,BillingProfile__r.ContractAccountCode__c, InvoicingCity__c, InvoicingCityCode__c, InvoicingCountry__c, InvoicingPlace__c, InvoicingPostalCode__c, InvoicingProvince__c, InvoicingStreetCode__c, InvoicingStreetName__c, InvoicingStreetNumber__c, InvoicingStreetNumberExtension__c ,InvoicingStreetToponym__c, IsInvoicingVerified__c';
        whereq = 'Id = \''+inputParams.recordId+'\'';
        queryString = 'SELECT ' + fieldq + ' FROM ' + fromq + ' WHERE ' +  whereq;
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
        requestBody.ordine.indirizzo.civico = (String) caseRecord.get('InvoicingStreetNumber__c');
        requestBody.ordine.indirizzo.suffissoCivico = (String) caseRecord.get('InvoicingStreetNumberExtension__c') != null? (String) caseRecord.get('InvoicingStreetNumberExtension__c'):'';
        requestBody.ordine.indirizzo.cap = (String) caseRecord.get('InvoicingPostalCode__c');
        requestBody.ordine.indirizzo.provincia = (String) caseRecord.get('InvoicingProvince__c');
        requestBody.ordine.indirizzo.via = (String) caseRecord.get('InvoicingStreetName__c');
        requestBody.ordine.indirizzo.piano = '';
        //requestBody.ordine.indirizzo.presso = (String) caseRecord.get('CareOf__c');
        requestBody.ordine.emailInvioBolletta = (String) caseRecord.get('InvoiceEmail__c');
        requestBody.ordine.pecInvioBolletta = (String) caseRecord.get('InvoiceCertifiedEmailAddress__c');
        //requestBody.ordine.modalitaInvioBolletta = (String) caseRecord.get('BillSendingMethod__c');
        inputParams.requestBody = JSON.serialize(requestBody);
        System.debug('requestBody ' + requestBody);
        inputParams.namedCredential = 'Callout:BpCaVariation';
        return inputParams;
    }

    private static HDT_WRP_GenericSapIntegration manageGruppoIva(HDT_WRP_GenericSapIntegration inputParams){
        String fieldq;
        String whereq;
        String fromq = 'Case';
        String queryString;
        fieldq = 'Id,Account.CustomerCode__c,CaseNumber,Account.VatNumber__c';
        fieldq += ',IsVATGroupJoined__c,VATGroup__c';
        whereq = 'Id = \''+inputParams.recordId+'\'';
        queryString = 'SELECT ' + fieldq + ' FROM ' + fromq + ' WHERE ' +  whereq;
        List<SObject> sobjectRecordList = HDT_QR_GenericQuery.getGenericRecords(queryString, fromQ);
        Case caseRecord = (Case) sobjectRecordList[0];
        Account acc = (Account) caseRecord.Account;	
        HDT_WRP_BpCaVariationVatGroup requestBody = new HDT_WRP_BpCaVariationVatGroup();
        requestBody.numeroSr = (String) caseRecord.get('CaseNumber');
        requestBody.codiceCausale = 'MAG';
        requestBody.dataCreazione = getFormattedToday();
        requestBody.account.partner = (String) acc.get('CustomerCode__c');
        requestBody.account.partitaIva = (String) acc.get('VatNumber__c');
        requestBody.account.gruppoIva.adesione = String.valueOf(caseRecord.get('IsVATGroupJoined__c'));
        requestBody.account.gruppoIva.partitaIva = (String) caseRecord.get('VATGroup__c');

        System.debug('requestBody ' + requestBody);
        inputParams.requestBody = JSON.serialize(requestBody);
        System.debug('serialized requestBody ' + requestBody);
        inputParams.namedCredential = 'Callout:BpCaVariation';
        return inputParams;
    }

    private static HDT_WRP_GenericSapIntegration manageMA2DatiFiscali(HDT_WRP_GenericSapIntegration inputParams){
        String fieldq;
        String whereq;
        String fromq = 'Case';
        String queryString;
        fieldq = 'Id,Account.CustomerCode__c,CaseNumber,FirstName__c,LastName__c,FiscalCode__c,VatNumber__c,CustomerMarking__c';
        fieldq += ',BillingCity__c,BillingCountry__c,BillingStreetNumber__c,BillingStreetNumberExtension__c,BillingPostalCode__c,BillingProvince__c,BillingStreetName__c';
        whereq = 'Id = \''+inputParams.recordId+'\'';
        queryString = 'SELECT ' + fieldq + ' FROM ' + fromq + ' WHERE ' +  whereq;
        List<SObject> sobjectRecordList = HDT_QR_GenericQuery.getGenericRecords(queryString, fromQ);
        Case caseRecord = (Case) sobjectRecordList[0];
        Account acc = (Account) caseRecord.Account;
        HDT_WRP_BpCaVariation requestBody = new HDT_WRP_BpCaVariation();
        requestBody.numeroSr = (String) caseRecord.get('CaseNumber');
        requestBody.codiceCausale = 'MA2';
        requestBody.dataCreazione = getFormattedToday();
        requestBody.account.partner = (String) acc.get('CustomerCode__c');
        requestBody.account.nome = (String) caseRecord.get('FirstName__c') != null ? (String) caseRecord.get('FirstName__c') : '';
        requestBody.account.alias = (String) caseRecord.get('LastName__c'); // Non dovrebbe mai essere vuoto.
        requestBody.account.codiceFiscale = (String) caseRecord.get('FiscalCode__c') != null ? (String) caseRecord.get('FiscalCode__c') : '';
        requestBody.account.partitaIva = (String) caseRecord.get('VatNumber__c') != null ? (String) caseRecord.get('VatNumber__c') : '';
        requestBody.account.marcaturaCliente = (String) caseRecord.get('CustomerMarking__c') != null ? (String) caseRecord.get('CustomerMarking__c') : '';
        requestBody.account.indirizzo.comune = (String) caseRecord.get('BillingCity__c');
        requestBody.account.indirizzo.nazione = getFormattedCountry((String) caseRecord.get('BillingCountry__c'));
        requestBody.account.indirizzo.civico = (String) caseRecord.get('BillingStreetNumber__c');
        requestBody.account.indirizzo.suffissoCivico = (String) caseRecord.get('BillingStreetNumberExtension__c') != null? (String) caseRecord.get('BillingStreetNumberExtension__c'):'';
        requestBody.account.indirizzo.cap = (String) caseRecord.get('BillingPostalCode__c');
        requestBody.account.indirizzo.provincia = (String) caseRecord.get('BillingProvince__c');
        requestBody.account.indirizzo.via = (String) caseRecord.get('BillingStreetName__c');
        requestBody.account.indirizzo.piano = '';
        System.debug('requestBody indirizzo ' + requestBody.account.indirizzo);

        inputParams.requestBody = JSON.serialize(requestBody);
        System.debug('requestBody ' + requestBody);
        inputParams.namedCredential = 'Callout:BpCaVariation';
        return inputParams;
    }

    public static void createActivity(String recordId, String description, String type){
        String queryString = 'Select id,wrts_prcgvr__Assignees__c, wrts_prcgvr__Subject__c, wrts_prcgvr__DueDateField__c,Name from wrts_prcgvr__ActivityTemplate__c  where Name = \''+ type +'\'';
        String objectName = 'wrts_prcgvr__ActivityTemplate__c';
        List<SObject> listRecord = HDT_QR_GenericQuery.getGenericRecords(queryString, objectName);
        wrts_prcgvr__ActivityTemplate__c template = new wrts_prcgvr__ActivityTemplate__c();
        if(listRecord.size()>0){
            template = (wrts_prcgvr__ActivityTemplate__c) listRecord[0];
            wrts_prcgvr__Activity__c activity = new wrts_prcgvr__Activity__c();
            activity.wrts_prcgvr__ActivityTemplate__c = template.Id;
            activity.Case__c = recordId;
            activity.CausalError__c = description;
            activity.wrts_prcgvr__Description__c = description;
            Boolean insertAct = HDT_UTL_DatabaseService.insertSObject(activity);
        }
    }

    // Restituisce Today nel formato richiesto da mulesoft (es. 20210511)
    private static String getFormattedToday() {
        Datetime today = Datetime.now();
        String formattedToday = today.format('yMMdd');
        return formattedToday;
    }

    // Restituisce la nazione nel formato richiesto da SAP (IT)
    private static String getFormattedCountry(String country) {
        if (country == null) {
            return '';
        }

        return country.toUpperCase().substring(0, 2);
    }
}