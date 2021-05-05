public inherited sharing class HDT_UTL_CheckDocumentSelected {

    @InvocableMethod(label = 'Controlla Documenti a Credito/Debito')
    public static List<HDT_UTL_FlowOutputs> checkCreditDebit(List<HDT_UTL_FlowInputs> inputs){

        HDT_QR_Reimbursement reimbursementQr = new HDT_QR_Reimbursement();

        List<HDT_UTL_FlowOutputs> outputs = new List<HDT_UTL_FlowOutputs>();
        List<DocumentSelected__c> documents = new List<DocumentSelected__c>();

        HDT_UTL_FlowOutputs output = new HDT_UTL_FlowOutputs();
        String phase;

        String recordId = inputs[0].recordId;
        String reimburseMethod = inputs[0].reimburseMethod;
        Boolean isForeign = inputs[0].isForeign;
        String beneficiary = inputs[0].beneficiary;

        Decimal residualSum;
        Integer creditDocument = 0;
        Integer debitDocument = 0;
        Boolean creditDebit = false;
        Boolean onlyCredit = false;

        documents = reimbursementQr.getDocumentSelectedByCaseId(recordId);

        if(documents.size() == 1){

            if(reimburseMethod == 'Assegno' || (isForeign != null && isForeign == true) || documents[0].Residue__c == 0){

                phase = 'Elaborazione Manuale';

            } else {

                if(beneficiary == 'Erede'){

                    phase = 'Attesa Modulo Firmato';
                } else {

                    phase = 'Da Inviare';
                
                }

            }

        } else {
            // Controlli sui documenti
            for(DocumentSelected__c document : documents){

                if(document.Residue__c > 0){

                    ++debitDocument;

                } else if(document.Residue__c < 0){

                    ++creditDocument;

                }

                residualSum += document.Residue__c;

            }

            if(debitDocument > 0 && creditDocument > 0){

                creditDebit = true;

            } else if(creditDocument == documents.size()){

                onlyCredit = true;

            }
            //Controlli sui documenti

            if(onlyCredit == true){

                if(reimburseMethod == 'Bonifico' && (isForeign != null && isForeign == false)){

                    if(beneficiary == 'Erede'){

                        phase = 'Attesa Modulo Firmato';

                    } else {

                        phase = 'Da Inviare';

                    }
                }else{

                    phase = 'Elaborazione Manuale';

                }

            } else if(creditDebit == true && residualSum != 0){

                if(reimburseMethod == 'Bonifico' && beneficiary == 'Erede'){

                    phase = 'Attesa Modulo Firmato';

                } else {
                    
                    phase = 'Da Inviare';
                }

            } else if(residualSum == 0){

                phase = 'Elaborazione Manuale';

            }

        }

        output.phase = phase;

        outputs.add(output);

        return outputs;

    }

    public class HDT_UTL_FlowInputs{

        @InvocableVariable
        public String recordId;

        @InvocableVariable
        public String reimburseMethod;

        @InvocableVariable
        public Boolean isForeign;

        @InvocableVariable
        public String beneficiary;

    }

    public class HDT_UTL_FlowOutputs{

        @InvocableVariable
        public String phase;

    }

  

}