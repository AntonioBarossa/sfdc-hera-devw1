/*
 * File: HDT_UTL_FormatTextScriptTest.cls
 * Project: HERA
 * File Created: Tuesday, 1st June 2021 3:38:49 pm
 * Author: fdefelice
 * -----
 * Last Modified: Tuesday, 1st June 2021 7:16:25 pm
 * Modified By: fdefelice
 * -----
 * History:
 * Last Modified: Thursday, 10th June 2021 4:39:29 pm
 * Modified By: fdefelice
 * Changes: 
 * --END--
 */


@isTest 
public class HDT_UTL_FormatTextScriptTest {

  
    @isTest public static void testScriptWithDataBinding(){
        //Id processTypeId = ((SObject)Type.forName('Schema','ScriptConfig__c').newInstance()).getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_RT_Processo').getRecordTypeId();
        ScriptConfig__c config = new ScriptConfig__c(Name='my Script', ScriptType__c='Processo');
        insert config;
        ScriptConfig__c configChild = new ScriptConfig__c(Name='my ChildScript', ParentSection__c=config.id);
        insert configChild;
        HDT_UTL_FormatTextScriptInvocable.HDT_WRP_FlowInput inp = new HDT_UTL_FormatTextScriptInvocable.HDT_WRP_FlowInput();
        inp.textScript='{{ name }} {{ParentSection__r.Name}}';
        inp.recordId=configChild.id;
        string formattedText =HDT_UTL_FormatTextScriptInvocable.formatScript(new List<HDT_UTL_FormatTextScriptInvocable.HDT_WRP_FlowInput>{inp})[0];
        system.debug(formattedText);
        system.debug(configChild.name+' '+config.Name);
        system.assertEquals(formattedText.replaceAll('<[^>]+>',''),configChild.name+' '+config.Name, 'Data is not formatted as expected');
        inp.textScript='{{ LastModifiedDate }} {{ StartRecording__c }}';
        formattedText =HDT_UTL_FormatTextScriptInvocable.formatScript(new List<HDT_UTL_FormatTextScriptInvocable.HDT_WRP_FlowInput>{inp})[0];        
    	system.assertEquals((DateTime.now().format('dd/MM/yyyy')+' '+configChild.StartRecording__c).replaceAll('\\p{C}', '?'), formattedText.replaceAll('\\p{C}', '?').replaceAll('<[^>]+>',''), 'Data is not formatted as expected');
        inp.textScript='{{owner.Name}}';
        formattedText =HDT_UTL_FormatTextScriptInvocable.formatScript(new List<HDT_UTL_FormatTextScriptInvocable.HDT_WRP_FlowInput>{inp})[0];        
        system.assertEquals(formattedText,'<b>*valore mancante*</b>', 'Data is not formatted as expected');
        system.debug('CPU TIME: '+Limits.getCpuTime());
    }

    @isTest public static void testScriptWithoutDataBinding(){
        //Id processTypeId = ((SObject)Type.forName('Schema','ScriptConfig__c').newInstance()).getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_RT_Processo').getRecordTypeId();
        ScriptConfig__c config = new ScriptConfig__c(Name='my Script', ScriptType__c='Processo');
        insert config;
        ScriptConfig__c configChild = new ScriptConfig__c(Name='my ChildScript', ParentSection__c=config.id);
        insert configChild;
        HDT_UTL_FormatTextScriptInvocable.HDT_WRP_FlowInput inp = new HDT_UTL_FormatTextScriptInvocable.HDT_WRP_FlowInput();
        inp.recordId=configChild.id;
        inp.textScript='test';
        String formattedText =HDT_UTL_FormatTextScriptInvocable.formatScript(new List<HDT_UTL_FormatTextScriptInvocable.HDT_WRP_FlowInput>{inp})[0];
        system.assertEquals(formattedText, 'test', 'Data is not get right');
        inp.textScript='{{globaltag.today}}';
        formattedText =HDT_UTL_FormatTextScriptInvocable.formatScript(new List<HDT_UTL_FormatTextScriptInvocable.HDT_WRP_FlowInput>{inp})[0];
		system.assertEquals(formattedText.replaceAll('<[^>]+>',''), DateTime.now().format('dd/MM/yyyy'), 'Data is not formatted as expected');
        system.debug('CPU TIME: '+Limits.getCpuTime());

    }

    @isTest public static void testScriptExceptionHandler(){
        //Id processTypeId = ((SObject)Type.forName('Schema','ScriptConfig__c').newInstance()).getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_RT_Processo').getRecordTypeId();
        ScriptConfig__c config = new ScriptConfig__c(Name='my Script', ScriptType__c='Processo');
        insert config;
        ScriptConfig__c configChild = new ScriptConfig__c(Name='my ChildScript');
        insert configChild;
        HDT_UTL_FormatTextScriptInvocable.HDT_WRP_FlowInput inp = new HDT_UTL_FormatTextScriptInvocable.HDT_WRP_FlowInput('', '');
        inp.recordId=configChild.id;
        try{
            inp.textScript='{{ test }}';
        	String formattedText =HDT_UTL_FormatTextScriptInvocable.formatScript(new List<HDT_UTL_FormatTextScriptInvocable.HDT_WRP_FlowInput>{inp})[0];
        }catch(Exception e){
            system.assertEquals(e.getTypeName(), 'HDT_UTL_FormatTextScript.HDT_UTL_FormatTextScriptException', 'Unexpected Exception Launched');
        }
        system.debug('CPU TIME: '+Limits.getCpuTime());
	}

    
}