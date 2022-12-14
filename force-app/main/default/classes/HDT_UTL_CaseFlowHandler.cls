/**
 * @Author: NTTDATA
 * @Description: Questa classe è richiamabile da Flow come Apex Action e serve 
 * ad eseguire dei check in back-end
 **/

public with sharing class HDT_UTL_CaseFlowHandler {
    @InvocableMethod(label='Handle Case Check')
    
    public static List<HDT_WRP_FlowOutputs> handleCaseCheck(List<HDT_WRP_FlowInputs> inputs){
        HDT_WRP_FlowInputs input = inputs[0];
        HDT_WRP_FlowOutputs output = new HDT_WRP_FlowOutputs();
        List<HDT_WRP_FlowOutputs> outputList = new List<HDT_WRP_FlowOutputs>(); 
        String method = input.method;
        if(String.isBlank(method)){
            output.outcome = false;
            output.outcomeDescription = 'Il metod deve essere sempre valorizzato';
            outputList.add(output);
            return outputList;
        }
        switch on method {
            when 'checkModificaRecapito' {
                return handleModificaRecapito(input);
            }
            when else {
                output.outcome = false;
                output.outcomeDescription = 'Method non gestito';
                outputList.add(output);
                return outputList;
            }
        }

    }
    private static List<HDT_WRP_FlowOutputs> handleModificaRecapito(HDT_WRP_FlowInputs input){
        HDT_WRP_FlowOutputs output = new HDT_WRP_FlowOutputs();
        List<HDT_WRP_FlowOutputs> outputList = new List<HDT_WRP_FlowOutputs>();
        if((input.oldEmail != input.newEmail ||
           input.oldPec   != input.newPec   ||
           input.oldAddress != input.newAddress ||
           input.oldSendMethod != input.newSendMethod || 
           String.isNotBlank(input.newPresso)) && String.isNotBlank(input.phase) &&
           (input.phase.equalsIgnoreCase('Bozza') || 
            input.phase.equalsIgnoreCase('Errore Lavorazione SAP') 
           )
        ){
            output.outcome = true;
            output.outcomeDescription = 'Necessaria modifica recapito';
        }else{
            output.outcome = false;
            output.outcomeDescription = 'Modifica recapito non necessaria';
        }
        outputList.add(output);
        return outputList;
    }

    public class HDT_WRP_FlowOutputs{
        @InvocableVariable
        public Boolean outcome;
        @InvocableVariable
        public String outcomeDescription;
    }
    public class HDT_WRP_FlowInputs{
        @InvocableVariable(required=true)
        public String method;
        @InvocableVariable
        public String oldEmail;
        @InvocableVariable
        public String newEmail;
        @InvocableVariable
        public String oldSendMethod;
        @InvocableVariable
        public String newSendMethod;
        @InvocableVariable
        public String oldAddress;
        @InvocableVariable
        public String newAddress;
        @InvocableVariable
        public String oldPresso;
        @InvocableVariable
        public String newPresso;
        @InvocableVariable
        public String oldPec;
        @InvocableVariable
        public String newPec;
        @InvocableVariable
        public String phase;

    }
}

