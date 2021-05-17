public inherited sharing class HDT_UTL_Reimbursement {
    
    @InvocableMethod(label = 'Check Processo Rimborso')
    public static List<HDT_UTL_FlowOutputs> reimbursementChecks(List<HDT_UTL_FlowInputs> inputs){

        HDT_SRV_Reimbursement reimbursementSrv = new HDT_SRV_Reimbursement();

        List<HDT_UTL_FlowOutputs> outputs = new List<HDT_UTL_FlowOutputs>();
        HDT_UTL_FlowOutputs output = new HDT_UTL_FlowOutputs();

        String recordId = inputs[0].recordId;
        String customerCode = inputs[0].customerCode;

        output.documentCheck = reimbursementSrv.checkDocumentDate(recordId);
        output.accountBalanceCheck = reimbursementSrv.checkAccountBalance(customerCode);

        outputs.add(output);

        return outputs;

    }


    public class HDT_UTL_FlowInputs{

        @InvocableVariable
        public String recordId;

        @InvocableVariable
        public String customerCode;

    }

    public class HDT_UTL_FlowOutputs{

        @InvocableVariable
        public Boolean documentCheck;

        @InvocableVariable
        public Boolean accountBalanceCheck;


    }

}
