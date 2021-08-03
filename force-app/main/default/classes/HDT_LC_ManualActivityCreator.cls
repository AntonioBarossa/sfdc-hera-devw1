public with sharing class HDT_LC_ManualActivityCreator {
    
    @AuraEnabled
    public static void createActivity(String type){
        HDT_UTL_Scarti.getTemplatesMapByName(new Set<String>{'manualiTemplateName'});
        
    }
}
