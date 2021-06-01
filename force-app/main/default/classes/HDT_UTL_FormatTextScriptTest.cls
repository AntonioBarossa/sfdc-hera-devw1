@isTest 
public class HDT_UTL_FormatTextScriptTest {


    @isTest public static void testScriptWithDataBinding(){
        ConfigurazioneScript__c config = new ConfigurazioneScript__c(Name='my Script');
        insert config;
        ConfigurazioneScript__c configChild = new ConfigurazioneScript__c(Name='my ChildScript', ParentSection__c=config.id);
        insert configChild;
        HDT_UTL_FormatTextScript.HDT_WRP_FlowInput inp = new HDT_UTL_FormatTextScript.HDT_WRP_FlowInput();
        inp.textScript='<<{ name }>> <<{ParentSection__r.Name}>>';
        inp.recordId=configChild.id;
        string formattedText =HDT_UTL_FormatTextScript.formatText(new List<HDT_UTL_FormatTextScript.HDT_WRP_FlowInput>{inp})[0];
        system.debug(formattedText);
        system.debug(configChild.name+' '+config.Name);
        system.assertEquals(formattedText,configChild.name+' '+config.Name);
		inp.textScript='<<{ LastModifiedDate }>> <<{ StartRecording__c }>>';
        formattedText =HDT_UTL_FormatTextScript.formatText(new List<HDT_UTL_FormatTextScript.HDT_WRP_FlowInput>{inp})[0];        
    	system.assertEquals((DateTime.now().format('dd.MM.yyyy')+' '+configChild.StartRecording__c).replaceAll('\\p{C}', '?'), formattedText.replaceAll('\\p{C}', '?'));
        inp.textScript='<<{owner.Name}>>';
        formattedText =HDT_UTL_FormatTextScript.formatText(new List<HDT_UTL_FormatTextScript.HDT_WRP_FlowInput>{inp})[0];        
        system.assertEquals(formattedText,'*valore mancante*');
    }

    @isTest public static void testScriptWithoutDataBinding(){
        ConfigurazioneScript__c config = new ConfigurazioneScript__c(Name='my Script');
        insert config;
        ConfigurazioneScript__c configChild = new ConfigurazioneScript__c(Name='my ChildScript', ParentSection__c=config.id);
        insert configChild;
        HDT_UTL_FormatTextScript.HDT_WRP_FlowInput inp = new HDT_UTL_FormatTextScript.HDT_WRP_FlowInput();
        inp.recordId=configChild.id;
        inp.textScript='test';
        String formattedText =HDT_UTL_FormatTextScript.formatText(new List<HDT_UTL_FormatTextScript.HDT_WRP_FlowInput>{inp})[0];
        system.assertEquals(formattedText, 'test');
    }

    @isTest public static void testScriptExceptionHandler(){
        ConfigurazioneScript__c config = new ConfigurazioneScript__c(Name='my Script');
        insert config;
        ConfigurazioneScript__c configChild = new ConfigurazioneScript__c(Name='my ChildScript');
        insert configChild;
        HDT_UTL_FormatTextScript.HDT_WRP_FlowInput inp = new HDT_UTL_FormatTextScript.HDT_WRP_FlowInput();
        inp.recordId=configChild.id;
        try{
            inp.textScript='<<{ test }>>';
        	String formattedText =HDT_UTL_FormatTextScript.formatText(new List<HDT_UTL_FormatTextScript.HDT_WRP_FlowInput>{inp})[0];
        }catch(Exception e){
            system.debug(e.getTypeName());
        }
    }

    
}