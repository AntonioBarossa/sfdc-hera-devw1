@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing class HDT_SRV_PaymentCommunication {
  
    HDT_QR_Payments paymentsQr = new HDT_QR_Payments();
    HDT_UTL_CreatePaymentsRequestBody paymentsUtl = new HDT_UTL_CreatePaymentsRequestBody();

    public String createRequestBody(String recordId){

        List<HDT_UTL_CreatePaymentsRequestBody.HDT_UTL_WrapperInput> inputList = new List<HDT_UTL_CreatePaymentsRequestBody.HDT_UTL_WrapperInput>();
        HDT_UTL_CreatePaymentsRequestBody.HDT_UTL_WrapperInput caseInput = new HDT_UTL_CreatePaymentsRequestBody.HDT_UTL_WrapperInput();
        HDT_UTL_CreatePaymentsRequestBody.HDT_UTL_WrapperInput documentInput = new HDT_UTL_CreatePaymentsRequestBody.HDT_UTL_WrapperInput();
        List<Map<String, Object>> documentsListMap = new List<Map<String, Object>>();
        List<Map<String, Object>> caseListMap = new List<Map<String, Object>>();
        List<DocumentSelected__c> documents = new List<DocumentSelected__c>();
        Case currentCase = new Case();
        String pretty;
        Boolean modalitaPagamento = false;
        currentCase = paymentsQr.getCaseById(recordId);
        documents = paymentsQr.getDocumentSelectedByCase(recordId);

        System.debug(LoggingLevel.DEBUG, 'SRV_PaymenCommunication Case--> '+currentCase);
        System.debug(LoggingLevel.DEBUG, 'SRV_PaymentCommunication Documetns--> '+documents);

        modalitaPagamento = (String.isNotBlank(currentCase.DocumentPaymentMethod__c) && currentCase.DocumentPaymentMethod__c.equalsIgnoreCase('Virtual Account'));
        Map<String, Object> caseMap;
        if(String.valueOf(currentCase.Type).equalsIgnoreCase('Promessa di Pagamento Ente')){
            caseMap = new Map<String, Object>{
                'rds' => currentCase.CaseNumber,
                'totale' => currentCase.TotalToPay__c,
                'residuo' => currentCase.TotalToPay__c,
                'dataPagamento' => currentCase.PaymentDate__c,
                'modalitaPagamento' => modalitaPagamento,
                'abi' => currentCase.IbanABI__c,
                'intestatarioContoOrdinante' => currentCase.BeneficiaryAccount__r.Name,
                'type' => currentCase.Type,
                'comuneEnte' => currentCase.CityOrInstitution__c,
                'note' => currentCase.Note__c
            };
        }else{
            caseMap = new Map<String, Object>{
                'rds' => currentCase.CaseNumber,
                'totale' => currentCase.TotalToPay__c,
                'residuo' => currentCase.TotalToPay__c,
                'dataPagamento' => currentCase.PaymentDate__c,
                'modalitaPagamento' => modalitaPagamento,
                'abi' => currentCase.IbanABI__c,
                'intestatarioContoOrdinante' => currentCase.BeneficiaryAccount__r.Name,
                'type' => currentCase.Type
            };
        }

        caseListMap.add(caseMap);

        caseInput.isParent = true;
        caseInput.isChild = false;
        caseInput.configMapList = caseListMap;

        inputList.add(caseInput);

        for(DocumentSelected__c document : documents){
            documentsListMap.add(
                new Map<String, Object>{
                    'numeroBollettino' => document.Bill__c,
                    'numeroFattura' => document.DocumentNumber__c.startsWith('0') ? document.DocumentNumber__c : '',
                    'numeroFattura1' => '',
                    'rataFattura' => 'RATEIZZAZIONI' == document.Type__c ? document.DocumentNumber__c : '',
                    'scadenza' => document.ExpirationDate__c,
                    'infoBlocco' => '',
                    'idProcesso' => '',
                    'numeroDocumento' => document.DocumentNumber__c.startsWith('0') ? '' : document.DocumentNumber__c,
                    'dataFattura' => document.IssueDate__c,
                    'totaleParziale' => document.TotalCommunicationPayment__c
                }
            );

        }

        documentInput.isParent = false;
        documentInput.isChild = true;
        documentInput.childObjName = 'pagamenti';
        documentInput.configMapList = documentsListMap;

        inputList.add(documentInput);
    

        pretty = paymentsUtl.createBodyRequest(inputList);

        System.debug(LoggingLevel.DEBUG, 'SRV_PaymentCommunication -->' +pretty);

        return pretty;
    }
}