@isTest public class HDT_LC_HdtScriptManagementModalTest {

    @TestSetup static void makeData(){
        //Id processTypeId = ((SObject)Type.forName('Schema','ScriptConfig__c').newInstance()).getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_RT_Processo').getRecordTypeId();
        ScriptConfig__c process = new ScriptConfig__c(Name='my Script', ScriptType__c='Processo', contextObject__c='Script');
        insert process;
        List<ScriptConfig__c> sections = new List<ScriptConfig__c>();

        //start creating single section
        if(true){
            ScriptConfig__c section= new ScriptConfig__c(ParentSection__c=process.Id);

            section.Name ='sec';
            section.SectionOrder__c=1;
            section.isChildLoopEvaluated__c=false;
            section.checkVisibility__c='';
            section.TextScript__c='Testo';
            sections.add(section);
        }
        // end section

        //start creating single section
        if(true){
            ScriptConfig__c section= new ScriptConfig__c(ParentSection__c=process.Id);

            section.Name ='sec2';
            section.SectionOrder__c=2;
            section.isChildLoopEvaluated__c=false;
            section.checkVisibility__c='ParentSection__c==null AND Name!=null';
            section.TextScript__c='Testo';
            sections.add(section);
        }
        // end section

        //start creating single section
        if(true){
            ScriptConfig__c section= new ScriptConfig__c(ParentSection__c=process.Id);

            section.Name ='sec3';
            section.SectionOrder__c=3;
            section.isChildLoopEvaluated__c=true;
            section.checkVisibility__c='ParentSection__r.ParentSection__c==null AND name!=null AND TextScript__c!=null AND SectionOrder__c!=2';
            section.TextScript__c='';
            sections.add(section);
        }
        // end section
        insert sections;

        
    }
    @isTest public static void testScriptPagesWithoutChildIdentifier(){
        ScriptConfig__c process = [select Name from ScriptConfig__c where ScriptType__c='Processo'];
        HDT_LC_HdtScriptManagementModal.getScriptSections(process.name, process.id, '');
        List<HDT_UTL_ScriptWrappers.HDT_WRP_ScriptOutput>
            output=HDT_LC_HdtScriptManagementModal.getScriptSections(process.name, process.id, 'name');
        system.assertEquals(3, output.size(), 'childs objects were not filtered as expected');
    } 
    
    
}