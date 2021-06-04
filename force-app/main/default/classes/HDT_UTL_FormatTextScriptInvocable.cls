public with sharing class HDT_UTL_FormatTextScriptInvocable {
        

    public class HDT_WRP_FlowInput{
        public HDT_WRP_FlowInput(){}
        public HDT_WRP_FlowInput(String text, String recordId){
            this.textScript=text;
            this.recordId=recordId;
        }
        @InvocableVariable(label='Testo Script' description='Testo Script Da formattare')
        public String textScript;
        @InvocableVariable(label='ID Record Riferimento' description='ID Record oggetto di partenza')
        public String recordId;
    }

    @InvocableMethod
    public static List<String> formatScript(List<HDT_WRP_FlowInput> inputs){
        List<String> formattedScript=new List<String>();
        formattedScript.add(new HDT_UTL_FormatTextScript()
                                .formatText(inputs[0].textScript, inputs[0].recordId)
                            );
        return formattedScript;
    }
}
