/**
 * Header of the class "HDT_UTL_FormatTextScriptInvocableTst"
 * @author Cesare Bagnolini, cesare.bagnolini@webresults.it
 * @version 1.0
 * @description: Apex Test Class of the relative Apex Class "HDT_UTL_FormatTextScriptInvocable"
 * @history
 * @Created 23/09/2021
 * Modified By:
 **/

@isTest
public class HDT_UTL_FormatTextScriptInvocableTst {

  @isTest
	static void test1(){
        
        Test.startTest();
        
        HDT_UTL_FormatTextScriptInvocable.HDT_WRP_FlowInput flowInput = new HDT_UTL_FormatTextScriptInvocable.HDT_WRP_FlowInput('firstText','firstId');
        HDT_UTL_FormatTextScriptInvocable.HDT_WRP_FlowInput flowInput2 = new HDT_UTL_FormatTextScriptInvocable.HDT_WRP_FlowInput();
        flowinput2.recordId = 'secondId';
        flowinput2.textScript = 'secondText';
        
        List<HDT_UTL_FormatTextScriptInvocable.HDT_WRP_FlowInput> flows = new List<HDT_UTL_FormatTextScriptInvocable.HDT_WRP_FlowInput>();
        flows.add(flowInput);
        flows.add(flowInput2);
        
        List<String> formattedText = HDT_UTL_FormatTextScriptInvocable.formatScript(flows);
        
        Test.stopTest();
        
        System.assertEquals('firstText', formattedText[0], 'First input not returned correctly');
        
        System.assertNotEquals(2, formattedText.size(), 'The second input should be ignored');
        
    }
}