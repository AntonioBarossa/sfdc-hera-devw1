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

        currentCase = paperlessQr.getCaseById(recordId);
        documents = paperlessQr.getDocumentSelectedByCase(recordId);

        System.debug('SRV_Paperless Case--> '+currentCase);
        System.debug('SRV_Paperless Documetns--> '+documents);

        Map<String, Object> caseMap = new Map<String, Object>{
            'codicecliente' => currentCase.AccountCode__c,
            'contocontrattuale' => currentCase.BillingProfile__r.ContractAccountCode__c,
            'rds' => currentCase.CaseNumber
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
                    'importo' => document.Amount__c,
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

        System.debug('SRV_Paperless -->' +pretty);

        return pretty;
    
    }
}
