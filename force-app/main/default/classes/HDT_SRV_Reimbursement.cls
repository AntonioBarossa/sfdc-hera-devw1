public inherited sharing class HDT_SRV_Reimbursement {

    HDT_QR_Reimbursement reimbursementQr = new HDT_QR_Reimbursement();
    HDT_WS_Reimbursement reimbursementWs = new HDT_WS_Reimbursement();
    
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

        JSONGenerator gen = JSON.createGenerator(true);
        String pretty;
        String result;
        Boolean flag = false;

        gen.writeStartObject();
        gen.writeStringField('codiceCliente', customerCode);
        gen.writeStringField('tipoEstrattoConto', 'ORDINARIO');
        gen.writeEndObject();

        pretty = gen.getAsString();

        System.debug('SRV_Reimbursement bodyRequest--> '+pretty);

        result = reimbursementWs.calloutAccountBalance(pretty);

        if(result == 'N'){

            flag = true;

        }

        return flag;


    }


}
