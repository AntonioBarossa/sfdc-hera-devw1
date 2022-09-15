public with sharing class HDT_SRV_SelfReadings {

    public static void handleInvioLettureForzato(SObject selfReadingCase) {

        System.enqueueJob(new HDT_QBL_SelfReadingsCallouts((Case) selfReadingCase, 'InvioLettureForzato'));

    }

    /*
    * @Author: Salvatore A. Sarà 19/10/2021
    * Risoluzione "Debug Should Use Logging Level"
    * Risoluzione "Avoid debug statements since they impact on performance"
    */
    @SuppressWarnings('PMD.AvoidDebugStatements')
    public static HDT_WRP_GenericSapIntegration generateJson(HDT_WRP_GenericSapIntegration inputParams){
        System.debug(LoggingLevel.DEBUG, 'Generating JSON for request type: ' + inputParams.requestType);
        switch on inputParams.requestType {
            when 'CheckAutolettura' {
                return generateJsonCheckAutolettura(inputParams);
            }
            when 'InvioLetture', 'InvioLettureForzato' {
                return generateJsonInvioLetture(inputParams);
            }
            when else {
               return null;
            }
        }
    }

    // TODO WAVE 2: adeguare per altre commodity.
    /*
    * @Author: Salvatore A. Sarà 19/10/2021
    * Risoluzione "Debug Should Use Logging Level"
    * Risoluzione "Avoid debug statements since they impact on performance"
    */
    @SuppressWarnings('PMD.AvoidDebugStatements')
    @testVisible
    private static HDT_WRP_GenericSapIntegration generateJsonCheckAutolettura(HDT_WRP_GenericSapIntegration inputParams) {
        if (inputParams == null) {
            System.debug(LoggingLevel.DEBUG, 'inputParams null.');
            return null;
        }

        String caseId = inputParams.recordId;

        HDT_QR_Case queryCase = new HDT_QR_Case();
        HDT_QR_SelfReadings queryReadings = new HDT_QR_SelfReadings();

        List<Case> cases = queryCase.getRecordsById(new List<String> {caseId}, 'Id,ContractCode__c,CommodityFormula__c');
        if (cases.isEmpty()) {
            System.debug(LoggingLevel.DEBUG, 'No Cases found.');
            return null;
        }

        Case readingCase = cases[0];
        System.debug(LoggingLevel.DEBUG, 'readingCase.CommodityFormula__c: ' + readingCase.CommodityFormula__c);
        
        String readingFields = 'Id';
        if (readingCase.CommodityFormula__c == 'Gas' || readingCase.CommodityFormula__c == 'Acqua') {
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
        System.debug(LoggingLevel.DEBUG, 'reading: ' + reading);
        
        JSONGenerator gen = JSON.createGenerator(false);
        

        gen.writeStartObject();
        gen.writeStringField('caseId', caseId);
        gen.writeStringField('readingId', reading.Id);
        gen.writeStringField('contractCode', readingCase.ContractCode__c);
        gen.writeStringField('commodity', readingCase.CommodityFormula__c);
        gen.writeFieldName('position');
        gen.writeStartArray();
        
        if (readingCase.CommodityFormula__c == 'Gas' || readingCase.CommodityFormula__c == 'Acqua') {
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
    /*
    * @Author: Salvatore A. Sarà 19/10/2021
    * Risoluzione "Debug Should Use Logging Level"
    * Risoluzione "Avoid debug statements since they impact on performance"
    */
    @SuppressWarnings('PMD.AvoidDebugStatements')
    @testVisible
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
        System.debug(LoggingLevel.DEBUG, 'readingCase.CommodityFormula__c: ' + readingCase.CommodityFormula__c);

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
        System.debug(LoggingLevel.DEBUG, 'reading: ' + reading);
        
        JSONGenerator gen = JSON.createGenerator(false);

        gen.writeStartObject();
        gen.writeStringField('serviceRequest', readingCase.Id);
        gen.writeStringField('pod', readingCase.PODPDRFormula__c);
        gen.writeFieldName('element');
        gen.writeStartArray();
        
        if (readingCase.CommodityFormula__c == 'Gas') {
            gen.writeStartObject();
            gen.writeStringField('counter', '1');
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
                gen.writeStringField('counter', '2');
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
                gen.writeStringField('counter', String.valueOf(i));
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

    public class HDT_WRP_SelfReadingResponse {
        public Boolean isResponseOk;
        public String checkAutoletturaDescription;
    }

    /*
    * @Author: Salvatore A. Sarà 19/10/2021
    * Risoluzione "Debug Should Use Logging Level"
    * Risoluzione "Avoid debug statements since they impact on performance"
    */
    @SuppressWarnings('PMD.AvoidDebugStatements')
    public static HDT_WRP_SelfReadingResponse handleResponse(HDT_WRP_GenericSapIntegration sapIntegration, String checkAutoletturaDescription) {
        System.debug(LoggingLevel.DEBUG, 'Handling response for request type: ' + sapIntegration.requestType);
        switch on sapIntegration.requestType {
            when 'CheckAutolettura' {
                return handleResponseCheckAutolettura(sapIntegration);
            }
            when 'InvioLetture' {
                return handleResponseInvioLetture(sapIntegration, checkAutoletturaDescription);
            }
            when 'InvioLettureForzato' {
                return handleResponseInvioLettureForzato(sapIntegration);
            }
            when else {
               return null;
            }
        }
    }

    private static HDT_WRP_SelfReadingResponse handleResponseCheckAutolettura(HDT_WRP_GenericSapIntegration sapIntegration) {

        String caseId = sapIntegration.recordId;
        HDT_WRP_SelfReadingResponse retWrap = new HDT_WRP_SelfReadingResponse();
        retWrap.isResponseOk = true;
        HDT_QR_Case queryCase = new HDT_QR_Case();
        List<Case> cases = queryCase.getRecordsById(new List<String> {caseId}, 'Id,Origin,Description,CommodityFormula__c');
        Boolean enableTurbobilling = String.isNotBlank(System.Label.TRB_Enable) && 'Y'.equalsIgnoreCase(System.Label.TRB_Enable)?true:false;
        Boolean isEnergy = !cases.isEmpty() && ('Gas'.equalsIgnoreCase(cases[0].CommodityFormula__c) || 'Energia Elettrica'.equalsIgnoreCase(cases[0].CommodityFormula__c))? true:false;
        Case readingCaseToUpdate = new Case();
        readingCaseToUpdate.Id = caseId;
        Map<String, Object> body = (Map<String, Object>) JSON.deserializeUntyped(sapIntegration.responseBody);
        Map<String,Object> dataBody = body.get('data') != null? (Map<String, Object>) body.get('data') : new Map<String,Object>();
        String outcome = dataBody.get('outcome') != null? (String)dataBody.get('outcome'):'KO';
        // SAP restituisce codice 502 in caso di check preliminare non superato.
        if ((sapIntegration.responseCode != 200 && sapIntegration.responseCode != 201) || (outcome != null && outcome.equalsIgnoreCase('KO'))) {
            retWrap.isResponseOk = false;
            String errorMessage = '';
            List<Object> errorDetails = (List<Object>) body.get('errorDetails');
            if(errorDetails != null && !errorDetails.isEmpty()) {
                Map<String, Object> errorObj = (Map<String, Object>) errorDetails[0];
                errorMessage = errorObj != null ? (String) errorObj.get('message') : '';
            }else{
                errorMessage = (String)dataBody.get('message');
            }
            if(enableTurbobilling && isEnergy){
                readingCaseToUpdate.TecnicalPhase__c = 'Esito KO da SAP';
            }else{
                readingCaseToUpdate.TecnicalPhase__c = 'Check preliminari KO';
            }
            
            
            
            if(!cases.isEmpty()) {
                Case currentReadingCase = cases[0];
                String nowDateFormat = Datetime.now().format('dd/MM/yyyy h:mm');
                String currentDescription = currentReadingCase.Description != null ? currentReadingCase.Description : '';
                readingCaseToUpdate.Description = nowDateFormat + ': ' + errorMessage + '\n' + currentDescription;
                HDT_UTL_DatabaseService.updateSObject(readingCaseToUpdate);
                if (isErrorWithActivity(errorMessage, currentReadingCase.Origin)) {
                    if(enableTurbobilling && isEnergy){
                        HDT_UTL_Case.createActivity(caseId, errorMessage, 'CBS_AUT002__ESITO_KO_DA_SAP', 'Esito KO da SAP');
                    }else {
                        HDT_UTL_Case.createActivity(caseId, errorMessage, 'CBS_AUT001__CHECK_PRELIMINARI_KO', 'Check preliminari KO');
                    }
                }
                HDT_UTL_DatabaseService.updateSObject(readingCaseToUpdate);
                if (isClosingError(errorMessage, currentReadingCase.Origin)) {
                    
                    if(currentReadingCase.Origin.equalsIgnoreCase('Web') 
                        || currentReadingCase.Origin.equalsIgnoreCase('App') 
                        || currentReadingCase.Origin.equalsIgnoreCase('Sportello')
                        || currentReadingCase.Origin.equalsIgnoreCase('Telefono Inbound')
                    ){
                        readingCaseToUpdate.Status = 'Closed';
                        readingCaseToUpdate.Phase__c = 'Annullato';
                        updateFuture(JSON.serialize(readingCaseToUpdate));
                    }else{
                        readingCaseToUpdate.Status = 'Closed';
                        readingCaseToUpdate.TecnicalPhase__c = 'Annullato';
                        HDT_UTL_DatabaseService.updateSObject(readingCaseToUpdate);
                    }
                }
                
            }
        } else {
            if(enableTurbobilling && isEnergy){
                readingCaseToUpdate.TecnicalPhase__c = 'Esito KO da SAP';
                HDT_UTL_DatabaseService.updateSObject(readingCaseToUpdate);
            }else{
                // L'aggiornamento a Check preliminari OK non possiamo farlo adesso, poichè va fatta prima la seconda callout per l'invio letture a SAP.
                //readingCaseToUpdate.TecnicalPhase__c = 'Check preliminari OK';
                // Salviamo nel wrp object il messaggio che in seguito dovremo scrivere sul campo Description del Case.
                Map<String, Object> data = (Map<String, Object>) body.get('data');
                String message = (String) data.get('message');
                if (message == 'data fuori finestra acquisibile') {
                    retWrap.checkAutoletturaDescription = message;
                }
            }
            
        }

        //HDT_UTL_DatabaseService.updateSObject(readingCaseToUpdate);
        // String serializedCase = JSON.serialize(readingCaseToUpdate);
        // updateFuture(serializedCase);

        return retWrap;
    }

    @Future
    private static void updateFuture(String inputString) {

        Case c = (Case) JSON.deserialize(inputString, Case.class);

        HDT_UTL_DatabaseService.updateSObject(c);

    }

    private static String getErrorMessage(HDT_WRP_GenericSapIntegration sapIntegration){
        String errorMessage = '';
        try{
            Map<String, Object> body = (Map<String, Object>) JSON.deserializeUntyped(sapIntegration.responseBody);
            Map<String,Object> dataBody = body.get('data') != null? (Map<String, Object>) body.get('data') : new Map<String,Object>();
            List<Object> errorDetails = (List<Object>) body.get('errorDetails');
            if(errorDetails != null && !errorDetails.isEmpty()) {
                Map<String, Object> errorObj = (Map<String, Object>) errorDetails[0];
                errorMessage = errorObj != null ? (String) errorObj.get('message') : '';
            }else{
                errorMessage = (String)dataBody.get('message');
            }
        }catch (Exception e){
            errorMessage = (sapIntegration.responseCode != null || String.isNotBlank(sapIntegration.responseStatus) )?sapIntegration.responseCode+' - ' + sapIntegration.responseStatus : 'Nessuna risposta dal server';
        }
        return errorMessage;
    }

    private static HDT_WRP_SelfReadingResponse handleResponseInvioLetture(HDT_WRP_GenericSapIntegration sapIntegration, String checkAutoletturaDescription) {

        String caseId = sapIntegration.recordId;
        HDT_WRP_SelfReadingResponse retWrap = new HDT_WRP_SelfReadingResponse();
        retWrap.isResponseOk = true;

        Case readingCaseToUpdate = new Case();
        readingCaseToUpdate.Id = caseId;
        /*
        * @Author: Salvatore A. Sarà 19/10/2021
        * Risoluzione "Detects when a local variable is declared and-or assigned but not used."
        */
        // Map<String, Object> body = (Map<String, Object>) JSON.deserializeUntyped(sapIntegration.responseBody);

        if (sapIntegration.responseCode != 200 && sapIntegration.responseCode != 201) {
            retWrap.isResponseOk = false;
        } else {
            // Settiamo prima l'esito precedente del Check Autolettura
            readingCaseToUpdate.TecnicalPhase__c = 'Check preliminari OK';
            readingCaseToUpdate.Description = checkAutoletturaDescription;
            HDT_UTL_DatabaseService.updateSObject(readingCaseToUpdate);
            // Infine settiamo l'esito OK dell'Invio Lettura.
            Case readingCaseToUpdateInvioLetture = new Case(); // Necessario un nuovo oggetto Case, altrimenti non sbianca la TechnicalPhase precedente.
            readingCaseToUpdateInvioLetture.Id = readingCaseToUpdate.Id;
            readingCaseToUpdateInvioLetture.Phase__c = 'Inviata a SAP';
            String serializedCase = JSON.serialize(readingCaseToUpdateInvioLetture);
            updateFuture(serializedCase);
        }

        //HDT_UTL_DatabaseService.updateSObject(readingCaseToUpdate);


        return retWrap;
    }

    private static HDT_WRP_SelfReadingResponse handleResponseInvioLettureForzato(HDT_WRP_GenericSapIntegration sapIntegration) {

        String caseId = sapIntegration.recordId;
        HDT_WRP_SelfReadingResponse retWrap = new HDT_WRP_SelfReadingResponse();
        retWrap.isResponseOk = true;

        Case readingCaseToUpdate = new Case();
        readingCaseToUpdate.Id = caseId;
        /*
        * @Author: Salvatore A. Sarà 19/10/2021
        * Risoluzione "Detects when a local variable is declared and-or assigned but not used."
        */
        // Map<String, Object> body = (Map<String, Object>) JSON.deserializeUntyped(sapIntegration.responseBody);

        if (sapIntegration.responseCode != 200 && sapIntegration.responseCode != 201) {
            retWrap.isResponseOk = false;
            retWrap.checkAutoletturaDescription = getErrorMessage(sapIntegration);
        } else {
            readingCaseToUpdate.Phase__c = 'Inviata a SAP';
            String serializedCase = JSON.serialize(readingCaseToUpdate);
            updateFuture(serializedCase);
        }

        //HDT_UTL_DatabaseService.updateSObject(readingCaseToUpdate);

        return retWrap;
    }

    // Verifica se per il dato Canale è prevista la creazione di Activity per l'errore restituito dal Check Autolettura.
    private static Boolean isErrorWithActivity(String msg, String origin) {
        if (String.isBlank(origin) || String.isBlank(msg)) {
            return False;
        }

        Boolean createActivity = False;
        switch on origin {
            when 'Sportello', 'Telefono Inbound' {
                createActivity = msg.contains('superiore valore massimo concesso') || msg.contains('registri incompleti');
            }
            when else {
                /*
                * @Author: Salvatore A. Sarà 18/10/2021
                * Risoluzione "Avoid Empty Block Statements"
                */
                return createActivity;
            }
        }

        return createActivity;
    }

    // Verifica se per il dato Canale l'errore deve chiudere il Case.
    private static Boolean isClosingError(String msg, String origin) {
        if (String.isBlank(origin) || String.isBlank(msg)) {
            return false;
        }

        Boolean closeCase = false;
        switch on origin {
            when 'Sportello', 'Telefono Inbound' {
                closeCase = msg.contains('data fuori finestra (non acquisibile)') || msg.contains('inferiore valore minimo concesso');
            }when 'Web', 'App', 'APP'{
                closeCase = true;
            }
            when else {
                /*
                * @Author: NTTDATA 17/03/2022
                * Risoluzione "Restituiamo true per tutti gli altri canali in quanto il case in caso di KO si deve Annullare"
                */
                closeCase = true;
            }
        }

        return closeCase;
    }

}