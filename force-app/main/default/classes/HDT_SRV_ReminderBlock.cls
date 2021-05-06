public inherited sharing class HDT_SRV_ReminderBlock {

    HDT_QR_ReminderBlock reminderQr = new HDT_QR_ReminderBlock();

    public String createRequestBody(String recordId){

        List<DocumentSelected__c> documents = new List<DocumentSelected__c>();
        Case currentCase = new Case();
        String pretty;
        Integer blockDuration;

        currentCase = reminderQr.getCaseById(recordId);

        JSONGenerator gen = JSON.createGenerator(true);

        if(currentCase.BlockType__c == '1'){

            blockDuration = 45;

        } else if(currentCase.BlockType__c == 'W'){

            blockDuration = 240;

        }

        gen.writeStartObject();
        gen.writeStringField('bp', currentCase.AccountCode__c);
        gen.writeStringField('blocco', currentCase.BlockType__c);
        gen.writeNumberField('durataBlocco', blockDuration);
        gen.writeFieldName('fatture');
        gen.writeStartArray();
        for(DocumentSelected__c document : documents){
            gen.writeStartObject();
            gen.writeStringField('numeroDocumento', document.DocumentNumber__c.startsWith('0') ? null : document.DocumentNumber__c);
            gen.writeStringField('numeroFattura', document.DocumentNumber__c.startsWith('0') ? document.DocumentNumber__c : null);
            gen.writeStringField('ca', document.ContractualAccount__c);
            gen.writeEndObject();
        }
        gen.writeEndArray();
        gen.writeEndObject();

        pretty = gen.getAsString();

        return pretty;

    }


}
