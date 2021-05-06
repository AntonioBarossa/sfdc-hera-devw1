public inherited sharing class HDT_SRV_PaymentCommunication {

    HDT_QR_PaymentCommunication paymentQr = new HDT_QR_PaymentCommunication();

    public String createRequestBody(String recordId){

        List<DocumentSelected__c> documents = new List<DocumentSelected__c>();
        Case currentCase = new Case();
        String pretty;


        currentCase = paymentQr.getCaseById(recordId);
        documents = paymentQr.getDocumentSelectedByCase(recordId);

        JSONGenerator gen = JSON.createGenerator(true);

        gen.writeStartObject();
        gen.writeStringField('rds', currentCase.CaseNumber);
        gen.writeNumberField('totale',currentCase.TotalPaidCustomer__c);
        gen.writeNumberField('residuo',currentCase.TotalResidue__c);
        gen.writeNumberField('importo',currentCase.TotalToPay__c);
        gen.writeBooleanField('acconto',currentCase.Deposit__c);
        gen.writeFieldName('pagamenti');
        gen.writeStartArray();
        for(DocumentSelected__c document : documents){

            gen.writeStartObject();
            gen.writeStringField('numeroBollettino',document.Bill__c);
            gen.writeStringField('numeroFattura',document.DocumentNumber__c.startsWith('0') ? document.DocumentNumber__c : null);
            gen.writeStringField('numeroFattura1','');
            gen.writeStringField('rataFattura','');
            gen.writeDateField('scadenza',document.ExpirationDate__c);
            gen.writeNumberField('pagato',document.PaidCustomer__c);
            gen.writeStringField('infoBlocco','');
            gen.writeStringField('idProcesso','');
            gen.writeStringField('numeroDocumento',document.DocumentNumber__c.startsWith('0') ? null : document.DocumentNumber__c);
            gen.writeStringField('rateizzazione',document.Extension__c);
            gen.writeDateField('dataFattura',document.IssueDate__c);
            gen.writeNumberField('totaleParziale',document.TotalCommunicationPayment__c);
            gen.writeEndObject();
        }
        gen.writeEndArray();
        gen.writeEndObject();
    
        pretty = gen.getAsString();

        return pretty;
    }



}
