public inherited sharing class HDT_SRV_IndemnityConfirmation {

    @InvocableMethod(label = 'Check Conferma Indennizzo')
    public static List<HDT_UTL_FlowOutputs> checkIndemnityConfirmation(List<HDT_UTL_FlowInputs> inputs){

        HDT_QR_IndemnityConfirmation indemnityQr = new HDT_QR_IndemnityConfirmation();

        List<Case> cases = new List<Case>();
        List<HDT_UTL_FlowOutputs> outputs = new List<HDT_UTL_FlowOutputs>();
        HDT_UTL_FlowOutputs output = new HDT_UTL_FlowOutputs();

        Boolean flag = false;
        

        String recordId = inputs[0].recordId;
        String accountId = inputs[0].accountId;
        String servicePointId = inputs[0].servicePointId;
        String firstLevel = inputs[0].firstLevel;
        String secondLevel = inputs[0].secondLevel;

        cases = indemnityQr.getOtherIndemnityCases(recordId, accountId, servicePointId, firstLevel, secondLevel);

        if(cases.size() > 0){

            for(Case singleCase : cases){

                if((Date.valueOf(singleCase.CreatedDate) + 365) > System.today()){

                    flag = true;
                    break;

                }

            }

        }

        output.indemnityNotConfirmed = flag;

        outputs.add(output);

        return outputs;

    }


    public class HDT_UTL_FlowInputs{

        @InvocableVariable
        public String recordId;

        @InvocableVariable
        public String accountId;

        @InvocableVariable
        public String servicePointId;

        @InvocableVariable
        public String firstLevel;

        @InvocableVariable
        public String secondLevel;

    }

    public class HDT_UTL_FlowOutputs{

        @InvocableVariable
        public Boolean indemnityNotConfirmed;

    }
}
