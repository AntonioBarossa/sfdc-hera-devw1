public with sharing class HDT_LC_DecisionalScriptController extends HDT_LC_HdtScriptManagementModal {

    private static final String DECISIONAL_TYPE = 'Decisionale';

    @AuraEnabled
    public static Boolean isDecisionalScript(String processName){
        List<ScriptConfig__c> decisionalPages = [SELECT Id FROM ScriptConfig__c
            WHERE ParentSection__r.Name=:processName AND ScriptType__c=:DECISIONAL_TYPE WITH SECURITY_ENFORCED LIMIT 1];
        return (!decisionalPages.isEmpty());
    }
    
    @AuraEnabled
    public static HDT_WRP_ScriptOutput getScriptPage(String processName, String recordId, Integer pageIndex){
        HDT_LC_DecisionalScriptController scriptFormatter = new HDT_LC_DecisionalScriptController();
        return scriptFormatter.getScriptTextPage(processName, recordId, pageIndex);
    }

    private HDT_WRP_ScriptOutput getScriptTextPage(String processName, String recordId, Integer pageIndex){
        ScriptConfig__c process = [SELECT Name, contextObject__c, ChildRelationName__c,
            (SELECT textScript__c, SectionLabel__c, checkVisibility__c, isChildLoopEvaluated__C,
                ScriptType__c, LabelOption1__c, LabelOption2__c, LabelOption3__c, NextSection__c
                FROM ChildSections__r WHERE SectionOrder__c=:pageIndex)
            FROM ScriptConfig__c WHERE Name=:processName AND ScriptType__c='Processo' WITH SECURITY_ENFORCED LIMIT 1 ];
        return getScriptPagesFromScript(process, recordId)[0];
    }
}
