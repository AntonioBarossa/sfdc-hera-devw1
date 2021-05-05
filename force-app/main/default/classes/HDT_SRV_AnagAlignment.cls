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
        MODIFICA_ANAGRAFICA_CLIENTE,        // Innesco automatico alla chiusura del wizard del processo di Modifica Anagrafica - Variazione Anagrafica Cliente
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
                result = handleAnagAlignment(inputCase, HDT_ENU_AnagAlignmentContext.SERVICE_CATALOG);
            }
            when 'VARIAZIONI_MARCATURA_USO_PDR' {
                result = handleAnagAlignment(inputCase, HDT_ENU_AnagAlignmentContext.VARIAZIONI_MARCATURA_USO_PDR);
            }
            when 'VARIAZIONI_INDIRIZZO_FORNITURA' {
                result = handleAnagAlignment(inputCase, HDT_ENU_AnagAlignmentContext.VARIAZIONI_INDIRIZZO_FORNITURA);
            }
            when 'VARIAZIONI_TARIFFA_RES_NONRES' {
                result = handleAnagAlignment(inputCase, HDT_ENU_AnagAlignmentContext.VARIAZIONI_TARIFFA_RES_NONRES);
            }
            when else {
                // TODO
            }
        }

        resultList.add(result);
        return resultList;
    }

    public static Id handleAnagAlignment(SObject triggerObj, HDT_ENU_AnagAlignmentContext context) {

        switch on context {
            when SERVICE_CATALOG {
                updateAnagAlignmentCaseServiceConsole((Case) triggerObj);
                return triggerObj.Id;
            }
            when VARIAZIONI_FISCALE {
                // TODO
            }
            when VARIAZIONI_MARCATURA_USO_PDR {
                // TODO
                Case anagAlignCase = createAnagAlignmentCase(triggerObj);
                updateAnagAlignmentCaseVariazioni(anagAlignCase, (Case) triggerObj, context);
            }
            when VARIAZIONI_INDIRIZZO_FORNITURA {
                // TODO
            }
            when VARIAZIONI_TARIFFA_RES_NONRES {
                // TODO
            }
            when else {
                // TODO
            }
        }

        return null;
    }


    // Aggiorna il Case creato da Service Catalog con i dati necessari per l'allineamento anagrafica.
    // Si assume che che l'arricchimento dati è già stato effettuato sul Case.
    private static Boolean updateAnagAlignmentCaseServiceConsole(Case inputCase) {

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

        inputCase.CausalCode__c = causalCodeAnagAlignment(inputCase.CommodityFormula__c, HDT_ENU_AnagAlignmentContext.SERVICE_CATALOG);

        return HDT_UTL_DatabaseService.updateSObject(inputCase);
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
                inputMap.put('recordType', 'HDT_RT_AllineamentoAnagrafica');
                inputMap.put('cluster', 'Modifiche Anagrafiche');
                inputMap.put('type', 'Allineamento Anagrafica');
                inputMap.put('inputSObj', triggerObj);
                HDT_UTL_CreateGenericCase createCaseUtility = new HDT_UTL_CreateGenericCase();
                newCaseList = createCaseUtility.createCaseFromCase(inputMap);
            }
            when Order triggerOrder {
                // TODO
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
     * Richiama l'arricchimento dati sul Case di Allineamento Anagrafica;
     * Poi valorizza in base al contesto i dati specifici presi dal Case di Variazioni.
     */
    private static Boolean updateAnagAlignmentCaseVariazioni(Case anagAlignCase, Case triggerCase, HDT_ENU_AnagAlignmentContext context) {

        String arricchimentoResponse = HDT_WS_ArricchimentoDatiTemp.submitRequest(triggerCase.PODPDRFormula__c, triggerCase.ContractCode__c);
        anagAlignCase = HDT_UTL_DataEnrichmentPostSales.handleResponse(arricchimentoResponse, anagAlignCase);

        switch on context {
            when VARIAZIONI_FISCALE {
                // TODO
            }
            when else {
                // TODO
            }
        }

        return False;
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
