public with sharing class HDT_SRV_Paperless {

    HDT_QR_Paperless paperlessQr = new HDT_QR_Paperless();

    public String createRequestBody(String recordId){

        List<DocumentSelected__c> documents = new List<DocumentSelected__c>();
        Case currentCase = new Case();
        String pretty;

        currentCase = paperlessQr.getCaseById(recordId);
        documents = paperlessQr.getDocumentSelectedByCase(recordId);

        JSONGenerator gen = JSON.createGenerator(true);

        gen.writeStartObject();
        gen.writeStringField('codicecliente', currentCase.AccountCode__c);
        gen.writeStringField('contocontrattuale',currentCase.BillingProfile__r.ContractAccountCode__c);
        gen.writeStringField('rds', currentCase.CaseNumber);
        gen.writeFieldName('bollettini');
        gen.writeStartArray();
        for(DocumentSelected__c document : documents){
            gen.writeStartObject();
            gen.writeStringField('documento', document.DocumentNumber__c);
            gen.writeStringField('posizione1','');
            gen.writeStringField('posizione2','');
            gen.writeStringField('posizione3','');
            gen.writeNumberField('importo',document.Amount__c);
            gen.writeDateField('scadenza',document.ExpirationDate__c);
            gen.writeEndObject();
        }
        gen.writeEndArray();
        gen.writeEndObject();

        pretty = gen.getAsString();

        return pretty;

    }

}
