/*
 * Classe che centralizza l'innesco del processo di Allineamento Anagrafica.
 */
@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing class HDT_SRV_AnagAlignment {
    
    // I possibili contesti di innesco di un Allineamento Anagrafica.
    public enum HDT_ENU_AnagAlignmentContext {
        SERVICE_CATALOG,                    // Innesco manuale da Service Catalog
        ALLINEAMENTO_CANONE_RAI,            // Innesco automatico alla chiusura del Case del processo di Allineamento Canone RAI
        GESTIONE_DISALIMENTABILITA,         // Innesco automatico alla chiusura del Case del processo di Gestione Disalimentabilità
        VARIAZIONI_FISCALE,                 // Innesco automatico alla chiusura del Case del processo di Variazioni - Fiscale
        VARIAZIONI_MARCATURA_USO_PDR,       // Innesco automatico alla chiusura del wizard del processo di Variazioni - Marcatura/Uso PDR
        VARIAZIONI_INDIRIZZO_FORNITURA,     // Innesco automatico alla chiusura del wizard del processo di Variazioni - Indirizzo Fornitura
        VARIAZIONI_TARIFFA_RES_NONRES,      // Innesco automatico alla chiusura del wizard del processo di Variazioni - Modifica Tariffa Residente/Non res.
        VARIAZIONE_ANAGRAFICA_CLIENTE,      // Innesco automatico alla chiusura del wizard del processo di Modifica Anagrafica - Variazione Anagrafica Cliente
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
            System.debug(LoggingLevel.DEBUG, 'HDT_WRP_HerokuPostSalesManager null in input.');
            return anagAlignCase;
        }

        if (herokuWrapper.responseMap == null) {
            System.debug(LoggingLevel.DEBUG, 'HDT_WRP_HerokuPostSalesManager null responseMap.');
            return anagAlignCase;
        }

        /*
            @Author: Davide Viola - 19/10/2021
            Description: PMD -> Commentata variabile non utilizzata.
        */
        //String codiceFlusso = herokuWrapper.requestMap.get('COD_FLUSSO');
        // COD_SERVIZIO e COD_PRESTAZIONE sono obbligatori insieme
        String codiceServizio = herokuWrapper.requestMap.get('COD_SERVIZIO');
        String codicePrestazione = herokuWrapper.requestMap.get('COD_PRESTAZIONE');
        // if (codicePrestazione == null || codiceServizio == null) {
        //     System.debug(LoggingLevel.DEBUG, 'codicePrestazione o codiceServizio non valorizzato');
        //     return anagAlignCase;
        // }
        if (codiceServizio == null) {
            System.debug(LoggingLevel.DEBUG, 'codiceServizio non valorizzato');
            return anagAlignCase;
        }

        if(codiceServizio != null && codicePrestazione == null && codiceServizio == 'A02'){
            codicePrestazione = codiceServizio;
        }

        System.debug(LoggingLevel.DEBUG, 'Gestione Allineamento Anagrafica da richiesta passiva Heroku');

        // COD_PRESA e COD_PRAT_DISTR sono obbligatori insieme
        String codicePresa = herokuWrapper.requestMap.get('COD_PRESA');
        String codicePraticaDistributore = herokuWrapper.requestMap.get('COD_PRAT_DISTR');
        String herokuCode = herokuWrapper.requestMap.get('requestId');
        HDT_ENU_AnagAlignmentContext context = codiceServizio.equals('VS2') ? HDT_ENU_AnagAlignmentContext.VARIAZIONE_STATO_POD : HDT_ENU_AnagAlignmentContext.VARIAZIONE_STATO_PDR;

        HDT_QR_AnagAlignment queryHandlerOrder = new HDT_QR_AnagAlignment();
        switch on codicePrestazione {
            when 'A01', 'A40', 'A03', 'S01', 'S02','A10' { // Casistica 1: link a pratica di origine + creazione Case Allineamento Anagrafica
                Order triggerOrder = null;
                /*if (!String.isBlank(codicePraticaDistributore)) {
                    triggerOrder = queryHandlerOrder.findOrderByDistributorPracticeCode(codicePraticaDistributore);
                } else {*/
                    Set<String> processTypeSet = getProcessTypeFromCodPrestazione(codicePrestazione);
                    triggerOrder = queryHandlerOrder.findOrderByTypeAndServicePointCode(processTypeSet, codicePresa);
                //}
                Case tempCase = new Case();
                Set<String> dataEnrichmentFields = new Set<String>();
                try {
                    HDT_WS_ArrichmentDataEntityResponse res = HDT_WS_ArrichmentDataEntityInvoker.callService(null, codicePresa);
                    HDT_UTL_DataEnrichmentPostSales.handleResponse(JSON.serialize(res), tempCase, dataEnrichmentFields);
                } catch (Exception ex){
                    System.debug(LoggingLevel.DEBUG, 'Arricchimento dati fallito: line [' + ex.getLineNumber() + ']; ' + ex.getMessage());
                }

                if (triggerOrder != null) {
                    anagAlignCase = createAnagAlignmentCase(triggerOrder);
                    anagAlignCase.CausalCode__c = causalCodeAnagAlignment(triggerOrder.CommodityFormula__c, context);
                    anagAlignCase.OperationCode__c = reasonAnagAlignment(anagAlignCase.CausalCode__c);
                    //anagAlignCase.SalesCompanyCode__c = companyCodeTemp(triggerOrder.CommodityFormula__c);
                    anagAlignCase.Excises__c = transcodeExcises(triggerOrder);
                    anagAlignCase.RegionalAdditional__c = queryHandlerOrder.findRegionalAdditional(triggerOrder.ExciseGAS__c, triggerOrder.SupplyPlace__c, getRegion(triggerOrder.SupplyState__c));
                    if(anagAlignCase.CausalCode__c != null && anagAlignCase.CausalCode__c.equalsIgnoreCase('VS2')){
                        anagAlignCase.DistributorPracticeCode__c = codicePraticaDistributore;
                    }
                    for (String field : dataEnrichmentFields) {
                        anagAlignCase.put(field, tempCase.get(field));
                    }
                    alignSalesCompany(anagAlignCase,triggerOrder);
                    System.debug(LoggingLevel.DEBUG, 'Invio ad heroku Case con Id: ' + anagAlignCase.Id);
                    anagAlignCase.Phase__c = 'Da Inviare';
                    HDT_UTL_DatabaseService.updateSObject(anagAlignCase);
                }
            }
            when 'N02', 'U01' { // Casistica 2: non è possibile linkare a pratica di origine, creiamo solo il Case di Allineamento Anagrafica.
                Case tempCase = new Case();
                Set<String> dataEnrichmentFields = new Set<String>();
                try {
                    HDT_WS_ArrichmentDataEntityResponse res = HDT_WS_ArrichmentDataEntityInvoker.callService(null, codicePresa);
                    HDT_UTL_DataEnrichmentPostSales.handleResponse(JSON.serialize(res), tempCase, dataEnrichmentFields);
                } catch (Exception ex){
                    System.debug(LoggingLevel.DEBUG, 'Arricchimento dati fallito: line [' + ex.getLineNumber() + ']; ' + ex.getMessage());
                }

                anagAlignCase = createAnagAlignmentCaseFromServicePoint(codicePresa,herokuCode);
                updateAnagAlignmentCaseCustomerData(anagAlignCase);
                anagAlignCase.CausalCode__c = causalCodeAnagAlignment(anagAlignCase.CommodityFormula__c, context);
                anagAlignCase.OperationCode__c = reasonAnagAlignment(anagAlignCase.CausalCode__c);
                if(anagAlignCase.CausalCode__c != null && anagAlignCase.CausalCode__c.equalsIgnoreCase('VS2')){
                    anagAlignCase.DistributorPracticeCode__c = codicePraticaDistributore;
                }
                for (String field : dataEnrichmentFields) {
                    anagAlignCase.put(field, tempCase.get(field));
                }

                System.debug(LoggingLevel.DEBUG, 'Invio ad heroku Case con Id: ' + anagAlignCase.Id);
                anagAlignCase.Phase__c = 'Da Inviare';
                HDT_UTL_DatabaseService.updateSObject(anagAlignCase);
            }
            when 'F01', 'F02' { // Casistica 3: creazione Case Allineamento Anagrafica + Case Ricostruzione Consumi
                Case tempCase = new Case();
                Set<String> dataEnrichmentFields = new Set<String>();
                try {
                    HDT_WS_ArrichmentDataEntityResponse res = HDT_WS_ArrichmentDataEntityInvoker.callService(null, codicePresa);
                    HDT_UTL_DataEnrichmentPostSales.handleResponse(JSON.serialize(res), tempCase, dataEnrichmentFields);
                } catch (Exception ex){
                    System.debug(LoggingLevel.DEBUG, 'Arricchimento dati fallito: line [' + ex.getLineNumber() + ']; ' + ex.getMessage());
                }

                anagAlignCase = createAnagAlignmentCaseFromServicePoint(codicePresa,herokuCode);
                updateAnagAlignmentCaseCustomerData(anagAlignCase);
                anagAlignCase.CausalCode__c = causalCodeAnagAlignment(anagAlignCase.CommodityFormula__c, context);
                anagAlignCase.OperationCode__c = reasonAnagAlignment(anagAlignCase.CausalCode__c);
                if(anagAlignCase.CausalCode__c != null && anagAlignCase.CausalCode__c.equalsIgnoreCase('VS2')){
                    anagAlignCase.DistributorPracticeCode__c = codicePraticaDistributore;
                }

                for (String field : dataEnrichmentFields) {
                    anagAlignCase.put(field, tempCase.get(field));
                }


                System.debug(LoggingLevel.DEBUG, 'Invio ad heroku Case con Id: ' + anagAlignCase.Id);
                anagAlignCase.Phase__c = 'Da Inviare';
                HDT_UTL_DatabaseService.updateSObject(anagAlignCase);

                Case ricostruzioneConsumiCase = createCaseRicostruzioneConsumi(codicePresa, herokuCode);
                for (String field : dataEnrichmentFields) {
                    ricostruzioneConsumiCase.put(field, tempCase.get(field));
                }
                HDT_UTL_DatabaseService.updateSObject(ricostruzioneConsumiCase);
            }
            when 'A02'{
                System.debug(LoggingLevel.DEBUG, 'ENTRATO IN A02');
                Case reqCase = new Case();
                HDT_SRV_Case caseSrv = new HDT_SRV_Case();
                String codiceFlusso = herokuWrapper.requestMap.get('COD_FLUSSO');
                Id sospensioneRiattivazione = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_SospensioneRiattivazione').getRecordTypeId();
                ServicePoint__c servicePoint = [SELECT Id, Name, Account__c FROM ServicePoint__c WHERE Name =: codicePresa WITH SECURITY_ENFORCED LIMIT 1];
                Account account = [SELECT Id, CompanyOwner__c FROM Account WHERE Id =: servicePoint.Account__c WITH SECURITY_ENFORCED LIMIT 1];
                AccountContactRelation accContRel = [SELECT Id, AccountId, ContactId FROM AccountContactRelation WHERE AccountId =: account.Id AND Roles = 'Titolare' WITH SECURITY_ENFORCED LIMIT 1];
                Contact contact = [SELECT Id, MobilePhone, Email FROM Contact WHERE Id =: accContRel.ContactId WITH SECURITY_ENFORCED LIMIT 1];
                Contract contract = [SELECT Id, SAPContractCode__c FROM Contract WHERE ServicePoint__c =: servicePoint.Id AND AccountId =: accContRel.AccountId AND Status = 'Attivo' WITH SECURITY_ENFORCED LIMIT 1];
                try{
                    reqCase = HDT_UTL_HerokuPostSalesManager.dataEnrichment(codicePresa, contract.SAPContractCode__c, reqCase);
                }
                catch(Exception ex){
                    System.debug(LoggingLevel.DEBUG, 'Arricchimento dati fallito: line [' + ex.getLineNumber() + ']; ' + ex.getMessage());
                }
                reqCase.RecordTypeId = sospensioneRiattivazione;
                reqCase.AccountId = account.Id;
                reqCase.ServicePoint__c = servicePoint.Id;
                reqCase.Contract__c = contract.Id;
                reqCase.ContactId = contact.Id;
                reqCase.PhoneNumber__c = contact.MobilePhone;
                reqCase.Email__c = contact.Email;
                reqCase.CompanyOwner__c = account.CompanyOwner__c;
                reqCase.Cluster__c = 'Notifiche';
                reqCase.Origin = 'Da PGM';
                reqCase.Phase__c = 'Bozza';
                if(codiceFlusso == '0150'){
                    reqCase.Type = 'Sospensione a seguito di potenziale pericolo';
                }
                else if(codiceFlusso == '0151'){
                    reqCase.Type = 'Riattivazione a seguito di cessato pericolo';
                }
                caseSrv.createRecord(reqCase);//Da chiedere a Francesco se va bene
                Case caseToUpdate = new Case();
                caseToUpdate.Id = reqCase.Id;
                caseToUpdate.Phase__c = 'In Lavorazione SAP';
                caseSrv.updateRecord(caseToUpdate);//Da chiedere a Francesco se va bene

                anagAlignCase = caseToUpdate;

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
                 VARIAZIONI_TARIFFA_RES_NONRES,
                 ALLINEAMENTO_CANONE_RAI,
                 GESTIONE_DISALIMENTABILITA {
                Case anagAlignCase = createAnagAlignmentCase(triggerObj);
                updateAnagAlignmentCasePostSalesDispatcher(anagAlignCase, (Case) triggerObj, context);
                returnCases.add(anagAlignCase);
            }
            when VARIAZIONE_ANAGRAFICA_CLIENTE {
                /*
                    @Author: Davide Viola - 19/10/2021
                    Description: PMD -> Commentata variabile non utilizzata.
                */
                //Case varAnagCase = (Case) triggerObj;
                List<Case> anagAlignCases = createAnagAlignmentCasesModAnagCliente(triggerObj);
                returnCases.addAll(anagAlignCases);
            }
            when VARIAZIONE_STATO_POD {
                // TODO
                /**@frpanico 15/10/2021
                 * Risoluzione "Avoid using empty block statement"
                 */
                return returnCases;
            }
            when VARIAZIONE_STATO_PDR {
                // TODO
                /**@frpanico 15/10/2021
                 * Risoluzione "Avoid using empty block statement"
                 */
                return returnCases;
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
        accountQueryFields += 'BillingState,BillingStreetNumber__c,BillingPlace__c,BillingStreetName__c,BillingPostalCode,BillingCountry,BillingCityCode__c';
        // DATI CLIENTE FINALE
        accountQueryFields += ',FirstName__c,LastName__c,FiscalCode__c,VATNumber__c';
        Account caseAccount = accountQueryHandler.getRecordById(inputCase.AccountId, accountQueryFields);

        // DATI INDIRIZZO DI RESIDENZA
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
        inputCase.OperationCode__c = reasonAnagAlignment(inputCase.CausalCode__c);

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
            System.debug(LoggingLevel.DEBUG, 'Service Point non trovato a sistema: ' + servicePointCode);
            return null;
        }

        String accountId = servicePoint.Account__c;
        AccountContactRelation acr = acrQueryHandler.getPrimaryContactRelation(accountId);
        if (acr == null) {
            System.debug(LoggingLevel.DEBUG, 'Nessun contact Titolare trovato a sistema per l\'account: ' + accountId);
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
            try {
                System.debug(LoggingLevel.DEBUG, 'Going to insert case: ' + anagAlignCase);
                HDT_UTL_DatabaseService.insertSObject(anagAlignCase);
            } catch (Exception e) {
                System.debug(LoggingLevel.DEBUG, 'Expection: ' + e.getMessage());
                throw e;
            }

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
            System.debug(LoggingLevel.DEBUG, 'Service Point non trovato a sistema: ' + servicePointCode);
            return null;
        }

        String accountId = servicePoint.Account__c;
        AccountContactRelation acr = acrQueryHandler.getPrimaryContactRelation(accountId);
        if (acr == null) {
            System.debug(LoggingLevel.DEBUG, 'Nessun contact Titolare trovato a sistema per l\'account: ' + accountId);
            return null;
        }

        String recordTypeId = rtQueryHandler.getRecordTypeByDevName('HDT_RT_FatturazioneConsumi')[0].Id;
        inputMap.put('recordTypeId', recordTypeId);
        inputMap.put('cluster', 'Fatturazione');
        inputMap.put('type', 'Ricostruzione Consumi');
        inputMap.put('accountId', accountId);
        inputMap.put('contactId', acr.ContactId);
        inputMap.put('servicePointId', servicePoint.Id);
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
                /**@frpanico 15/10/2021
                 * Risoluzione "Avoid using empty block statement"
                 */
                return null;
            }
        }

        if (!newCaseList.isEmpty()) {
            HDT_UTL_DatabaseService.insertSObject(newCaseList);
            return newCaseList[0];
        }

        return null;
    }

    /**
     * Aggiorna il Case di allineamento anagrafica con i dati di anagrafica del cliente ed eventuali logiche specifiche 
     * del processo che ha originato l'allineamento, e infine invia il Case ad Heroku.
     */
    /**@frpanico 15/10/2021
     * Annotato con @SuppressWatnings
     * Gli switch block sono stati inseriti in maniera preventiva per futuri update.
     */
    @SuppressWarnings('PMD.EmptyStatementBlock')
    private static Boolean updateAnagAlignmentCasePostSalesDispatcher(Case anagAlignCase, Case triggerCase, HDT_ENU_AnagAlignmentContext context) {

        updateAnagAlignmentCaseCustomerData(anagAlignCase);

        switch on context {
            when ALLINEAMENTO_CANONE_RAI {
                // TODO: aggiungere qui eventuali logiche specifiche per Allineamento Canone RAI
            }
            when GESTIONE_DISALIMENTABILITA {
                // TODO: aggiungere qui eventuali logiche specifiche per Gestione Disalimentabilità
            }
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

        // Necessario per valorizzare i campi formula PODPDRFormula__c e ContractCode__c
        List<Case> anagAlignCases = new List<Case>();
        anagAlignCases.add(anagAlignCase);
        Formula.recalculateFormulas(anagAlignCases);

        List<ServiceRequest__c> serviceRequestList = HDT_UTL_Case.createServiceRequestFromCases(anagAlignCases);
        HDT_UTL_DatabaseService.insertSObject(serviceRequestList);

        anagAlignCase.CausalCode__c = causalCodeAnagAlignment(anagAlignCase.CommodityFormula__c, context);
        anagAlignCase.OperationCode__c = reasonAnagAlignment(anagAlignCase.CausalCode__c);
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
            System.debug(LoggingLevel.DEBUG, 'createAnagAlignmentCasesModAnagCliente: null object in input');
            return null;
        }

        Case triggerCase = (Case) triggerObj;
        HDT_QR_Contract contractQueryHandler = new HDT_QR_Contract();
        List<Contract> activeContracts = contractQueryHandler.getActiveRecordsByAccountId(triggerCase.AccountId);
        System.debug(LoggingLevel.DEBUG, 'createAnagAlignmentCasesModAnagCliente: # contratti attivi: ' + activeContracts.size());

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

        // Necessario per valorizzare i campi formula PODPDRFormula__c e ContractCode__c usati dall'arricchimento dati.
        Formula.recalculateFormulas(anagAlignCases);

        HDT_QR_Account accountQueryHandler = new HDT_QR_Account();
        HDT_QR_Contact contactQueryHandler = new HDT_QR_Contact();
        String accountQueryFields = '';
        // DATI INDIRIZZO DI RESIDENZA
        accountQueryFields += 'BillingState,BillingStreetNumber__c,BillingCity,BillingPlace__c,BillingStreetName__c,BillingPostalCode,BillingCountry,BillingCityCode__c';
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
            anagAlignCase.BillingProvince__c = caseAccount.BillingState;
            anagAlignCase.BillingStreetNumber__c = caseAccount.BillingStreetNumber__c;
            anagAlignCase.BillingCity__c = caseAccount.BillingCity;
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
            if(caseContact!=null){
                anagAlignCase.Mobile__c = caseContact.MobilePhone != null ? caseContact.MobilePhone : caseContact.Phone;
            }
            anagAlignCase.CausalCode__c = causalCodeAnagAlignment(anagAlignCase.CommodityFormula__c, HDT_ENU_AnagAlignmentContext.VARIAZIONE_ANAGRAFICA_CLIENTE);
            anagAlignCase.OperationCode__c = reasonAnagAlignment(anagAlignCase.CausalCode__c);

        }

        // Queueable per invocare l'arricchimento dati su ogni Case e per inviarli ad heroku.
        System.enqueueJob(new HDT_QBL_AnagAlignment(anagAlignCases));

        return anagAlignCases;
    }
    /**
     * A01 --> Subentro su GdM chiuso - Prima Attivazione
     * A02 --> Non è gestita
     * A03 --> Prima attivazione con modifica	
     * A40 --> Subentro su GdM chiuso - Prima Attivazione
     * S01 --> Subentro su GdM chiuso
     * S02 --> Subentro su GdM chiuso
     */
    private static Set<String> getProcessTypeFromCodPrestazione(String codicePrestazione) {
        Set<String> processTypeString = new Set<String>();

        switch on codicePrestazione {
            when 'A01','A40','A10' {
                processTypeString.add('Subentro su GdM chiuso');
                processTypeString.add('Prima Attivazione');
            }
            when 'A03'{
                processTypeString.add('Prima attivazione con modifica');
            }
            when 'S01','S02'{
                processTypeString.add('Subentro su GdM chiuso');
            }
        }

        return processTypeString;
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

    /**
     * Calcola il campo MOTIVAZIONE richiesto dal SII. I valori previsti sono i seguenti:
     * 
     * 01: Integrazione dati cliente finale;
     * 02: Correzione errore;
     * 03: Integrazione dati;
     * 04: Correzione a seguito di segnalazione da parte del Gestore
     * 05: Altro
     */
    private static String reasonAnagAlignment(String causalCode) {
        if (causalCode == null) {
            return '';
        }

        return causalCode.equals('AGG') ? '01' : '03';
    }

    /**
     * Transcodifica le accise raccolte sugli Order nel valore numerico richiesto dal SII.
     * La transcodifica di default è 0, quindi gestiamo solo le eccezioni che hanno accisa > 0.
     */
    private static Double transcodeExcises(Order triggerOrder) {
        String acc = triggerOrder.ExciseGAS__c != null ? triggerOrder.ExciseGAS__c : triggerOrder.ExciseEle__c;
        if (acc == null) {
            return 0;
        }

        Double transcodedValue = 0;
        if (acc.contains('G_ICD') || acc.contains('G_ICC')) {
            transcodedValue = 0.044;
        } else if (acc.contains('E_IE_L01') || acc.contains('E_IE_M04') || acc.contains('E_IE_L13') || acc.contains('E_IE_13A')) {
            transcodedValue = 0.0125;
        }

        return transcodedValue;
    }

    private static void alignSalesCompany(Case newCase, Order ord){
        if (String.isNotBlank(newCase.SalesCompanyCode__c) || String.isNotBlank(newCase.SalesCompany__c)){
            return;
        }
        /* if (String.isNotBlank(ord.SalesCompanyCode__c)){
            newCase.SalesCompanyCode__c = ord.SalesCompanyCode__c;
            newCase.SalesCompany__c = ord.SalesCompany__c;
            return;
        } */
        newCase.SalesCompanyCode__c = 'Gas'.equals(ord.CommodityFormula__c) ? '10V0000160' : '13V0000000';
        HDT_SRV_DataEnrichmentPostSales depsSrv = new HDT_SRV_DataEnrichmentPostSales();
        newCase.SalesCompany__c = depsSrv.calculateSalesCompany(newCase.SalesCompanyCode__c);
    }

    // Codice venditore cablato essendo cablato anche nel template pclick delle attivazioni.
    /* private static String companyCodeTemp(String commodity) {
        return commodity.equals('Gas') ? '10V0000160' : '13V0000000';
    } */

    // Fornisce la regione a partire dalla provincia. Per Wave 1 sono gestite solo MARCHE e ABRUZZO.
    // TODO WAVE 3: creare un metadato ad-hoc per configurare tutte le province e tutte le regioni.
    public static String getRegion(String province) {
        if (String.isBlank(province)) {
            return '';
        }

        switch on province.toUpperCase() {
            when 'AQ', 'CH', 'PE', 'TE' {
                return 'ABRUZZO';
            }
            when 'AN', 'AP', 'FM', 'MC', 'PU' {
                return 'MARCHE';
            }
            when else {
                System.debug(LoggingLevel.DEBUG, 'Provincia non in ambito wave 1: ' + province);
            }
        }

        return '';
    }

}