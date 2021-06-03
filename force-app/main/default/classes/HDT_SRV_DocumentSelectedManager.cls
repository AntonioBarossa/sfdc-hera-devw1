public with sharing class HDT_SRV_DocumentSelectedManager {
    @InvocableMethod(label='Manage Document Selected')
    public static List<HDT_WRP_DocumentSelectedResponse> execute(List<HDT_WRP_DocumentSelectedRequest> inputs){
        if(inputs==null || inputs.size()<=0 || String.isBlank(inputs[0].recordId) || String.isBlank(inputs[0].method)) return null;
        String method = inputs[0].method;
        switch on method{
            when 'manageDocuments' {
                String queryString = 'SELECT Id,Context__c FROM AccountStatementFilter__c WHERE Id=\''+inputs[0].recordId+'\'';
                List<SObject> recordList = HDT_QR_GenericQuery.getGenericRecords(queryString, 'AccountStatementFilter__c');
                String context = (String) recordList[0].get('Context__c');
                switch on context {
                    when 'EC1L', 'EC2L' {
                        return manageDocuments(inputs);
                    }
                    when 'InstallmentsView', 'EC7' {
                        return manageDocumentsCreditViews(inputs);
                    }
                    when else {
                        return null;
                    }
                }
            }
            when else {
                return null;
            }
        }
    }

    private static List<HDT_WRP_DocumentSelectedResponse> manageDocuments(List<HDT_WRP_DocumentSelectedRequest> inputs){
        if(inputs==null || inputs.size()<=0 || String.isBlank(inputs[0].recordId)) return null;
        HDT_WRP_DocumentSelectedResponse response = new HDT_WRP_DocumentSelectedResponse();
        List<HDT_WRP_DocumentSelectedResponse> responseList = new List<HDT_WRP_DocumentSelectedResponse>();
        try {
            String queryString = 'SELECT Id,Context__c,DocumentSelected__c FROM AccountStatementFilter__c WHERE Id=\''+inputs[0].recordId+'\'';
            String queryObject = 'AccountStatementFilter__c';
            List<SObject> recordList = HDT_QR_GenericQuery.getGenericRecords(queryString, queryObject);
            String documentJson = (String) recordList[0].get('DocumentSelected__c');
            String context = (String) recordList[0].get('Context__c');
            List<Object> primoLivelloList = (List<Object>)JSON.deserializeUntyped(documentJson);
            Map<String,Object> primolivello = (Map<String, Object>)primoLivelloList[0];
            List<Object> secondoLivelloList = (List<Object>)primolivello.get('secondoLivelloInformativo');
            Map<String, Object> secondoLivello = new Map<String, Object>();
            if(secondoLivelloList != null){
                secondoLivello = (Map<String, Object>) secondoLivelloList[0];
            }

            Case caseRecord = new Case();
            
            Date dataEmissione = formatDate((String) primolivello.get('dataEmissione'));
            Date dataScadenza = formatDate((String) primolivello.get('dataScadenza'));
            
            String numeroDocumento = (String) primolivello.get('numeroDocumento');
            String numeroFattura = (String) primolivello.get('numeroFattura');
            String contractCode = (String) secondoLivello.get('contratto') != null? (String) secondoLivello.get('contratto'):(String) primolivello.get('contratto');
            String tipoDocumento = (String) secondoLivello.get('testoDettaglio');
            caseRecord.ContractAccountCode__c = (String) primolivello.get('contoContrattuale');
            caseRecord.DocumentExpirationDate__c = dataScadenza;
            caseRecord.DocumentPaymentMethod__c = (String) primolivello.get('modalitaPagamento');
            caseRecord.DocumentResidue__c = Double.valueOf(primolivello.get('residuo'));
            caseRecord.DocumentAmount__c = Double.valueOf(primolivello.get('importo'));
            caseRecord.Amount__c = Double.valueOf(primolivello.get('importo'));
            caseRecord.BillNumber__c = numeroFattura != null? numeroFattura:numeroDocumento;
            caseRecord.SalesCompany__c = (String) primolivello.get('societa');
            System.debug('società ' + (String) primolivello.get('societa'));
            caseRecord.Id = inputs[0].caseId;
            //caseRecord.ReadType__c = (String) secondoLivello.get('importo'); --> Richiamare WS ad hoc
            
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
                    dataEmissione = formatDate((String) primolivello.get('dataEmissione'));
                    dataScadenza = formatDate((String) primolivello.get('dataScadenza'));
                    Double totaleCopertina = Double.valueOf(primolivello.get('totaleCopertina'));
                    Double importo = Double.valueOf(primolivello.get('importo'));
                    singleDocument.DocumentNumber__c = numeroFattura != null? numeroFattura:numeroDocumento;
                    singleDocument.Bill__c = (String) primolivello.get('numeroBollettino');
                    singleDocument.Type__c = (String) primolivello.get('tipoDocumento');
                    singleDocument.IssueDate__c = dataEmissione;
                    singleDocument.ExpirationDate__c = dataScadenza;
                    singleDocument.Amount__c = totaleCopertina != null? totaleCopertina:importo;
                    singleDocument.DocumentResidue__c = Double.valueOf(primolivello.get('residuo'));
                    singleDocument.Extension__c = (String) primolivello.get('dilazione');
                    singleDocument.PaymentMode__c = (String) primolivello.get('modalitaPagamento');
                    singleDocument.TvFeeResidual__c = calculateRaiFee(secondoLivelloList);
                    singleDocument.IssuingCompany__c = (String) primolivello.get('societa');
                    singleDocument.ContractualAccount__c = (String) primolivello.get('contoContrattuale');
                    singleDocument.TotalCommunicationPayment__c = totaleCopertina != null? totaleCopertina:importo;
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
                    Boolean insertDoc = HDT_UTL_DatabaseService.insertSObject(documentList);
                }
            }
            Boolean updateCase = HDT_UTL_DatabaseService.updateSObject(caseRecord);
        } catch (Exception ex) {
            System.debug('Error in HDT_SRV_DocumentSelectedManager: ' + ex.getMessage() + ' at line ' + ex.getLineNumber());
            return null;
        }
        responseList.add(response);
        return responseList;
    }

    private static List<HDT_WRP_DocumentSelectedResponse> manageDocumentsCreditViews(List<HDT_WRP_DocumentSelectedRequest> inputs){
        if(inputs==null || inputs.size()<=0 || String.isBlank(inputs[0].recordId)) return null;
        HDT_WRP_DocumentSelectedResponse response = new HDT_WRP_DocumentSelectedResponse();
        List<HDT_WRP_DocumentSelectedResponse> responseList = new List<HDT_WRP_DocumentSelectedResponse>();
        try {
            String queryString = 'SELECT Id,Context__c,DocumentSelected__c FROM AccountStatementFilter__c WHERE Id=\''+inputs[0].recordId+'\'';
            List<SObject> recordList = HDT_QR_GenericQuery.getGenericRecords(queryString, 'AccountStatementFilter__c');
            String documentJson = (String) recordList[0].get('DocumentSelected__c');
            String context = (String) recordList[0].get('Context__c');
            List<Object> primoLivelloList = (List<Object>)JSON.deserializeUntyped(documentJson);
            Map<String,Object> primolivello = (Map<String, Object>)primoLivelloList[0];
            List<Object> secondoLivelloList = (List<Object>)primolivello.get('secondoLivelloInformativoF2');
            Map<String, Object> secondoLivello = new Map<String, Object>();
            if(secondoLivelloList != null){
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
            caseRecord.ContractAccountCode__c = (String) primolivello.get('contoContrattuale');
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
                    singleDocument.Name = numeroDocumento;
                    documentList.add(singleDocument);
                }
                if(documentList.size()>0){
                    Boolean insertDoc = HDT_UTL_DatabaseService.insertSObject(documentList);
                }
            }
            Boolean updateCase = HDT_UTL_DatabaseService.updateSObject(caseRecord);
        } catch (Exception ex) {
            System.debug('Error in HDT_SRV_DocumentSelectedManager: ' + ex.getMessage() + ' at line ' + ex.getLineNumber());
            return null;
        }
        responseList.add(response);
        return responseList;
    }

    private static Date formatDate(String inputDate){
        if(inputDate==null || String.isBlank(inputDate)) return null;
        List<String> listString = inputDate.split('/');
        String gg = listString[0];
        String mm = listString[1];
        String yyyy = listString[2];
        return Date.valueOf(yyyy+'-'+mm+'-'+gg);
    }

    private static Double calculateRaiFee(List<Object> secondoLivelloList){
        if(secondoLivelloList==null || secondoLivelloList.size()<=0) return null;
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
            System.debug('Error in HDT_SRV_DocumentSelectedManager: ' + ex.getMessage());
            return null;
        }
    }

    private static String getRiferimentoFattura(List<Object> secondoLivelloList){
        if(secondoLivelloList==null || secondoLivelloList.size()<=0) return null;
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
            System.debug('Error in HDT_SRV_DocumentSelectedManager: ' + ex.getMessage());
            return null;
        }
    }

    public static List<SObject> getDocumentsSelected(Id caseId){
        String queryString = 'SELECT Id,TotalCommunicationPayment__c,DocumentNumber__c, Bill__c, Type__c, IssueDate__c,ExpirationDate__c,Amount__c,Residue__c,PaymentMode__c,IssuingCompany__c,ContractualAccount__c FROM DocumentSelected__c WHERE Case__c = \''+caseId+'\'';
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
    }
    
}