public inherited sharing class HDT_SRV_ReminderBlock {

    HDT_QR_ReminderBlock reminderQr = new HDT_QR_ReminderBlock();
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
        Integer blockDuration;

        currentCase = reminderQr.getCaseById(recordId);
        documents = reminderQr.getDocumentSelectedByCaseId(recordId);

        System.debug('SRV_ReminderBlock Case--> '+currentCase);
        System.debug('SRV_ReminderBlock Documetns--> '+documents);

        if(currentCase.BlockType__c == '1'){

            blockDuration = 45;

        } else if(currentCase.BlockType__c == 'W'){

            blockDuration = 240;

        }

        Map<String, Object> caseMap = new Map<String, Object>{
            'bp' => currentCase.AccountCode__c,
            'blocco' => currentCase.BlockType__c,
            'durataBlocco' => blockDuration
        };

        caseListMap.add(caseMap);

        caseInput.isParent = true;
        caseInput.isChild = false;
        caseInput.configMapList = caseListMap;

        inputList.add(caseInput);

        for(DocumentSelected__c document : documents){
            documentsListMap.add(
                new Map<String, Object>{
                    'numeroDocumento' => document.DocumentNumber__c.startsWith('0') ? '' : document.DocumentNumber__c,
                    'numeroFattura' => document.DocumentNumber__c.startsWith('0') ? document.DocumentNumber__c : '',
                    'ca' => document.ContractualAccount__c
                }
            );
        } 
        
        documentInput.isParent = false;
        documentInput.isChild = true;
        documentInput.childObjName = 'fatture';
        documentInput.configMapList = documentsListMap;

        inputList.add(documentInput);
    

        pretty = paymentsUtl.createBodyRequest(inputList);

        System.debug('SRV_ReminderBlock -->' +pretty);

        return pretty;
    }
}
