@SuppressWarnings('PMD.AvoidDebugStatements')
public with sharing class HDT_SRV_DocumentSelectedManager {
    
    @InvocableMethod(label='Manage Document Selected')
    public static List<HDT_WRP_DocumentSelectedResponse> execute(List<HDT_WRP_DocumentSelectedRequest> inputs){
        
        System.debug(LoggingLevel.DEBUG, 'HDT_SRV_DocumentSelectedManager - execute - inputs: ' + inputs);
        
        if(inputs==null || inputs.size()<=0 || String.isBlank(inputs[0].recordId) || String.isBlank(inputs[0].method)){
            return null;
        }
                
        String method = inputs[0].method;
        String context = '';
        String queryString = 'SELECT Id,Context__c FROM AccountStatementFilter__c WHERE Id=\''+inputs[0].recordId+'\'';
        
        List<SObject> recordList = HDT_QR_GenericQuery.getGenericRecords(queryString, 'AccountStatementFilter__c');
        switch on method{
            when 'manageDocuments' {
                context = (String) recordList[0].get('Context__c');
                switch on context {
                    when 'EC1L', 'EC2L' {
                        return manageDocuments(inputs);
                    }
                    when 'InstallmentsView', 'EC7' {
                        return manageDocumentsCreditViews(inputs);
                    }
                    when 'Paperless' {
                        return manageDocumentsPaperless(inputs);
                    }
                    when else {
                        return null;
                    }
                }
            }
            when 'manageDocumentsInformative'{
                context = inputs[0].contesto;
                switch on context {
                    when 'EC1Level','NoteVarIva' {
                        return manageDocuments(inputs);
                    }
                    when else {
                        return manageDocumentsCreditViews(inputs);
                    }
                }
            }
            when 'manageDocumentsPaperless'{
                return manageDocumentsPaperless(inputs);
            }
            when else {
                return null;
            }
        }
    }

    private static List<HDT_WRP_DocumentSelectedResponse> manageDocuments(List<HDT_WRP_DocumentSelectedRequest> inputs){
        
        if(inputs==null || inputs.size()<=0 || String.isBlank(inputs[0].recordId)){
            return null;
        }
        
        HDT_WRP_DocumentSelectedResponse response = new HDT_WRP_DocumentSelectedResponse();
        List<HDT_WRP_DocumentSelectedResponse> responseList = new List<HDT_WRP_DocumentSelectedResponse>();
        
        try {
            HDT_QR_Case qrCase = new HDT_QR_Case();
            HDT_QR_BillingProfile bpQueryHandler = new HDT_QR_BillingProfile();
            String queryString = 'SELECT Id,Context__c,DocumentSelected__c FROM AccountStatementFilter__c WHERE Id=\''+inputs[0].recordId+'\'';
            String queryObject = 'AccountStatementFilter__c';
            List<SObject> recordList = HDT_QR_GenericQuery.getGenericRecords(queryString, queryObject);
            String documentJson = (String) recordList[0].get('DocumentSelected__c');
            /*
                @Author: Davide Viola - 19/10/2021
                Description: PMD -> Commentata variabile non utilizzata.
            */
            //String context = (String) recordList[0].get('Context__c');
            List<Object> primoLivelloList = (List<Object>)JSON.deserializeUntyped(documentJson);
            Map<String,Object> primolivello = (Map<String, Object>)primoLivelloList[0];
            List<Object> secondoLivelloList = (List<Object>)primolivello.get('secondoLivelloInformativo');
            Map<String, Object> secondoLivello = new Map<String, Object>();
            if(secondoLivelloList != null){
                secondoLivello = (Map<String, Object>) secondoLivelloList[0];
            }

            Case caseRecord = new Case();
            Case caseCommitted;
            
            Date dataEmissione = formatDate((String) primolivello.get('dataEmissione'));
            Date dataScadenza = formatDate((String) primolivello.get('dataScadenza'));
            
            String numeroDocumento = (String) primolivello.get('numeroDocumento');
            String numeroFattura = (String) primolivello.get('numeroFattura');
            
            String contractCode = (String) secondoLivello.get('contratto') != null? (String) secondoLivello.get('contratto'):(String) primolivello.get('contratto');
            String tipoDocumento = (String) secondoLivello.get('testoDettaglio');
            String processType = '';
            String contoContrattuale = (String) primolivello.get('contoContrattuale');
            BillingProfile__c billingProfile = bpQueryHandler.getRecordByContractAccount(contoContrattuale);
            if (billingProfile != null) {
                caseRecord.BillingProfile__c = billingProfile.Id;
            }
            caseRecord.ContractAccountCode__c = contoContrattuale;
            caseRecord.DocumentExpirationDate__c = dataScadenza;
            caseRecord.DocumentPaymentMethod__c = (String) primolivello.get('modalitaPagamento');
            caseRecord.DocumentResidue__c = Double.valueOf(primolivello.get('residuo'));
            caseRecord.DocumentAmount__c = Double.valueOf(primolivello.get('importo'));
            caseRecord.Amount__c = Double.valueOf(primolivello.get('importo'));
            caseRecord.BillNumber__c = numeroFattura != null? numeroFattura:numeroDocumento;
            
            System.debug(LoggingLevel.DEBUG, 'società ' + (String) primolivello.get('societa'));
            caseRecord.SalesCompany__c = (String) primolivello.get('societa');
            
            caseRecord.Id = inputs[0].caseId;
            caseCommitted = qrCase.getRecordById(inputs[0].caseId);
            processType = caseCommitted != null? caseCommitted.Type:'';
            response.caseRecord = caseRecord;
            response.contractCode = contractCode;
            response.tipoDocumento = tipoDocumento;

            if(inputs[0].createDocuments){
                List<DocumentSelected__c> documentList = new List<DocumentSelected__c>();
                for(Object singleRecord : primoLivelloList){
                    DocumentSelected__c singleDocument = new DocumentSelected__c();
                    
                    primolivello = (Map<String, Object>) singleRecord;
                    secondoLivelloList = (List<Object>)primolivello.get('secondoLivelloInformativo');
                    
                    numeroDocumento = (String) primolivello.get('numeroDocumento') != null? (String) primolivello.get('numeroDocumento'):(String) primolivello.get('documento');
                    numeroFattura = (String) primolivello.get('numeroFattura');
                    
                    singleDocument.DocumentNumber__c = numeroFattura != null? numeroFattura:numeroDocumento;
                    dataEmissione = formatDate((String) primolivello.get('dataEmissione'));
                    dataScadenza = formatDate((String) primolivello.get('dataScadenza'));
                    singleDocument.Bill__c = (String) primolivello.get('numeroBollettino');
                    singleDocument.Type__c = (String) primolivello.get('tipoDocumento');
                    singleDocument.IssueDate__c = dataEmissione;
                    singleDocument.ExpirationDate__c = dataScadenza;
                    // Valorizzazione Amount
                    Double totaleCopertina = Double.valueOf(primolivello.get('totaleCopertina'));
                    Double importo = Double.valueOf(primolivello.get('importo'));
                    if(processType.equalsIgnoreCase('Piano Rateizzazione') && Double.valueOf(primolivello.get('residuo')) == 0){
                        singleDocument.Amount__c = importo;
                    }else {
                        singleDocument.Amount__c = totaleCopertina != null? totaleCopertina:importo;
                    }
                    singleDocument.DocumentResidue__c = Double.valueOf(primolivello.get('residuo'));
                    singleDocument.Extension__c = (String) primolivello.get('dilazione');
                    singleDocument.PaymentMode__c = (String) primolivello.get('modalitaPagamento');
                    singleDocument.TvFeeResidual__c = calculateRaiFee(secondoLivelloList);
                    singleDocument.RaiFeeAmount__c = calculateRaiFeeAmount(secondoLivelloList);
                    singleDocument.IssuingCompany__c = (String) primolivello.get('societa');
                    singleDocument.ContractualAccount__c = (String) primolivello.get('contoContrattuale');
                    singleDocument.TotalCommunicationPayment__c = totaleCopertina != null? totaleCopertina:importo;
                    singleDocument.Case__c = inputs[0].caseId;
                    singleDocument.CommoditySector__c = calculateCommodity(secondoLivelloList);// fpalladi sviluppo per W2 Errore Fatturazione Idrico
                    
                    if(String.isNotBlank(numeroFattura)){
                        singleDocument.Name = numeroFattura;
                    }else if(String.isNotBlank(numeroDocumento)) {
                        singleDocument.Name = numeroDocumento;
                    }else {
                        singleDocument.Name = '';//getRiferimentoFattura(secondoLivelloList);
                    }
                    documentList.add(singleDocument);
                }
                if(documentList.size()>0){
                    documentList = calculateSalesCompanyCode(documentList);
                    HDT_UTL_DatabaseService.insertSObject(documentList);
                }
            }
            HDT_UTL_DatabaseService.updateSObject(caseRecord);
        } catch (Exception ex) {
            System.debug(LoggingLevel.DEBUG, 'Error in HDT_SRV_DocumentSelectedManager: ' + ex.getMessage() + ' at line ' + ex.getLineNumber());
            return null;
        }
        responseList.add(response);
        return responseList;
    }

    private static List<HDT_WRP_DocumentSelectedResponse> manageDocumentsCreditViews(List<HDT_WRP_DocumentSelectedRequest> inputs){
        
        if(inputs==null || inputs.size()<=0 || String.isBlank(inputs[0].recordId)){
            return null;
        }
        
        HDT_WRP_DocumentSelectedResponse response = new HDT_WRP_DocumentSelectedResponse();
        List<HDT_WRP_DocumentSelectedResponse> responseList = new List<HDT_WRP_DocumentSelectedResponse>();
        
        try {
            HDT_QR_BillingProfile bpQueryHandler = new HDT_QR_BillingProfile();
            String queryString = 'SELECT Id,Context__c,DocumentSelected__c FROM AccountStatementFilter__c WHERE Id=\''+inputs[0].recordId+'\'';
            List<SObject> recordList = HDT_QR_GenericQuery.getGenericRecords(queryString, 'AccountStatementFilter__c');
            String documentJson = (String) recordList[0].get('DocumentSelected__c');
            String context = (String) recordList[0].get('Context__c');
            List<Object> primoLivelloList = (List<Object>)JSON.deserializeUntyped(documentJson);
            Map<String,Object> primolivello = (Map<String, Object>)primoLivelloList[0];
            List<Object> secondoLivelloList = (List<Object>)primolivello.get('secondoLivelloInformativoF2');
            Map<String, Object> secondoLivello = new Map<String, Object>();
            if(secondoLivelloList != null && !secondoLivello.isEmpty()){
                secondoLivello = (Map<String, Object>) secondoLivelloList[0];
            }

            queryString = 'SELECT Id,Type FROM Case WHERE Id=\''+inputs[0].caseId+'\'';
            List<SObject> cases = HDT_QR_GenericQuery.getGenericRecords(queryString, 'Case');
            String processType = (String) cases[0].get('Type') != null ? (String) cases[0].get('Type') : '';

            Case caseRecord = new Case();
            
            Date dataEmissione = formatDate((String) primolivello.get('dataEmissione'));
            Date dataScadenza = formatDate((String) primolivello.get('dataScadenza'));
            
            String numeroDocumento = (String) primolivello.get('documento');
            String numeroFattura = (String) primolivello.get('docOriginario'); // // Valorizzato solo su Partite non Fatturate.
            String contractCode = (String) primolivello.get('contratto'); // Valorizzato solo su Partite non Fatturate.
            String contoContrattuale = (String) primolivello.get('contoContrattuale');
            BillingProfile__c billingProfile = bpQueryHandler.getRecordByContractAccount(contoContrattuale);
            if (billingProfile != null) {
                caseRecord.BillingProfile__c = billingProfile.Id;
            }
            caseRecord.ContractAccountCode__c = contoContrattuale;
            caseRecord.DocumentExpirationDate__c = dataScadenza;
            caseRecord.DocumentResidue__c = Double.valueOf(primolivello.get('residuo'));
            caseRecord.DocumentAmount__c = Double.valueOf(primolivello.get('importo'));
            caseRecord.Amount__c = Double.valueOf(primolivello.get('importo'));
            //caseRecord.BillNumber__c = numeroFattura != null? numeroFattura:numeroDocumento;
            caseRecord.BillNumber__c = numeroDocumento; // Eventualmente per Errore di Fatturazione possiamo mettere il docOriginario
            caseRecord.Id = inputs[0].caseId;
            
            response.caseRecord = caseRecord;
            response.contractCode = contractCode;
            response.hasPartiteNonFatturate = (context != null && context.equals('EC7'));

            if(inputs[0].createDocuments){
                List<DocumentSelected__c> documentList = new List<DocumentSelected__c>();
                for(Object singleRecord : primoLivelloList){
                    DocumentSelected__c singleDocument = new DocumentSelected__c();
                    primolivello = (Map<String, Object>) singleRecord;
                    secondoLivelloList = (List<Object>)primolivello.get('secondoLivelloInformativoF2');
                    numeroDocumento = (String) primolivello.get('documento');
                    numeroFattura = (String) primolivello.get('docOriginario');
                    dataEmissione = formatDate((String) primolivello.get('dataEmissione'));
                    dataScadenza = formatDate((String) primolivello.get('dataScadenza'));
                    Double importo = Double.valueOf(primolivello.get('importo'));
                    singleDocument.DocumentNumber__c = numeroDocumento;
                    singleDocument.Bill__c = (String) primolivello.get('numeroBollettino');
                    // Per le Comunicazioni di Pagamento innescate da vista Rate bisogna mandare a SAP il valore fisso "RATEIZZAZIONI"
                    singleDocument.Type__c = processType.equals('Comunicazione Pagamento') ? 'RATEIZZAZIONI' : '';
                    singleDocument.IssueDate__c = dataEmissione;
                    singleDocument.ExpirationDate__c = dataScadenza;
                    singleDocument.Amount__c = importo;
                    singleDocument.DocumentResidue__c = Double.valueOf(primolivello.get('residuo'));
                    singleDocument.ContractualAccount__c = (String) primolivello.get('contoContrattuale');
                    singleDocument.TotalCommunicationPayment__c = importo;
                    singleDocument.Case__c = inputs[0].caseId;
                    
                    if(String.isNotBlank(numeroFattura)){
                        singleDocument.Name = numeroFattura;
                    }else if(String.isNotBlank(numeroDocumento)) {
                        singleDocument.Name = numeroDocumento;
                    }else {
                        singleDocument.Name = getRiferimentoFattura(secondoLivelloList);
                    }
                    documentList.add(singleDocument);
                }
                if(documentList.size()>0){
                    /*
                        @Author: Davide Viola - 19/10/2021
                        Description: PMD -> Commentata variabile non utilizzata.
                    */
                    /*Boolean insertDoc = */HDT_UTL_DatabaseService.insertSObject(documentList);
                }
            }
            /*
                @Author: Davide Viola - 19/10/2021
                Description: PMD -> Commentata variabile non utilizzata.
            */
            /*Boolean updateCase = */HDT_UTL_DatabaseService.updateSObject(caseRecord);
        } catch (Exception ex) {
            System.debug(LoggingLevel.DEBUG, 'Error in HDT_SRV_DocumentSelectedManager: ' + ex.getMessage() + ' at line ' + ex.getLineNumber());
            return null;
        }
        responseList.add(response);
        return responseList;
    }

    private static List<HDT_WRP_DocumentSelectedResponse> manageDocumentsPaperless(List<HDT_WRP_DocumentSelectedRequest> inputs){
        
        if(inputs==null || inputs.size()<=0 || String.isBlank(inputs[0].recordId)){
            return null;
        }
        
        HDT_WRP_DocumentSelectedResponse response = new HDT_WRP_DocumentSelectedResponse();
        List<HDT_WRP_DocumentSelectedResponse> responseList = new List<HDT_WRP_DocumentSelectedResponse>();
        
        try {
            HDT_QR_BillingProfile bpQueryHandler = new HDT_QR_BillingProfile();
            String queryString = 'SELECT Id,DocumentSelected__c FROM AccountStatementFilter__c WHERE Id=\''+inputs[0].recordId+'\'';
            List<SObject> recordList = HDT_QR_GenericQuery.getGenericRecords(queryString, 'AccountStatementFilter__c');
            String documentJson = (String) recordList[0].get('DocumentSelected__c');
            List<Object> primoLivelloList = (List<Object>)JSON.deserializeUntyped(documentJson);
            Map<String,Object> primolivello = (Map<String, Object>)primoLivelloList[0];

            Case caseRecord = new Case();
            
            Date dataEmissione = formatDate((String) primolivello.get('dataEmissione'));
            Date dataScadenza = formatDate((String) primolivello.get('dataScadenza'));
            
            String numeroDocumento = (String) primolivello.get('documento');
            String numeroFattura = (String) primolivello.get('numeroFattura');
            String contoContrattuale = (String) primolivello.get('contoContrattuale');
            BillingProfile__c billingProfile = bpQueryHandler.getRecordByContractAccount(contoContrattuale);
            if (billingProfile != null) {
                caseRecord.BillingProfile__c = billingProfile.Id;
            }
            caseRecord.ContractAccountCode__c = contoContrattuale;
            caseRecord.Id = inputs[0].caseId;
            
            response.caseRecord = caseRecord;

            if(inputs[0].createDocuments){
                List<DocumentSelected__c> documentList = new List<DocumentSelected__c>();
                for(Object singleRecord : primoLivelloList){
                    DocumentSelected__c singleDocument = new DocumentSelected__c();
                    primolivello = (Map<String, Object>) singleRecord;
                    numeroDocumento = (String) primolivello.get('documento');
                    numeroFattura = (String) primolivello.get('numeroFattura');
                    dataEmissione = formatDate((String) primolivello.get('dataEmissione'));
                    dataScadenza = formatDate((String) primolivello.get('dataScadenza'));
                    singleDocument.DocumentNumber__c = numeroDocumento;
                    singleDocument.Position1__c = (String) primolivello.get('posizione1');
                    singleDocument.Position2__c = (String) primolivello.get('posizione2');
                    singleDocument.Position3__c = (String) primolivello.get('posizione3');
                    singleDocument.Type__c = (String) primolivello.get('tipoDocumento');
                    singleDocument.IssueDate__c = dataEmissione;
                    singleDocument.ExpirationDate__c = dataScadenza;
                    singleDocument.DocumentResidue__c = Double.valueOf(primolivello.get('residuo'));
                    singleDocument.ContractualAccount__c = (String) primolivello.get('contoContrattuale');
                    singleDocument.TotalCommunicationPayment__c = Double.valueOf(primolivello.get('residuo'));
                    singleDocument.Case__c = inputs[0].caseId;
                    singleDocument.PaymentMode__c = 'BOLLETTINO POSTALE';
                    singleDocument.Amount__c = Double.valueOf(primolivello.get('residuo'));
                    
                    if(String.isNotBlank(numeroFattura)) {
                        singleDocument.Name = numeroFattura;
                    }else if(String.isNotBlank(numeroDocumento)){
                        singleDocument.Name = numeroDocumento;
                    }else {
                        singleDocument.Name = String.valueOf(Date.today());
                    }
                    documentList.add(singleDocument);
                }
                if(documentList.size()>0){
                    /*
                        @Author: Davide Viola - 19/10/2021
                        Description: PMD -> Commentata variabile non utilizzata.
                    */
                    /*Boolean insertDoc = */HDT_UTL_DatabaseService.insertSObject(documentList);
                }
            }
            /*
                @Author: Davide Viola - 19/10/2021
                Description: PMD -> Commentata variabile non utilizzata.
            */
            /*Boolean updateCase = */HDT_UTL_DatabaseService.updateSObject(caseRecord);
        } catch (Exception ex) {
            System.debug(LoggingLevel.DEBUG, 'Error in HDT_SRV_DocumentSelectedManager: ' + ex.getMessage() + ' at line ' + ex.getLineNumber());
            return null;
        }
        responseList.add(response);
        return responseList;
    }
    
    @TestVisible
    private static Date formatDate(String inputDate){
        if(inputDate==null || String.isBlank(inputDate)) {
            return null;
        }
        List<String> listString = inputDate.split('/');
        String gg = listString[0];
        String mm = listString[1];
        String yyyy = listString[2];
        return Date.valueOf(yyyy+'-'+mm+'-'+gg);
    }
    /**@frpanico 2022-06-05
     * Calcola l'importo del canone rai
     * Indipendentemente se e' stato pareggiato
     * o meno
     */
    @TestVisible
    private static Double calculateRaiFeeAmount(List<Object> secondoLivelloList)
    {
        if(secondoLivelloList==null || secondoLivelloList.size()<=0) {
            return null;
        }
        try
        {
            Double raiFee = 0;
            for(Object singleRecord : secondoLivelloList){
                Map<String, Object> secondolivello = (Map<String, Object>) singleRecord;
                Double importo = Double.valueOf(secondolivello.get('importo'));
                String tipoDocumento = (String) secondolivello.get('tipoDocumento');
                if(tipoDocumento.equalsIgnoreCase('VR')){
                    raiFee += importo;
                }
            }
            return raiFee;
        }
        catch(Exception ex)
        {
            System.debug(LoggingLevel.DEBUG, 'Error in HDT_SRV_DocumentSelectedManager: ' + ex.getMessage());
            return null;
        }
    }

    /**
     * @fpalladi 2022-08-26
     * Wave2 - Calcola la commodity della partita (2nd livello) selezionata 
     */
    @TestVisible
    private static String calculateCommodity(List<Object> secondoLivelloList){ 
        String toReturn = '';
        Set<String> commoditySectorSet = new Set<String>();
        
        if(secondoLivelloList != null) {
            for(Object singleRecord : secondoLivelloList){
                Map<String, Object> secondolivello = (Map<String, Object>) singleRecord;
                commoditySectorSet.add((String) secondolivello.get('settoreMerceologico'));
            }         
        }

        toReturn = commoditySectorSet.size() == 0 ? '' : toReturn;
        toReturn = commoditySectorSet.size() == 1 ? new List<String> (commoditySectorSet)[0] : toReturn;
        toReturn = commoditySectorSet.size()  > 1 ? 'Multi' : toReturn;

        return toReturn ;                
    }
    
    @TestVisible
    private static Double calculateRaiFee(List<Object> secondoLivelloList){
        if(secondoLivelloList==null || secondoLivelloList.size()<=0) {
            return null;
        }
        
        try {
            Double raiFee = 0;
            for(Object singleRecord : secondoLivelloList){
                Map<String, Object> secondolivello = (Map<String, Object>) singleRecord;
                String tipoDocumento = (String) secondolivello.get('tipoDocumento');
                String motivoPareggio = (String) secondolivello.get('motivoDiPareggio');
                Double importo = Double.valueOf(secondolivello.get('importo'));
                if(tipoDocumento.equalsIgnoreCase('VR') && (String.isBlank(motivoPareggio) || String.isEmpty(motivoPareggio))){
                    raiFee += importo;
                }
            }
            return raiFee;
        } catch (Exception ex) {
            System.debug(LoggingLevel.DEBUG, 'Error in HDT_SRV_DocumentSelectedManager: ' + ex.getMessage());
            return null;
        }
    }

    @TestVisible
    private static String getRiferimentoFattura(List<Object> secondoLivelloList){
        if(secondoLivelloList == null || secondoLivelloList.size() <= 0) {
            return null;
        }
        
        try {
            String riferimentoFattura = '';
            for(Object singleRecord : secondoLivelloList){
                Map<String, Object> secondolivello = (Map<String, Object>) singleRecord;
                riferimentoFattura = (String) secondolivello.get('riferimentoFattura');
                if (String.isNotBlank(riferimentoFattura)) {
                    return riferimentoFattura;
                }
            }
            return riferimentoFattura;
        } catch (Exception ex) {
            System.debug(LoggingLevel.DEBUG, 'Error in HDT_SRV_DocumentSelectedManager: ' + ex.getMessage());
            return null;
        }
    }
    
    @TestVisible
    private static List<DocumentSelected__c> calculateSalesCompanyCode(List<DocumentSelected__c> documents)
    {
        List<String> salesCompany = new List<String>();
        for(DocumentSelected__c singleDocument : documents)
        {
            salesCompany.add(singleDocument.IssuingCompany__c);
        }
        List<HDT_HeraCompany__mdt> companiesTranscode = [SELECT Id, CompanyCode__c,SalesCompany__c FROM HDT_HeraCompany__mdt WHERE SalesCompany__c IN :salesCompany WITH SECURITY_ENFORCED];
        Map<String, String> companyCodeMap = new Map<String,String>();
        for(HDT_HeraCompany__mdt singleTranscode : companiesTranscode)
        {
            companyCodeMap.put(singleTranscode.SalesCompany__c, singleTranscode.CompanyCode__c);
        }
        for(DocumentSelected__c singleDocument : documents)
        {
            if(singleDocument.IssuingCompany__c != null && String.isNotBlank(singleDocument.IssuingCompany__c))
            {
                singleDocument.IssuingCompanyCode__c = companyCodeMap.get(singleDocument.IssuingCompany__c);
            }
        }
        return documents;
    }
    
    public static List<SObject> getDocumentsSelected(Id caseId){
        String queryString = 'SELECT Id,RaiFeeAmount__c,TotalCommunicationPayment__c,DocumentNumber__c, TvFeeResidual__c, DocumentResidue__c, Bill__c, Type__c, IssueDate__c,ExpirationDate__c,Amount__c,Residue__c,PaymentMode__c,IssuingCompany__c,ContractualAccount__c FROM DocumentSelected__c WHERE Case__c = \''+caseId+'\'';
        String objectName = 'DocumentSelected__c';
        List<SObject> documentSelected = HDT_QR_GenericQuery.getGenericRecords(queryString, objectName);
        return documentSelected;
    }

    public class HDT_WRP_DocumentSelectedResponse{
    
        @InvocableVariable
        public Case caseRecord;
        
        @InvocableVariable
        public String contractCode;
        
        @InvocableVariable
        public List<DocumentSelected__c> documents;

        @InvocableVariable
        public String tipoDocumento;

        @InvocableVariable
        public Boolean hasPartiteNonFatturate;
        
    }

    public class HDT_WRP_DocumentSelectedRequest{
        @InvocableVariable
        public String recordId;

        @InvocableVariable
        public String caseId;
        
        @InvocableVariable
        public Boolean createDocuments;

        @InvocableVariable
        public String method;

        @InvocableVariable
        public String contractCode;

        @InvocableVariable
        public String contesto;
    }
    
}