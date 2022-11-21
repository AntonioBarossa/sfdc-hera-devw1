@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing class HDT_UTL_SelfReadings {

    private static HDT_QR_SelfReadings queryHandler = new HDT_QR_SelfReadings();
    private static HDT_QR_RecordType rtQueryHandler = new HDT_QR_RecordType();

    public class HDT_UTL_SelfReadingsFlowInputs {

        @InvocableVariable
        public String servicePointId;

        @InvocableVariable
        public String accountId;

        @InvocableVariable
        public Datetime caseCreatedDateTime;

        @InvocableVariable
        public String metadataRecordName;

    }

    public class HDT_UTL_SelfReadingsFlowOutputs {
        @InvocableVariable
        public Boolean isProcessReading;
    
        @InvocableVariable
        public String orderId;

        @InvocableVariable
        public String orderRecordType;
    }

    // Restituisce il numero di registri su cui è presente una lettura.
    // Si assume che la lettura in input non sia su commodity Gas.
    public static Integer getRegistersCount(Reading__c reading) {
        if (reading == null) {
            return 0;
        }

        Integer registersCount = 0;
        for (Integer i = 1; i <= 9; i++) { // TODO WAVE 2|3: estendere a 12?
            List<String> indexParam = new List<String> { String.valueOf(i) };
            Decimal readingValue = (Decimal) reading.get(String.format('ReadingValue{0}__c', indexParam));
            if (readingValue != null) {
                registersCount++;
            }
        }

        return registersCount;
    }
    
    @InvocableMethod(label = 'isProcessReading')
    public static List<HDT_UTL_SelfReadingsFlowOutputs> isProcessReading(List<HDT_UTL_SelfReadingsFlowInputs> inputs) {
        List<HDT_UTL_SelfReadingsFlowOutputs> results = new List<HDT_UTL_SelfReadingsFlowOutputs>();
        HDT_UTL_SelfReadingsFlowOutputs result = new HDT_UTL_SelfReadingsFlowOutputs();

        String servicePointId = inputs[0].servicePointId;
        String accountId = inputs[0].accountId;
        Date caseCreatedDate = inputs[0].caseCreatedDateTime.date();
        String metadataRecordName = inputs[0].metadataRecordName;

        List<HDT_SelfReadings__mdt> configs = queryHandler.getConfigurationByName(metadataRecordName);
        if (configs.isEmpty()) {
            System.debug(LoggingLevel.DEBUG, 'HDT_UTL_SelfReadings: Nessun custom metadata trovato.');
            result.isProcessReading = false;
            results.add(result);
            return results; 
        }

        List<String> recordTypes = configs[0].OrderRecordTypes__c.split(',');
        List<Id> recordTypeIds = rtQueryHandler.getRecordTypeIdsByNames(recordTypes);
        
        List<String> badPhases = new List<String>();
        List<String> badStates = new List<String>();

        if (!String.isBlank(configs[0].OrderBadPhases__c)) {
            badPhases = configs[0].OrderBadPhases__c.split(',');
        }

        if (!String.isBlank(configs[0].OrderBadStates__c)) {
            badStates = configs[0].OrderBadStates__c.split(',');
        }

        List<Order> activeOrders = queryHandler.accountOrders(accountId, servicePointId, recordTypeIds, badPhases, badStates);
        System.debug(LoggingLevel.DEBUG, 'activeOrders size: ' + activeOrders.size());

        Date contractStartDate = null;
        for (Order activeOrder : activeOrders) {
            contractStartDate = activeOrder.EffectiveDate__c;
            if (contractStartDate == null) {
                contractStartDate = activeOrder.CreatedDate.date();
            }

            Date minimumDate = contractStartDate.addDays(Integer.valueOf(configs[0].ReadingDateDecrease__c));
            Date maximumDate = contractStartDate.addDays(Integer.valueOf(configs[0].ReadingDateIncrease__c));

            if (caseCreatedDate > minimumDate && caseCreatedDate < maximumDate) {
                System.debug(LoggingLevel.DEBUG, 'Trovato processo elegibile per innesco autolettura da processo.');
                result.isProcessReading = true;
                result.orderId = activeOrder.Id;
                result.orderRecordType = activeOrder.RecordType.DeveloperName;
                results.add(result);
                return results;
            }
        }
        
        System.debug(LoggingLevel.DEBUG, 'Nessun processo trovato per innescare una autolettura da processo.');
        result.isProcessReading = false;
        results.add(result);
        return results; 
    }

    /**
     * Gestisce l'upsert dei Case di Autolettura con canale IVR/SOL.
     * Mulesoft crea inizialmente un Case vuoto e poi lo aggiorna dopo aver chiamato il Check Autolettura di SAP.
     */
    public static void upsertInboundSelfReading(HDT_WRP_SelfReadings.HDT_WRP_SelfReadingsRequest request, HDT_WRP_SelfReadings.HDT_WRP_SelfReadingsResponse response) {

        Case c = new Case();
        Reading__c r = new Reading__c();
        Boolean isGas = request.commodity.equals('Gas') || request.commodity.equals('G');

        if (String.isNotBlank(request.id)) {
            c.Id = request.id;
        }

        if (String.isNotBlank(request.readings.id)) {
            r.Id = request.readings.id;
        }

        Contract inputContract = queryHandler.getContractBySapCode(request.contractCode);
        if (inputContract == null) {
            throw new HDT_UTL_HeraException('Could not find contract with code: ' + request.contractCode);
        }

        HDT_QR_AccountContactRelation acrQueryHandler = new HDT_QR_AccountContactRelation();
        AccountContactRelation acr = acrQueryHandler.getPrimaryContactRelation(inputContract.AccountId);
        if (acr == null || String.isBlank(acr.ContactId)) {
            throw new HDT_UTL_HeraException('Could not find primary contact for Account: ' + inputContract.AccountId);
        }

        c.AccountId = inputContract.AccountId;
        c.ContactId = acr.ContactId;
        c.Contract__c = inputContract.Id;
        c.ServicePoint__c = inputContract.ServicePoint__c;
        if(String.isNotBlank(request.origin)){
            c.Origin = request.origin;
        }
        c.RecordTypeId = rtQueryHandler.getRecordTypeIdByName('HDT_RT_Autolettura');
        c.Cluster__c = String.isNotBlank(request.cluster) ? request.cluster : 'Autolettura';
        c.Type = String.isNotBlank(request.type) ? request.type : 'Autolettura da cliente';
        c.IntegrationId__c = request.integrationId;
        c.MeterCode__c = request.serialNumber;
        c.ReadingDate__c = request.readingDate != null ? request.readingDate : System.today();
        c.DistributorCode__c = inputContract.ServicePoint__r.Distributor__r.Code__c;
        c.ServicePointCode__c = inputContract.ServicePoint__r?.ServicePointCode__c;
        c.Commodity__c = isGas ? 'Gas' : 'Energia Elettrica';
        c.SalesCompanyCode__c = isGas ? '10V0000160' : '13V0000000'; // TODO WAVE 2: adeguare con le altre company in ambito.

        HDT_QR_CausalCodeCalculation causalCodeHandler = new HDT_QR_CausalCodeCalculation();
        HDT_CausalCodeCalculation__mdt causalCodeMdt = causalCodeHandler.calculateCausalCode(c.Cluster__c, c.Type, '', request.commodity);
        c.CausalCode__c = causalCodeMdt.CausalCode__c;

        /**@frpanico 2022-11
         * Sulle autoletture IVR e' necessario inserire il controllo di compatibilita'
         * In quanto altrimenti possono crearei N pratiche di cui N-1 andranno in Heroku KO
         * Poiche' esiste gia' la prima pratica
         * Dalla velocita' con cui arrivano i due messaggi di creazione e poi di OK 
         * Che appaiono quasi simultanei e' necessario inserire il controllo di compatibilita'
         * Sul Check preliminari OK piuttosto che sulla Bozza
         * Dato che nel caso in cui il check sia in KO il Case viene annullato
         */
        switch on request.outcome {
            when 'OK' {
                String compatibility = '';
                try
                {
                     compatibility = HDT_UTL_MatrixCompatibility.checkCompatibilityPostSales(c);
                }
                catch(Exception e)
                {
                    compatibility = '';
                }
                if(String.isEmpty(compatibility))
                {
                    c.Phase__c = 'Check preliminari OK';
                }
                else
                {
                    c.Phase__c = 'Annullato';
                    c.Status = 'Closed';
                    c.CancellationReason__c = 'Processo incompatibile';
                }
            }
            when 'KO' {
                c.Phase__c = 'Check preliminari KO';
                HDT_UTL_DatabaseService.upsertSObject(c); // necessario per doppia transizione di fase.
                String nowDateFormat = Datetime.now().format('dd/MM/yyyy h:mm');
                c.Description = nowDateFormat + ': '  + request.outcomeDescription;
                c.Phase__c = 'Annullato';
                c.Status = 'Closed';
            }
            when else {
                c.Phase__c = 'Bozza';
                c.Status = 'In Lavorazione';
            }
        }

        c.Outcome__c = request.outcome;
        //request.outcomeCode;
        //request.outcomeDescription;

        HDT_UTL_DatabaseService.upsertSObject(c);
        response.caseId = c.Id;

        r.Mru__c = request.readings.mru;
        r.SendTo__c = request.readings.sendTo;
        r.Name = 'Lettura ' + Datetime.now().format('dd/MM/y HH:mm:ss');
        r.ReadingDate__c = request.readingDate != null ? request.readingDate : request.readings.date1 != null ? request.readings.date1 : System.today();
        if (isGas) {
            r.CaseGas__c = c.Id;
            r.RecordTypeId = rtQueryHandler.getRecordTypeIdByName('HDT_RT_LetturaGas');
            r.ReadingDigitNumberMeter__c = request.readings.digits1;
            r.ReadingDigitNumberCorrector__c = request.readings.digits2;
            r.ReadingDateMeter__c = request.readings.date1;
            r.ReadingDateCorrector__c = request.readings.date2;
            r.ReadingBandMeter__c = request.readings.band1;
            r.ReadingBandCorrector__c = request.readings.band2;
            r.ReadingValueMeter__c = request.readings.value1;
            r.ReadingValueCorrector__c = request.readings.value2;
            r.ReadingSerialNumberMeter__c = request.readings.serialNumber1;
            r.ReadingSerialNumberCorrector__c = request.readings.serialNumber2;
            r.ReadingRegisterMeter__c = request.readings.register1;
            r.ReadingRegisterCorrector__c = request.readings.register2;
            r.ReadingTypeMeter__c = request.readings.type1;
            r.ReadingTypeCorrector__c = request.readings.type2;
            r.ReadingUnitMeter__c = request.readings.unit1;
            r.ReadingUnitCorrector__c = request.readings.unit2;
        } else { // Energia Elettrica (TODO: da adeguare in Wave 2 per gestire anche le altre commodity)
            r.CaseEle__c = c.Id;
            r.RecordTypeId = rtQueryHandler.getRecordTypeIdByName('HDT_RT_LetturaEle');
            r.ReadingDigitNumber1__c = request.readings.digits1;
            r.ReadingDigitNumber2__c = request.readings.digits2;
            r.ReadingDigitNumber3__c = request.readings.digits3;
            r.ReadingDigitNumber4__c = request.readings.digits4;
            r.ReadingDigitNumber5__c = request.readings.digits5;
            r.ReadingDigitNumber6__c = request.readings.digits6;
            r.ReadingDigitNumber7__c = request.readings.digits7;
            r.ReadingDigitNumber8__c = request.readings.digits8;
            r.ReadingDigitNumber9__c = request.readings.digits9;
            r.ReadingDate1__c = request.readings.date1;
            r.ReadingDate2__c = request.readings.date2;
            r.ReadingDate3__c = request.readings.date3;
            r.ReadingDate4__c = request.readings.date4;
            r.ReadingDate5__c = request.readings.date5;
            r.ReadingDate6__c = request.readings.date6;
            r.ReadingDate7__c = request.readings.date7;
            r.ReadingDate8__c = request.readings.date8;
            r.ReadingDate9__c = request.readings.date9;
            r.ReadingBand1__c = request.readings.band1;
            r.ReadingBand2__c = request.readings.band2;
            r.ReadingBand3__c = request.readings.band3;
            r.ReadingBand4__c = request.readings.band4;
            r.ReadingBand5__c = request.readings.band5;
            r.ReadingBand6__c = request.readings.band6;
            r.ReadingBand7__c = request.readings.band7;
            r.ReadingBand8__c = request.readings.band8;
            r.ReadingBand9__c = request.readings.band9;
            r.ReadingValue1__c = request.readings.value1;
            r.ReadingValue2__c = request.readings.value2;
            r.ReadingValue3__c = request.readings.value3;
            r.ReadingValue4__c = request.readings.value4;
            r.ReadingValue5__c = request.readings.value5;
            r.ReadingValue6__c = request.readings.value6;
            r.ReadingValue7__c = request.readings.value7;
            r.ReadingValue8__c = request.readings.value8;
            r.ReadingValue9__c = request.readings.value9;
            r.ReadingSerialNumber1__c = request.readings.serialNumber1;
            r.ReadingSerialNumber2__c = request.readings.serialNumber2;
            r.ReadingSerialNumber3__c = request.readings.serialNumber3;
            r.ReadingSerialNumber4__c = request.readings.serialNumber4;
            r.ReadingSerialNumber5__c = request.readings.serialNumber5;
            r.ReadingSerialNumber6__c = request.readings.serialNumber6;
            r.ReadingSerialNumber7__c = request.readings.serialNumber7;
            r.ReadingSerialNumber8__c = request.readings.serialNumber8;
            r.ReadingSerialNumber9__c = request.readings.serialNumber9;
            r.ReadingRegister1__c = request.readings.register1;
            r.ReadingRegister2__c = request.readings.register2;
            r.ReadingRegister3__c = request.readings.register3;
            r.ReadingRegister4__c = request.readings.register4;
            r.ReadingRegister5__c = request.readings.register5;
            r.ReadingRegister6__c = request.readings.register6;
            r.ReadingRegister7__c = request.readings.register7;
            r.ReadingRegister8__c = request.readings.register8;
            r.ReadingRegister9__c = request.readings.register9;
            r.ReadingType1__c = request.readings.type1;
            r.ReadingType2__c = request.readings.type2;
            r.ReadingType3__c = request.readings.type3;
            r.ReadingType4__c = request.readings.type4;
            r.ReadingType5__c = request.readings.type5;
            r.ReadingType6__c = request.readings.type6;
            r.ReadingType7__c = request.readings.type7;
            r.ReadingType8__c = request.readings.type8;
            r.ReadingType9__c = request.readings.type9;
            r.ReadingUnit1__c = request.readings.unit1;
            r.ReadingUnit2__c = request.readings.unit2;
            r.ReadingUnit3__c = request.readings.unit3;
            r.ReadingUnit4__c = request.readings.unit4;
            r.ReadingUnit5__c = request.readings.unit5;
            r.ReadingUnit6__c = request.readings.unit6;
            r.ReadingUnit7__c = request.readings.unit7;
            r.ReadingUnit8__c = request.readings.unit8;
            r.ReadingUnit9__c = request.readings.unit9;
        }
        
        HDT_UTL_DatabaseService.upsertSObject(r);
        response.readingId = r.Id;
        if('Bozza'.equalsIgnoreCase(c.Phase__c)){
            c.Phase__c = 'Attivo'.equalsIgnoreCase(inputContract.Status)? 'Attesa check preliminari' : 'Bozza Annullata';
            if('Bozza Annullata'.equalsIgnoreCase(c.Phase__c)){
                c.Status = 'Closed';
                c.CancellationNote__c = 'Contratto cessato';
                c.CancellationReason__c = 'Pratica errata';
            }
            HDT_UTL_DatabaseService.upsertSObject(c);
        }
        
    }

    public static Map<String,DiscardAnnullmentRule__c> isAutomaticDiscard(Set<String> errorCodes) {
        if (errorCodes == null) {
            return null;
        }

        Map<String, DiscardAnnullmentRule__c> isAutomaticDiscardMap = new Map<String, DiscardAnnullmentRule__c>();

        HDT_QR_SelfReadings queryHandler = new HDT_QR_SelfReadings();
        List<DiscardAnnullmentRule__c> configs = queryHandler.getDiscardConfigurations(errorCodes);

        if (configs.isEmpty()) {
            return new Map<String,DiscardAnnullmentRule__c>();
        }

        for (DiscardAnnullmentRule__c conf : configs) {
            if(String.isNotBlank(conf.DiscardCode__c)){
                isAutomaticDiscardMap.put(conf.DiscardCode__c, conf);
            }
            if(String.isNotBlank(conf.ControllingValue__c)){
                isAutomaticDiscardMap.put(conf.ControllingValue__c.toLowerCase(), conf);
            }
        }

        return isAutomaticDiscardMap;
    }

}