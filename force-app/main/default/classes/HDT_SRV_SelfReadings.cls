public with sharing class HDT_SRV_SelfReadings {
    public static HDT_WRP_GenericSapIntegration generateJson(HDT_WRP_GenericSapIntegration inputParams){
        System.debug('Generating JSON for request type: ' + inputParams.requestType);
        switch on inputParams.requestType {
            when 'CheckAutolettura' {
                return manageCheckAutolettura(inputParams);
            }
            // when 'InvioLetture' {
            //     return manageInvioLetture(inputParams);
            // }
            when else {
               return null;
            }
        }
    }

    // TODO WAVE 2: adeguare per altre commodity.
    private static HDT_WRP_GenericSapIntegration manageCheckAutolettura(HDT_WRP_GenericSapIntegration inputParams) {
        if (inputParams == null) {
            return null;
        }

        String caseId = inputParams.recordId;

        HDT_QR_Case queryCase = new HDT_QR_Case();
        HDT_QR_SelfReadings queryReadings = new HDT_QR_SelfReadings();

        List<Case> cases = queryCase.getRecordsById(new List<String> {caseId}, 'Id,ContractCode__c,CommodityFormula__c');
        if (cases.isEmpty()) {
            return null;
        }

        Case readingCase = cases[0];

        String readingFields = 'Id';
        if (readingCase.CommodityFormula__c == 'Gas') {
            readingFields += ',ReadingRegisterMeter__c,ReadingRegisterCorrector__c,ReadingValueMeter__c,ReadingValueCorrector__c';
        } else {
            String fieldsTemplate = ',ReadingRegister{0}__c,ReadingValue{1}__c';
            for (Integer i = 1; i <= 9; i++) {
                List<String> fieldsParameters = new List<String> { String.valueOf(i), String.valueOf(i) };
                String fields = String.format(fieldsTemplate, fieldsParameters);
                readingFields += fields;
            }
        }
        Reading__c reading = queryReadings.getReading('Case', caseId, readingCase.CommodityFormula__c, readingFields);

        JSONGenerator gen = JSON.createGenerator(false);

        gen.writeStartObject();
        gen.writeStringField('caseId', caseId);
        gen.writeStringField('readingId', reading.Id);
        gen.writeStringField('contractCode', readingCase.ContractCode__c);
        gen.writeStringField('commodity', readingCase.CommodityFormula__c);
        gen.writeFieldName('position');
        gen.writeStartArray();

        if (readingCase.CommodityFormula__c == 'Gas') {
            gen.writeStartObject();
            gen.writeStringField('register', reading.ReadingRegisterMeter__c);
            gen.writeStringField('reading', reading.ReadingValueMeter__c.format());
            gen.writeEndObject();

            if (reading.ReadingValueCorrector__c != null && String.isNotBlank(reading.ReadingRegisterCorrector__c)) {
                gen.writeStartObject();
                gen.writeStringField('register', reading.ReadingRegisterCorrector__c);
                gen.writeStringField('reading', reading.ReadingValueCorrector__c.format());
                gen.writeEndObject();
            }
        } else {
            Integer registersCount = HDT_UTL_SelfReadings.getRegistersCount(reading);
            for (Integer i = 1; i <= registersCount; i++) {
                List<String> indexParam = new List<String> { String.valueOf(i) };
                gen.writeStartObject();
                gen.writeStringField('register', (String) reading.get(String.format('ReadingRegister{0}__c', indexParam)));
                Decimal readingValue = (Decimal) reading.get(String.format('ReadingValue{0}__c', indexParam));
                gen.writeStringField('reading', readingValue.format());
                gen.writeEndObject();
            }
        }

        gen.writeEndArray();
        gen.writeEndObject();

        String body = gen.getAsString();
        inputParams.requestBody = body;
        inputParams.namedCredential = 'Callout:SelfReadingsCheck';
        return inputParams;
    }

}