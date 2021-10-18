/**
 * @description       : Controller for decisional scripts
 * @author            : gabriele.rota@webresults.it
 * @group             : WR
 * @last modified on  : 2021-10-05
 * @last modified by  : gabriele.rota@webresults.it
**/
public with sharing class HDT_LC_DecisionalScriptController extends HDT_LC_HdtScriptManagementModal {

    private static final String DECISIONAL_TYPE = 'Decisionale';

    /**
    * @description Check if the given script is decisional
    * @author gabriele.rota@webresults.it | 2021-10-05 
    * @param processName  
    * @return Boolean
    **/
    @AuraEnabled
    public static Boolean isDecisionalScript(String processName){
        if(processName!=null && String.isNotBlank(processName)){
            List<ScriptConfig__c> decisionalPages = [SELECT Id FROM ScriptConfig__c
            WHERE ParentSection__r.Name=:processName AND ScriptType__c=:DECISIONAL_TYPE WITH SECURITY_ENFORCED LIMIT 1];
            return (!decisionalPages.isEmpty());
        }else{
            return false;
        }       
    }
    
    /**
    * @description Get a single page of the given decisional script
    * @author gabriele.rota@webresults.it | 2021-10-05 
    * @param processName 
    * @param recordId 
    * @param pageIndex 
    * @return HDT_WRP_ScriptOutput
    **/
    @AuraEnabled
    public static HDT_WRP_ScriptOutput getScriptPage(String processName, String recordId, Integer pageIndex){
        HDT_LC_DecisionalScriptController scriptFormatter = new HDT_LC_DecisionalScriptController();
        return scriptFormatter.getScriptTextPage(processName, recordId, pageIndex);
    }

    /**
    * @description Load single page of the given decisional script
    * @author gabriele.rota@webresults.it | 2021-10-05 
    * @param processName 
    * @param recordId 
    * @param pageIndex 
    * @return HDT_WRP_ScriptOutput
    **/
    private HDT_WRP_ScriptOutput getScriptTextPage(String processName, String recordId, Integer pageIndex){
        List<ScriptConfig__c> processList = [SELECT Name, contextObject__c, ChildRelationName__c,
            (SELECT textScript__c, SectionLabel__c, checkVisibility__c, isChildLoopEvaluated__C,
                ScriptType__c, LabelOption1__c, LabelOption2__c, LabelOption3__c, NextSection__c
                FROM ChildSections__r WHERE SectionOrder__c=:pageIndex)
            FROM ScriptConfig__c WHERE Name=:processName AND ScriptType__c='Processo' WITH SECURITY_ENFORCED];
            if(!processList.isEmpty()){
                List<HDT_WRP_ScriptOutput> scriptPages= getScriptPagesFromScript(processList[0], recordId);
                if(!scriptPages.isEmpty()){
                    return scriptPages[0];
                }
            }
        return null;
    }
}
