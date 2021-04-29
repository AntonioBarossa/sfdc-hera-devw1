public inherited sharing class HDT_SRV_CreateGenericCase {

    @InvocableMethod(label = 'Crea Case')
    public static List<String> createCaseInvocable(List<HDT_UTL_FlowInputs> inputs){

        Map<String, Object> inputMap = new Map<String, Object>();
        List<String> resultList = new List<String>();

        inputMap.put('recordType', inputs[0].recordTypeDevName);
        inputMap.put('type', inputs[0].caseType);
        inputMap.put('cluster', inputs[0].caseCluster);
        inputMap.put('inputSObj', inputs[0].inputSobj);

        resultList.add(createCase(inputMap));

        return resultList;

    }

    public static String createCase(Map<String, Object> inputs){

        HDT_UTL_CreateGenericCase cgcUtl = new HDT_UTL_CreateGenericCase();

        List<Case> newCases = new List<Case>();
        String createdCaseId;

        if(inputs.get('inputSObj') instanceof SObject){

            SObject inputSobj = (SObject) inputs.get('inputSObj');

            switch on inputSobj{

                when Case newCase{

                    newCases = cgcUtl.createCaseFromCase(inputs);

                }

            }

            HDT_UTL_DatabaseService.insertSObject(newCases);

            createdCaseId = newCases[0].Id;

        }else{

            //blank code

        }

        return createdCaseId;

    }

    public class HDT_UTL_FlowInputs{

        //Aggiungere inputs nel qual caso ne servano altri

        @InvocableVariable
        public String recordTypeDevName;

        @InvocableVariable
        public String caseType;

        @InvocableVariable
        public String caseCluster;

        @InvocableVariable
        public SObject inputSobj;

    }


}
