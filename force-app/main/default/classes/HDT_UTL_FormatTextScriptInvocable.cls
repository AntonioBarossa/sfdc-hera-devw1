/*
 * File: HDT_UTL_FormatTextScriptInvocable.cls
 * Project: HERA
 * File Created: Friday, 4th June 2021 4:15:38 pm
 * Author: fdefelice
 * -----
 * HISTORY:
 */



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
        formattedScript.add(new HDT_UTL_FormatRichText()//HDT_UTL_FormatTextScript()
                                .formatText(inputs[0].textScript, inputs[0].recordId)
                            );
        return formattedScript;
    }

    private class HDT_UTL_FormatRichText extends HDT_UTL_FormatTextScript{
        public HDT_UTL_FormatRichText(){
            this.regEx= '\\{\\{([\\xa0\\s]?)+[A-Za-z0-9_.]+([\\xa0\\s]?)+\\}\\}';//xa0 matches nbsp; 
            this.leftIncapsulatingData= '{{';
            this.rightIncapsulatingData= '}}';
        }
    }
}
