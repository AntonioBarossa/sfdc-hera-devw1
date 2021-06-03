public without sharing class  HDT_LC_HdtScriptManagementModal {
    

    public static String getScriptText(String processName, String recordId){
        ScriptConfig__c process= [select Name, (Select textScript__c, SectionLabel__c from ChildSections__r order by SectionOrder__c asc) from ScriptConfig__c where Name=:processName AND RecordType.DeveloperName='HDT_RT_Processo' LIMIT 1];
        String textToFormat='';
        system.debug(process.ChildSections__r.size());
        for(ScriptConfig__c section : process.ChildSections__r){
            String sectionLabel = '<<{ globalTag.section__d.'+section.SectionLabel__c.replace(' ', '_')+ ' }>>';
            textToFormat +=sectionLabel+section.textScript__c;
        }
        HDT_UTL_FormatTextScript.HDT_WRP_FlowInput input = new  HDT_UTL_FormatTextScript.HDT_WRP_FlowInput(textToFormat, recordId);
        String formattedtext = HDT_UTL_FormatTextScript.formatText(
                                    new List<HDT_UTL_FormatTextScript.HDT_WRP_FlowInput>{input})[0];
        return  formattedtext;   
    }
}
