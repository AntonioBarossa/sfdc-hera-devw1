public inherited sharing class HDT_SRV_PaymentCommunication {

    HDT_QR_PaymentCommunication paymentQr = new HDT_QR_PaymentCommunication();

    public String createRequestBody(String recordId){

        List<DocumentSelected__c> documents = new List<DocumentSelected__c>();
        Case currentCase = new Case();
        String pretty;

        currentCase = paymentQr.getCaseById(recordId);
        documents = paymentQr.getDocumentSelectedByCase(recordId);

        System.debug('SRV_PaymenCommunication Case--> '+currentCase);
        System.debug('SRV_PaymentCommunication Documetns--> '+documents);

        Map<String, Object> caseMap = new Map<String, Object>{
            'rds' => currentCase.CaseNumber,
            'totale' => currentCase.TotalPaidCustomer__c,
            'residuo' => currentCase.TotalResidue__c,
            'importo' => currentCase.TotalToPay__c,
            'acconto' => currentCase.Deposit__c
        };

        JSONGenerator gen = JSON.createGenerator(true);

        gen.writeStartObject();
        for(String mapKey : caseMap.keySet()){

            if(caseMap.get(mapKey) != null){

                if(caseMap.get(mapKey) instanceof String){

                    gen.writeStringField(mapKey, (String) caseMap.get(mapKey));

                } else if(caseMap.get(mapKey) instanceof Integer){

                    gen.writeNumberField(mapKey, (Integer) caseMap.get(mapKey));

                }else if(caseMap.get(mapKey) instanceof Decimal){

                    gen.writeNumberField(mapKey, (Decimal) caseMap.get(mapKey));

                } else if(caseMap.get(mapKey) instanceof Date){

                    gen.writeDateField(mapKey, (Date) caseMap.get(mapKey));

                } else if(caseMap.get(mapKey) instanceof Boolean){

                    gen.writeBooleanField(mapKey, (Boolean) caseMap.get(mapKey));

                }

            }else{

                gen.writeNullField(mapKey);

            }

        }
        gen.writeFieldName('pagamenti');
        gen.writeStartArray();
        for(DocumentSelected__c document : documents){

            gen.writeStartObject();
            gen.writeStringField('numeroBollettino','');
            gen.writeStringField('numeroFattura',document.DocumentNumber__c.startsWith('0') ? document.DocumentNumber__c : '');
            gen.writeStringField('numeroFattura1','');
            gen.writeStringField('rataFattura','');
            gen.writeDateField('scadenza',document.ExpirationDate__c);
            //gen.writeNumberField('pagato',document.PaidCustomer__c);
            gen.writeStringField('infoBlocco','');
            gen.writeStringField('idProcesso','');
            gen.writeStringField('numeroDocumento',document.DocumentNumber__c.startsWith('0') ? '' : document.DocumentNumber__c);
            //gen.writeStringField('rateizzazione',document.Extension__c);
            gen.writeDateField('dataFattura',document.IssueDate__c);
            gen.writeNumberField('totaleParziale',document.TotalCommunicationPayment__c);
            gen.writeEndObject();
        }
        gen.writeEndArray();
        gen.writeEndObject();
    
        pretty = gen.getAsString();

        System.debug('SRV_PaymentCommunication -->' +pretty);

        return pretty;
    }



}
