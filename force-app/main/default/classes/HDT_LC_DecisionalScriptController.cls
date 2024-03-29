/**
 * @description       : Controller for decisional scripts
 * @author            : gabriele.rota@webresults.it
 * @group             : WR
 * @last modified on  : 2021-10-05
 * @last modified by  : gabriele.rota@webresults.it
**/
public with sharing class HDT_LC_DecisionalScriptController extends HDT_LC_HdtScriptManagementModal {
    
    /**
    * @description Get a single page of the given decisional script
    * @author gabriele.rota@webresults.it | 2021-10-05 
    * @param processName 
    * @param recordId 
    * @param pageIndex 
    * @return HDT_UTL_ScriptWrappers.HDT_WRP_ScriptOutput
    **/
    @AuraEnabled
    public static HDT_UTL_ScriptWrappers.HDT_WRP_ScriptOutput getScriptPage(String processName, String recordId, Integer pageIndex){
        HDT_LC_DecisionalScriptController scriptFormatter = new HDT_LC_DecisionalScriptController();
        return scriptFormatter.getScriptTextPage(processName, recordId, pageIndex);
    }

    /**
    * @description Load single page of the given decisional script
    * @author gabriele.rota@webresults.it | 2021-10-05 
    * @param processName 
    * @param recordId 
    * @param pageIndex 
    * @return HDT_UTL_ScriptWrappers.HDT_WRP_ScriptOutput
    **/
    private HDT_UTL_ScriptWrappers.HDT_WRP_ScriptOutput getScriptTextPage(String processName, String recordId, Integer pageIndex){
        List<ScriptConfig__c> processList = [SELECT Name, contextObject__c, ChildRelationName__c,
            (SELECT textScript__c, SectionLabel__c, checkVisibility__c, isChildLoopEvaluated__C,
                ScriptType__c, LabelOption1__c, LabelOption2__c, LabelOption3__c, NextSection__c
                FROM ChildSections__r WHERE SectionOrder__c=:pageIndex)
            FROM ScriptConfig__c WHERE Name=:processName AND ScriptType__c='Processo' WITH SECURITY_ENFORCED];
        if(!processList.isEmpty()){
            List<HDT_UTL_ScriptWrappers.HDT_WRP_ScriptOutput> scriptPages= getScriptPagesFromScript(processList[0], recordId, true);
            if(!scriptPages.isEmpty()){
                return scriptPages[0];
            }
        }
        return null;
    }
}