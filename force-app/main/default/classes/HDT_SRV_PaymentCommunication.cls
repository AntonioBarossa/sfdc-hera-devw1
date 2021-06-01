public inherited sharing class HDT_SRV_PaymentCommunication {

    HDT_QR_PaymentCommunication paymentQr = new HDT_QR_PaymentCommunication();
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

        currentCase = paymentQr.getCaseById(recordId);
        documents = paymentQr.getDocumentSelectedByCase(recordId);

        System.debug('SRV_PaymenCommunication Case--> '+currentCase);
        System.debug('SRV_PaymentCommunication Documetns--> '+documents);

        Map<String, Object> caseMap = new Map<String, Object>{
            'rds' => currentCase.CaseNumber,
            'totale' => currentCase.TotalPaidCustomer__c,
            'residuo' => currentCase.TotalResidue__c,
            'importo' => currentCase.TotalToPay__c
        };

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
                    'rataFattura' => '',
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

        System.debug('SRV_PaymentCommunication -->' +pretty);

        return pretty;
    }



}
