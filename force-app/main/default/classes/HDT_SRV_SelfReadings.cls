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

    @InvocableMethod(label = 'Clona Readings da Padre')
    public static void cloneReadingFromParentCase (List<HDT_UTL_FlowFatturazioneInputs> inputs){

        Case parentCase = inputs[0].parentCase;
        Case childCase = inputs[0].childCase;
		HDT_QR_RecordType rtQueryHandler = new HDT_QR_RecordType();

        try {
            switch on parentCase.CommodityFormula__c {
                when  'Acqua'{
    
                    List<Reading__c> letturaAcquaParentList = [SELECT Mru__c, SendTo__c, Name, ReadingDate__c, ReadingDigitNumberMeter__c, ReadingDigitNumberCorrector__c, ReadingDateMeter__c, ReadingDateCorrector__c, ReadingBandMeter__c, ReadingBandCorrector__c, ReadingValueMeter__c, ReadingValueCorrector__c, ReadingSerialNumberMeter__c, ReadingSerialNumber2__c, ReadingRegisterMeter__c, ReadingRegisterCorrector__c, ReadingTypeMeter__c, ReadingTypeCorrector__c, ReadingUnitMeter__c, ReadingUnitCorrector__c FROM Reading__c WHERE CaseAcqua__c =: parentCase.Id WITH SECURITY_ENFORCED LIMIT 1];
    
                    if(letturaAcquaParentList.size() > 0){
                        List<Reading__c> listaLettureAcquaChild = new List<Reading__c>();
                        for  (Reading__c letturaAcquaParent : letturaAcquaParentList ) {
                            Reading__c letturaAcquaChild = new Reading__c();
                            letturaAcquaChild.CaseAcqua__c = childCase.Id;
                            letturaAcquaChild.RecordTypeId = rtQueryHandler.getRecordTypeIdByName('HDT_RT_LetturaAcqua');
                            letturaAcquaChild.Mru__c = letturaAcquaParent.Mru__c;
                            letturaAcquaChild.SendTo__c = letturaAcquaParent.SendTo__c;
                            letturaAcquaChild.Name = letturaAcquaParent.Name;
                            letturaAcquaChild.ReadingDate__c =  letturaAcquaParent.ReadingDate__c;
                            letturaAcquaChild.ReadingDigitNumberMeter__c = letturaAcquaParent.ReadingDigitNumberMeter__c;
                            letturaAcquaChild.ReadingDigitNumberCorrector__c = letturaAcquaParent.ReadingDigitNumberCorrector__c;
                            letturaAcquaChild.ReadingDateMeter__c = letturaAcquaParent.ReadingDateMeter__c;
                            letturaAcquaChild.ReadingDateCorrector__c = letturaAcquaParent.ReadingDateCorrector__c;
                            letturaAcquaChild.ReadingBandMeter__c = letturaAcquaParent.ReadingBandMeter__c;
                            letturaAcquaChild.ReadingBandCorrector__c = letturaAcquaParent.ReadingBandCorrector__c;
                            letturaAcquaChild.ReadingValueMeter__c = letturaAcquaParent.ReadingValueMeter__c;
                            letturaAcquaChild.ReadingValueCorrector__c = letturaAcquaParent.ReadingValueCorrector__c;
                            letturaAcquaChild.ReadingSerialNumberMeter__c = letturaAcquaParent.ReadingSerialNumberMeter__c;
                            letturaAcquaChild.ReadingSerialNumber2__c = letturaAcquaParent.ReadingSerialNumber2__c;
                            letturaAcquaChild.ReadingRegisterMeter__c = letturaAcquaParent.ReadingRegisterMeter__c;
                            letturaAcquaChild.ReadingRegisterCorrector__c = letturaAcquaParent.ReadingRegisterCorrector__c;
                            letturaAcquaChild.ReadingTypeMeter__c = letturaAcquaParent.ReadingTypeMeter__c;
                            letturaAcquaChild.ReadingTypeCorrector__c = letturaAcquaParent.ReadingTypeCorrector__c;
                            letturaAcquaChild.ReadingUnitMeter__c = letturaAcquaParent.ReadingUnitMeter__c;
                            letturaAcquaChild.ReadingUnitCorrector__c = letturaAcquaParent.ReadingUnitCorrector__c;
                            listaLettureAcquaChild.add(letturaAcquaChild);
                        }
                        insert listaLettureAcquaChild;
                        
                    }
                    
                }
                when 'Energia Elettrica' {

                    List<Reading__c> letturaEleParentList = [SELECT Mru__c,SendTo__c,Name,ReadingDate__c,ReadingDigitNumber2__c,ReadingDigitNumber1__c,ReadingDigitNumber3__c,ReadingDigitNumber4__c,ReadingDigitNumber5__c,ReadingDigitNumber6__c,ReadingDigitNumber7__c,ReadingDigitNumber8__c,ReadingDigitNumber9__c,ReadingDate1__c,ReadingDate2__c,ReadingDate3__c,ReadingDate4__c,ReadingDate5__c,ReadingDate6__c,ReadingDate7__c,ReadingDate8__c,ReadingDate9__c,ReadingBand1__c,ReadingBand2__c,ReadingBand3__c,ReadingBand4__c,ReadingBand5__c,ReadingBand6__c,ReadingBand7__c,ReadingBand8__c,ReadingBand9__c,ReadingValue1__c,ReadingValue2__c,ReadingValue3__c,ReadingValue4__c,ReadingValue5__c,ReadingValue6__c,ReadingValue7__c,ReadingValue8__c,ReadingValue9__c,ReadingSerialNumber1__c,ReadingSerialNumber2__c,ReadingSerialNumber3__c,ReadingSerialNumber4__c,ReadingSerialNumber5__c,ReadingSerialNumber6__c,ReadingSerialNumber7__c,ReadingSerialNumber8__c,ReadingSerialNumber9__c,ReadingRegister1__c,ReadingRegister2__c,ReadingRegister3__c,ReadingRegister4__c,ReadingRegister5__c,ReadingRegister6__c,ReadingRegister7__c,ReadingRegister8__c,ReadingRegister9__c,ReadingType1__c,ReadingType2__c,ReadingType3__c,ReadingType4__c,ReadingType5__c,ReadingType6__c,ReadingType7__c,ReadingType8__c,ReadingType9__c,ReadingUnit1__c,ReadingUnit2__c,ReadingUnit3__c,ReadingUnit4__c,ReadingUnit5__c,ReadingUnit6__c,ReadingUnit7__c,ReadingUnit8__c,ReadingUnit9__c FROM Reading__c WHERE CaseEle__c =: parentCase.Id WITH SECURITY_ENFORCED LIMIT 1];

                    if(letturaEleParentList.size() > 0){
                        List<Reading__c> listaLettureEleChild = new List<Reading__c>();
                        for (Reading__c letturaEleParent : letturaEleParentList){
                            Reading__c letturaEleChild = new Reading__c();
                            letturaEleChild.CaseEle__c = childCase.Id;
                            letturaEleChild.RecordTypeId = rtQueryHandler.getRecordTypeIdByName('HDT_RT_LetturaEle');
                            letturaEleChild.Mru__c = letturaEleParent.Mru__c;
                            letturaEleChild.SendTo__c = letturaEleParent.SendTo__c;
                            letturaEleChild.Name = letturaEleParent.Name;
                            letturaEleChild.ReadingDate__c =  letturaEleParent.ReadingDate__c;
                            letturaEleChild.ReadingDigitNumber1__c = letturaEleParent.ReadingDigitNumber1__c;
                            letturaEleChild.ReadingDigitNumber2__c = letturaEleParent.ReadingDigitNumber2__c;
                            letturaEleChild.ReadingDigitNumber3__c = letturaEleParent.ReadingDigitNumber3__c;
                            letturaEleChild.ReadingDigitNumber4__c = letturaEleParent.ReadingDigitNumber4__c;
                            letturaEleChild.ReadingDigitNumber5__c = letturaEleParent.ReadingDigitNumber5__c;
                            letturaEleChild.ReadingDigitNumber6__c = letturaEleParent.ReadingDigitNumber6__c;
                            letturaEleChild.ReadingDigitNumber7__c = letturaEleParent.ReadingDigitNumber7__c;
                            letturaEleChild.ReadingDigitNumber8__c = letturaEleParent.ReadingDigitNumber8__c;
                            letturaEleChild.ReadingDigitNumber9__c = letturaEleParent.ReadingDigitNumber9__c;
                            letturaEleChild.ReadingDate1__c = letturaEleParent.ReadingDate1__c;
                            letturaEleChild.ReadingDate2__c = letturaEleParent.ReadingDate2__c;
                            letturaEleChild.ReadingDate3__c = letturaEleParent.ReadingDate3__c;
                            letturaEleChild.ReadingDate4__c = letturaEleParent.ReadingDate4__c;
                            letturaEleChild.ReadingDate5__c = letturaEleParent.ReadingDate5__c;
                            letturaEleChild.ReadingDate6__c = letturaEleParent.ReadingDate6__c;
                            letturaEleChild.ReadingDate7__c = letturaEleParent.ReadingDate7__c;
                            letturaEleChild.ReadingDate8__c = letturaEleParent.ReadingDate8__c;
                            letturaEleChild.ReadingDate9__c = letturaEleParent.ReadingDate9__c;
                            letturaEleChild.ReadingBand1__c = letturaEleParent.ReadingBand1__c;
                            letturaEleChild.ReadingBand2__c = letturaEleParent.ReadingBand2__c;
                            letturaEleChild.ReadingBand3__c = letturaEleParent.ReadingBand3__c;
                            letturaEleChild.ReadingBand4__c = letturaEleParent.ReadingBand4__c;
                            letturaEleChild.ReadingBand5__c = letturaEleParent.ReadingBand5__c;
                            letturaEleChild.ReadingBand6__c = letturaEleParent.ReadingBand6__c;
                            letturaEleChild.ReadingBand7__c = letturaEleParent.ReadingBand7__c;
                            letturaEleChild.ReadingBand8__c = letturaEleParent.ReadingBand8__c;
                            letturaEleChild.ReadingBand9__c = letturaEleParent.ReadingBand9__c;
                            letturaEleChild.ReadingValue1__c = letturaEleParent.ReadingValue1__c;
                            letturaEleChild.ReadingValue2__c = letturaEleParent.ReadingValue2__c;
                            letturaEleChild.ReadingValue3__c = letturaEleParent.ReadingValue3__c;
                            letturaEleChild.ReadingValue4__c = letturaEleParent.ReadingValue4__c;
                            letturaEleChild.ReadingValue5__c = letturaEleParent.ReadingValue5__c;
                            letturaEleChild.ReadingValue6__c = letturaEleParent.ReadingValue6__c;
                            letturaEleChild.ReadingValue7__c = letturaEleParent.ReadingValue7__c;
                            letturaEleChild.ReadingValue8__c = letturaEleParent.ReadingValue8__c;
                            letturaEleChild.ReadingValue9__c = letturaEleParent.ReadingValue9__c;
                            letturaEleChild.ReadingSerialNumber1__c = letturaEleParent.ReadingSerialNumber1__c;
                            letturaEleChild.ReadingSerialNumber2__c = letturaEleParent.ReadingSerialNumber2__c;
                            letturaEleChild.ReadingSerialNumber3__c = letturaEleParent.ReadingSerialNumber3__c;
                            letturaEleChild.ReadingSerialNumber4__c = letturaEleParent.ReadingSerialNumber4__c;
                            letturaEleChild.ReadingSerialNumber5__c = letturaEleParent.ReadingSerialNumber5__c;
                            letturaEleChild.ReadingSerialNumber6__c = letturaEleParent.ReadingSerialNumber6__c;
                            letturaEleChild.ReadingSerialNumber7__c = letturaEleParent.ReadingSerialNumber7__c;
                            letturaEleChild.ReadingSerialNumber8__c = letturaEleParent.ReadingSerialNumber8__c;
                            letturaEleChild.ReadingSerialNumber9__c = letturaEleParent.ReadingSerialNumber9__c;
                            letturaEleChild.ReadingRegister1__c = letturaEleParent.ReadingRegister1__c;
                            letturaEleChild.ReadingRegister2__c = letturaEleParent.ReadingRegister2__c;
                            letturaEleChild.ReadingRegister3__c = letturaEleParent.ReadingRegister3__c;
                            letturaEleChild.ReadingRegister4__c = letturaEleParent.ReadingRegister4__c;
                            letturaEleChild.ReadingRegister5__c = letturaEleParent.ReadingRegister5__c;
                            letturaEleChild.ReadingRegister6__c = letturaEleParent.ReadingRegister6__c;
                            letturaEleChild.ReadingRegister7__c = letturaEleParent.ReadingRegister7__c;
                            letturaEleChild.ReadingRegister8__c = letturaEleParent.ReadingRegister8__c;
                            letturaEleChild.ReadingRegister9__c = letturaEleParent.ReadingRegister9__c;
                            letturaEleChild.ReadingType1__c = letturaEleParent.ReadingType1__c;
                            letturaEleChild.ReadingType2__c = letturaEleParent.ReadingType2__c;
                            letturaEleChild.ReadingType3__c = letturaEleParent.ReadingType3__c;
                            letturaEleChild.ReadingType4__c = letturaEleParent.ReadingType4__c;
                            letturaEleChild.ReadingType5__c = letturaEleParent.ReadingType5__c;
                            letturaEleChild.ReadingType6__c = letturaEleParent.ReadingType6__c;
                            letturaEleChild.ReadingType7__c = letturaEleParent.ReadingType7__c;
                            letturaEleChild.ReadingType8__c = letturaEleParent.ReadingType8__c;
                            letturaEleChild.ReadingType9__c = letturaEleParent.ReadingType9__c;
                            letturaEleChild.ReadingUnit1__c = letturaEleParent.ReadingUnit1__c;
                            letturaEleChild.ReadingUnit2__c = letturaEleParent.ReadingUnit2__c;
                            letturaEleChild.ReadingUnit3__c = letturaEleParent.ReadingUnit3__c;
                            letturaEleChild.ReadingUnit4__c = letturaEleParent.ReadingUnit4__c;
                            letturaEleChild.ReadingUnit5__c = letturaEleParent.ReadingUnit5__c;
                            letturaEleChild.ReadingUnit6__c = letturaEleParent.ReadingUnit6__c;
                            letturaEleChild.ReadingUnit7__c = letturaEleParent.ReadingUnit7__c;
                            letturaEleChild.ReadingUnit8__c = letturaEleParent.ReadingUnit8__c;
                            letturaEleChild.ReadingUnit9__c = letturaEleParent.ReadingUnit9__c;
                            listaLettureEleChild.add(letturaEleChild);
                        }

                        insert listaLettureEleChild;
                    }

                }
                when 'Gas' {
    
                    List<Reading__c> letturaGasParentList = [SELECT Mru__c, SendTo__c, Name, ReadingDate__c, ReadingDigitNumberMeter__c, ReadingDigitNumberCorrector__c, ReadingDateMeter__c, ReadingDateCorrector__c, ReadingBandMeter__c, ReadingBandCorrector__c, ReadingValueMeter__c, ReadingValueCorrector__c, ReadingSerialNumberMeter__c, ReadingSerialNumber2__c, ReadingRegisterMeter__c, ReadingRegisterCorrector__c, ReadingTypeMeter__c, ReadingTypeCorrector__c, ReadingUnitMeter__c, ReadingUnitCorrector__c FROM Reading__c WHERE CaseGas__c =: parentCase.Id WITH SECURITY_ENFORCED LIMIT 1];
    
                    if(letturaGasParentList.size() > 0){
                        List<Reading__c> listaLettureGasChild = new List<Reading__c>();
                        for (Reading__c letturaGasParent : letturaGasParentList){
                            Reading__c letturaGasChild = new Reading__c();
                            letturaGasChild.CaseGas__c = childCase.Id;
                            letturaGasChild.RecordTypeId = rtQueryHandler.getRecordTypeIdByName('HDT_RT_LetturaGas');
                            letturaGasChild.Mru__c = letturaGasParent.Mru__c;
                            letturaGasChild.SendTo__c = letturaGasParent.SendTo__c;
                            letturaGasChild.Name = letturaGasParent.Name;
                            letturaGasChild.ReadingDate__c =  letturaGasParent.ReadingDate__c;
                            letturaGasChild.ReadingDigitNumberMeter__c = letturaGasParent.ReadingDigitNumberMeter__c;
                            letturaGasChild.ReadingDigitNumberCorrector__c = letturaGasParent.ReadingDigitNumberCorrector__c;
                            letturaGasChild.ReadingDateMeter__c = letturaGasParent.ReadingDateMeter__c;
                            letturaGasChild.ReadingDateCorrector__c = letturaGasParent.ReadingDateCorrector__c;
                            letturaGasChild.ReadingBandMeter__c = letturaGasParent.ReadingBandMeter__c;
                            letturaGasChild.ReadingBandCorrector__c = letturaGasParent.ReadingBandCorrector__c;
                            letturaGasChild.ReadingValueMeter__c = letturaGasParent.ReadingValueMeter__c;
                            letturaGasChild.ReadingValueCorrector__c = letturaGasParent.ReadingValueCorrector__c;
                            letturaGasChild.ReadingSerialNumberMeter__c = letturaGasParent.ReadingSerialNumberMeter__c;
                            letturaGasChild.ReadingSerialNumber2__c = letturaGasParent.ReadingSerialNumber2__c;
                            letturaGasChild.ReadingRegisterMeter__c = letturaGasParent.ReadingRegisterMeter__c;
                            letturaGasChild.ReadingRegisterCorrector__c = letturaGasParent.ReadingRegisterCorrector__c;
                            letturaGasChild.ReadingTypeMeter__c = letturaGasParent.ReadingTypeMeter__c;
                            letturaGasChild.ReadingTypeCorrector__c = letturaGasParent.ReadingTypeCorrector__c;
                            letturaGasChild.ReadingUnitMeter__c = letturaGasParent.ReadingUnitMeter__c;
                            letturaGasChild.ReadingUnitCorrector__c = letturaGasParent.ReadingUnitCorrector__c;
                            listaLettureGasChild.add(letturaGasChild);
                        }
                        insert listaLettureGasChild;
                    }
                }
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.DEBUG,'Exception--> '+e.getMessage());
        }
    }

    public class HDT_UTL_FlowFatturazioneInputs {
        @InvocableVariable
        public Case parentCase;
        @InvocableVariable
        public Case childCase;
    }
}