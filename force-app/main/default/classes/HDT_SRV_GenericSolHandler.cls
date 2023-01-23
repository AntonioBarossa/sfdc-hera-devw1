@SuppressWarnings('PMD.AvoidDebugStatements')
public with sharing class HDT_SRV_GenericSolHandler {
    public static void checkCompatibility(String caseId,String phase){
        HDT_QR_HerokuPostSalesManager qrClass = new HDT_QR_HerokuPostSalesManager();
        Case currentCase = qrClass.getCaseRecord(caseId);
        //CompatibilityCheck
        String compatibility = '';
        //checkCompatibility Method Call
        try{
            compatibility = HDT_UTL_MatrixCompatibility.checkCompatibilityPostSales(currentCase);
        } catch (Exception e) {
            System.debug(LoggingLevel.DEBUG, 'Errore Compatibilita ' + e.getMessage());
        }
        //Check Compatibility Output
        if(String.isEmpty(compatibility)){
            if(String.isNotBlank(phase)){
                currentCase.Phase__c = phase;
            }
            System.debug(LoggingLevel.DEBUG, 'Compatibilita superata con successo ' + compatibility);
        } else {
            System.debug(LoggingLevel.DEBUG, 'Compatibilita non superata ' + compatibility);
            currentCase.Phase__c = 'Bozza Annullata';
            currentCase.Status = 'Closed';
            currentCase.CancellationReason__c = 'Processo incompatibile';
        }
        HDT_UTL_DatabaseService.updateSObject(currentCase);
    }

    public static void dataEnrichment(String caseId){
        HDT_QR_HerokuPostSalesManager qrClass = new HDT_QR_HerokuPostSalesManager();
        Case currentCase = qrClass.getCaseRecord(caseId);
        String pod = currentCase.PODPDRFormula__c;
        String contractCode = currentCase.ContractCode__c; 
        HDT_WS_ArrichmentDataEntityResponse res = HDT_WS_ArrichmentDataEntityInvoker.callService(contractCode, pod);
        currentCase = HDT_UTL_DataEnrichmentPostSales.handleResponse(JSON.serialize(res), currentCase);              
    }

    public static void handleInstallment(String caseId){
        HDT_QR_HerokuPostSalesManager qrClass = new HDT_QR_HerokuPostSalesManager();
        Case currentCase = qrClass.getCaseRecord(caseId);
        String contractAccountCode = currentCase.ContractAccountCode__c;
        String docNumber = currentCase.DocumentNumber__c;
        String bollettino = currentCase.BillNumber__c;
        String accountCode = currentCase.AccountCode__c;
        Map<String,String> params = new Map<String,String>();
        params.put('codCli', accountCode);
        params.put('codContoContratto', contractAccountCode);
        params.put('xblnr', docNumber);
        if(String.isNotBlank(bollettino)){
            params.put('bollo', bollettino);
        }
        DateTime toDate = Datetime.now();
        Datetime fromDate = toDate.addYears(-3);
        params.put('fromDate', fromDate.format('dd/MM/yyyy'));
        params.put('toDate', toDate.format('dd/MM/yyyy'));

        String responseResult = HDT_LC_AccountStatementPicker.getStatements(JSON.serialize(params));
        List<Object> posizioniList = (List<Object>) JSON.deserializeUntyped(responseResult);
        if(posizioniList != null && posizioniList.size()>0){
            Map<String,Object> posizioniMap = (Map<String,Object>) posizioniList[0];
            DocumentSelected__c recordToInsert = new DocumentSelected__c();
            recordToInsert.Name = (String) posizioniMap.get('xblnr');
            recordToInsert.DocumentNumber__c = (String) posizioniMap.get('xblnr');
            recordToInsert.Bill__c = (String) posizioniMap.get('bollo');
            recordToInsert.Type__c = (String) posizioniMap.get('tipoDocDesc');
            recordToInsert.IssueDate__c = formatDateForInsert((String) posizioniMap.get('bmItemDt'));
            recordToInsert.ExpirationDate__c = formatDateForInsert((String) posizioniMap.get('bmEndDt'));
            recordToInsert.Amount__c= (Double) Double.valueOf(posizioniMap.get('totFattura'));
            recordToInsert.DocumentResidue__c= (Double) Double.valueOf(posizioniMap.get('residuo'));
            recordToInsert.Extension__c= (String) posizioniMap.get('sollecitato');
            recordToInsert.PaymentMode__c= (String) posizioniMap.get('payment');
            recordToInsert.TvFeeResidual__c= (Double) Double.valueOf(posizioniMap.get('restituzioneCanoneRai'));
            recordToInsert.IssuingCompany__c= (String) posizioniMap.get('socEmittenteDesc');
            recordToInsert.ContractualAccount__c= (String) posizioniMap.get('contoContrattuale');
            recordToInsert.TotalCommunicationPayment__c= (Double) Double.valueOf(posizioniMap.get('totPagare'));
            recordToInsert.Case__c = caseId;
            HDT_UTL_DatabaseService.insertSObject(recordToInsert);
        }
    }
    
    private static Date formatDateForInsert(String dateString){
        if(dateString!= null && dateString != ''){
            List<String> dateSplitted = new List<String>();
            dateSplitted = dateString.split('/');
            return Date.newInstance(Integer.valueOf(dateSplitted[2]), Integer.valueOf(dateSplitted[1]), Integer.valueOf(dateSplitted[0]));
        } else {
            return null;
        }
    }

    public static void handleAnalisiConsumi(Map<String,Object> inputParams){
        String accountId = (String) inputParams.get('accountId');
        String contactId = (String) inputParams.get('contactId');
        String contractNumber = (String) inputParams.get('contractNumber');
        String serviceRequest = (String) inputParams.get('serviceRequest');
        String integrationId = (String) inputParams.get('integrationId');
        if(String.isBlank(serviceRequest)){
            Sale__c sale = HDT_UTL_GenericSolHandler.createSale(accountId, contactId,'Vendita Analisi Consumi da Web ');
            HDT_UTL_GenericSolHandler.createBaseOrder(inputParams,sale.Id);
        }else{
            HDT_UTL_GenericSolHandler.handleAnalisiConsumiOrder(inputParams);
        }
    }

    public static void handleVolturaH2o(Map<String,Object> inputParams){
        String accountId = (String) inputParams.get('accountId');
        String contactId = (String) inputParams.get('contactId');
        String serviceRequest = (String) inputParams.get('serviceRequest');
        if(String.isBlank(serviceRequest)){
            Sale__c sale = HDT_UTL_GenericSolHandler.createSale(accountId, contactId,'Voltura Idrica da Web');
            //HDT_UTL_GenericSolHandler.createBaseOrder(inputParams,sale.Id);
            HDT_UTL_GenericSolHandler.createBaseOrderVoltura(inputParams,sale.Id);
        }else{
            //HDT_UTL_GenericSolHandler.handleAnalisiConsumiOrder(inputParams);
        }
    }
    
}