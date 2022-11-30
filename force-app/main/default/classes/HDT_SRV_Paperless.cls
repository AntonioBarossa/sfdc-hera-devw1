@SuppressWarnings('PMD.AvoidDebugStatements')
public with sharing class HDT_SRV_Paperless {

    HDT_QR_Paperless paperlessQr = new HDT_QR_Paperless();
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
        String modalitaPagamento;

        currentCase = paperlessQr.getCaseById(recordId);
        documents = paperlessQr.getDocumentSelectedByCase(recordId);
        switch on (currentCase.DocumentPaymentMethod__c){
            when 'Bollettino Paperless' {
                modalitaPagamento = 'P';
            }
            when 'Bonifico Paperless' {
                modalitaPagamento = 'B';
            }
            when else {
                modalitaPagamento = '';
            }
        }
        System.debug(LoggingLevel.DEBUG, 'SRV_Paperless Case--> '+currentCase);
        System.debug(LoggingLevel.DEBUG, 'SRV_Paperless Documetns--> '+documents);


        Map<String, Object> caseMap = new Map<String, Object>{
            'codiceCliente' => currentCase.AccountCode__c,
            'contoContrattuale' => currentCase.BillingProfile__r.ContractAccountCode__c,
            'rds' => currentCase.CaseNumber,
            'modalitaPagamento' => modalitaPagamento
        };

        caseListMap.add(caseMap);

        caseInput.isParent = true;
        caseInput.isChild = false;
        caseInput.configMapList = caseListMap;

        inputList.add(caseInput);

        for(DocumentSelected__c document : documents){
            documentsListMap.add(
                new Map<String, Object>{
                    'documento' => document.DocumentNumber__c,
                    'posizione1' => document.Position1__c,
                    'posizione2' => document.Position2__c,
                    'posizione3' => document.Position3__c,
                    'importo' => document.DocumentResidue__c,
                    'scadenza' => document.ExpirationDate__c
                }
            );
        }

        documentInput.isParent = false;
        documentInput.isChild = true;
        documentInput.childObjName = 'bollettini';
        documentInput.configMapList = documentsListMap;
        inputList.add(documentInput);
        pretty = paymentsUtl.createBodyRequest(inputList);

        System.debug(LoggingLevel.DEBUG, 'SRV_Paperless -->' +pretty);
        return pretty;
    }
    
}
