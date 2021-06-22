public inherited sharing class HDT_UTL_CausalCodeCalculation {

    private static HDT_QR_CausalCodeCalculation cccQr = new HDT_QR_CausalCodeCalculation();


    @InvocableMethod(label = 'Calculate Causal Code')
    public static List<HDT_CausalCodeCalculation__mdt> calculateCausalCode(List<HDT_UTL_FlowInputs> inputs){

        List<HDT_CausalCodeCalculation__mdt> cccList = new List<HDT_CausalCodeCalculation__mdt>();

        String cluster = inputs[0].cluster;
        String process = inputs[0].process;
        String subprocess = inputs[0].subprocess;
        String commodity = inputs[0].commodity;

        cccList.add(cccQr.calculateCausalCode(cluster, process, subprocess,commodity));

        return cccList;

    }

    public class HDT_UTL_FlowInputs{

        @InvocableVariable
        public String cluster;

        @InvocableVariable
        public String process;

        @InvocableVariable
        public String subprocess;

        @InvocableVariable
        public String commodity;


    }



}
