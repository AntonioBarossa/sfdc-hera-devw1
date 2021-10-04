/*
 * File: HDT_UTL_FormatTextScriptInvocable.cls
 * Project: HERA
 * File Created: Friday, 4th June 2021 4:15:38 pm
 * Author: fdefelice
 * -----
 * HISTORY:
 * Last Modified: Monday, 7th June 2021 5:57:33 pm
 * Modified By: fdefelice
 * Changes: 
 * --END--
 */



public with sharing class HDT_UTL_FormatTextScriptInvocable {
        

    public class HDT_WRP_FlowInput{

        @InvocableVariable(label='Testo Script' description='Testo Script Da formattare')
        public String textScript;

        @InvocableVariable(label='ID Record Riferimento' description='ID Record oggetto di partenza')
        public String recordId;

        public HDT_WRP_FlowInput(){
            return;
        }

        public HDT_WRP_FlowInput(String text, String recordId){
            this.textScript=text;
            this.recordId=recordId;
        }
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
