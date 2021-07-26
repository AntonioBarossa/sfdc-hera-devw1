public with sharing class HDT_SRV_SelfReadings {
    public static HDT_WRP_GenericSapIntegration generateJson(HDT_WRP_GenericSapIntegration inputParams){
        System.debug('Generating JSON for request type: ' + inputParams.requestType);
        switch on inputParams.requestType {
            when 'CheckAutolettura' {
                return generateJsonCheckAutolettura(inputParams);
            }
            when 'InvioLetture' {
                return generateJsonInvioLetture(inputParams);
            }
            when else {
               return null;
            }
        }
    }

    // TODO WAVE 2: adeguare per altre commodity.
    private static HDT_WRP_GenericSapIntegration generateJsonCheckAutolettura(HDT_WRP_GenericSapIntegration inputParams) {
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
            String fieldsTemplate = ',ReadingRegister{0}__c,ReadingValue{0}__c';
            for (Integer i = 1; i <= 9; i++) {
                List<String> fieldsParameters = new List<String> { String.valueOf(i) };
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
            gen.writeStringField('reading', String.valueOf(reading.ReadingValueMeter__c));
            gen.writeEndObject();

            if (reading.ReadingValueCorrector__c != null && String.isNotBlank(reading.ReadingRegisterCorrector__c)) {
                gen.writeStartObject();
                gen.writeStringField('register', reading.ReadingRegisterCorrector__c);
                gen.writeStringField('reading', String.valueOf(reading.ReadingValueCorrector__c));
                gen.writeEndObject();
            }
        } else {
            Integer registersCount = HDT_UTL_SelfReadings.getRegistersCount(reading);
            for (Integer i = 1; i <= registersCount; i++) {
                List<String> indexParam = new List<String> { String.valueOf(i) };
                gen.writeStartObject();
                gen.writeStringField('register', (String) reading.get(String.format('ReadingRegister{0}__c', indexParam)));
                Decimal readingValue = (Decimal) reading.get(String.format('ReadingValue{0}__c', indexParam));
                gen.writeStringField('reading', String.valueOf(readingValue));
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

    // TODO WAVE 2: adeguare per altre commodity.
    private static HDT_WRP_GenericSapIntegration generateJsonInvioLetture(HDT_WRP_GenericSapIntegration inputParams) {
        if (inputParams == null) {
            return null;
        }

        String caseId = inputParams.recordId;

        HDT_QR_Case queryCase = new HDT_QR_Case();
        HDT_QR_SelfReadings queryReadings = new HDT_QR_SelfReadings();

        List<Case> cases = queryCase.getRecordsById(new List<String> {caseId}, 'Id,PODPDRFormula__c,CaseNumber,CommodityFormula__c');
        if (cases.isEmpty()) {
            return null;
        }

        Case readingCase = cases[0];

        String readingFields = 'Id';
        String fieldsTemplate = ',ReadingRegister{0}__c,ReadingValue{0}__c,ReadingBand{0}__c,ReadingDate{0}__c,ReadingDigitNumber{0}__c,ReadingSerialNumber{0}__c,ReadingType{0}__c,ReadingUnit{0}__c';
        if (readingCase.CommodityFormula__c == 'Gas') {
            List<String> gasRegisters = new List<String> {'Meter', 'Corrector'};
            for (String gasRegister : gasRegisters) {
                List<String> fieldsParameters = new List<String> { gasRegister };
                String fields = String.format(fieldsTemplate, fieldsParameters);
                readingFields += fields;
            }
        } else {
            for (Integer i = 1; i <= 9; i++) {
                List<String> fieldsParameters = new List<String> { String.valueOf(i) };
                String fields = String.format(fieldsTemplate, fieldsParameters);
                readingFields += fields;
            }
        }
        Reading__c reading = queryReadings.getReading('Case', caseId, readingCase.CommodityFormula__c, readingFields);

        JSONGenerator gen = JSON.createGenerator(false);

        gen.writeStartObject();
        gen.writeStringField('serviceRequest', readingCase.CaseNumber);
        gen.writeStringField('pod', readingCase.PODPDRFormula__c);
        gen.writeFieldName('element');
        gen.writeStartArray();

        if (readingCase.CommodityFormula__c == 'Gas') {
            gen.writeStartObject();
            gen.writeStringField('typology', reading.ReadingTypeMeter__c);
            gen.writeStringField('identifier', reading.ReadingSerialNumberMeter__c);
            gen.writeStringField('section', reading.ReadingBandMeter__c);
            gen.writeStringField('register', reading.ReadingRegisterMeter__c);
            gen.writeStringField('um', reading.ReadingUnitMeter__c);
            gen.writeStringField('digit', reading.ReadingDigitNumberMeter__c);
            gen.writeStringField('date', String.valueOf(reading.ReadingDateMeter__c));
            gen.writeStringField('reading', String.valueOf(reading.ReadingValueMeter__c));
            gen.writeEndObject();

            if (reading.ReadingValueCorrector__c != null) {
                gen.writeStartObject();
                gen.writeStringField('typology', reading.ReadingTypeCorrector__c);
                gen.writeStringField('identifier', reading.ReadingSerialNumberCorrector__c);
                gen.writeStringField('section', reading.ReadingBandCorrector__c);
                gen.writeStringField('register', reading.ReadingRegisterCorrector__c);
                gen.writeStringField('um', reading.ReadingUnitCorrector__c);
                gen.writeStringField('digit', reading.ReadingDigitNumberCorrector__c);
                gen.writeStringField('date', String.valueOf(reading.ReadingDateCorrector__c));
                gen.writeStringField('reading', String.valueOf(reading.ReadingValueCorrector__c));
                gen.writeEndObject();
            }
        } else {
            Integer registersCount = HDT_UTL_SelfReadings.getRegistersCount(reading);
            for (Integer i = 1; i <= registersCount; i++) {
                List<String> indexParam = new List<String> { String.valueOf(i) };
                gen.writeStartObject();
                gen.writeStringField('typology', (String) reading.get(String.format('ReadingType{0}__c', indexParam)));
                gen.writeStringField('identifier', (String) reading.get(String.format('ReadingSerialNumber{0}__c', indexParam)));
                gen.writeStringField('section', (String) reading.get(String.format('ReadingBand{0}__c', indexParam)));
                gen.writeStringField('register', (String) reading.get(String.format('ReadingRegister{0}__c', indexParam)));
                gen.writeStringField('um', (String) reading.get(String.format('ReadingUnit{0}__c', indexParam)));
                gen.writeStringField('digit', (String) reading.get(String.format('ReadingDigitNumber{0}__c', indexParam)));
                Date readingDate = (Date) reading.get(String.format('ReadingDate{0}__c', indexParam));
                gen.writeStringField('date', String.valueOf(readingDate));
                Decimal readingValue = (Decimal) reading.get(String.format('ReadingValue{0}__c', indexParam));
                gen.writeStringField('reading', String.valueOf(readingValue));
                gen.writeEndObject();
            }
        }

        gen.writeEndArray();
        gen.writeEndObject();

        String body = gen.getAsString();
        inputParams.requestBody = body;
        inputParams.namedCredential = 'Callout:SendReadings';
        return inputParams;
    }

    public static Boolean handleResponse(HDT_WRP_GenericSapIntegration sapIntegration) {
        System.debug('Handling response for request type: ' + sapIntegration.requestType);
        switch on sapIntegration.requestType {
            when 'CheckAutolettura' {
                return handleResponseCheckAutolettura(sapIntegration);
            }
            // when 'InvioLetture' {
            //     return handleResponseInvioLetture(sapIntegration);
            // }
            when else {
               return null;
            }
        }
    }

    private static Boolean handleResponseCheckAutolettura(HDT_WRP_GenericSapIntegration sapIntegration) {

        String caseId = sapIntegration.recordId;
        Boolean responseOk = true;

        Case readingCase = new Case();
        readingCase.Id = caseId;
        Map<String, Object> body = (Map<String, Object>) JSON.deserializeUntyped(sapIntegration.responseBody);

        // SAP restituisce codice 502 in caso di check preliminare non superato.
        if (sapIntegration.responseCode != 200 && sapIntegration.responseCode != 201) {
            responseOk = false;
            List<Object> errorDetails = (List<Object>) body.get('errorDetails');
            if (errorDetails != null && !errorDetails.isEmpty()) {
                Map<String, Object> errorObj = (Map<String, Object>) errorDetails[0];
                String errorMessage = errorObj != null ? (String) errorObj.get('message') : '';
                readingCase.Phase__c = 'Check preliminari KO';
                readingCase.Description = errorMessage;
            }
        } else {
            readingCase.Phase__c = 'Check preliminari OK';
        }

        HDT_UTL_DatabaseService.updateSObject(readingCase);


        return responseOk;
    }

}