public inherited sharing class HDT_UTL_CheckDocumentSelected {

    @InvocableMethod(label = 'Controlla Documenti a Credito/Debito')
    public static List<HDT_UTL_FlowOutputs> checkCreditDebit(List<HDT_UTL_FlowInputs> inputs){

        HDT_QR_Reimbursement reimbursementQr = new HDT_QR_Reimbursement();

        List<HDT_UTL_FlowOutputs> outputs = new List<HDT_UTL_FlowOutputs>();
        List<DocumentSelected__c> documents = new List<DocumentSelected__c>();

        HDT_UTL_FlowOutputs output = new HDT_UTL_FlowOutputs();
        String phase = '';
        String invoiceList = '';
        String documentList = '';
        String causalCode = '';

        String recordId = inputs[0].recordId;
        String reimburseMethod = inputs[0].reimburseMethod;
        Boolean isForeign = inputs[0].isForeign;
        String beneficiary = inputs[0].beneficiary;

        Decimal residualSum = 0;
        Integer creditDocument = 0;
        Integer debitDocument = 0;
        //Boolean creditDebit = false;
        //Boolean onlyCredit = false;

        documents = reimbursementQr.getDocumentSelectedByCaseId(recordId);

        // Controlli sui documenti
        for(DocumentSelected__c document : documents){

            if(document.DocumentResidue__c > 0){

                ++debitDocument;

            } else if(document.DocumentResidue__c < 0){

                ++creditDocument;

            }

            residualSum += document.DocumentResidue__c;

            // Concatenazione numeri fattura/documento per Heroku.
            String documentNumber = document.DocumentNumber__c;
            if(String.isNotBlank(documentNumber)){
                if(documentNumber.startsWith('0')){
                    invoiceList += documentNumber + ';';
                } else {
                    documentList += documentNumber + ';';
                }
            }

        }

        switch on reimburseMethod {
            when 'Bonifico' {
                if(documents.size() >= 1 && creditDocument == documents.size()){
                    if(!isForeign){
                        causalCode = 'FAD';
                        phase = beneficiary == 'Erede' ? 'Attesa Modulo Firmato' : 'Da Inviare';
                    }else{
                        phase = 'Elaborazione Manuale';
                    }
                }else if(debitDocument > 0 && creditDocument > 0){
                    causalCode = isForeign ? 'COM' : 'COF';
                    phase = beneficiary == 'Erede' ? 'Attesa Modulo Firmato' : 'Da Inviare';
                } else {
                    phase = 'Elaborazione Manuale';
                }
            }
            when 'Assegno'{
                if(documents.size() >= 1 && creditDocument == documents.size()){
                    phase = 'Elaborazione Manuale';
                }else if(creditDocument > 0 && debitDocument > 0){
                    causalCode = 'COM';
                    phase = beneficiary == 'Erede' ? 'Attesa Modulo Firmato' : 'Da Inviare';
                }else{
                    phase = 'Elaborazione Manuale';
                }
            }
            when 'Compensazione'{
                if(creditDocument > 0 && debitDocument > 0){
                    causalCode = 'COM';
                    phase = beneficiary == 'Erede' ? 'Attesa Modulo Firmato' : 'Da Inviare';
                }else{
                    phase = 'Elaborazione Manuale';
                }
            }
            when else {
                phase = 'Elaborazione Manuale';
            }
        }


        /*if(documents.size() == 1){

            if(reimburseMethod == 'Assegno' || (isForeign != null && isForeign == true) || documents[0].DocumentResidue__c == 0){

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

                if(document.DocumentResidue__c > 0){

                    ++debitDocument;

                } else if(document.DocumentResidue__c < 0){

                    ++creditDocument;

                }

                residualSum += document.DocumentResidue__c;

                // Concatenazione numeri fattura/documento per Heroku.
                String documentNumber = document.DocumentNumber__c;
                if(String.isNotBlank(documentNumber)){
                    if(documentNumber.startsWith('0')){
                        invoiceList += documentNumber + ';';
                    } else {
                        documentList += documentNumber + ';';
                    }
                }

            }

            if(debitDocument > 0 && creditDocument > 0){

                creditDebit = true;
                causalCode = 'COF';

            } else if(creditDocument == documents.size()){

                onlyCredit = true;
                causalCode = 'FAD';
            } else if(debitDocument == documents.size()){
                causalCode = 'COM';
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

            } else {

                phase = 'Elaborazione Manuale';
            }

        }*/

        output.phase = phase;
        output.invoiceList = invoiceList;
        output.documentList = documentList;
        output.causalCode = causalCode;

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

        @InvocableVariable
        public String invoiceList;

        @InvocableVariable
        public String documentList;

        @InvocableVariable
        public String causalCode;
    }

  

}