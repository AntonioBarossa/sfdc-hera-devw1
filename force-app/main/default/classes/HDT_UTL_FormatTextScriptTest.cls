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
        system.assertEquals(formattedText.replaceAll('<[^>]+>',''),configChild.name+' '+config.Name, 'Data is not formatted as expected');
        inp.textScript='{{ LastModifiedDate }} {{ StartRecording__c }}';
        formattedText =HDT_UTL_FormatTextScriptInvocable.formatScript(new List<HDT_UTL_FormatTextScriptInvocable.HDT_WRP_FlowInput>{inp})[0];        
    	system.assertEquals((DateTime.now().format('dd/MM/yyyy')+' '+configChild.StartRecording__c).replaceAll('\\p{C}', '?'), formattedText.replaceAll('\\p{C}', '?').replaceAll('<[^>]+>',''), 'Data is not formatted as expected');
        inp.textScript='{{owner.Name}}';
        formattedText =HDT_UTL_FormatTextScriptInvocable.formatScript(new List<HDT_UTL_FormatTextScriptInvocable.HDT_WRP_FlowInput>{inp})[0];        
        system.assertEquals('<b>[Vuoto]</b>', formattedText, 'Empty value is not formatted as expected');
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
        	HDT_UTL_FormatTextScriptInvocable.formatScript(new List<HDT_UTL_FormatTextScriptInvocable.HDT_WRP_FlowInput>{inp});
        }catch(Exception e){
            system.assertEquals(e.getTypeName(), 'HDT_UTL_FormatTextScript.HDT_UTL_FormatTextScriptException', 'Unexpected Exception Launched');
        }
	}
    
    
    @isTest static void testGetConstantValue(){
        HDT_UTL_FormatTextScript script = new HDT_UTL_FormatTextScript();
        String s = script.getConstantValue(new List<String>{'test0','test1'});
        System.assertEquals('*Costante test1 non trovata*', s, 'GetConstantValue did not work correctly');
        System.assertNotEquals(null, s, 'GetConstantValue did not work correctly');
    }

    @isTest static void testGetGlobalTagValues(){
        HDT_UTL_FormatTextScript script = new HDT_UTL_FormatTextScript();        
        
        String stringaNow = script.getGlobalTagValues(new List<String>{'test0','now'}, null);
        System.assertEquals(Datetime.now().format('HH:mm'), stringaNow, 'GetGlobalTagValues did not work correctly');
        System.assertNotEquals(null, stringaNow, 'GetGlobalTagValues did not work correctly');

        String stringaSection = script.getGlobalTagValues(new List<String>{'test0','section__d','test2'}, null);
        System.assertEquals('test2'+'\n', stringaSection, 'GetGlobalTagValues did not work correctly');
        System.assertNotEquals(null, stringaSection, 'GetGlobalTagValues did not work correctly');

        String stringaSectionSecond = script.getGlobalTagValues(new List<String>{'test0','section__d','test2'}, null);
        System.assertEquals('\n\n'+'test2'+'\n', stringaSectionSecond, 'GetGlobalTagValues did not work correctly');
        System.assertNotEquals(null, stringaSectionSecond, 'GetGlobalTagValues did not work correctly');

		String stringaUsername = script.getGlobalTagValues(new List<String>{'test0','username'}, null);
        System.assertEquals(UserInfo.getName(), stringaUsername, 'GetGlobalTagValues did not work correctly');
        System.assertNotEquals(null, stringaUsername, 'GetGlobalTagValues did not work correctly');

        String stringaMancante = script.getGlobalTagValues(new List<String>{'test0','banana'}, null);
        System.assertEquals('*valore mancante*', stringaMancante, 'GetGlobalTagValues did not work correctly');
        System.assertNotEquals(null, stringaMancante, 'GetGlobalTagValues did not work correctly');
        
        String stringaToday = script.getGlobalTagValues(new List<String>{'test0','today'}, null);
        System.assertEquals(Date.Today().format(), stringaToday, 'GetGlobalTagValues did not work correctly');
        System.assertNotEquals(null, stringaToday, 'GetGlobalTagValues did not work correctly');
        
        String stringaPrivacy = script.getGlobalTagValues(new List<String>{'test0','modificaprivacy'}, null);
        System.assertEquals('*Costante modificaprivacy non trovata*', stringaPrivacy, 'GetGlobalTagValues did not work correctly');
        System.assertNotEquals(null, stringaPrivacy, 'GetGlobalTagValues did not work correctly');
        
        String stringaVara = script.getGlobalTagValues(new List<String>{'test0','varanagcliente'}, null);
        System.assertEquals('*Costante varanagcliente non trovata*', stringaVara, 'GetGlobalTagValues did not work correctly');
        System.assertNotEquals(null, stringaVara, 'GetGlobalTagValues did not work correctly');
    }
    
    @isTest static void overwriteValue(){
        HDT_UTL_FormatTextScript script = new HDT_UTL_FormatTextScript();
        List<HDT_CallScriptValue__mdt> metas = new List<HDT_CallScriptValue__mdt>();
        HDT_CallScriptValue__mdt meta = new HDT_CallScriptValue__mdt(ValueToOverride__c = 'ciao');
        metas.add(meta);
        script.overrideMap = new Map<String,List<HDT_CallScriptValue__mdt>>();
        script.overrideMap.put('key1-key2',metas);
        String result = script.overwriteValue('test', 'key1', 'key2');
        
        System.assertEquals('test', result, 'overwriteValue did not work correctly');
        System.assertNotEquals(null, result, 'overwriteValue did not work correctly');
    }
    
}