public inherited sharing class HDT_SRV_Reimbursement {

    HDT_QR_Reimbursement reimbursementQr = new HDT_QR_Reimbursement();
    HDT_WS_Reimbursement reimbursementWs = new HDT_WS_Reimbursement();
    HDT_UTL_CreatePaymentsRequestBody paymentsUtl = new HDT_UTL_CreatePaymentsRequestBody();
    
    public Boolean checkDocumentDate(String recordId){

        List<DocumentSelected__c> documents = new List<DocumentSelected__c>();

        Boolean flag = false;

        documents = reimbursementQr.getDocumentSelectedByCaseId(recordId);

        for(DocumentSelected__c document : documents){

            if(document.IssueDate__c.addDays(20) < System.today()){

                flag = true;

            }


        }

        return flag;

    }


    public Boolean checkAccountBalance(String customerCode){

        List<HDT_UTL_CreatePaymentsRequestBody.HDT_UTL_WrapperInput> inputList = new List<HDT_UTL_CreatePaymentsRequestBody.HDT_UTL_WrapperInput>();
        HDT_UTL_CreatePaymentsRequestBody.HDT_UTL_WrapperInput caseInput = new HDT_UTL_CreatePaymentsRequestBody.HDT_UTL_WrapperInput();
        List<Map<String, Object>> caseListMap = new List<Map<String, Object>>();

        String pretty;
        String result;
        Boolean flag = false;

        Map<String, Object> caseMap = new Map<String, Object>{
            'codiceCliente' => customerCode,
            'tipoEstrattoConto' => 'ORDINARIO'
        };

        caseListMap.add(caseMap);

        caseInput.isParent = true;
        caseInput.isChild = false;
        caseInput.configMapList = caseListMap;

        inputList.add(caseInput);

        pretty = paymentsUtl.createBodyRequest(inputList);

        System.debug('SRV_Reimbursement bodyRequest--> '+pretty);

        result = reimbursementWs.calloutAccountBalance(pretty);

        if(result == 'N'){

            flag = true;

        }

        return flag;

    }

}
