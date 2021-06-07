/*
 * Classe che centralizza l'innesco del processo di Allineamento Anagrafica.
 */
public inherited sharing class HDT_SRV_AnagAlignment {
    
    // I possibili contesti di innesco di un Allineamento Anagrafica.
    public enum HDT_ENU_AnagAlignmentContext {
        SERVICE_CATALOG,                    // Innesco manuale da Service Catalog
        VARIAZIONI_FISCALE,                 // Innesco automatico alla chiusura del Case del processo di Variazioni - Fiscale
        VARIAZIONI_MARCATURA_USO_PDR,       // Innesco automatico alla chiusura del wizard del processo di Variazioni - Marcatura/Uso PDR
        VARIAZIONI_INDIRIZZO_FORNITURA,     // Innesco automatico alla chiusura del wizard del processo di Variazioni - Indirizzo Fornitura
        VARIAZIONI_TARIFFA_RES_NONRES,      // Innesco automatico alla chiusura del wizard del processo di Variazioni - Modifica Tariffa Residente/Non res.
        VARIAZIONE_ANAGRAFICA_CLIENTE,      // Innesco automatico alla chiusura del wizard del processo di Modifica Anagrafica - Variazione Anagrafica Cliente
        // TODO: verificare se necessari o se basta la request di heroku.
        VARIAZIONE_STATO_POD,               // Innesco automatico all'arrivo del flusso VS2.0200 dal SII
        VARIAZIONE_STATO_PDR                // Innesco automatico all'arrivo del flusso VSG2.0200 dal SII
    }

    public class HDT_UTL_AnagAlignmentFlowInputs {

        @InvocableVariable
        public SObject inputCase;

        @InvocableVariable
        public String context;  // utilizzare stringhe equivalenti ai valori della enum HDT_ENU_AnagAlignmentContext
    }

    // Wrapper per l'innesco da flow. 
    @InvocableMethod(label = 'Gestione Allineamento Anagrafica')
    public static List<String> handleAnagAlignment(List<HDT_UTL_AnagAlignmentFlowInputs> inputs) {

        List<String> resultList = new List<String>();
        String result;

        SObject inputCase = inputs[0].inputCase;
        String context = inputs[0].context;

        switch on context {
            when 'SERVICE_CATALOG' {
                result = handleAnagAlignment(inputCase, HDT_ENU_AnagAlignmentContext.SERVICE_CATALOG)[0].Id;
            }
            when 'VARIAZIONI_MARCATURA_USO_PDR' {
                result = handleAnagAlignment(inputCase, HDT_ENU_AnagAlignmentContext.VARIAZIONI_MARCATURA_USO_PDR)[0].Id;
            }
            when 'VARIAZIONI_INDIRIZZO_FORNITURA' {
                result = handleAnagAlignment(inputCase, HDT_ENU_AnagAlignmentContext.VARIAZIONI_INDIRIZZO_FORNITURA)[0].Id;
            }
            when 'VARIAZIONI_TARIFFA_RES_NONRES' {
                result = handleAnagAlignment(inputCase, HDT_ENU_AnagAlignmentContext.VARIAZIONI_TARIFFA_RES_NONRES)[0].Id;
            }
        }

        resultList.add(result);
        return resultList;
    }

    /**
     * Gestisce la creazione di Case di Allineamento Anagrafici all'arrivo delle notifiche passive da Heroku.
     */
    public static Case handleAnagAlignmentHeroku(HDT_WRP_HerokuPostSalesManager herokuWrapper) {

        Case anagAlignCase = new Case();

        if (herokuWrapper == null) {
            System.debug('HDT_WRP_HerokuPostSalesManager null in input.');
            return anagAlignCase;
        }

        if (herokuWrapper.responseMap == null) {
            System.debug('HDT_WRP_HerokuPostSalesManager null responseMap.');
            return anagAlignCase;
        }

        String codiceFlusso = herokuWrapper.requestMap.get('COD_FLUSSO');
        // COD_SERVIZIO e COD_PRESTAZIONE sono obbligatori insieme
        String codiceServizio = herokuWrapper.requestMap.get('COD_SERVIZIO');
        String codicePrestazione = herokuWrapper.requestMap.get('COD_PRESTAZIONE');
        if (codicePrestazione == null || codiceServizio == null) {
            System.debug('codicePrestazione o codiceServizio non valorizzato');
            return anagAlignCase;
        }

        System.debug('Gestione Allineamento Anagrafica da richiesta passiva Heroku');

        // COD_PRESA e COD_PRAT_DISTR sono obbligatori insieme
        String codicePresa = herokuWrapper.requestMap.get('COD_PRESA');
        String codicePraticaDistributore = herokuWrapper.requestMap.get('COD_PRAT_DISTR');
        String herokuCode = herokuWrapper.requestMap.get('requestId');
        HDT_ENU_AnagAlignmentContext context = codiceServizio.equals('VS2') ? HDT_ENU_AnagAlignmentContext.VARIAZIONE_STATO_POD : HDT_ENU_AnagAlignmentContext.VARIAZIONE_STATO_PDR;

        HDT_QR_AnagAlignment queryHandlerOrder = new HDT_QR_AnagAlignment();
        switch on codicePrestazione {
            when 'A01', 'A03', 'S01', 'S02' { // Casistica 1: link a pratica di origine + creazione Case Allineamento Anagrafica
                Order triggerOrder = null;
                if (!String.isBlank(codicePraticaDistributore)) {
                    triggerOrder = queryHandlerOrder.findOrderByDistributorPracticeCode(codicePraticaDistributore);
                } else {
                    String processType = getProcessTypeFromCodPrestazione(codicePrestazione);
                    triggerOrder = queryHandlerOrder.findOrderByTypeAndServicePointCode(processType, codicePresa);
                }

                if (triggerOrder != null) {
                    anagAlignCase = createAnagAlignmentCase(triggerOrder);
                }
            }
            when 'N02', 'U01' { // Casistica 2: non è possibile linkare a pratica di origine, creiamo solo il Case di Allineamento Anagrafica.
                Case tempCase = new Case();
                Set<String> dataEnrichmentFields = new Set<String>();
                try {
                    String arricchimentoResponse = HDT_WS_ArricchimentoDatiTemp.submitRequest(codicePresa, null);
                    HDT_UTL_DataEnrichmentPostSales.handleResponse(arricchimentoResponse, tempCase, dataEnrichmentFields);
                } catch (Exception ex){
                    System.debug('Arricchimento dati fallito: line [' + ex.getLineNumber() + ']; ' + ex.getMessage());
                }

                anagAlignCase = createAnagAlignmentCaseFromServicePoint(codicePresa,herokuCode);
                updateAnagAlignmentCaseCustomerData(anagAlignCase);
                anagAlignCase.CausalCode__c = causalCodeAnagAlignment(anagAlignCase.CommodityFormula__c, context);

                for (String field : dataEnrichmentFields) {
                    anagAlignCase.put(field, tempCase.get(field));
                }

                System.debug('Invio ad heroku Case con Id: ' + anagAlignCase.Id);
                anagAlignCase.Phase__c = 'Da Inviare';
                HDT_UTL_DatabaseService.updateSObject(anagAlignCase);
            }
            when 'F01', 'F02' { // Casistica 3: creazione Case Allineamento Anagrafica + Case Ricostruzione Consumi
                Case tempCase = new Case();
                Set<String> dataEnrichmentFields = new Set<String>();
                try {
                    String arricchimentoResponse = HDT_WS_ArricchimentoDatiTemp.submitRequest(codicePresa, null);
                    HDT_UTL_DataEnrichmentPostSales.handleResponse(arricchimentoResponse, tempCase, dataEnrichmentFields);
                } catch (Exception ex){
                    System.debug('Arricchimento dati fallito: line [' + ex.getLineNumber() + ']; ' + ex.getMessage());
                }

                anagAlignCase = createAnagAlignmentCaseFromServicePoint(codicePresa,herokuCode);
                updateAnagAlignmentCaseCustomerData(anagAlignCase);
                anagAlignCase.CausalCode__c = causalCodeAnagAlignment(anagAlignCase.CommodityFormula__c, context);

                for (String field : dataEnrichmentFields) {
                    anagAlignCase.put(field, tempCase.get(field));
                }

                System.debug('Invio ad heroku Case con Id: ' + anagAlignCase.Id);
                anagAlignCase.Phase__c = 'Da Inviare';
                HDT_UTL_DatabaseService.updateSObject(anagAlignCase);

                Case ricostruzioneConsumiCase = createCaseRicostruzioneConsumi(codicePresa, herokuCode);
                for (String field : dataEnrichmentFields) {
                    ricostruzioneConsumiCase.put(field, tempCase.get(field));
                }
                HDT_UTL_DatabaseService.updateSObject(ricostruzioneConsumiCase);
            }
        }

        return anagAlignCase;
    }


    /**
     * Dispatcher per la gestione delle varie casistiche di Allineamento Anagrafica.
     * Restituisce la lista di Case di Allineamento Anagrafica che sono stati creati o modificati.
     */
    public static List<Case> handleAnagAlignment(SObject triggerObj, HDT_ENU_AnagAlignmentContext context) {

        List<Case> returnCases = new List<Case>();

        switch on context {
            when SERVICE_CATALOG {
                updateAnagAlignmentCaseServiceCatalog((Case) triggerObj);
                returnCases.add((Case) triggerObj);
            }
            when VARIAZIONI_FISCALE,
                 VARIAZIONI_MARCATURA_USO_PDR,
                 VARIAZIONI_INDIRIZZO_FORNITURA,
                 VARIAZIONI_TARIFFA_RES_NONRES {
                Case anagAlignCase = createAnagAlignmentCase(triggerObj);
                updateAnagAlignmentCaseVariazioni(anagAlignCase, (Case) triggerObj, context);
                returnCases.add(anagAlignCase);
            }
            when VARIAZIONE_ANAGRAFICA_CLIENTE {
                Case varAnagCase = (Case) triggerObj;
                List<Case> anagAlignCases = createAnagAlignmentCasesModAnagCliente(triggerObj);
                returnCases.addAll(anagAlignCases);
            }
            when VARIAZIONE_STATO_POD {
                // TODO
            }
            when VARIAZIONE_STATO_PDR {
                // TODO
            }
        }

        return returnCases;
    }

    // Aggiorna il Case di Allineamento Anagrafica con i dati fiscali e di contatto presenti sull'Account.
    private static void updateAnagAlignmentCaseCustomerData(Case inputCase) {
        HDT_QR_Account accountQueryHandler = new HDT_QR_Account();
        HDT_QR_Contact contactQueryHandler = new HDT_QR_Contact();

        String accountQueryFields = '';
        // DATI INDIRIZZO DI RESIDENZA
        accountQueryFields += 'BillingStreetToponym__c,BillingState,BillingStreetNumber__c,BillingPlace__c,BillingStreetName__c,BillingPostalCode,BillingCountry,BillingCityCode__c';
        // DATI CLIENTE FINALE
        accountQueryFields += ',FirstName__c,LastName__c,FiscalCode__c,VATNumber__c';
        Account caseAccount = accountQueryHandler.getRecordById(inputCase.AccountId, accountQueryFields);

        // DATI INDIRIZZO DI RESIDENZA
        inputCase.BillingStreetToponym__c = caseAccount.BillingStreetToponym__c;
        inputCase.BillingProvince__c = caseAccount.BillingState;
        inputCase.BillingStreetNumber__c = caseAccount.BillingStreetNumber__c;
        inputCase.BillingPlace__c = caseAccount.BillingPlace__c;
        inputCase.BillingStreetName__c = caseAccount.BillingStreetName__c;
        inputCase.BillingPostalCode__c = caseAccount.BillingPostalCode;
        inputCase.BillingCountry__c = caseAccount.BillingCountry;
        inputCase.BillingCityCode__c = caseAccount.BillingCityCode__c;

        // DATI CLIENTE FINALE
        inputCase.FirstName__c = caseAccount.FirstName__c;
        inputCase.LastName__c = caseAccount.LastName__c;
        inputCase.VATNumber__c = caseAccount.VATNumber__c;
        inputCase.FiscalCode__c = caseAccount.FiscalCode__c;
        Contact caseContact = contactQueryHandler.getRecordById(inputCase.ContactId);
        inputCase.Mobile__c = caseContact.MobilePhone != null ? caseContact.MobilePhone : caseContact.Phone;
    }


    // Aggiorna il Case creato da Service Catalog con i dati necessari per l'allineamento anagrafica.
    // Si assume che che l'arricchimento dati è già stato effettuato sul Case.
    // Il passaggio alla fase 'Da Inviare' viene fatto dal flow.
    private static Boolean updateAnagAlignmentCaseServiceCatalog(Case inputCase) {

        updateAnagAlignmentCaseCustomerData(inputCase);

        inputCase.CausalCode__c = causalCodeAnagAlignment(inputCase.CommodityFormula__c, HDT_ENU_AnagAlignmentContext.SERVICE_CATALOG);

        return HDT_UTL_DatabaseService.updateSObject(inputCase);
    }

    /**
     * Crea il Case di allineamento anagrafica a partire da un POD/PDR senza processo collegato.
     */
    private static Case createAnagAlignmentCaseFromServicePoint(String servicePointCode,String herokuCode) {
        if (servicePointCode == null) {
            return null;
        }

        Map<String, Object> inputMap = new Map<String, Object>();
        HDT_QR_CreateGenericCase rtQueryHandler = new HDT_QR_CreateGenericCase();
        HDT_QR_Case caseQuery = new HDT_QR_Case();
        HDT_QR_AnagAlignment queryHandler = new HDT_QR_AnagAlignment();
        HDT_QR_AccountContactRelation acrQueryHandler = new HDT_QR_AccountContactRelation();
        ServicePoint__c servicePoint = queryHandler.findServicePointByCode(servicePointCode);
        if (servicePoint == null) {
            System.debug('Service Point non trovato a sistema: ' + servicePointCode);
            return null;
        }

        String accountId = servicePoint.Account__c;
        AccountContactRelation acr = acrQueryHandler.getPrimaryContactRelation(accountId);
        if (acr == null) {
            System.debug('Nessun contact Titolare trovato a sistema per l\'account: ' + accountId);
            return null;
        }

        String recordTypeId = rtQueryHandler.getRecordTypeByDevName('HDT_RT_AllineamentoAnagrafica')[0].Id;
        inputMap.put('recordTypeId', recordTypeId);
        inputMap.put('cluster', 'Modifiche Anagrafiche');
        inputMap.put('type', 'Allineamento Anagrafica');
        inputMap.put('accountId', accountId);
        inputMap.put('contactId', acr.ContactId);
        inputMap.put('servicePointId', servicePoint.Id);
        inputMap.put('HerokuPracticeCode__c', herokuCode);

        HDT_UTL_CreateGenericCase createCaseUtility = new HDT_UTL_CreateGenericCase();
        Case anagAlignCase = createCaseUtility.createCase(inputMap);

        if (anagAlignCase != null) {
            HDT_UTL_DatabaseService.insertSObject(anagAlignCase);
            return caseQuery.getRecordById(anagAlignCase.Id);
        }

        return null;

    }

    /**
     * Crea il Case di Ricostruzione Consumi in caso di F01/F02
     */
    private static Case createCaseRicostruzioneConsumi(String servicePointCode, String herokuCode) {
        if (servicePointCode == null) {
            return null;
        }

        Map<String, Object> inputMap = new Map<String, Object>();
        HDT_QR_CreateGenericCase rtQueryHandler = new HDT_QR_CreateGenericCase();
        HDT_QR_Case caseQuery = new HDT_QR_Case();
        HDT_QR_AnagAlignment queryHandler = new HDT_QR_AnagAlignment();
        HDT_QR_AccountContactRelation acrQueryHandler = new HDT_QR_AccountContactRelation();
        ServicePoint__c servicePoint = queryHandler.findServicePointByCode(servicePointCode);
        if (servicePoint == null) {
            System.debug('Service Point non trovato a sistema: ' + servicePointCode);
            return null;
        }

        String accountId = servicePoint.Account__c;
        AccountContactRelation acr = acrQueryHandler.getPrimaryContactRelation(accountId);
        if (acr == null) {
            System.debug('Nessun contact Titolare trovato a sistema per l\'account: ' + accountId);
            return null;
        }

        String recordTypeId = rtQueryHandler.getRecordTypeByDevName('HDT_RT_FatturazioneConsumi')[0].Id;
        inputMap.put('recordTypeId', recordTypeId);
        inputMap.put('cluster', 'Fatturazione');
        inputMap.put('type', 'Ricostruzione Consumi');
        inputMap.put('accountId', accountId);
        inputMap.put('contactId', acr.ContactId);
        inputMap.put('servicePointId', servicePoint);
        inputMap.put('HerokuPracticeCode__c', herokuCode);

        HDT_UTL_CreateGenericCase createCaseUtility = new HDT_UTL_CreateGenericCase();
        Case c = createCaseUtility.createCase(inputMap);

        if (c != null) {
            c.Reason__c = 'Blocco per frode';
            HDT_UTL_DatabaseService.insertSObject(c);
            return caseQuery.getRecordById(c.Id);
        }

        return c;
    }

    /**
     * Crea il Case di allineamento anagrafica a partire da un altro processo.
     * triggerObj = Case o Order da cui è scaturito l'allineamento anagrafico.
     * return = il Case creato oppure null.
     */
    private static Case createAnagAlignmentCase(SObject triggerObj) {

        List<Case> newCaseList = new List<Case>();

        switch on triggerObj {
            when Case triggerCase {
                Map<String, Object> inputMap = new Map<String, Object>();
                HDT_QR_CreateGenericCase rtQueryHandler = new HDT_QR_CreateGenericCase();
                String recordTypeId = rtQueryHandler.getRecordTypeByDevName('HDT_RT_AllineamentoAnagrafica')[0].Id;
                inputMap.put('recordTypeId', recordTypeId);
                inputMap.put('cluster', 'Modifiche Anagrafiche');
                inputMap.put('type', 'Allineamento Anagrafica');
                inputMap.put('inputSObj', triggerObj);
                HDT_UTL_CreateGenericCase createCaseUtility = new HDT_UTL_CreateGenericCase();
                newCaseList = createCaseUtility.createCaseFromCase(inputMap);
            }
            when Order triggerOrder {
                Map<String, Object> inputMap = new Map<String, Object>();
                HDT_QR_CreateGenericCase rtQueryHandler = new HDT_QR_CreateGenericCase();
                String recordTypeId = rtQueryHandler.getRecordTypeByDevName('HDT_RT_AllineamentoAnagrafica')[0].Id;
                inputMap.put('recordTypeId', recordTypeId);
                inputMap.put('cluster', 'Modifiche Anagrafiche');
                inputMap.put('type', 'Allineamento Anagrafica');
                inputMap.put('inputSObj', triggerObj);

                HDT_UTL_CreateGenericCase createCaseUtility = new HDT_UTL_CreateGenericCase();
                newCaseList.add(createCaseUtility.createCaseFromOrder(inputMap));
            }
            when else {
            }
        }

        if (!newCaseList.isEmpty()) {
            HDT_UTL_DatabaseService.insertSObject(newCaseList);
            return newCaseList[0];
        }

        return null;
    }

    /**
     * Aggiorna il Case di Variazioni con i dati di anagrafica del cliente e poi lo invia ad Heroku.
     */
    private static Boolean updateAnagAlignmentCaseVariazioni(Case anagAlignCase, Case triggerCase, HDT_ENU_AnagAlignmentContext context) {

        updateAnagAlignmentCaseCustomerData(anagAlignCase);

        switch on context {
            when VARIAZIONI_FISCALE {
                // TODO: aggiungere qui eventuali logiche specifiche per Variazioni/Fiscali
            }
            when VARIAZIONI_MARCATURA_USO_PDR {
                // TODO: aggiungere qui eventuali logiche specifiche per Variazioni/MarcaturaUsoPDR
            }
            when VARIAZIONI_INDIRIZZO_FORNITURA {
                // TODO: aggiungere qui eventuali logiche specifiche per Variazioni/Mod.Indirizzo di fornitura
            }
            when VARIAZIONI_TARIFFA_RES_NONRES {
                // TODO: aggiungere qui eventuali logiche specifiche per Variazioni/TariffaRes/NonRes
            }
        }

        anagAlignCase.CausalCode__c = causalCodeAnagAlignment(anagAlignCase.CommodityFormula__c, context);
        anagAlignCase.Phase__c = 'Da Inviare';

        return HDT_UTL_DatabaseService.updateSObject(anagAlignCase);
    }

    /**
     * Il processo di Variazione Anagrafica Cliente modifica direttamente le entità master (Account/Contact/BillingProfile) senza un ServicePoint di riferimento.
     * Per questo motivo vanno creati N Case di Allineamento Anagrafica, uno per ogni contratto attivo sul cliente.
     * Per ognuni di essi richiamiamo l'arricchimento dati e valorizziamo i dati come nello scenario di innesco da Service Catalog.
     */
    private static List<Case> createAnagAlignmentCasesModAnagCliente(SObject triggerObj) {
        if (triggerObj == null) {
            System.debug('createAnagAlignmentCasesModAnagCliente: null object in input');
            return null;
        }

        Case triggerCase = (Case) triggerObj;
        HDT_QR_Contract contractQueryHandler = new HDT_QR_Contract();
        List<Contract> activeContracts = contractQueryHandler.getActiveRecordsByAccountId(triggerCase.AccountId);
        System.debug('createAnagAlignmentCasesModAnagCliente: # contratti attivi: ' + activeContracts.size());

        Map<String, Object> inputMap = new Map<String, Object>();
        HDT_QR_CreateGenericCase rtQueryHandler = new HDT_QR_CreateGenericCase();
        String recordTypeId = rtQueryHandler.getRecordTypeByDevName('HDT_RT_AllineamentoAnagrafica')[0].Id;
        inputMap.put('recordTypeId', recordTypeId);
        inputMap.put('cluster', 'Modifiche Anagrafiche');
        inputMap.put('type', 'Allineamento Anagrafica');
        inputMap.put('inputSObj', triggerObj);

        HDT_UTL_CreateGenericCase createCaseUtility = new HDT_UTL_CreateGenericCase();

        List<Case> anagAlignCases = new List<Case>();
        for (Contract contract : activeContracts) {
            Case anagAlignCase = createCaseUtility.createCaseFromCase(inputMap)[0];
            anagAlignCase.Contract__c = contract.Id;
            anagAlignCase.ServicePoint__c = contract.ServicePoint__c;
            anagAlignCases.add(anagAlignCase);
        }

        Boolean outcome = HDT_UTL_DatabaseService.insertSObject(anagAlignCases);
        if (outcome) {
            System.debug('createAnagAlignmentCasesModAnagCliente: # Case creati: ' + anagAlignCases.size());
        }

        // Necessario per valorizzare i campi formula PODPDRFormula__c e ContractCode__c usati dall'arricchimento dati.
        Formula.recalculateFormulas(anagAlignCases);

        HDT_QR_Account accountQueryHandler = new HDT_QR_Account();
        HDT_QR_Contact contactQueryHandler = new HDT_QR_Contact();
        String accountQueryFields = '';
        // DATI INDIRIZZO DI RESIDENZA
        accountQueryFields += 'BillingStreetToponym__c,BillingState,BillingStreetNumber__c,BillingPlace__c,BillingStreetName__c,BillingPostalCode,BillingCountry,BillingCityCode__c';
        // DATI CLIENTE FINALE
        accountQueryFields += ',FirstName__c,LastName__c,FiscalCode__c,VATNumber__c';
        Account caseAccount = accountQueryHandler.getRecordById(triggerCase.AccountId, accountQueryFields);
        Map<Id, Contact> contactsMap = new Map<Id, Contact>();
        Set<Id> contactIds = new Set<Id>();
        for (Case anagAlignCase : anagAlignCases) {
            contactIds.add(anagAlignCase.ContactId);
        }
        List<Contact> contacts = contactQueryHandler.getRecordsByIds(contactIds);
        for (Contact c : contacts) {
            contactsMap.put(c.Id, c);
        }

        for (Case anagAlignCase : anagAlignCases) {

            // DATI INDIRIZZO DI RESIDENZA
            anagAlignCase.BillingStreetToponym__c = caseAccount.BillingStreetToponym__c;
            anagAlignCase.BillingProvince__c = caseAccount.BillingState;
            anagAlignCase.BillingStreetNumber__c = caseAccount.BillingStreetNumber__c;
            anagAlignCase.BillingPlace__c = caseAccount.BillingPlace__c;
            anagAlignCase.BillingStreetName__c = caseAccount.BillingStreetName__c;
            anagAlignCase.BillingPostalCode__c = caseAccount.BillingPostalCode;
            anagAlignCase.BillingCountry__c = caseAccount.BillingCountry;
            anagAlignCase.BillingCityCode__c = caseAccount.BillingCityCode__c;

            // DATI CLIENTE FINALE
            anagAlignCase.FirstName__c = caseAccount.FirstName__c;
            anagAlignCase.LastName__c = caseAccount.LastName__c;
            anagAlignCase.VATNumber__c = caseAccount.VATNumber__c;
            anagAlignCase.FiscalCode__c = caseAccount.FiscalCode__c;
            Contact caseContact = contactsMap.get(anagAlignCase.ContactId);
            anagAlignCase.Mobile__c = caseContact.MobilePhone != null ? caseContact.MobilePhone : caseContact.Phone;

            anagAlignCase.CausalCode__c = causalCodeAnagAlignment(anagAlignCase.CommodityFormula__c, HDT_ENU_AnagAlignmentContext.VARIAZIONE_ANAGRAFICA_CLIENTE);
        }

        HDT_UTL_DatabaseService.updateSObject(anagAlignCases);

        // Queueable per invocare l'arricchimento dati su ogni Case e per inviarli ad heroku.
        System.enqueueJob(new HDT_QBL_AnagAlignment(anagAlignCases));

        return anagAlignCases;
    }

    private static String getProcessTypeFromCodPrestazione(String codicePrestazione) {
        String processType = '';

        switch on codicePrestazione {
            when 'A01' {
                processType = 'Prima Attivazione Ele'; // TODO adeguare
            }
            when else {
                // TODO
            }
        }

        return processType;
    }

    /**
     * Calcola il codice causale richiesto da Heroku per i flussi di allineamento anagrafica.
     * I possibili valori sono i seguenti:
     * - ATT --> ricezione flusso VSG2.0200 dal SII su prima attivazione o subentro (GAS)
     * - VS2 --> ricezione flusso VS2.0200 dal SII su prima attivazione o subentro (ELE)
     * - AE1 --> aggiornamento dati innescato dal CRM (ELE)
     * - AGG --> aggiornamento dati innescato dal CRM (GAS) --> flusso SII ACG1
     */
    private static String causalCodeAnagAlignment(String commodity, HDT_ENU_AnagAlignmentContext context) {

        String causalCode = '';
        Boolean isGas = commodity == 'Gas';

        switch on context {
            when VARIAZIONE_STATO_POD {
                causalCode = 'VS2';
            }
            when VARIAZIONE_STATO_PDR {
                causalCode = 'ATT';
            }
            when else {
                causalCode = isGas ? 'AGG' : 'AE1';
            }
        }

        return causalCode;
    }
}