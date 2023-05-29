@isTest
public with sharing class HDT_UTL_CaseFlowHandlerTst {
    @isTest
    private static void handleModificaRecapito(){
        Test.startTest();
        HDT_UTL_CaseFlowHandler.HDT_WRP_FlowInputs input = new HDT_UTL_CaseFlowHandler.HDT_WRP_FlowInputs();
        List<HDT_UTL_CaseFlowHandler.HDT_WRP_FlowInputs> inputList = new List<HDT_UTL_CaseFlowHandler.HDT_WRP_FlowInputs>();
        //input.method = 'handleModificaRecapito';
        input.newEmail = 'nuova email';
        input.oldEmail = 'vecchia email';
        input.phase = 'Bozza';
        inputList.add(input);
        List<HDT_UTL_CaseFlowHandler.HDT_WRP_FlowOutputs> outputList = HDT_UTL_CaseFlowHandler.handleCaseCheck(inputList);
        System.assertEquals(false, outputList[0].outcome,'Method required');
        input.method = 'methodInesistente';
        outputList = HDT_UTL_CaseFlowHandler.handleCaseCheck(inputList);
        System.assertEquals(false, outputList[0].outcome,'Metodo Inesistente');
        input.method = 'checkModificaRecapito';
        outputList = HDT_UTL_CaseFlowHandler.handleCaseCheck(inputList);
        System.assertEquals(true, outputList[0].outcome,'Dati modificati');
        input.newEmail = 'stessa email';
        input.oldEmail = 'stessa email';
        outputList = HDT_UTL_CaseFlowHandler.handleCaseCheck(inputList);
        System.assertEquals(false, outputList[0].outcome,'Dati non modificati');
        Test.stopTest();
    }
}

